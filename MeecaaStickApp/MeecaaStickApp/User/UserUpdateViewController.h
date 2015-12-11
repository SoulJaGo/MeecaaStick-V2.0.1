//
//  UserUpdateViewController.h
//  MeecaaStickApp
//
//  Created by mciMac on 15/11/27.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserUpdateViewController : UIViewController
@property (nonatomic,strong) NSDictionary *memberInfoDict;
@property (nonatomic,assign) int section;
/**
 *  从主页点击进入
 */
@property (nonatomic,assign) BOOL isFromMain;
@end
