//
//  ViewController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/10.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#define CellBookIdentifer @"BookTableCell"


#import "ViewController.h"
#import "BookTableCell.h"

#import "YLReadTextParser.h"
#import "LingDianParser.h"
#import "YLKeyedArchiver.h"

#import "HTTPManager.h"
#import "MBProgressHUD.h"
#import "BiQuGeParser.h"

@interface ViewController ()
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray<BookModel *> *booksArray;

@end
//

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]);
    
    self.navigationItem.title = @"书架";
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.tableView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[BiQuGeParser getBookAllStringByBookID:@"53605"];
//         [LingDianParser getBookAllStringByBookID:@"300340"];
        NSLog(@"%@", [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]);
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [BookModel getBooks:^(NSMutableArray<BookModel *> *bookArray) {
        self.booksArray = bookArray;
        [self.tableView reloadData];
    }];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.booksArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BookTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellBookIdentifer];
    cell.book = self.booksArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BookModel *book = self.booksArray[indexPath.row];
    NSLog(@"path ------------------- %@",book.filePath);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在解析...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YLReadModel *readModel = [YLReadTextParser parserWithURL:book.fileUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            YLReadController *readVC = [[YLReadController alloc] init];
            readVC.readModel = readModel;
            [self.navigationController pushViewController:readVC animated:YES];
        });
    });
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"清除缓存";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在清理...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BookModel *book = self.booksArray[indexPath.row];
        [YLKeyedArchiver removeWithFolderName:book.bookName fileName:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
    });
}

#pragma mark - getter and setter

- (UITableView *)tableView{
    if(_tableView == nil){
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds),CGRectGetHeight(UIScreen.mainScreen.bounds)) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        tableView.rowHeight = kBookTableCellHeight;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:BookTableCell.class forCellReuseIdentifier:CellBookIdentifer];
        
        _tableView = tableView;
    }
    return _tableView;
}


@end
