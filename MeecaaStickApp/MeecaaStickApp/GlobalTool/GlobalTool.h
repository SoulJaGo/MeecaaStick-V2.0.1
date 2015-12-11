//
//  GlobalTool.h
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/19.
//  Copyright © 2015年 SoulJa. All rights reserved.
//  全局工具类

#import <UIKit/UIKit.h>

@interface GlobalTool : UIViewController
/**
 *  获取手机的UUID
 */
@property (nonatomic,copy) NSString *PhoneUUID;

/**
 *  获取手机上版本号
 */
@property (nonatomic,copy) NSString *Version;

/**
 *  单例模式
 */
+ (id)shared;

/**
 *  color转image
 */
- (UIImage*)createImageWithColor: (UIColor*)color;

/**
 *  判断设备型号
 */
- ( NSString *)deviceString;

/**
 *  手机号码验证
 */
- (BOOL)isMobileNumberClassification:(NSString *)phoneNum;
/**
 *  地理位置
 */
@property (nonatomic,copy) NSString *city;
@property (nonatomic,assign) float longitude;
@property (nonatomic,assign) float latitude;

/**
 *  DeviceToken
 */
@property (nonatomic,strong) NSData *DeviceToken;

- (NSString *)getSymptonNameByTag:(NSNumber *)tag;

@property (retain, nonatomic) NSArray *symptonTemplateList;

- (NSArray *)getFlagInIntergerPosition:(NSNumber *)value;

/**
 *  是否允许通知
 */
- (BOOL)isAllowedNotification;
/**
 *  是否含非法字符
 */
- (BOOL)isHaveIllegalChar:(NSString *)str;
@end
