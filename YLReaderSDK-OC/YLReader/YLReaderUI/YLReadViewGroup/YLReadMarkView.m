//
//  YLReadMarkView.m
//  YLRead
//
//  Created by 苏沫离 on 2017/6/30.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import "YLReadMarkView.h"

#import "YLReadUserDefaults.h"

#import "YLReadModel.h"
#import "YLReadMarkModel.h"


#define CellIdentifer @"YLReadMarkCell"


@interface YLReadMarkCell : UITableViewCell
@property (nonatomic ,strong) UILabel *title;
@property (nonatomic ,strong) UILabel *time;
@property (nonatomic ,strong) UILabel *content;
@property (nonatomic ,strong) UIView *spaceLine;
@property (nonatomic ,strong) YLReadMarkModel *markModel;

@end

@implementation YLReadMarkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.time];
        [self.contentView addSubview:self.content];
        [self.contentView addSubview:self.spaceLine];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.contentView.frame);
    CGFloat height = CGRectGetHeight(self.contentView.frame);
    CGFloat itemX = 15,itemY = 15,itemH = 20;
    CGFloat contentW = width - 2*itemX;
    CGFloat contentY = itemY + itemH + 10;
    CGFloat itemW = (contentW - 10) / 2;

    self.title.frame = CGRectMake(itemX, itemY, itemW, itemH);
    self.time.frame = CGRectMake(width - itemW - itemX, itemY, itemW, itemH);
    
    self.content.frame = CGRectMake(itemX, contentY, contentW, height - contentY - 15);
    self.spaceLine.frame = CGRectMake(itemX, height - 0.5, width - itemX * 2.0, 0.5);
}

- (void)setMarkModel:(YLReadMarkModel *)markModel{
    _markModel = markModel;
    
    self.title.text = markModel.name;
    self.time.text = ylReadTransformTimeToMMSS(markModel.time);
    self.content.attributedText = textLineSpacing_1(markModel.content, 5);
}

#pragma mark - setter and getters

- (UILabel *)title{
    if (_title == nil){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
        _title = label;
    }
    return _title;
}

- (UILabel *)time{
    if (_time == nil){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentRight;
        _time = label;
    }
    return _time;
}

- (UILabel *)content{
    if (_content == nil){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
        label.numberOfLines = 0;
        _content = label;
    }
    return _content;
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




@interface YLReadMarkView ()
<UITableViewDelegate,UITableViewDataSource>


@end

@implementation YLReadMarkView

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

#pragma mark - public method


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.readModel.markModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    YLReadMarkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer forIndexPath:indexPath];
    
    // 设置数据
    cell.markModel = self.readModel.markModels[indexPath.row];

    // 日夜间
    if ([YLReadUserDefaults getBoolWithKey:kYLRead_Save_Day_Night]) {
        cell.spaceLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.1];
    }else{
        cell.spaceLine.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(markViewClickMark:markModel:)]) {
        [self.delegate markViewClickMark:self markModel:self.readModel.markModels[indexPath.row]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.readModel removeMarkWithIndex:indexPath.row];
    if (self.readModel.markModels.count) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [tableView reloadData];
    }
}

#pragma mark - setter and getters

- (void)setReadModel:(YLReadModel *)readModel{
    _readModel = readModel;
    [self.tableView reloadData];
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 100;
        [tableView registerClass:YLReadMarkCell.class forCellReuseIdentifier:CellIdentifer];
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
