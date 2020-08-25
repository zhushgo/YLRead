//
//  YLReadCatalogView.m
//  YLRead
//
//  Created by 苏沫离 on 2020/6/24.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#import "YLReadCatalogView.h"
#import "YLReadModel.h"
#import "YLReadRecordModel.h"
#import "YLReadChapterModel.h"
#import "YLReadChapterListModel.h"
#import "YLReadUserDefaults.h"
#import "YLReadConfigure.h"

#define CellIdentifer @"YLReadCatalogCell"


@interface YLReadCatalogCell : UITableViewCell
@property (nonatomic ,strong) UILabel *chapterName;
@property (nonatomic ,strong) UIView *spaceLine;
@end

@implementation YLReadCatalogCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        
        [self.contentView addSubview:self.chapterName];
        [self.contentView addSubview:self.spaceLine];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    self.chapterName.frame = CGRectMake(15, 0, width - 15 * 2.0, height);
    self.spaceLine.frame = CGRectMake( 15, height - 0.5, width - 15 * 2.0, 0.5);
}

#pragma mark - setter and getters

- (UILabel *)chapterName{
    if (_chapterName == nil){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
        _chapterName = label;
    }
    return _chapterName;
}

- (UIView *)spaceLine{
    if (_spaceLine == nil) {
        UIView *view = [[UIView alloc] init];        
        view.frame = CGRectMake(12,82,351,108);
        view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
        _spaceLine = view;
    }
    return _spaceLine;
}

@end




@interface YLReadCatalogView ()
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) NSArray<YLReadChapterListModel *> *reverseArray;
@property (nonatomic ,strong) NSArray<YLReadChapterListModel *> *dataArray;

@end

@implementation YLReadCatalogView

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isReverse = NO;
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

#pragma mark - public method

/// 滚动到阅读记录
- (void)scrollRecord{
    if (self.readModel) {
        [self.tableView reloadData];
        if (self.readModel.chapterListModels.count) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %d", self.readModel.recordModel.chapterModel.id];
            YLReadChapterListModel *chapterListModel = [self.dataArray filteredArrayUsingPredicate:predicate].firstObject;
            if (chapterListModel) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray indexOfObject:chapterListModel] inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YLReadCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer forIndexPath:indexPath];
     // 章节
    YLReadChapterListModel *chapterListModel = self.dataArray[indexPath.row];
    // 章节名
    cell.chapterName.text = chapterListModel.name;
    
    // 日夜间
    if ([YLReadUserDefaults getBoolWithKey:kYLRead_Save_Day_Night]) {
        cell.spaceLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.1];
    }else{
        cell.spaceLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
    
    if (self.readModel.recordModel.chapterModel.id == chapterListModel.id) {
        cell.chapterName.textColor = kYLRead_Color_Main();
    }else{
        cell.chapterName.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(catalogViewClickChapter:chapterListModel:)]) {
        [self.delegate catalogViewClickChapter:self chapterListModel:self.dataArray[indexPath.row]];
    }
}

#pragma mark - setter and getters

- (void)setIsReverse:(BOOL)isReverse{
    _isReverse = isReverse;
    [self scrollRecord];
}

- (void)setReadModel:(YLReadModel *)readModel{
    _readModel = readModel;
    [self.tableView reloadData];
    [self scrollRecord];
}

- (NSArray<YLReadChapterListModel *> *)dataArray{
    if (_isReverse) {
        if (_reverseArray.count < 1) {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.readModel.chapterListModels];
            _reverseArray = [[array reverseObjectEnumerator] allObjects];
        }
        return _reverseArray;///倒序数组
    }
    return self.readModel.chapterListModels;///正序数组
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 50;
        [tableView registerClass:YLReadCatalogCell.class forCellReuseIdentifier:CellIdentifer];

        tableView.backgroundColor = UIColor.clearColor;
        tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        if (@available(iOS 11.0, *)) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
        }
        
        _tableView = tableView;
    }
    return _tableView;
}

@end
