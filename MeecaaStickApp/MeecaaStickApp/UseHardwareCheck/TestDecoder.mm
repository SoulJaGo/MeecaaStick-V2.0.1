//
//  TestDecoder.m
//  HomeKinsa
//
//  Created by SoulJa on 15/10/23.
//  Copyright © 2015年 Mikai. All rights reserved.
//

#import "TestDecoder.h"
#import "decoder.hpp"
#import "decoder_def.h"

@implementation TestDecoder
- (instancetype)init
{
    self = [super init];
    return self;
}

+ (id)sharedTestDecoder
{
    static TestDecoder *sharedTestDecoder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedTestDecoder == nil) {
            sharedTestDecoder = [[self alloc] init];
        }
    });
    return sharedTestDecoder;
}

+ (TestDecoder *)testDecoder
{
    return [[self alloc] init];
}

- (NSMutableDictionary *)TestDecoderWithPath:(NSString *)path
{
    int rawFileLength;
    int recordBufSize;
    
    char* debugBuf;
    INT16* recordBuf;
    INT16 temperature;
    
    
    debugBuf = new char[16];
    
    NSData *myData = [[NSData alloc] initWithContentsOfFile:path];
    
    //NSLog(@"myData,length=%lu",  (unsigned long)[myData length]);
    
    Byte* bytes = (Byte *)[myData bytes];
    
    
    rawFileLength = (int)[myData length];
    
    
    // for 16bits, size is half of length, which unit is byte
    recordBufSize = rawFileLength / 2;
    recordBuf = new INT16[recordBufSize];
    
    char str[16];
    
    Decoder* micDecoder = new Decoder(recordBufSize, 44100, 16);
    // Decoder* micDecoder = new Decoder(sizeof(bytes)/2, 44100, 4);
    
    INT32 returnINT=999;
    
    returnINT= micDecoder->Decode(  (INT16 *)bytes, &temperature, str);
    
    printf("%s", debugBuf);
    
    SAFE_DELETE_ARRAY(debugBuf)
    SAFE_DELETE_ARRAY(recordBuf)
    SAFE_DELETE(micDecoder)
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"returnINT"] = [NSNumber numberWithInt:returnINT];
    dict[@"temperature"] = [NSNumber numberWithLong:temperature];
//    NSString *debugBufStr = [NSString stringWithCString:debugBuf encoding:NSUTF8StringEncoding];
//    if (debugBufStr == nil) {
//        debugBufStr = @"";
//    }
//    dict[@"debugBuf"] = debugBufStr;
    return dict;
}




@end
