//
//  TestDecoder.h
//  HomeKinsa
//
//  Created by SoulJa on 15/10/23.
//  Copyright © 2015年 Mikai. All rights reserved.
//  岳海啸解码库版本 0.1

#import <Foundation/Foundation.h>


@interface TestDecoder : NSObject
+ (id)sharedTestDecoder;
+ (TestDecoder *)testDecoder;
- (NSMutableDictionary *)TestDecoderWithPath:(NSString *)path;
@end
