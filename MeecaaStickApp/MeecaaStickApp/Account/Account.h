//
//  Account.h
//  HomeKinsa
//
//  Created by SoulJa on 15/11/16.
//  Copyright © 2015年 Mikai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : UIView <NSCoding>
/**
 *  电话
 */
@property (nonatomic,copy) NSString *telephone;
/**
 *  密码
 */
@property (nonatomic,copy) NSString *password;
/**
 *  三方登陆的openID
 */
@property (nonatomic,copy) NSString *openID;
/**
 *  登陆的平台
 */
@property (nonatomic,assign) int platForm;
@end
