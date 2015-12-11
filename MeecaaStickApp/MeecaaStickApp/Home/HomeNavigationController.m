//
//  HomeNavigationController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/18.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "HomeNavigationController.h"
#import "MainTabBarController.h"

@implementation HomeNavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tabBarController.tabBar setHidden:NO];
    [self.tabBarController setSelectedViewController:self];
    
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:nil selectedImage:nil];
    [self.navigationBar setBackgroundImage:[[GlobalTool shared] createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR]  forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageNamed:@"shouye"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"shouyexuanzhong"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.tabBarItem = tabBarItem;
    self.tabBarItem.title = @"首页";    
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
