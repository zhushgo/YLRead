//
//  YLReadViewScrollController.h
//  YLRead
//
//  Created by 苏沫离 on 2017/6/24.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 翻页控制器 (滚动)
@class YLReadController,YLReadChapterModel;
@interface YLReadViewScrollController : UIViewController

/// 当前主控制器
@property (nonatomic ,weak) YLReadController *vc;

/// 刷新阅读进度显示
- (void)reloadProgress;

/// 获取章节内容模型
- (YLReadChapterModel *)getChapterModelWithChapterID:(NSInteger)chapterID;

/// 预加载上一个章节
- (void)preloadingPrevious:(YLReadChapterModel *)chapterModel;
/// 预加载下一个章节
- (void)preloadingNext:(YLReadChapterModel *)chapterModel;
/// 更新阅读记录(滚动模式) isRollingUp:是否为往上滚动
- (void)updateReadRecord:(BOOL)isRollingUp;

@end

NS_ASSUME_NONNULL_END
