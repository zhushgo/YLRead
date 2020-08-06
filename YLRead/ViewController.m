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
#import "YLReadController.h"
#import "LingDianParser.h"
#import "HTTPManager.h"
#import "MBProgressHUD.h"



@interface ViewController ()
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray<BookModel *> *booksArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]);

    self.navigationItem.title = @"书架";
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.tableView];
    
    [BookModel getBooks:^(NSMutableArray<BookModel *> *bookArray) {
        self.booksArray = bookArray;
        [self.tableView reloadData];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//         [LingDianParser getBookAllStringByBookID:@"410820"];
        NSLog(@"%@", [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()]);
    });
    
    
//    [BiQuGeParser getBookAllStringByBookID:@"1959"];
   
//    [LingDianParser textRegula];
    
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
    YLReadModel *readModel = [YLReadTextParser parserWithURL:book.fileUrl];
    [hud hideAnimated:YES];
    
    YLReadController *readVC = [[YLReadController alloc] init];
    readVC.readModel = readModel;
    [self.navigationController pushViewController:readVC animated:YES];
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
