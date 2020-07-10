//
//  YLReadCatalogView.h
//  FM
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@class YLReadCatalogView,YLReadChapterListModel,YLReadModel;
@protocol YLReadCatalogViewDelegate <NSObject>

/// 点击章节
- (void)catalogViewClickChapter:(YLReadCatalogView *)catalogView chapterListModel:(YLReadChapterListModel *)chapterListModel;

@end

/// 目录
@interface YLReadCatalogView : UIView

@property (nonatomic ,weak) id <YLReadCatalogViewDelegate> delegate;

/// 数据源
@property (nonatomic ,strong) YLReadModel *readModel;

@property (nonatomic ,strong) UITableView *tableView;


/// 滚动到阅读记录
- (void)scrollRecord;

@end

NS_ASSUME_NONNULL_END
