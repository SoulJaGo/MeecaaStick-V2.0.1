//
//  ZX.h
//  CaiFuBB
//
//  Created by sigboat on 14-8-25.
//  Copyright (c) 2014年 曾祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ZX : UIView


//横竖轴距离间隔
@property (assign) NSInteger hInterval;
@property (assign) NSInteger vInterval;

//横竖轴显示标签
@property (nonatomic, strong) NSArray *hDesc;
@property (nonatomic, strong) NSArray *vDesc;

//点信息
@property (nonatomic, strong) NSMutableArray *array;

@end
