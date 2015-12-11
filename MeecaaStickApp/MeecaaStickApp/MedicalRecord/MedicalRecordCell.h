//
//  MedicalRecordCell.h
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/28.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicalRecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *symptonLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@end
