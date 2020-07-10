//
//  YLReadView.h
//  FM
//
//  Created by 苏沫离 on 2020/6/30.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLCoreText.h"
#import "YLReadPageModel.h"

NS_ASSUME_NONNULL_BEGIN

@class YLReadPageModel;
@interface YLReadView : UIView

/// 当前页模型(使用contentSize绘制)

@property (nonatomic ,strong) YLReadPageModel *pageModel;

/// 当前页内容(使用固定范围绘制)
@property (nonatomic ,strong) NSAttributedString *content;

@property (nonatomic ,assign) CTFrameRef frameRef;

@end

NS_ASSUME_NONNULL_END
