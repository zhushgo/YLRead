//
//  ViewController.m
//  Demo
//
//  Created by 苏沫离 on 2020/10/27.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>


/**************** WebView 约定的方法 ***************/
NSString *const kWebViewDemoClick = @"getMemberInfor";

@interface ViewController ()
<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic ,strong) NSURL *url;
@property (nonatomic ,strong) WKWebView *webView;
@end

@implementation ViewController

#pragma mark - life cycle

- (void)dealloc{
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:kWebViewDemoClick];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    self.url = [NSURL URLWithString:@"http://192.168.1.14:8080"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    [_webView loadRequest:request];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *href = navigationAction.request.URL.absoluteString;
    NSLog(@"href ====== %@",href);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation");
//    @"加载中..."
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"didCommitNavigation");
//    [self setUserInfoForWebView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didFailProvisionalNavigation");
}

#pragma mark - WKUIDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"runJavaScriptAlertPanelWithMessage : %@",message);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    NSLog(@"runJavaScriptConfirmPanelWithMessage");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    NSLog(@"runJavaScriptTextInputPanelWithPrompt");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(@"");
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message ==== %@ : %@",message.name,message.body);
    if ([message.name isEqualToString:kWebViewDemoClick]){//
        [self setUserInfoForWebView];
//        [self demoClick:message.body];
    }
}

#pragma mark - response click

//拨打电话
- (void)demoClick:(NSString *)para{
    
}

#pragma mark - private method

/** localStorage 存取数据本地数据
 */
- (void)setUserInfoForWebView{
    NSString *path = [NSBundle.mainBundle pathForResource:@"demo" ofType:@"json"];
    NSError *error;
    NSString *string = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    string = [[string stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *info = [NSString stringWithFormat:@"responseToJS('%@')", string];
    NSLog(@"info ====== %@",info);

    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:info completionHandler:^(id _Nullable model, NSError * _Nullable error) {
        if (error) {
            [weakSelf showError:error];
            NSLog(@"error ----- %@",error);
        }else{
            NSLog(@"model ===== %@",model);
        }
    }];
}

- (void)showError:(NSError *)error{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:error.description preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        [self.webView loadRequest:request];
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }])];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark - setter and getter

- (WKWebView *)webView{
    if (_webView == nil){
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        configuration.userContentController = userController;
        
        _webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:configuration];
        _webView.backgroundColor = _webView.scrollView.backgroundColor = [UIColor colorWithRed:240 / 255.0 green:240 / 255.0 blue:240 / 255.0 alpha:1];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.opaque = YES;
        
        /** JS 调用 OC 方法 ***/
        [_webView.configuration.userContentController addScriptMessageHandler:self name:kWebViewDemoClick];
    }
    return _webView;
}

@end
