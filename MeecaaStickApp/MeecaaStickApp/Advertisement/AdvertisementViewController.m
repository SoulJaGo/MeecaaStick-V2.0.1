//
//  AdvertisementViewController.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/12/8.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "AdvertisementViewController.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import <QuartzCore/QuartzCore.h>
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"

@interface AdvertisementViewController ()
@property (nonatomic,strong) MMDrawerController * drawerController;
@property (nonatomic,assign) int timercount;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation AdvertisementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timercount = 0;
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIVIEW_BACKGROUND_COLOR];
    if (self.imageUrl) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = self.view.bounds;
        [self.view addSubview:imageView];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.view.bounds.size.width - 80, self.view.bounds.size.height - 60, 50, 30);
        [btn setTitle:@"跳过" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onClickJump) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageUrl] placeholderImage:[UIImage imageNamed:@"ad_background"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    }];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
        [[NSRunLoop alloc] addTimer:self.timer forMode:NSRunLoopCommonModes];
    } else {
        [self presentViewController:self.drawerController animated:NO completion:^{
            [[HttpTool shared] getAdvertisementDictionary];
        }];
    }
}

- (void)handleTimer {
    self.timercount++;
    if (self.timercount==3) {
        if (self.timer) {
            [self.timer invalidate];
        }
        [self presentViewController:self.drawerController animated:NO completion:^{
            [[HttpTool shared] getAdvertisementDictionary];
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
}

- (MMDrawerController *)drawerController {
    if (_drawerController == nil) {
        MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
        LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
        RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
        
        self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
        [self.drawerController setShowsShadow:NO];
        [self.drawerController setMaximumRightDrawerWidth:200];
        [self.drawerController setMaximumLeftDrawerWidth:200];
    }
    return _drawerController;
}
-(BOOL)prefersStatusBarHidden {
    return YES;
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

- (void)onClickJump {
    [self presentViewController:self.drawerController animated:NO completion:^{
        [[HttpTool shared] getAdvertisementDictionary];
    }];

}
@end
