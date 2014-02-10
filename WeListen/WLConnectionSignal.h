//
//  WLConnectionSignal.h
//  WeListen
//
//  Created by Lancy on 10/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLConnectionSignalType) {
    WLConnectionSignalTypeDataMediaItem = 0,
    WLConnectionSignalTypeDataAudioPacket,
    
    WLConnectionSignalTypeControlPlay,
    WLConnectionSignalTypeControlPause,
    WLConnectionSignalTypeControlSkipToNext,
    WLConnectionSignalTypeControlSkipToPrevious,
    WLConnectionSignalTypeControlSkipToBeginning,
    
    WLConnectionSignalTypeRepeatNone,
    WLConnectionSignalTypeRepeatOne,
    WLConnectionSignalTypeRepeatAll,
    
    WLConnectionSignalTypeShuffleOff,
    WLConnectionSignalTypeShuffleOn
};


@interface WLConnectionSignal : NSObject <NSCoding>

@property (nonatomic) WLConnectionSignalType type;
@property (strong, nonatomic) id payload;

+ (WLConnectionSignal *)signalWithType:(WLConnectionSignalType)type;
+ (WLConnectionSignal *)signalWithType:(WLConnectionSignalType)type payload:(id)payload;

@end
