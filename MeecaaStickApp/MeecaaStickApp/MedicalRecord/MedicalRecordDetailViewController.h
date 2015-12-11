//
//  MedicalRecordDetailViewController.h
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/29.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MedicalRecordViewController.h"
@interface MedicalRecordDetailViewController : UIViewController
@property (nonatomic,strong) MedicalRecordViewController *medicalRecordVc;
@property (nonatomic,copy) NSString *desc;
@property (nonatomic,strong) NSMutableArray *picsArray;
@end
