//
//  AppDelegate.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/18.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "AppDelegate.h"
#import "HttpTool.h"
#import "MainTabBarController.h"
//ShareSDK引入
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
//开启QQ和Facebook网页授权需要
#import <QZoneConnection/ISSQZoneApp.h>
#import "WXApi.h"
#import "WeiboSDK.h"
//开启微信授权
#import "WXApi.h"

#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import <QuartzCore/QuartzCore.h>
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"
#import "AdvertisementViewController.h"

@interface AppDelegate ()
@property (nonatomic,strong) MMDrawerController * drawerController;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //接入ShareSDK
    [ShareSDK registerApp:@"91389f1b1b22"];//字符串api20为您的ShareSDK的AppKey
    
    //开启QQ空间网页授权开关(optional)
    id<ISSQZoneApp> app =(id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
    [app setIsAllowWebAuthorize:YES];
    
    //添加新浪微博应用 注册网址 http://open.weibo.com
    [ShareSDK connectSinaWeiboWithAppKey:@"2943436169"
                               appSecret:@"3f910962eb3218700508ecc9b2c24fdf"
                             redirectUri:@"http://www.sharesdk.cn"];
    
    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
    [ShareSDK connectQZoneWithAppKey:@"1104709573"
                           appSecret:@"A6yl1nhY2wUPpiSQ"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    //添加QQ应用  注册网址  http://open.qq.com/
    [ShareSDK connectQQWithQZoneAppKey:@"1104709573"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //微信登陆应用
    [ShareSDK connectWeChatWithAppId:@"wxb3d63128c869c167" appSecret:@"275391a1930ff0e469427705b46b44f1" wechatCls:[WXApi class]];
    
    //推送通知
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        [application registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }

    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    BOOL isConnectInternet = [[HttpTool shared] isConnectInternet];
    if (isConnectInternet) { //连接的上网络
        //查看是否拥有广告位图片
        NSDictionary *adDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"ad"];
        if (adDict == nil) //第一次打开
        {
            /* 异步写入广告页信息 */
            [[HttpTool shared] getAdvertisementDictionary];
            /*跳转到主页面*/
            MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
            LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
            RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
            self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
            [self.drawerController setShowsShadow:NO];
            [self.drawerController setMaximumRightDrawerWidth:200];
            [self.drawerController setMaximumLeftDrawerWidth:200];
            self.window.rootViewController = self.drawerController;
        } else { //有广告页信息
            if ([[adDict objectForKey:@"status"] isEqual:@1])
            {
                /* 显示广告页信息 */
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Second" bundle:nil];
                AdvertisementViewController *adVc = [storyboard instantiateViewControllerWithIdentifier:@"AdvertisementViewController"];
                adVc.imageUrl = [[adDict objectForKey:@"data"] objectForKey:@"img"];
                self.window.rootViewController = adVc;
            } else { //不显示广告页信息
                /* 异步写入广告页信息 */
                [[HttpTool shared] getAdvertisementDictionary];
                /*跳转到主页面*/
                MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
                LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
                RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
                self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
                [self.drawerController setShowsShadow:NO];
                [self.drawerController setMaximumRightDrawerWidth:200];
                [self.drawerController setMaximumLeftDrawerWidth:200];
                self.window.rootViewController = self.drawerController;
            }
        }
    } else { //连接的不上网络
        MainTabBarController *mainTabBarC = [[MainTabBarController alloc] init];
        LeftMenuViewController *leftMenuVc = [[LeftMenuViewController alloc] init];
        RightMenuViewController *rightMenuVc = [[RightMenuViewController alloc] init];
        
        self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:mainTabBarC leftDrawerViewController:leftMenuVc rightDrawerViewController:rightMenuVc];
        [self.drawerController setShowsShadow:NO];
        [self.drawerController setMaximumRightDrawerWidth:200];
        [self.drawerController setMaximumLeftDrawerWidth:200];
        self.window.rootViewController = self.drawerController;
    }
    return YES;
}

/**
 *  接收到Token
 */
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[GlobalTool shared] setDeviceToken:deviceToken];
}

#pragma mark 获取device token失败后
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[GlobalTool shared] setDeviceToken:nil];
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError:%@",error.localizedDescription);
}

#pragma mark - 接收到消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"%@",userInfo);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation
{
    return [ShareSDK handleOpenURL: url
                 sourceApplication:sourceApplication
                        annotation: annotation
                        wxDelegate: self];
}

@end
