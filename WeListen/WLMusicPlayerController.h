//
//  WLMusicPlayerController.h
//  WeListen
//
//  Created by Lancy on 9/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLMediaItem.h"
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
    WLMusicShuffleModeSongs,
    WLMusicShuffleModeAlbums
};

@interface WLMusicPlayerController : NSObject

+ (WLMusicPlayerController *)sharedPlayer;

@property (nonatomic, readonly) WLMusicPlaybackState playbackState;
@property (nonatomic) WLMusicRepeatMode repeatMode;
@property (nonatomic) WLMusicShuffleMode shuffleMode;

@property (strong, nonatomic) WLMediaItem *nowPlayingItem;
@property (nonatomic, readonly) NSUInteger indexOfNowPlayingItem;
@property (strong, nonatomic) NSArray *mediaQueue;

@property (nonatomic) NSTimeInterval currentPlaybackTime;

- (void)play;
- (void)pause;
- (void)stop;

- (void)skipToNextItem;
- (void)skipToBeginning;
- (void)skipToPreviousItem;

@end
