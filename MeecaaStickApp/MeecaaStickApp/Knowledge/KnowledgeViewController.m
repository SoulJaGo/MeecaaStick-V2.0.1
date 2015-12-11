//
//  KnowledgeViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/25.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "KnowledgeViewController.h"
#import "MainTabBarController.h"

@interface KnowledgeViewController ()
@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) MMDrawerController * drawerController;
@end

@implementation KnowledgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置Nav
    [self setupNav];
    
    //加载HTML
    [self setupWebView];
}

/**
 *  设置Nav
 */
- (void)setupNav {
    self.navigationItem.title = @"体温小常识";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"login_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
}

/**
 *  返回按钮
 */
- (void)goBack {
    [self dismissViewControllerAnimated:NO completion:nil];
}

/**
 *  加载HTML
 */
- (void)setupWebView
{
    UIWebView *webView = [[UIWebView alloc] init];
    webView.frame = [UIScreen mainScreen].bounds;
    webView.scrollView.bounces = NO;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"体温小常识" ofType:@"html"];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    self.webView = webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
