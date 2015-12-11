//
//  ForgetPwdNavigationController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/23.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "ForgetPwdNavigationController.h"

@implementation ForgetPwdNavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBackgroundImage:[[GlobalTool shared]  createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR]forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
