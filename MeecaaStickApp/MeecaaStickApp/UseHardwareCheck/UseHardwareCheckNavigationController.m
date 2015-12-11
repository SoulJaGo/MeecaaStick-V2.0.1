//
//  UseHardwareCheckNavigationController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/26.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "UseHardwareCheckNavigationController.h"

@implementation UseHardwareCheckNavigationController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBackgroundImage:[[GlobalTool shared] createImageWithColor:NAVIGATIONBAR_BACKGROUND_COLOR]  forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
@end
