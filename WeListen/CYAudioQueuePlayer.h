//
//  CYAudioQueuePlayer.h
//  CYAudioQueuePlayer
//
//  Created by Lancy on 4/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
@import AVFoundation;
@import AudioToolbox;

@class CYAudioQueuePlayer;

@protocol CYAudioQueuePlayerDelegate <NSObject>
@optional
- (void)player:(CYAudioQueuePlayer *)player didStopPlayingWithFinishedFlag:(BOOL)isFinishedPlaying;

@end

@interface CYAudioQueuePlayer : NSObject

@property (nonatomic, weak) id<CYAudioQueuePlayerDelegate> delegate;

- (void)setupQueueWithAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription;
- (void)enqueuePacketData:(NSData *)packetData;

- (BOOL)isPlaying;
- (void)startQueue;
- (void)stopQueue;
- (void)pauseQueue;

@end
