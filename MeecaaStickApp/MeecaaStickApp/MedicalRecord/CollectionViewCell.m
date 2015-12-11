//
//  CollectionViewCell.m
//  MeecaaStickApp
//
//  Created by SoulJa on 15/12/1.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [imageView setBackgroundColor:[UIColor redColor]];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        delBtn.frame = CGRectMake(40, 40, 20, 20);
        [delBtn setBackgroundImage:[UIImage imageNamed:@"medical_del_icon"] forState:UIControlStateNormal];
        [self addSubview:delBtn];
        self.delBtn = delBtn;
    }
    return self;
}
@end
