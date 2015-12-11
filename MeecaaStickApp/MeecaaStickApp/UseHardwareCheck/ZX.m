//
//  ZX.m
//  CaiFuBB
//
//  Created by sigboat on 14-8-25.
//  Copyright (c) 2014年 曾祥. All rights reserved.
//

#import "ZX.h"
//颜色及图片获取
#define GETColor(r, g, b,a)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define GraphColor [[UIColor whiteColor] colorWithAlphaComponent:0.5]
#define str(index) [NSString stringWithFormat : @"%.1f", [[self.array objectAtIndex:(index)] floatValue]]
#define point(x, y) CGPointMake((x) * kXScale+50, yOffset - (y) * kYScale)

@interface ZX()
{
    CALayer *linesLayer;
    UIView *popView;
    UILabel *disLabel;
}

@end


@implementation ZX

@synthesize array;

@synthesize hInterval,vInterval;

@synthesize hDesc,vDesc;

const CGFloat   kXScale = 40.0;//X轴点间距
const CGFloat   kYScale = 4.0;//Y轴纵向拉伸比例

static inline CGAffineTransform
CGAffineTransformMakeScaleTranslate(CGFloat sx, CGFloat sy,
                                    CGFloat dx, CGFloat dy)
{
    return CGAffineTransformMake(sx, 0.f, 0.f, sy, dx, dy);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        hInterval = 10;
        vInterval = 40;
        
        NSMutableArray *vArr = [NSMutableArray array];

        [vArr addObject:@"00.0℃"];
        [vArr addObject:@"10.0℃"];
        [vArr addObject:@"20.0℃"];
        [vArr addObject:@"30.0℃"];
        [vArr addObject:@"40.0℃"];
        [vArr addObject:@"39.0℃"];
        [vArr addObject:@"40.0℃"];
        int y = 210;
        for (int i=0; i<5; i++) {
            CGPoint bPoint = CGPointMake(50, y);
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 50, 30)];
            label.textColor = NAVIGATIONBAR_BACKGROUND_COLOR;
            [label setBackgroundColor:[UIColor clearColor]];
            [label setCenter:CGPointMake(bPoint.x-15, bPoint.y-20)];
            [label setTextAlignment:NSTextAlignmentLeft];
            label.font=[UIFont systemFontOfSize:12];
            [label setText:[vArr objectAtIndex:i]];
            [self addSubview:label];
            y -= 40;
        }

        NSString*filePath=[[NSBundle mainBundle] pathForResource:@"TemperatureRecord" ofType:@"plist"];
        NSDictionary *dic=[[NSDictionary alloc] initWithContentsOfFile:filePath];
        NSArray *arrayL=[[dic allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *hArr=[NSMutableArray array];
        for (NSString *str in arrayL) {
            [hArr addObject:dic[str]];
        }
        for (int i=0; i<hArr.count; i++) {
            
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(i*vInterval+50, 190, 40, 30)];
            [label setBackgroundColor:[UIColor clearColor]];
            label.textColor = NAVIGATIONBAR_BACKGROUND_COLOR;
            [label setTextAlignment:NSTextAlignmentLeft];
            label.numberOfLines = 1;
            label.font=[UIFont systemFontOfSize:12];
            [label setText:[hArr objectAtIndex:i]];
            [self addSubview:label];
        }

        
    }
    return self;
}
#define ZeroPoint CGPointMake(30,230)


- (void)drawRect:(CGRect)rect
{
    [self setClearsContextBeforeDrawing: YES];
 
       
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    int x = 2000;
    int y = 210;
    
    for (int i=0; i<5; i++) {
        CGPoint bPoint = CGPointMake(50, y);
        CGPoint ePoint = CGPointMake(x, y);
//        CGFloat lengths[] = {5,5};
//        CGContextSetLineDash(context, 0, lengths,2);
        CGContextSetStrokeColorWithColor(context, NAVIGATIONBAR_BACKGROUND_COLOR.CGColor);
        CGContextSetLineWidth(context, 0.4);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineCap(context, kCGLineCapRound );
        CGContextMoveToPoint(context, bPoint.x, bPoint.y-20);
        CGContextAddLineToPoint(context, ePoint.x, ePoint.y-20);
        y -= 40;
    }
    CGContextStrokePath(context);
    
//    CGContextSetLineJoin(context, kCGLineJoinRound);
//    CGContextSetLineCap(context, kCGLineCapRound );
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    
//    CGContextSetStrokeColorWithColor(context, GETColor(230, 73, 51, 1).CGColor);
//    CGContextSetLineWidth(context, 2);
	//绘图
    
//    CGFloat lengths[] = {5,0};
//    CGContextSetLineDash(context, 0, lengths,2);
//    
//    if (array.count!=0) {
//        CGPoint p1 = [[array objectAtIndex:0] CGPointValue];
//        int i = 1;
//        CGContextMoveToPoint(context, 40*p1.x+50, 190-(p1.y-34)*30);
//        for (; i<[array count]; i++)
//        {
//            p1 = [[array objectAtIndex:i] CGPointValue];
//            CGPoint goPoint = CGPointMake(40*p1.x+50, 190-(p1.y-34)*30);
//      		CGContextAddLineToPoint(context, goPoint.x, goPoint.y);
//        }
//        CGContextStrokePath(context);
//    }
    
    
    
    if (array.count == 0) {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx,
                                     [UIColor redColor].CGColor);
    
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetLineWidth(ctx, 2.5);
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat yOffset = self.bounds.size.height / 2+75;
    CGAffineTransform transform = CGAffineTransformMakeScaleTranslate(kXScale, kYScale,60, yOffset);

    CGFloat yValue = [[self.array objectAtIndex:0] floatValue];
    CGPathMoveToPoint(path, &transform, 0, -yValue);
    
    for (NSUInteger x = 0; x < [self.array count]; ++x) {
        yValue = [[self.array objectAtIndex:x] floatValue];
        CGPathAddLineToPoint(path, &transform, x, -yValue);
        [self drawAtPoint:point(x, yValue) withStr:str(x)];
    }
    
    CGContextAddPath(ctx, path);
    CGPathRelease(path);
    CGContextStrokePath(ctx);
}

- (void)drawAtPoint:(CGPoint)point withStr:(NSString *)str
{
    
//    [str drawAtPoint:point withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSStrokeColorAttributeName:[UIColor whiteColor]}];
    [str drawInRect:CGRectMake(point.x, point.y, 30, 20) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:NAVIGATIONBAR_BACKGROUND_COLOR}];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
