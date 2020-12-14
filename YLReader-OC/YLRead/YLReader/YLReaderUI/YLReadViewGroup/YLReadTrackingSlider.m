//
//  YLReadTrackingSlider.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/10.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadTrackingSlider.h"

@protocol YLReadValuePopUpViewDelegate <NSObject>
- (CGFloat)currentValueOffset; //expects value in the range 0.0 - 1.0
- (void)colorDidUpdate:(UIColor *)opaqueColor;
@end

@interface YLReadValuePopUpView : UIView

@property (weak, nonatomic) id <YLReadValuePopUpViewDelegate> delegate;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat arrowLength;
@property (nonatomic) CGFloat widthPaddingFactor;
@property (nonatomic) CGFloat heightPaddingFactor;

- (UIColor *)color;
- (void)setColor:(UIColor *)color;
- (UIColor *)opaqueColor;

- (void)setTextColor:(UIColor *)textColor;
- (void)setFont:(UIFont *)font;
- (void)setText:(NSString *)text;

- (void)setAnimatedColors:(NSArray *)animatedColors withKeyTimes:(NSArray *)keyTimes;

- (void)setAnimationOffset:(CGFloat)animOffset returnColor:(void (^)(UIColor *opaqueReturnColor))block;

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset text:(NSString *)text;

- (void)animateBlock:(void (^)(CFTimeInterval duration))block;

- (CGSize)popUpSizeForString:(NSString *)string;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())block;

@end

@implementation CALayer (ASAnimationAdditions)

- (void)animateKey:(NSString *)animationName fromValue:(id)fromValue toValue:(id)toValue
         customize:(void (^)(CABasicAnimation *animation))block
{
    [self setValue:toValue forKey:animationName];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:animationName];
    anim.fromValue = fromValue ?: [self.presentationLayer valueForKey:animationName];
    anim.toValue = toValue;
    if (block) block(anim);
    [self addAnimation:anim forKey:animationName];
}
@end

NSString *const SliderFillColorAnim = @"fillColor";

@interface YLReadValuePopUpView ()
<CAAnimationDelegate>
@end


@implementation YLReadValuePopUpView
{
    BOOL _shouldAnimate;
    CFTimeInterval _animDuration;
    
    NSMutableAttributedString *_attributedString;
    CAShapeLayer *_pathLayer;
    
    CATextLayer *_textLayer;
    CGFloat _arrowCenterOffset;
    
    // never actually visible, its purpose is to interpolate color values for the popUpView color animation
    // using shape layer because it has a 'fillColor' property which is consistent with _backgroundLayer
    CAShapeLayer *_colorAnimLayer;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

// if ivar _shouldAnimate) is YES then return an animation
// otherwise return NSNull (no animation)
- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
    if (_shouldAnimate) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
        anim.beginTime = CACurrentMediaTime();
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.fromValue = [layer.presentationLayer valueForKey:key];
        anim.duration = _animDuration;
        return anim;
    } else return (id <CAAction>)[NSNull null];
}

#pragma mark - public

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldAnimate = NO;
        self.layer.anchorPoint = CGPointMake(0.5, 1);
        
        self.userInteractionEnabled = NO;
        _pathLayer = (CAShapeLayer *)self.layer; // ivar can now be accessed without casting to CAShapeLayer every time
        
        _cornerRadius = 4.0;
        _arrowLength = 13.0;
        _widthPaddingFactor = 1.15;
        _heightPaddingFactor = 1.1;
        
        _textLayer = [CATextLayer layer];
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.anchorPoint = CGPointMake(0, 0);
        _textLayer.contentsScale = [UIScreen mainScreen].scale;
        _textLayer.actions = @{@"contents" : [NSNull null]};
        
        _colorAnimLayer = [CAShapeLayer layer];
        
        [self.layer addSublayer:_colorAnimLayer];
        [self.layer addSublayer:_textLayer];
        
        _attributedString = [[NSMutableAttributedString alloc] initWithString:@" " attributes:nil];
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)radius
{
    if (_cornerRadius == radius) return;
    _cornerRadius = radius;
    _pathLayer.path = [self pathForRect:self.bounds withArrowOffset:_arrowCenterOffset].CGPath;
}

- (UIColor *)color
{
    return [UIColor colorWithCGColor:[_pathLayer.presentationLayer fillColor]];
}

- (void)setColor:(UIColor *)color
{
    _pathLayer.fillColor = color.CGColor;
    [_colorAnimLayer removeAnimationForKey:SliderFillColorAnim]; // single color, no animation required
}

- (UIColor *)opaqueColor
{
    return opaqueUIColorFromCGColor([_colorAnimLayer.presentationLayer fillColor] ?: _pathLayer.fillColor);
}

- (void)setTextColor:(UIColor *)color
{
    _textLayer.foregroundColor = color.CGColor;
}

- (void)setFont:(UIFont *)font
{
    [_attributedString addAttribute:NSFontAttributeName
                              value:font
                              range:NSMakeRange(0, [_attributedString length])];
    
    _textLayer.font = (__bridge CFTypeRef)(font.fontName);
    _textLayer.fontSize = font.pointSize;
}

- (void)setText:(NSString *)string
{
    [[_attributedString mutableString] setString:string];
    _textLayer.string = string;
}

// set up an animation, but prevent it from running automatically
// the animation progress will be adjusted manually
- (void)setAnimatedColors:(NSArray *)animatedColors withKeyTimes:(NSArray *)keyTimes
{
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *col in animatedColors) {
        [cgColors addObject:(id)col.CGColor];
    }
    
    CAKeyframeAnimation *colorAnim = [CAKeyframeAnimation animationWithKeyPath:SliderFillColorAnim];
    colorAnim.keyTimes = keyTimes;
    colorAnim.values = cgColors;
    colorAnim.fillMode = kCAFillModeBoth;
    colorAnim.duration = 1.0;
    colorAnim.delegate = self;
    
    // As the interpolated color values from the presentationLayer are needed immediately
    // the animation must be allowed to start to initialize _colorAnimLayer's presentationLayer
    // hence the speed is set to min value - then set to zero in 'animationDidStart:' delegate method
    _colorAnimLayer.speed = FLT_MIN;
    _colorAnimLayer.timeOffset = 0.0;
    
    [_colorAnimLayer addAnimation:colorAnim forKey:SliderFillColorAnim];
}

- (void)setAnimationOffset:(CGFloat)animOffset returnColor:(void (^)(UIColor *opaqueReturnColor))block
{
    if ([_colorAnimLayer animationForKey:SliderFillColorAnim]) {
        _colorAnimLayer.timeOffset = animOffset;
        _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
        block([self opaqueColor]);
    }
}

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset text:(NSString *)text
{
    // only redraw path if either the arrowOffset or popUpView size has changed
    if (arrowOffset != _arrowCenterOffset || !CGSizeEqualToSize(frame.size, self.frame.size)) {
        _pathLayer.path = [self pathForRect:frame withArrowOffset:arrowOffset].CGPath;
    }
    _arrowCenterOffset = arrowOffset;
    
    CGFloat anchorX = 0.5+(arrowOffset/CGRectGetWidth(frame));
    self.layer.anchorPoint = CGPointMake(anchorX, 1);
    self.layer.position = CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame)*anchorX, 0);
    self.layer.bounds = (CGRect){CGPointZero, frame.size};
    
    [self setText:text];
}

// _shouldAnimate = YES; causes 'actionForLayer:' to return an animation for layer property changes
// call the supplied block, then set _shouldAnimate back to NO
- (void)animateBlock:(void (^)(CFTimeInterval duration))block
{
    _shouldAnimate = YES;
    _animDuration = 0.5;
    
    CAAnimation *anim = [self.layer animationForKey:@"position"];
    if ((anim)) { // if previous animation hasn't finished reduce the time of new animation
        CFTimeInterval elapsedTime = MIN(CACurrentMediaTime() - anim.beginTime, anim.duration);
        _animDuration = _animDuration * elapsedTime / anim.duration;
    }
    
    block(_animDuration);
    _shouldAnimate = NO;
}

- (CGSize)popUpSizeForString:(NSString *)string
{
    [[_attributedString mutableString] setString:string];
    CGFloat w, h;
    w = ceilf([_attributedString size].width * _widthPaddingFactor);
    h = ceilf(([_attributedString size].height * _heightPaddingFactor) + _arrowLength);
    return CGSizeMake(w, h);
}

- (void)showAnimated:(BOOL)animated
{
    if (!animated) {
        self.layer.opacity = 1.0;
        return;
    }
    
    [CATransaction begin]; {
        // start the transform animation from scale 0.5, or its current value if it's already running
        NSValue *fromValue = [self.layer animationForKey:@"transform"] ? [self.layer.presentationLayer valueForKey:@"transform"] : [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)];
        
        [self.layer animateKey:@"transform" fromValue:fromValue toValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]
                     customize:^(CABasicAnimation *animation) {
                         animation.duration = 0.4;
                         animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :2.5 :0.35 :0.5];
         }];
        
        [self.layer animateKey:@"opacity" fromValue:nil toValue:@1.0 customize:^(CABasicAnimation *animation) {
            animation.duration = 0.1;
        }];
    } [CATransaction commit];
}

- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())block
{
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            block();
            self.layer.transform = CATransform3DIdentity;
        }];
        if (animated) {
            [self.layer animateKey:@"transform" fromValue:nil
                           toValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)]
                         customize:^(CABasicAnimation *animation) {
                             animation.duration = 0.55;
                             animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1 :-2 :0.3 :3];
                         }];
            
            [self.layer animateKey:@"opacity" fromValue:nil toValue:@0.0 customize:^(CABasicAnimation *animation) {
                animation.duration = 0.75;
            }];
        } else { // not animated - just set opacity to 0.0
            self.layer.opacity = 0.0;
        }
    } [CATransaction commit];
}

#pragma mark - CAAnimation delegate

// set the speed to zero to freeze the animation and set the offset to the correct value
// the animation can now be updated manually by explicity setting its 'timeOffset'
- (void)animationDidStart:(CAAnimation *)animation
{
    _colorAnimLayer.speed = 0.0;
    _colorAnimLayer.timeOffset = [self.delegate currentValueOffset];
    
    _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
    [self.delegate colorDidUpdate:[self opaqueColor]];
}

#pragma mark - private

- (UIBezierPath *)pathForRect:(CGRect)rect withArrowOffset:(CGFloat)arrowOffset;
{
    if (CGRectEqualToRect(rect, CGRectZero)) return nil;
    
    rect = (CGRect){CGPointZero, rect.size}; // ensure origin is CGPointZero
    
    // Create rounded rect
    CGRect roundedRect = rect;
    roundedRect.size.height -= _arrowLength;
    UIBezierPath *popUpPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:_cornerRadius];
    
    // Create arrow path
    CGFloat maxX = CGRectGetMaxX(roundedRect); // prevent arrow from extending beyond this point
    CGFloat arrowTipX = CGRectGetMidX(rect) + arrowOffset;
    CGPoint tip = CGPointMake(arrowTipX, CGRectGetMaxY(rect));
    
    CGFloat arrowLength = CGRectGetHeight(roundedRect)/2.0;
    CGFloat x = arrowLength * tan(45.0 * M_PI/180); // x = half the length of the base of the arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:tip];
    [arrowPath addLineToPoint:CGPointMake(MAX(arrowTipX - x, 0), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath addLineToPoint:CGPointMake(MIN(arrowTipX + x, maxX), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath closePath];
    
    [popUpPath appendPath:arrowPath];
    
    return popUpPath;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textHeight = [_attributedString size].height;
    CGRect textRect = CGRectMake(self.bounds.origin.x,
                                 (self.bounds.size.height-_arrowLength-textHeight)/2,
                                 self.bounds.size.width, textHeight);
    _textLayer.frame = CGRectIntegral(textRect);
}

static UIColor* opaqueUIColorFromCGColor(CGColorRef col)
{
    if (col == NULL) return nil;
    
    const CGFloat *components = CGColorGetComponents(col);
    UIColor *color;
    if (CGColorGetNumberOfComponents(col) == 2) {
        color = [UIColor colorWithWhite:components[0] alpha:1.0];
    } else {
        color = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0];
    }
    return color;
}

@end











@interface YLReadTrackingSlider()
<YLReadValuePopUpViewDelegate>
@property (strong, nonatomic) YLReadValuePopUpView *popUpView;
@property (nonatomic) BOOL popUpViewAlwaysOn; // default is NO
@end

@implementation YLReadTrackingSlider
{
    NSNumberFormatter *_numberFormatter;
    UIColor *_popUpViewColor;
    NSArray *_keyTimes;
    CGFloat _valueRange;
}

#pragma mark - initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - public

- (void)setAutoAdjustTrackColor:(BOOL)autoAdjust
{
    if (_autoAdjustTrackColor == autoAdjust) return;
    
    _autoAdjustTrackColor = autoAdjust;
    
    // setMinimumTrackTintColor has been overridden to also set autoAdjustTrackColor to NO
    // therefore super's implementation must be called to set minimumTrackTintColor
    if (autoAdjust == NO) {
        super.minimumTrackTintColor = nil; // sets track to default blue color
    } else {
        super.minimumTrackTintColor = [self.popUpView opaqueColor];
    }
}

- (void)setTextColor:(UIColor *)color
{
    _textColor = color;
    [self.popUpView setTextColor:color];
}

- (void)setFont:(UIFont *)font
{
    NSAssert(font, @"font can not be nil, it must be a valid UIFont");
    _font = font;
    [self.popUpView setFont:font];
}

// return the currently displayed color if possible, otherwise return _popUpViewColor
// if animated colors are set, the color will change each time the slider value changes
- (UIColor *)popUpViewColor
{
    return self.popUpView.color ?: _popUpViewColor;
}

- (void)setPopUpViewColor:(UIColor *)color
{
    _popUpViewColor = color;
    _popUpViewAnimatedColors = nil; // animated colors should be discarded
    [self.popUpView setColor:color];

    if (_autoAdjustTrackColor) {
        super.minimumTrackTintColor = [self.popUpView opaqueColor];
    }
}

- (void)setPopUpViewAnimatedColors:(NSArray *)colors{
    [self setPopUpViewAnimatedColors:colors withPositions:nil];
}

// if 2 or more colors are present, set animated colors
// if only 1 color is present then call 'setPopUpViewColor:'
// if arg is nil then restore previous _popUpViewColor
- (void)setPopUpViewAnimatedColors:(NSArray *)colors withPositions:(NSArray *)positions
{
    if (positions) {
        NSAssert([colors count] == [positions count], @"popUpViewAnimatedColors and locations should contain the same number of items");
    }
    
    _popUpViewAnimatedColors = colors;
    _keyTimes = [self keyTimesFromSliderPositions:positions];
    
    if ([colors count] >= 2) {
        [self.popUpView setAnimatedColors:colors withKeyTimes:_keyTimes];
    } else {
        [self setPopUpViewColor:[colors lastObject] ?: _popUpViewColor];
    }
}

- (void)setPopUpViewCornerRadius:(CGFloat)radius
{
    self.popUpView.cornerRadius = radius;
}

- (CGFloat)popUpViewCornerRadius
{
    return self.popUpView.cornerRadius;
}

- (void)setPopUpViewArrowLength:(CGFloat)length
{
    self.popUpView.arrowLength = length;
}

- (CGFloat)popUpViewArrowLength
{
    return self.popUpView.arrowLength;
}

- (void)setPopUpViewWidthPaddingFactor:(CGFloat)factor
{
    self.popUpView.widthPaddingFactor = factor;
}

- (CGFloat)popUpViewWidthPaddingFactor
{
    return self.popUpView.widthPaddingFactor;
}

- (void)setPopUpViewHeightPaddingFactor:(CGFloat)factor
{
    self.popUpView.heightPaddingFactor = factor;
}

- (CGFloat)popUpViewHeightPaddingFactor
{
    return self.popUpView.heightPaddingFactor;
}

// when either the min/max value or number formatter changes, recalculate the popUpView width
- (void)setMaximumValue:(float)maximumValue
{
    [super setMaximumValue:maximumValue];
    _valueRange = self.maximumValue - self.minimumValue;
}

- (void)setMinimumValue:(float)minimumValue
{
    [super setMinimumValue:minimumValue];
    _valueRange = self.maximumValue - self.minimumValue;
}

// set max and min digits to same value to keep string length consistent
- (void)setMaxFractionDigitsDisplayed:(NSUInteger)maxDigits
{
    [_numberFormatter setMaximumFractionDigits:maxDigits];
    [_numberFormatter setMinimumFractionDigits:maxDigits];
}

- (void)setNumberFormatter:(NSNumberFormatter *)numberFormatter
{
    _numberFormatter = [numberFormatter copy];
}

- (NSNumberFormatter *)numberFormatter
{
    return [_numberFormatter copy]; // return a copy to prevent formatter properties changing and causing mayhem
}

- (void)showPopUpViewAnimated:(BOOL)animated
{
    self.popUpViewAlwaysOn = YES;
    [self _showPopUpViewAnimated:animated];
}

- (void)hidePopUpViewAnimated:(BOOL)animated
{
    self.popUpViewAlwaysOn = NO;
    [self _hidePopUpViewAnimated:animated];
}

#pragma mark - ASValuePopUpViewDelegate

- (void)colorDidUpdate:(UIColor *)opaqueColor
{
    super.minimumTrackTintColor = opaqueColor;
}

// returns the current offset of UISlider value in the range 0.0 – 1.0
- (CGFloat)currentValueOffset
{
    return (self.value - self.minimumValue) / _valueRange;
}

#pragma mark - private

- (void)setup
{
    _autoAdjustTrackColor = YES;
    _valueRange = self.maximumValue - self.minimumValue;
    _popUpViewAlwaysOn = NO;

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:2];
    [formatter setMinimumFractionDigits:2];
    _numberFormatter = formatter;

    self.popUpView = [[YLReadValuePopUpView alloc] initWithFrame:CGRectZero];
    self.popUpViewColor = [UIColor colorWithHue:0.6 saturation:0.6 brightness:0.5 alpha:0.8];

    self.popUpView.alpha = 0.0;
    self.popUpView.delegate = self;
    [self addSubview:self.popUpView];

    self.textColor = [UIColor whiteColor];
    self.font = [UIFont boldSystemFontOfSize:22.0f];
}

// ensure animation restarts if app is closed then becomes active again
- (void)didBecomeActiveNotification:(NSNotification *)note
{
    if (self.popUpViewAnimatedColors) {
        [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
    }
}

- (void)updatePopUpView
{
    NSString *valueString; // ask dataSource for string, if nil or blank, get string from _numberFormatter
    CGSize popUpViewSize;
    if ((valueString = [self.dataSource slider:self stringForValue:self.value]) && valueString.length != 0) {
        popUpViewSize = [self.popUpView popUpSizeForString:valueString];
    } else {
        valueString = [_numberFormatter stringFromNumber:@(self.value)];
        popUpViewSize = [self calculatePopUpViewSize];
    }
    
    // calculate the popUpView frame
    CGRect thumbRect = [self thumbRect];
    CGFloat thumbW = thumbRect.size.width;
    CGFloat thumbH = thumbRect.size.height;
    
    CGRect popUpRect = CGRectInset(thumbRect, (thumbW - popUpViewSize.width)/2, (thumbH - popUpViewSize.height)/2);
    popUpRect.origin.y = thumbRect.origin.y - popUpViewSize.height;
    
    // determine if popUpRect extends beyond the frame of the progress view
    // if so adjust frame and set the center offset of the PopUpView's arrow
    CGFloat minOffsetX = CGRectGetMinX(popUpRect);
    CGFloat maxOffsetX = CGRectGetMaxX(popUpRect) - CGRectGetWidth(self.bounds);
    
    CGFloat offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0);
    popUpRect.origin.x -= offset;
    
    [self.popUpView setFrame:popUpRect arrowOffset:offset text:valueString];
}

- (CGSize)calculatePopUpViewSize
{
    // negative values need more width than positive values
    CGSize minValSize = [self.popUpView popUpSizeForString:[_numberFormatter stringFromNumber:@(self.minimumValue)]];
    CGSize maxValSize = [self.popUpView popUpSizeForString:[_numberFormatter stringFromNumber:@(self.maximumValue)]];

    return (minValSize.width >= maxValSize.width) ? minValSize : maxValSize;
}

// takes an array of NSNumbers in the range self.minimumValue - self.maximumValue
// returns an array of NSNumbers in the range 0.0 - 1.0
- (NSArray *)keyTimesFromSliderPositions:(NSArray *)positions
{
    if (!positions) return nil;
    
    NSMutableArray *keyTimes = [NSMutableArray array];
    for (NSNumber *num in [positions sortedArrayUsingSelector:@selector(compare:)]) {
        [keyTimes addObject:@((num.floatValue - self.minimumValue) / _valueRange)];
    }
    return keyTimes;
}

- (CGRect)thumbRect
{
    return [self thumbRectForBounds:self.bounds
                          trackRect:[self trackRectForBounds:self.bounds]
                              value:self.value];
}

- (void)_showPopUpViewAnimated:(BOOL)animated
{
    if (self.delegate) [self.delegate sliderWillDisplayPopUpView:self];
    [self.popUpView showAnimated:animated];
}

- (void)_hidePopUpViewAnimated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(sliderWillHidePopUpView:)]) {
        [self.delegate sliderWillHidePopUpView:self];
    }
    [self.popUpView hideAnimated:animated completionBlock:^{
        if ([self.delegate respondsToSelector:@selector(sliderDidHidePopUpView:)]) {
            [self.delegate sliderDidHidePopUpView:self];
        }
    }];
}

#pragma mark - subclassed

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self updatePopUpView];
}

- (void)didMoveToWindow
{
    if (!self.window) { // removed from window - cancel notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else { // added to window - register notifications
        
        if (self.popUpViewAnimatedColors) { // restart color animation if needed
            [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
}

- (void)setValue:(float)value
{
    [super setValue:value];
    [self.popUpView setAnimationOffset:[self currentValueOffset] returnColor:^(UIColor *opaqueReturnColor) {
        super.minimumTrackTintColor = opaqueReturnColor;
    }];
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    if (animated) {
        [self.popUpView animateBlock:^(CFTimeInterval duration) {
            [UIView animateWithDuration:duration animations:^{
                [super setValue:value animated:animated];
                [self.popUpView setAnimationOffset:[self currentValueOffset] returnColor:^(UIColor *opaqueReturnColor) {
                    super.minimumTrackTintColor = opaqueReturnColor;
                }];
                [self layoutIfNeeded];
            }];
        }];
    } else {
        [super setValue:value animated:animated];
    }
}

- (void)setMinimumTrackTintColor:(UIColor *)color
{
    self.autoAdjustTrackColor = NO; // if a custom value is set then prevent auto coloring
    [super setMinimumTrackTintColor:color];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
    if (begin && !self.popUpViewAlwaysOn) [self _showPopUpViewAnimated:YES];
    return begin;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL continueTrack = [super continueTrackingWithTouch:touch withEvent:event];
    if (continueTrack) {
        [self.popUpView setAnimationOffset:[self currentValueOffset] returnColor:^(UIColor *opaqueReturnColor) {
            super.minimumTrackTintColor = opaqueReturnColor;
        }];
    }
    return continueTrack;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
    if (self.popUpViewAlwaysOn == NO) [self _hidePopUpViewAnimated:YES];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.popUpViewAlwaysOn == NO) [self _hidePopUpViewAnimated:YES];
}

@end
