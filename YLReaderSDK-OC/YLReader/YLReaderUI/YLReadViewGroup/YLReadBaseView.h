//
//  YLReadBaseView.h
//  YLRead
//
//  Created by 苏沫离 on 2017/6/28.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YLReadMenu;
@interface YLReadBaseView : UIView

/// 菜单对象
@property (nonatomic ,strong) YLReadMenu *readMenu;

- (instancetype)initWithReadMenu:(YLReadMenu *)readMenu;

@end

NS_ASSUME_NONNULL_END
