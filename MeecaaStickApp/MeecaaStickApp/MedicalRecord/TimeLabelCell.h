//
//  TimeLabelCell.h
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/30.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMedicalRecordViewController.h"

@interface TimeLabelCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic,assign)BOOL isFromUpdateVC;
@property (nonatomic,strong) AddMedicalRecordViewController *addMedicalRecordVc;
@end
