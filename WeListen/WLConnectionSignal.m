//
//  WLConnectionSignal.m
//  WeListen
//
//  Created by Lancy on 10/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLConnectionSignal.h"

@implementation WLConnectionSignal

+ (WLConnectionSignal *)signalWithType:(WLConnectionSignalType)type {
    return [self signalWithType:type payload:nil];
}

+ (WLConnectionSignal *)signalWithType:(WLConnectionSignalType)type payload:(id)payload {
    WLConnectionSignal *signal = [[WLConnectionSignal alloc] init];
    signal.type = type;
    signal.payload = payload;
    return signal;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.payload = [aDecoder decodeObjectForKey:@"payload"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:self.payload forKey:@"payload"];
}

@end
