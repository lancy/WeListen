//
//  CYAudioStreamer.h
//  CYAudioQueuePlayer
//
//  Created by Lancy on 4/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MediaPlayer;
@import AVFoundation;
@import AudioToolbox;

@class CYAudioStreamer;

@protocol CYAudioStreamerDelegate <NSObject>
@optional
- (void)streamer:(CYAudioStreamer *)streamer didGetPacketData:(NSData *)packetData;
- (void)streamerDidFinishedStreaming:(CYAudioStreamer *)streamer;

@end

@interface CYAudioStreamer : NSObject

@property (nonatomic, weak) id<CYAudioStreamerDelegate> delegate;
@property (nonatomic, readonly) AudioStreamBasicDescription audioStreamBasicDescription;
@property (strong, nonatomic, readonly) NSArray *packets;

- (id)initWithUrlAsset:(AVURLAsset *)urlAsset delegate:(id<CYAudioStreamerDelegate>)delegate;

- (void)startStreaming;
- (void)cancleStreaming;

@end
