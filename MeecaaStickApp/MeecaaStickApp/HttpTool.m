//
//  HttpTool.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/18.
//  Copyright © 2015年 SoulJa. All rights reserved.
//  Http工具类

#import "HttpTool.h"
#import "Reachability.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>
#import "Account.h"

#define APPKEY @"!@#$%meecaa.com"

typedef enum
{
    CurrentLoginStatusPhoneNumber=0,
    CurrentLoginStatusSinaWeiBo = 1,
    CurrentLoginStatusQQ = 2,
    CurrentLoginStatusWeiXin = 3,
    CurrentLoginStatusNone = 4
}CurrentLoginStatus;

@interface HttpTool ()
@property (nonatomic,strong) AFHTTPRequestOperationManager *manager;
@end

@implementation HttpTool
/**
 *  http类管理者
 */
- (AFHTTPRequestOperationManager *)manager {
    if (_manager == nil) {
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return _manager;
}

/**
 *  单例对象
 */
+ (id)shared {
    static HttpTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    });
    return sharedInstance;
}

/**
 *  初始化方法
 */
- (id)init {
    self = [super init];
    return self;
}

/**
 *  监测是否连上网络
 */
- (BOOL)isConnectInternet
{
    BOOL isConnectInternet = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:HOST];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isConnectInternet = NO;
            break;
        default:
            isConnectInternet = YES;
            break;
    }
    return isConnectInternet;
}

/**
 *  获取广告页的数据
 */
- (void)getAdvertisementDictionary {
    //取出图片的质量
    NSString *quality = @"";
    if ([[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 4"] || [[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 4S"]) {
        quality = @"iphoneL";
    } else if ([[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 5"] || [[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 5C"] || [[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 5S"]) {
        quality = @"iphoneM";
    } else if ([[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 6"] || [[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 6 Plus"] || [[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 6S"] || [[[GlobalTool shared] deviceString] isEqualToString:@"iPhone 6S Plus"]) {
        quality = @"iphoneH";
    } else {
        quality = @"iphoneM";
    }
    NSString *urlStr = [[HOST stringByAppendingString:@"api.php?m=open&c=ads&a=spread&identifier="] stringByAppendingString:quality];
    [self.manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        /**
         *  存储广告数据
         */
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:responseObject forKey:@"ad"];
        [defaults synchronize];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }];
}

/**
 *  监测最新的版本
 */
- (NSMutableDictionary *)getLastVersion {
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=version&a=index&device=ios"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation start];
    [operation waitUntilFinished];
    NSError *error = nil;
    NSMutableDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"%@",error);
        return nil;
    } else {
        return resultDict;
    }
}

- (void)LoginWithPhoneNumber:(NSString *)phoneNumber Password:(NSString *)password
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = phoneNumber;
    params[@"password"] = password;
    params[@"devicetype"] = @"ios";
    params[@"timestamp"] = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    params[@"uuid"] = [[GlobalTool shared] PhoneUUID];
    params[@"version"] = VERSION;
    params[@"sign"] = [self getLoginSignWithPhoneNumber:phoneNumber Password:password Timestamp:params[@"timestamp"]];
    //取出用户的DeviceToken
    if ([[GlobalTool shared] DeviceToken] != nil) {
        NSData *deviceTokenData = [[GlobalTool shared] DeviceToken];
        params[@"devicetoken"] = [NSString stringWithFormat:@"%@",deviceTokenData];
        params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@"<" withString:@""];
        params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@">" withString:@""];
        params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    params[@"device_brand"] = @"apple";
    params[@"device_model"] = [[GlobalTool shared] deviceString];
    params[@"device_system"] = @"ios";
    params[@"device_version"] = [NSString stringWithFormat:@"%.1f",[[UIDevice currentDevice].systemVersion floatValue]];
    
    //请求地址
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=login"];
    
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //返回状态码
        NSNumber *status = [responseObject objectForKey:@"status"];
        if ([status isEqualToNumber:@1]) { //登陆成功
            [SVProgressHUD dismiss];
            BOOL result = [[DatabaseTool shared] insertInitMembers:responseObject[@"data"]];
            if (!result) {
                NSLog(@"数据写入失败!");
                [SVProgressHUD showErrorWithStatus:@"用户名或密码错误!"];
            } else {
                //记录账号密码信息到沙盒
                Account *account = [[Account alloc] init];
                account.telephone = phoneNumber;
                account.password = password;
                account.openID = @"";
                account.platForm = CurrentLoginStatusPhoneNumber;
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *path = [docDir stringByAppendingPathComponent:@"account.archive"];
                BOOL isArchive = [NSKeyedArchiver archiveRootObject:account toFile:path];
                
                if (!isArchive) {
                    NSLog(@"本地存储账号密码失败!");
                }
                
                //发出登陆成功的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }];
}

/**
 *  拼接login的Sign
 */
- (NSString *)getLoginSignWithPhoneNumber:(NSString *)phoneNumber Password:(NSString *)password Timestamp:(NSString *)timestamp
{
    NSString *sign = [[[phoneNumber stringByAppendingString:password] stringByAppendingString:timestamp] stringByAppendingString:APPKEY];
    NSString *signMd5 = [self md5:sign];
    return signMd5;
}

/**
 *  第三方登陆
 */
- (void)loginThirdPartyWithOpenId:(NSString *)openId NickName:(NSString *)nickName PlatForm:(NSString *)platForm Avatar:(NSString *)avatar
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"openid"] = openId;
    params[@"nickname"] = nickName;
    params[@"platform"] = platForm;
    params[@"avatar"] = avatar;
    params[@"timestamp"] = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    params[@"devicetype"] = @"ios";
    params[@"version"] = VERSION;
    params[@"uuid"] = [[GlobalTool shared] PhoneUUID];
    params[@"sign"] = [self getLoginThirdPartySignWithOpenId:openId PlatForm:platForm Timestamp:params[@"timestamp"]];
    params[@"device_brand"] = @"apple";
    params[@"device_model"] = [[GlobalTool shared] deviceString];
    params[@"device_system"] = @"ios";
    params[@"device_version"] = [NSString stringWithFormat:@"%.1f",[[UIDevice currentDevice].systemVersion floatValue]];
    
    //取出用户的DeviceToken
    //取出用户的DeviceToken
    if ([[GlobalTool shared] DeviceToken] != nil) {
        NSData *deviceTokenData = [[GlobalTool shared] DeviceToken];
        params[@"devicetoken"] = [NSString stringWithFormat:@"%@",deviceTokenData];
        params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@"<" withString:@""];
        params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@">" withString:@""];
        params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=oauth"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            //将数据写入FMDB
            BOOL result = [[DatabaseTool shared] insertInitMembers:responseObject[@"data"]];
            if (!result) {
                NSLog(@"数据写入失败!");
                [SVProgressHUD showErrorWithStatus:@"授权失败,请尝试重新登陆!"];
            } else {
                [SVProgressHUD dismiss];
                NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                NSString *path = [docDir stringByAppendingPathComponent:@"account.archive"];
                Account *account = [[Account alloc] init];
                account.telephone = @"";
                account.password = @"";
                account.openID = openId;
                switch ([platForm intValue]) {
                    case 1:
                        account.platForm = CurrentLoginStatusSinaWeiBo;
                        break;
                    case 2:
                        account.platForm = CurrentLoginStatusQQ;
                        break;
                    case 3:
                        account.platForm = CurrentLoginStatusWeiXin;
                        break;
                    default:
                        account.platForm = CurrentLoginStatusNone;
                        break;
                }
                
                BOOL isArchive = [NSKeyedArchiver archiveRootObject:account toFile:path];
                if (!isArchive) {
                    NSLog(@"第三方登陆压缩失败");
                }
                
                //发出登陆成功的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"授权失败,请尝试重新登陆!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}

/**
 *  获取第三方登陆的sign
 */
- (NSString *)getLoginThirdPartySignWithOpenId:(NSString *)openId PlatForm:(NSString *)platForm Timestamp:(NSString *)timestamp
{
    NSString *sign = [[[openId stringByAppendingString:platForm] stringByAppendingString:timestamp] stringByAppendingString:APPKEY];
    NSString *signMd5 = [self md5:sign];
    return signMd5;
}

/**
 *  修改密码接收验证码
 */
- (void)getResetPwdVerifyCode:(NSString *)phone
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = phone;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=resetsms"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            [SVProgressHUD showSuccessWithStatus:@"获取验证码成功，请5分钟内使用！"];
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }];
}

/**
 *  修改用户密码
 */
- (void)resetAccountPasswordByPhoneNumber:(NSString *)phoneNumber NewPwd:(NSString *)newPwd Code:(NSString *)code
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = phoneNumber;
    params[@"password"] = newPwd;
    params[@"code"] = code;
    
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=resetpsw"];
    
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            [self LoginWithPhoneNumber:phoneNumber Password:newPwd];
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}

/**
 *  自动登陆验证
 */
- (void)validLogin
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docDir stringByAppendingPathComponent:@"account.archive"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) { //本地文件不存在则表示没有登陆过
        return;
    } else {
        NSMutableDictionary *memberInfoDict = [[DatabaseTool shared] getDefaultMember];
        if (memberInfoDict == nil) { //没有登陆过
            return;
        } else {
            Account *account = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            switch (account.platForm) {
                case CurrentLoginStatusPhoneNumber:
                    [self validLoginWithPhoneNumber];
                    break;
                case CurrentLoginStatusSinaWeiBo:
                    [self validLoginWithThirdParty];
                    break;
                case CurrentLoginStatusQQ:
                    [self validLoginWithThirdParty];
                    break;
                case CurrentLoginStatusWeiXin:
                    [self validLoginWithThirdParty];
                    break;
                default:
                    break;
            }

        }
    }
    
}

/**
 *  账号密码验证
 */
- (void)validLoginWithPhoneNumber
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docDir stringByAppendingPathComponent:@"account.archive"];
    Account *account = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = account.telephone;
    params[@"password"] = account.password;
    params[@"devicetype"] = @"ios";
    params[@"timestamp"] = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    params[@"uuid"] = [[GlobalTool shared] PhoneUUID];
    params[@"version"] = VERSION;
    params[@"sign"] = [self getLoginSignWithPhoneNumber:account.telephone Password:account.password Timestamp:params[@"timestamp"]];
    //取出用户的DeviceToken
    NSData *deviceTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    params[@"devicetoken"] = [NSString stringWithFormat:@"%@",deviceTokenData];
    params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@">" withString:@""];
    params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    params[@"device_brand"] = @"apple";
    params[@"device_model"] = [[GlobalTool shared] deviceString];
    params[@"device_system"] = @"ios";
    params[@"device_version"] = [NSString stringWithFormat:@"%.1f",[[UIDevice currentDevice].systemVersion floatValue]];
    
    //请求地址
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=login"];
    
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] isEqual:[NSNumber numberWithInt:0]]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:vc animated:NO completion:nil];
            return;
        } else {
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        return;
    }];
    
}

/**
 *  验证第三方登陆
 */
- (void)validLoginWithThirdParty
{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [docDir stringByAppendingPathComponent:@"account.archive"];
    Account *account = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    
    NSString *platForm = @"";
    NSString *PlatFormMob = @"";
        switch (account.platForm) {
        case CurrentLoginStatusSinaWeiBo:
            platForm = @"1";
            PlatFormMob = @"SinaWeiBo";
            break;
        case CurrentLoginStatusQQ:
            platForm = @"2";
            PlatFormMob = @"QQ";
            break;
        case CurrentLoginStatusWeiXin:
            platForm = @"3";
            PlatFormMob = @"WeiXin";
            break;
        default:
            break;
    }
    
    if ([platForm  isEqualToString:@""]) {
        return;
    }
    
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"openid"] = account.openID;
    params[@"timestamp"] = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    params[@"platform"] = platForm;
    params[@"devicetype"] = @"ios";
    params[@"version"] = VERSION;
    params[@"uuid"] = [[GlobalTool shared] PhoneUUID];
    params[@"sign"] = [self getLoginThirdPartySignWithOpenId:account.openID PlatForm:platForm Timestamp:params[@"timestamp"]];
    
    //取出用户的DeviceToken
    NSData *deviceTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
    params[@"devicetoken"] = [NSString stringWithFormat:@"%@",deviceTokenData];
    params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@">" withString:@""];
    params[@"devicetoken"] = [params[@"devicetoken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    params[@"device_brand"] = @"apple";
    params[@"device_model"] = [[GlobalTool shared] deviceString];
    params[@"device_system"] = @"ios";
    params[@"device_version"] = [NSString stringWithFormat:@"%.1f",[[UIDevice currentDevice].systemVersion floatValue]];
    
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=oauth"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"status"] isEqual:[NSNumber numberWithInt:0]]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"First" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            [self presentViewController:vc animated:NO completion:nil];
            return;
        } else {
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        return;
    }];
}


/**
 *  MD5加密算法
 */
- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

/**
 *  设置为选中的成员
 */
- (void)setDefaultMemberWithAcc_id:(NSString *)acc_id Mid:(NSString *)mid
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"acc_id"] = acc_id;
    params[@"mid"] = mid;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=defaultSet"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            BOOL result = [[DatabaseTool shared] DefaultMemberWithAcc_id:acc_id Mid:mid];
            if (!result) {
                [SVProgressHUD dismiss];
//                [[TTToolsHelper shared] showAlertMessage:@"设置默认成员失败!"];
                [SVProgressHUD showErrorWithStatus:@"设置默认成员失败!"];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SetDefaultMemberSuccessNotification" object:nil];
                [SVProgressHUD showSuccessWithStatus:@"设置默认成员成功!"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
//        [[TTToolsHelper shared] showAlertMessage:@"网络不给力哦！"];
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}

/**
 *  获取默认用户的所有测温记录
 */
- (void)getDefaultMemberDiaryInfo
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //去除默认用户的id
    NSDictionary *defaultMemberInfo = [[DatabaseTool shared] getDefaultMember];
    params[@"mid"] = [NSString stringWithFormat:@"%@",defaultMemberInfo[@"id"]];
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=record"];
    
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            NSArray *diaryArray = responseObject[@"data"];
            if (diaryArray != nil || diaryArray.count != 0) {
                for (NSMutableDictionary *dict in diaryArray) {
                    BOOL result = [[DatabaseTool shared] addDiary:dict];
                    if (!result) {
                        NSLog(@"插入数据失败!");
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"InitDiaryDataSuccessNotification" object:nil];
            } else {
                return;
            }
            [SVProgressHUD dismiss];
        } else {
//            [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
            [SVProgressHUD dismiss];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }];
}

/**
 *  删除一个成员
 */
- (void)removeMember:(NSString *)mid
{
    //初始化请求管理者
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"member_id"] = mid;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=del"];
    [mgr POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if ([[NSString stringWithFormat:@"%@",responseObject[@"status"]] isEqualToString:@"1"]) { //表示删除成功
//            BOOL result = [DatabaseTool removeMember:mid];
            BOOL result = [[DatabaseTool shared] removeOneMember:mid];
            if (!result) {
//                [[TTToolsHelper shared] showAlertMessage:@"删除成员失败!"];
                [SVProgressHUD showErrorWithStatus:@"删除成员失败!"];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveMemberSuccessNotification" object:nil];
                [SVProgressHUD showSuccessWithStatus:@"删除成员成功！"];
            }
        } else {
//            [[TTToolsHelper shared] showAlertMessage:@"删除成员失败!"];
            [SVProgressHUD showErrorWithStatus:@"删除成员失败!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
//        [[TTToolsHelper shared] showAlertMessage:@"网络不给力哦！"];
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
    
}
/**
 *  添加成员的方法
 */
- (void)addMemberWithName:(NSString *)name Sex:(NSString *)sex City:(NSString *)city Birth:(NSString *)birth Addr:(NSString *)addr Acc_id:(NSString *)acc_id{
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"name"] = name;
    params[@"sex"] = sex;
    params[@"city"] = city;
    params[@"birth"] = birth;
    params[@"addr"] = addr;
    params[@"acc_id"] = acc_id;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=setting"];
    [mgr POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            BOOL result = [[DatabaseTool shared] addMember:responseObject[@"data"]];
            if (!result) {
                [SVProgressHUD showErrorWithStatus:@"添加成员失败!"];
            } else {
                //添加成功发出通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddMemberSuccessNotification" object:nil];
//                NSLog(@"params %@",params);
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"添加成员失败!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}
/**
 *  添加带图像成员的方法
 */
- (void)addMemberWithName:(NSString *)name Sex:(NSString *)sex City:(NSString *)city Birth:(NSString *)birth Addr:(NSString *)addr Acc_id:(NSString *)acc_id IconImage:(UIImage *)iconImage
{
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"name"] = name;
    params[@"sex"] = sex;
    params[@"city"] = city;
    params[@"birth"] = birth;
    params[@"addr"] = addr;
    params[@"acc_id"] = acc_id;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=setting"];
    [mgr POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(iconImage,0.5) name:@"img" fileName:@"img.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            BOOL result = [[DatabaseTool shared] addMember:responseObject[@"data"]];
            if (!result) {
//                [[TTToolsHelper shared] showAlertMessage:@"添加成员失败!"];
                [SVProgressHUD showErrorWithStatus:@"添加成员失败!"];
            } else {
                //添加成功发出通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddMemberSuccessNotification" object:nil];
            }
        } else {
//            [[TTToolsHelper shared] showAlertMessage:@"添加成员失败!"];
            [SVProgressHUD showErrorWithStatus:@"添加成员失败!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
//        [[TTToolsHelper shared] showAlertMessage:@"网络不给力哦！"];
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}

/**
 *  删除一条记录
 */
- (void)removeDiary:(NSString *)diaryId
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"diary_id"] = diaryId;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=delTemperature"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            BOOL result = [[DatabaseTool shared] removeDiaryByDiaryId:diaryId];
            if (!result) {
                [SVProgressHUD showErrorWithStatus:@"删除记录失败!"];
                return;
            } else {
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveDiarySuccessNotification" object:nil];
            }
        } else {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"删除记录失败!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}

/**
 *	更新一个改变了头像的成员的方法
 */
- (void)updateMemberWithMid:(NSString *)mid Name:(NSString *)name Sex:(NSString *)sex Birth:(NSString *)birth City:(NSString *)city IconImage:(UIImage *)iconImage{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mid"] = mid;
    params[@"name"] = name;
    params[@"sex"] = sex;
    params[@"birth"] = birth;
    params[@"city"] = city;
    
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=setting"];
    self.manager.requestSerializer.timeoutInterval = 40;
    [self.manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(iconImage, 0.5) name:@"img" fileName:@"img.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            BOOL result = [[DatabaseTool shared] updateMember:responseObject[@"data"]];
            if (!result) {
                NSLog(@"修改数据库失败!");
//                [[TTToolsHelper shared] showAlertMessage:@"修改成员失败!"];
                [SVProgressHUD showErrorWithStatus:@"修改成员失败!"];
            } else {
                //判断是否为默认成员
                NSDictionary *defaultMember = [[DatabaseTool shared] getDefaultMember];
                
                if ([mid isEqualToString:[NSString stringWithFormat:@"%@",defaultMember[@"id"]]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDefaultMemberSuccessNotification" object:nil];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMemberSuccessNotification" object:nil];
            }
        } else {
//            [[TTToolsHelper shared] showAlertMessage:@"修改成员失败!"];
            [SVProgressHUD showErrorWithStatus:@"修改成员失败!"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
//        [[TTToolsHelper shared] showAlertMessage:@"网络不给力哦！"];
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}
/**
 *	更新一个没有改变头像的成员的方法
 */
- (void)updateMemberWithMid:(NSString *)mid Name:(NSString *)name Sex:(NSString *)sex Birth:(NSString *)birth City:(NSString *)city
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mid"] = mid;
    params[@"name"] = name;
    params[@"sex"] = sex;
    params[@"birth"] = birth;
    params[@"city"] = city;
    
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=setting"];
    
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            BOOL result = [[DatabaseTool shared] updateMember:responseObject[@"data"]];
            if (!result) {
                NSLog(@"修改数据库失败!");
//                [[TTToolsHelper shared] showAlertMessage:@"修改成员失败!"];
                [SVProgressHUD showErrorWithStatus:@"修改成员失败!"];
            } else {
                //判断是否为默认成员
                NSDictionary *defaultMember = [[DatabaseTool shared] getDefaultMember];
                
                if ([mid isEqualToString:[NSString stringWithFormat:@"%@",defaultMember[@"id"]]]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDefaultMemberSuccessNotification" object:nil];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateMemberSuccessNotification" object:nil];
            }
        } else {
//            [[TTToolsHelper shared] showAlertMessage:@"修改成员失败!"];
            [SVProgressHUD showErrorWithStatus:@"修改成员失败!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
//        [[TTToolsHelper shared] showAlertMessage:@"网络不给力哦！"];
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
    
}

/**
 *  发起添加记录的请求
 */
- (void)addDiaryWithDate:(NSString *)date Temperature:(NSString *)temperature Symptoms:(NSString *)symptoms Photo_count:(NSString *)photo_count Description:(NSString *)description Member_id:(NSString *)member_id Longitude:(NSString *)longitude Latitude:(NSString *)latitude
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"date"] = date;
    params[@"temperature"] = temperature;
    params[@"symptoms"] = symptoms;
    params[@"photo_count"] = photo_count;
    params[@"description"] = description;
    params[@"member_id"] = member_id;
    params[@"longitude"] = longitude;
    params[@"latitude"] = latitude;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=addTemperature"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if (responseObject[@"status"]==[NSNumber numberWithInteger:1]) {
            //存储到数据库中
            BOOL result = [[DatabaseTool shared] addDiary:responseObject[@"data"]];
            if (!result) {
                NSLog(@"插入数据失败!");
                [SVProgressHUD showErrorWithStatus:@"添加数据失败!"];
            } else {
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddDiarySuccessNotification" object:nil userInfo:responseObject[@"data"]];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
    
}

/**
 *  发起修改病历记录的请求
 */
- (void)updateDiaryWithID:(NSString *)tid Temperature:(NSString *)temperature Date:(NSString *)date Symptoms:(NSString *)symptoms Photo_count:(NSString *)photo_count Description:(NSString *)description{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];    
    params[@"id"] = tid;
    params[@"temperature"] = temperature;
    params[@"date"] = date;
    params[@"symptoms"] = symptoms;
    params[@"photo_count"] = photo_count;
    params[@"description"] = description;

    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=editTemperature"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation * operation, id responseObject) {
        if (responseObject[@"status"] ==[NSNumber numberWithInteger:1]) {
            //存储到数据库中
            BOOL result = [[DatabaseTool shared] updateDiary:responseObject[@"data"]];
            if (!result) {
                NSLog(@"插入数据失败!");
                [SVProgressHUD showErrorWithStatus:@"添加数据失败!"];
            } else {
                [SVProgressHUD dismiss];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDiarySuccessNotification" object:nil userInfo:responseObject[@"data"]];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"更新病历记录失败!"];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
    
}

/**
 *  获取默认用户的所有测温记录
 */
- (void)getDefaultMemberDiaryInfoByPage:(int)page
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //去除默认用户的id
    NSDictionary *defaultMemberInfo = [[DatabaseTool shared] getDefaultMember];
    params[@"mid"] = [NSString stringWithFormat:@"%@",defaultMemberInfo[@"id"]];
    params[@"page"] = [NSString stringWithFormat:@"%d",page];
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=member&a=listTemperature"];
    
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            NSArray *diaryArray = responseObject[@"data"];
            if (diaryArray != nil || diaryArray.count != 0) {
                BOOL result = [[DatabaseTool shared] addDiaryWithArray:diaryArray];
                if (!result) {
                    NSLog(@"插入数据库失败!");
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"InitDiaryDataSuccessNotification" object:nil];
                
            } else {
                return;
            }
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InitDiaryDataEndSuccessNotification" object:nil];
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦！"];
    }];
}

/**
 *  注册用户
 */
- (void)registerAccountWithPhoneNumber:(NSString *)phoneNumber NickName:(NSString *)nickName Password:(NSString *)password registerCode:(NSString *)code
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = phoneNumber;
    params[@"nickname"] = nickName;
    params[@"password"] = password;
    params[@"code"] = code;
    params[@"devicetype"] = @"ios";
    params[@"timestamp"] = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    params[@"sign"] = [self getRegisterAccountSignWithPhoneNumber:phoneNumber NickName:nickName Password:password Timestamp:params[@"timestamp"]];
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=register"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            [self LoginWithPhoneNumber:phoneNumber Password:password];
        } else {
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }];
}

/**
 *  接收验证码
 */
- (void)getRegistVerifyCode:(NSString *)phone
{
    //发送请求数据
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"phone"] = phone;
    NSString *urlStr = [HOST stringByAppendingString:@"api.php?m=open&c=account&a=regsms"];
    [self.manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"status"] == [NSNumber numberWithInteger:1]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GETCODE_SUCCEED" object:nil];
        } else {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络不给力哦!"];
    }];
}


/**
 *  获取用户注册的sign
 */
- (NSString *)getRegisterAccountSignWithPhoneNumber:(NSString *)phoneNumber NickName:(NSString *)nickName Password:(NSString *)password Timestamp:(NSString *)timestamp
{
    NSString *sign = [[[[phoneNumber stringByAppendingString:nickName] stringByAppendingString:password] stringByAppendingString:timestamp] stringByAppendingString:APPKEY];
    NSString *signMd5 = [self md5:sign];
    return signMd5;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

@end
