//
//  TimeLabelCell.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/11/30.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "TimeLabelCell.h"

@implementation TimeLabelCell

- (void)awakeFromNib {
    // Initialization code
    if (self.isFromUpdateVC == NO) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *timeStr = [formatter stringFromDate:[NSDate date]];
        
        self.timeLabel.text = timeStr;
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
