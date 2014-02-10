//
//  WLMusicPlayerController.h
//  WeListen
//
//  Created by Lancy on 9/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLMediaItem.h"
#import "CYAudioStreamer.h"
#import "WLConnectionCenter.h"
#import "CYAudioQueuePlayer.h"
@import MediaPlayer;

typedef NS_ENUM(NSInteger, WLMusicPlaybackState) {
    WLMusicPlaybackStateStopped,
    WLMusicPlaybackStatePlaying,
    WLMusicPlaybackStatePaused,
    WLMusicPlaybackStateInterrupted,
    WLMusicPlaybackStateSeekingForward,
    WLMusicPlaybackStateSeekingBackward
};

typedef NS_ENUM(NSInteger, WLMusicRepeatMode) {
    WLMusicRepeatModeNone,
    WLMusicRepeatModeOne,
    WLMusicRepeatModeAll
};


typedef NS_ENUM(NSInteger, WLMusicShuffleMode) {
    WLMusicShuffleModeOff,
    WLMusicShuffleModeOn
};

typedef NS_ENUM(NSInteger, WLConnectionMode) {
    WLConnectionModePublisher,
    WLConnectionModeSubscriber
};

@interface WLMusicPlayerController : NSObject

+ (WLMusicPlayerController *)sharedPlayer;

@property (strong, nonatomic, readonly) WLConnectionCenter *connectionCenter;
@property (nonatomic, readonly) WLConnectionMode connectionMode;
@property (strong, nonatomic) CYAudioQueuePlayer *audioQueuePlayer;
@property (strong, nonatomic) CYAudioStreamer *audioStreamer;

@property (nonatomic, readonly) WLMusicPlaybackState playbackState;
@property (nonatomic) WLMusicRepeatMode repeatMode;
@property (nonatomic) WLMusicShuffleMode shuffleMode;

// use as publisher
@property (strong, nonatomic) MPMediaItem *nowPlayingItem;
@property (nonatomic, readonly) NSUInteger indexOfNowPlayingItem;
@property (strong, nonatomic) NSArray *mediaQueue;

// use as subscriber
@property (strong, nonatomic) WLMediaItem *subscribedItem;

@property (nonatomic) NSTimeInterval currentPlaybackTime;

- (void)play;
- (void)pause;
- (void)stop;

- (void)skipToNextItem;
- (void)skipToBeginning;
- (void)skipToPreviousItem;

@end
