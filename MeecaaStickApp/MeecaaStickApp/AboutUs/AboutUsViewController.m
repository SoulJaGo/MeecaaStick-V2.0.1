//
//  AboutUsViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/24.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "AboutUsViewController.h"
@interface AboutUsViewController ()
@property (nonatomic,strong) MMDrawerController * drawerController;
@end
@implementation AboutUsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIVIEW_BACKGROUND_COLOR;
    //设置版本
    self.versionLabel.text = [@"V" stringByAppendingString:VERSION];
    
    //设置Nav
    [self setupNav];

}


- (void)setupNav {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"aboutus_back_icon"] style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
    self.navigationItem.title = @"关于米开";
}

/**
 *  返回按钮
 */
- (void)goBack {
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
