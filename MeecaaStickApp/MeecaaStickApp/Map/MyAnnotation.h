//
//  MyAnnotation.h
//  HomeKinsa
//
//  Created by Zhang guangchun on 15/5/7.
//  Copyright (c) 2015年 Mikai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>



@interface MyAnnotation : NSObject <MKAnnotation>
//显示标注的经纬度
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
//标注的标题
@property (nonatomic,copy,readonly) NSString * title;
//标注的子标题
@property (nonatomic,copy,readonly) NSString * subtitle;

-(id)initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle subTitle:(NSString *)paramTitle;

@end
