//
//  MyAnnotation.m
//  HomeKinsa
//
//  Created by Zhang guangchun on 15/5/7.
//  Copyright (c) 2015年 Mikai. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle
                subTitle:(NSString *)paramSubitle
{
    self = [super init];
    if(self != nil)
    {
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubitle;
    }
    return self;
}

@end