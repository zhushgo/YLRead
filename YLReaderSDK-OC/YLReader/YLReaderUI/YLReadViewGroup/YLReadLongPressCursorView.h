//
//  YLReadLongPressCursorView.h
//  YLRead
//
//  Created by 苏沫离 on 2017/5/9.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLReadLongPressCursorView : UIView
/// 光标圆圈显示位置: true -> 圆圈在上面 , false -> 圆圈在下面
@property (nonatomic ,assign) BOOL isTorB;

 /// 光标颜色
@property (nonatomic ,strong) UIColor *color;
@end

NS_ASSUME_NONNULL_END
