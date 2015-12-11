//
//  Header.h
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/18.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#ifndef Header_h
#define Header_h
/**
 *  引入全局工具类
 */
#import "GlobalTool.h"

/**
 *  HUD工具类
 */
#import "SVProgressHUD.h"

/**
 *  网络请求工具类
 */
#import "HttpTool.h"

/**
 *  数据库工具类
 */
#import "DatabaseTool.h"

/**
 *  图像工具类
 */
#import "UIImageView+WebCache.h"

/**
 *  主TabBarController
 */
#import "MainTabBarController.h"

/**
 *  左边菜单栏
 */
#import "LeftMenuViewController.h"

/**
 *  右边菜单栏
 */
#import "RightMenuViewController.h"

/**
 *  正式服务器地址
 */
//#define HOST @"http://api.meecaa.cn/"

/**
 *  测试服务器地址
 */
#define HOST @"http://120.24.174.207/"

/**
 *  TabBar的背景色
 */
#define TABBAR_BACKGROUND_COLOR [UIColor colorWithRed:80/255.0 green:205/255.0 blue:216/255.0 alpha:1.0]

/**
 *  Navigationbar的背景色
 */
#define NAVIGATIONBAR_BACKGROUND_COLOR [UIColor colorWithRed:80/255.0 green:205/255.0 blue:216/255.0 alpha:1.0]

/**
 *  View的背景色
 */
#define UIVIEW_BACKGROUND_COLOR [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]

/**
 *  自定义版本号
 */
#define VERSION @"2.0.0"

/**
 *  按钮圆角
 */
#define BUTTON_CORNER_RADIUS 8.0f
/**
 *	屏幕的高
 */
#define kScreen_Height      ([UIScreen mainScreen].bounds.size.height)
/**
 *	屏幕的宽
 */
#define kScreen_Width       ([UIScreen mainScreen].bounds.size.width)

#endif /* Header_h */
