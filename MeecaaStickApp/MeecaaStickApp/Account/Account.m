//
//  Account.m
//  HomeKinsa
//
//  Created by SoulJa on 15/11/16.
//  Copyright © 2015年 Mikai. All rights reserved.
//

#import "Account.h"

@implementation Account
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.telephone forKey:@"telephone"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.openID forKey:@"openID"];
    [aCoder encodeInt:self.platForm forKey:@"platForm"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.telephone = [aDecoder decodeObjectForKey:@"telephone"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.openID = [aDecoder decodeObjectForKey:@"openID"];
        self.platForm = [aDecoder decodeIntForKey:@"platForm"];
    }
    return self;
}
@end
