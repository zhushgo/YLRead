//
//  ViewController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/10.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#define CellIdentifer @"YLReadCollectionViewCell"


#import "ViewController.h"
#import "YLReadTextParser.h"
#import "YLReadController.h"
#import "LingDianParser.h"
#import "HTTPManager.h"
#import "MBProgressHUD.h"
#import "BiQuGeParser.h"

NSBundle *bookBundle(void){
    return [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"BookResources" ofType:@"bundle"]];
}

NSURL *bookURL(NSString *name,NSString *extension){
    return [bookBundle() URLForResource:name withExtension:extension];
}

@interface YLReadCollectionViewCell: UICollectionViewCell
@property (nonatomic ,strong) UIImageView *imageView;
@property (nonatomic ,strong) UILabel *titleLabel;
@end
@implementation YLReadCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = UIColor.whiteColor;
        _imageView = [[UIImageView alloc]init];
        _imageView.layer.cornerRadius = 3;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat contentView_height = CGRectGetHeight(self.contentView.frame);
    CGFloat contentView_width = CGRectGetWidth(self.contentView.frame);
//    _imageView.frame = CGRectMake(0, 0, 60, contentView_height);

    CGFloat start_x = CGRectGetMaxX(_imageView.frame) + 10.0;
    start_x = 10;
    _titleLabel.frame = CGRectMake(start_x, 0, contentView_width - start_x - 6, contentView_height);
}
@end



@interface ViewController ()
<UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout>
@property (nonatomic ,strong) UICollectionView *collectionView;
@property (nonatomic ,strong) NSArray<NSString *> *pathArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]);

    self.navigationItem.title = @"书架";
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.collectionView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.pathArray = [bookBundle() pathsForResourcesOfType:@"txt" inDirectory:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
    
        
//    [BiQuGeParser getBookAllStringByBookID:@"1959"];
//    [LingDianParser getBookAllStringByBookID:@"4626"];
//    [LingDianParser textRegula];
    NSLog(@"%@", [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]);
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.pathArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YLReadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifer forIndexPath:indexPath];
    NSString *path = self.pathArray[indexPath.row];
    NSString *bookName = [path stringByRemovingPercentEncoding].lastPathComponent.stringByDeletingPathExtension ? : @"";
    cell.titleLabel.text = bookName;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *path = self.pathArray[indexPath.row];
    NSLog(@"path ------------------- %@",path);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在解析...";
    YLReadModel *readModel = [YLReadTextParser parserWithURL:[NSURL fileURLWithPath:path]];
    [hud hideAnimated:YES];

    YLReadController *readVC = [[YLReadController alloc] init];
    readVC.readModel = readModel;
    [self.navigationController pushViewController:readVC animated:YES];
}

#pragma mark - getter and setter

- (UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0.1;
        layout.minimumLineSpacing = 6;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - 30, 40);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [collectionView registerClass:YLReadCollectionViewCell.class forCellWithReuseIdentifier:CellIdentifer];
        _collectionView = collectionView;
    }
    return _collectionView;
}

@end
