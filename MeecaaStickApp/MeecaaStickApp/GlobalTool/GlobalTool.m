//
//  GlobalTool.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/19.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "GlobalTool.h"
#import "sys/utsname.h"

@implementation GlobalTool
/**
 *  单例模式
 */
+ (id)shared {
    static GlobalTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedInstance == nil) {
            sharedInstance = [[GlobalTool alloc] init];
        }
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

/**
 *  color转image
 */
- (UIImage*)createImageWithColor: (UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

/**
 *  判断设备型号
 */
- ( NSString *)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [ NSString stringWithCString:systemInfo.machine encoding: NSUTF8StringEncoding ];
    
    if ([deviceString isEqualToString:@ "iPhone1,1" ])     return @ "iPhone 1G" ;
    if ([deviceString isEqualToString:@ "iPhone1,2" ])     return @ "iPhone 3G" ;
    if ([deviceString isEqualToString:@ "iPhone2,1" ])     return @ "iPhone 3GS" ;
    if ([deviceString isEqualToString:@ "iPhone3,1" ])     return @ "iPhone 4" ;
    if ([deviceString isEqualToString:@ "iPhone4,1" ])     return @ "iPhone 4S" ;
    if ([deviceString isEqualToString:@ "iPhone5,2" ])     return @ "iPhone 5" ;
    if ([deviceString isEqualToString:@ "iPhone5,3" ])     return @ "iPhone 5C" ;
    if ([deviceString isEqualToString:@ "iPhone6,2" ])     return @ "iPhone 5S" ;
    if ([deviceString isEqualToString:@ "iPhone7,1" ])     return @ "iPhone 6 Plus" ;
    if ([deviceString isEqualToString:@ "iPhone7,2" ])     return @ "iPhone 6" ;
    if ([deviceString isEqualToString:@ "iPhone8,1" ])     return @ "iPhone 6S" ;
    if ([deviceString isEqualToString:@ "iPhone8,2" ])     return @ "iPhone 6S Plus" ;
    if ([deviceString isEqualToString:@ "iPhone3,2" ])     return @ "Verizon iPhone 4" ;
    if ([deviceString isEqualToString:@ "iPod1,1" ])       return @ "iPod Touch 1G" ;
    if ([deviceString isEqualToString:@ "iPod2,1" ])       return @ "iPod Touch 2G" ;
    if ([deviceString isEqualToString:@ "iPod3,1" ])       return @ "iPod Touch 3G" ;
    if ([deviceString isEqualToString:@ "iPod4,1" ])       return @ "iPod Touch 4G" ;
    if ([deviceString isEqualToString:@ "iPad1,1" ])       return @ "iPad" ;
    if ([deviceString isEqualToString:@ "iPad2,1" ])       return @ "iPad 2 (WiFi)" ;
    if ([deviceString isEqualToString:@ "iPad2,2" ])       return @ "iPad 2 (GSM)" ;
    if ([deviceString isEqualToString:@ "iPad2,3" ])       return @ "iPad 2 (CDMA)" ;
    if ([deviceString isEqualToString:@ "iPad4,4" ])       return @ "iPad Mini" ;
    if ([deviceString isEqualToString:@ "i386" ])         return @ "Simulator" ;
    if ([deviceString isEqualToString:@ "x86_64" ])       return @ "Simulator" ;
    NSLog (@ "NOTE: Unknown device type: %@" , deviceString);
    return deviceString;
}

/**
 *  获取手机上的UUID
 */
- (NSString *)PhoneUUID {
    if (_PhoneUUID == nil) {
        _PhoneUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return _PhoneUUID;
}

/**
 *  获取程序版本号
 */
- (NSString *)Version {
    if (_Version == nil) {
        _Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return _Version;
}

/**
 *  手机号码验证
 */
- (BOOL) isMobileNumberClassification:(NSString *)phoneNum{
    if (phoneNum.length==11&&[[phoneNum substringToIndex:1] isEqualToString:@"1"]) {
        return YES;
    }
    return NO;
    
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188,1705
     * 联通：130,131,132,152,155,156,185,186,1709
     * 电信：133,1349,153,180,189,1700
     */
    //    NSString * MOBILE = @"^1((3//d|5[0-35-9]|8[025-9])//d|70[059])\\d{7}$";//总况
    
    /**®
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188，1705
     12         */
    //    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d|705)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186,1709
     17         */
    //    NSString * CU = @"^1((3[0-2]|5[256]|8[56])\\d|709)\\d{7}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189,1700
     22         */
    //    NSString * CT = @"^1((33|53|8[09])\\d|349|700)\\d{7}$";
    
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    //    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    /*
     //    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
     NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
     NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
     NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
     NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHS];
     
     if (([regextestcm evaluateWithObject:phoneNum] == YES)
     || ([regextestct evaluateWithObject:phoneNum] == YES)
     || ([regextestcu evaluateWithObject:phoneNum] == YES)
     || ([regextestphs evaluateWithObject:phoneNum] == YES))
     {
     return YES;
     }
     else
     {
     return NO;
     }*/
}

- (NSArray *)getFlagInIntergerPosition:(NSNumber *)value{
    NSString *str = [self toBinarySystemWithDecimalSystem:[NSString stringWithFormat:@"%@",value]];
    NSMutableArray *positions = [NSMutableArray array];
    for (int i=0; i<str.length; i++) {
        NSString *tmp = [str substringWithRange:NSMakeRange(i, 1)];
        if ([tmp isEqualToString:@"1"]) {
            [positions addObject:[NSNumber numberWithInt:((int)str.length-i-1)]];
        }
    }
    return positions;
}

- (NSString *)toBinarySystemWithDecimalSystem:(NSString *)decimal
{
    int num = [decimal intValue];
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    NSString * result = @"";
    for (int i = (int)prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    
    return result;
}


- (NSString *)getSymptonNameByTag:(NSNumber *)tag{
    for (int i=0; i<self.symptonTemplateList.count; i++) {
        NSDictionary *symptonTemplate = [self.symptonTemplateList objectAtIndex:i];
        NSNumber *symptonTag = [symptonTemplate objectForKey:@"tag"];
        if ([symptonTag intValue]==[tag intValue]) {
            return [symptonTemplate objectForKey:@"name"];
        }
    }
    return @"";
}

- (NSArray *)symptonTemplateList {
    return  @[
                                 @{
                                     @"tag":@1, @"name":@"咽痛",
                                     },
                                 @{
                                     @"tag":@2, @"name":@"咳嗽",
                                     },
                                 @{
                                     @"tag":@3, @"name":@"流涕",
                                     },
                                 @{
                                     @"tag":@4, @"name":@"气短",
                                     },
                                 @{
                                     @"tag":@5, @"name":@"腹痛",
                                     },
                                 @{
                                     @"tag":@6, @"name":@"腹泻",
                                     },
                                 @{
                                     @"tag":@7, @"name":@"呕吐",
                                     },
                                 @{
                                     @"tag":@8, @"name":@"乏力",
                                     },
                                 @{
                                     @"tag":@9, @"name":@"头痛",
                                     },
                                 @{
                                     @"tag":@10, @"name":@"耳痛",
                                     },
                                 @{
                                     @"tag":@11, @"name":@"体痛",
                                     },
                                 @{
                                     @"tag":@12, @"name":@"寒战",
                                     },
                                 @{
                                     @"tag":@13, @"name":@"关节痛",
                                     },
                                 @{
                                     @"tag":@14, @"name":@"尿痛",
                                     },
                                 @{
                                     @"tag":@15, @"name":@"一般不适",
                                     }
                                 ];
}

- (BOOL)isAllowedNotification {
         //iOS8 check if user allow notification
        if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {// system is iOS8
                 UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
                 if (UIUserNotificationTypeNone != setting.types) {
                         return YES;
                }
             } else {//iOS7
                 UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
                 if(UIRemoteNotificationTypeNone != type)
                         return YES;
            }
    
         return NO;
}

- (BOOL)isHaveIllegalChar:(NSString *)str{
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%-*+=_）\\|~(＜＞$%^&*)_+ "];
    NSRange range = [str rangeOfCharacterFromSet:doNotWant];
    return range.location<str.length;
}
@end
