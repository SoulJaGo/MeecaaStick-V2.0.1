//
//  UserNavigationController.m
//  MeecaaStickApp
//
//  Created by mciMac on 15/11/26.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "UserNavigationController.h"

@interface UserNavigationController ()

@end

@implementation UserNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBackgroundImage:[[GlobalTool shared] createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR]  forBarMetrics:UIBarMetricsDefault];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
