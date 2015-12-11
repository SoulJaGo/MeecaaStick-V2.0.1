//
//  DoctorNavigationController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/25.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "DoctorNavigationController.h"

@interface DoctorNavigationController ()

@end

@implementation DoctorNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"医生" image:nil selectedImage:nil];
    
    [self.navigationBar setBackgroundImage:[[GlobalTool shared] createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR]  forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:@"wenzhen"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"wenzhenxuanzhong"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.tabBarItem = tabBarItem;
    self.tabBarItem.title = @"问诊";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
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
