//
//  ViewController.m
//  YLRead
//
//  Created by 苏沫离 on 2020/7/10.
//  Copyright © 2020 苏沫离. All rights reserved.
//

#define SLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )



#import "ViewController.h"
#import "YLReadTextParser.h"
#import "YLReadController.h"
#import "NSString+HTML.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSString beiSong_sectionLink:@"https://m.lingdiankanshu.co/410820/2151954.html"];

     
     
    //https://m.lingdiankanshu.co/410820/all.html  完整目录
    //https://m.lingdiankanshu.co/410820/2519061_2.html  568
    //https://m.lingdiankanshu.co/410820/2519062.html    569
    
//    NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://m.lingdiankanshu.co/410820/all.html"] encoding:NSUTF8StringEncoding error:nil];
    
    
    //@{@"sectionName":sectionName,@"sectionLink":sectionLink}
    
//    NSString *path = [NSString stringWithFormat:@"%@/Documents/beiSong_Catalogue",NSHomeDirectory()];
//    NSMutableArray<NSDictionary *> *beiSong_Catalogue = [htmlString beiSong_Catalogue];
//    [beiSong_Catalogue writeToFile:path atomically:YES];
//    NSLog(@"path ====== %@",path);
//    [beiSong_Catalogue enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dictionary, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *sectionName = dictionary[@"sectionName"];
//        NSString *sectionLink = [NSString stringWithFormat:@"https://m.lingdiankanshu.co/410820/%@",dictionary[@"sectionLink"]];
//        SLog(@"%@ ======= %@",sectionName,[NSString beiSong_sectionLink:sectionLink]);
//    }];
    
        
//    NSURL *url = [NSBundle.mainBundle URLForResource:@"求魔" withExtension:@"txt"];
//    [YLReadTextParser parserWithURL:url completion:^(YLReadModel * _Nonnull readModel) {
//        if (readModel) {
//            YLReadController *readVC = [[YLReadController alloc] init];
//            readVC.readModel = readModel;
//            [self.navigationController pushViewController:readVC animated:YES];
//        }
//    }];

}

@end

