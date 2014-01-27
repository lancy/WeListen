//
//  WLPlayerAgent.m
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLPlayerAgent.h"

@implementation WLPlayerAgent

+ (WLPlayerAgent *)sharedAgent {
    static dispatch_once_t pred = 0;
    static id _sharedAgent = nil;
    dispatch_once(&pred, ^{
        _sharedAgent = [[WLPlayerAgent alloc] init];
    });
    return _sharedAgent;
}

@end
