//
//  WLMusicPlayerController.m
//  WeListen
//
//  Created by Lancy on 9/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLMusicPlayerController.h"

@implementation WLMusicPlayerController

+ (WLMusicPlayerController *)sharedPlayer {
    static dispatch_once_t pred = 0;
    static id _sharedPlayer = nil;
    dispatch_once(&pred, ^{
        _sharedPlayer = [[WLMusicPlayerController alloc] init];
    });
    return _sharedPlayer;
}
@end
