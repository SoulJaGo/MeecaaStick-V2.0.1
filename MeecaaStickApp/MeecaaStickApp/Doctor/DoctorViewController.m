//
//  DoctorViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/25.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "DoctorViewController.h"
#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface DoctorViewController () <UIWebViewDelegate>
@property (nonatomic,strong) UIWebView *webView;
@end

@implementation DoctorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置Nav
    [self setupNav];
    
    NSMutableDictionary *memberInfoDict = [[DatabaseTool shared] getDefaultMember];
    if (memberInfoDict == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
        LoginViewController *loginVc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self presentViewController:loginVc animated:NO completion:^{
            [SVProgressHUD showErrorWithStatus:@"请您先登录!"];
        }];
        return;
    }
    
    NSString *user_id = [NSString stringWithFormat:@"%@",memberInfoDict[@"id"]];
    NSString *appKey = @"bfac41d6e46684d019eac2a8486912aa";
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *appKeyStr = [self md5:[NSString stringWithFormat:@"%@%f%@",appKey,timestamp,user_id]];
    NSString *appKeyParam = [appKeyStr substringWithRange:NSMakeRange((appKeyStr.length-16)/2, 16)];
    
    NSString *urlStr = [[NSString stringWithFormat:@"http://www.chunyuyisheng.com/ehr/ask_service/?app_key=%@&user_id=%@&timestamp=%f",appKeyParam,user_id,timestamp] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 60)];
    webView.delegate = self;
    [webView loadRequest:request];
    [self.view addSubview:webView];
    self.webView = webView;
}

/**
 *  设置Nav
 */
- (void)setupNav {
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo"]];
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (![[HttpTool shared] isConnectInternet]) {
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    } else {
        [SVProgressHUD show];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

@end
