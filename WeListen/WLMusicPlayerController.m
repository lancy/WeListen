//
//  WLMusicPlayerController.m
//  WeListen
//
//  Created by Lancy on 9/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLMusicPlayerController.h"
#import "CYAudioSessionManager.h"
@interface WLMusicPlayerController () <CYAudioStreamerDelegate, CYAudioQueuePlayerDelegate>

@property (nonatomic) WLMusicPlaybackState playbackState;
@property (strong, nonatomic) CYAudioSessionManager *audioSessionManager;

@property (strong, nonatomic) NSArray *shuffledMediaQueue;

@end

@implementation WLMusicPlayerController

+ (WLMusicPlayerController *)sharedPlayer {
    static dispatch_once_t pred = 0;
    static WLMusicPlayerController *_sharedPlayer = nil;
    dispatch_once(&pred, ^{
        _sharedPlayer = [[WLMusicPlayerController alloc] init];
        [_sharedPlayer setupAudioSessionManager];
    });
    return _sharedPlayer;
}


- (void)setupAudioSessionManager {
    self.audioSessionManager = [[CYAudioSessionManager alloc] init];
}

- (void)setNowPlayingItem:(MPMediaItem *)nowPlayingItem {
    _nowPlayingItem = nowPlayingItem;
    if (_nowPlayingItem) {
        [self cleanup];
        [self startStreaming];
    }
}

- (void)setMediaQueue:(NSArray *)mediaQueue {
    _mediaQueue = mediaQueue;
    if (_mediaQueue) {
        self.shuffledMediaQueue = _mediaQueue.shuffledArray;
    }
}

- (NSUInteger)indexOfNowPlayingItem {
    return [self.mediaQueue indexOfObject:self.nowPlayingItem];
}

- (void)cleanup {
    [self.audioQueuePlayer stopQueue];
    [self.audioQueuePlayer disposeQueue];
    [self.audioStreamer cancleStreaming];
}

- (void)startStreaming {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[self.nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL]];
    self.audioStreamer = [[CYAudioStreamer alloc] initWithUrlAsset:asset delegate:self];
    
    AudioStreamBasicDescription audioStreamBasicDescription = [self.audioStreamer audioStreamBasicDescription];
    [self setupAudioQueuePlayerWithASDB:audioStreamBasicDescription];
    
    [self.audioStreamer startStreaming];
}

- (void)setupAudioQueuePlayerWithASDB:(AudioStreamBasicDescription)asdb {
    self.audioQueuePlayer = [[CYAudioQueuePlayer alloc] init];
    self.audioQueuePlayer.delegate = self;
    [self.audioQueuePlayer setupQueueWithAudioStreamBasicDescription:asdb];
}

#pragma mark - Player Controller

- (void)play {
    self.playbackState = WLMusicPlaybackStatePlaying;
    [self.audioQueuePlayer startQueue];
}

- (void)pause {
    self.playbackState = WLMusicPlaybackStatePaused;
    [self.audioQueuePlayer pauseQueue];
}

- (void)stop {
    self.playbackState = WLMusicPlaybackStateStopped;
    [self.audioQueuePlayer stopQueue];
}

- (void)skipToNextItem {
    [self skipToItemWithOffset:+1];
}

- (void)skipToBeginning {
    [self.audioQueuePlayer resetQueue];
    [self play];
}

- (void)skipToPreviousItem {
    [self skipToItemWithOffset:-1];
}

- (void)skipToItemWithOffset:(NSInteger)offset {
    if (self.repeatMode == WLMusicRepeatModeOne) {
        [self.audioQueuePlayer resetQueue];
        [self play];
    } else {
        NSArray *useQueue = (self.shuffleMode == WLMusicShuffleModeOff) ? self.mediaQueue : self.shuffledMediaQueue;
        NSInteger currentIndex = [useQueue indexOfObject:self.nowPlayingItem];
        NSInteger nextIndex = currentIndex + offset;
        if (nextIndex < 0) {
            if (self.repeatMode == WLMusicRepeatModeAll) {
                self.nowPlayingItem = useQueue.lastObject;
                [self play];
            }
        } else if (nextIndex < useQueue.count) {
            self.nowPlayingItem = useQueue[currentIndex + offset];
            [self play];
        } else if (nextIndex >= useQueue.count) {
            if (self.repeatMode == WLMusicRepeatModeAll) {
                self.nowPlayingItem = useQueue.firstObject;
                [self play];
            } else {
                [self.audioQueuePlayer resetQueue];
                [self pause];
            }
        }
    }
}

#pragma mark - Audio Streamer Callback Methods
- (void)streamer:(CYAudioStreamer *)streamer didGetPacketData:(NSData *)packetData {
    [self.audioQueuePlayer enqueuePacketData:packetData];
}

#pragma mark - Audio QueuePlayer Callback Methods 
- (void)player:(CYAudioQueuePlayer *)player didStopPlayingWithFinishedFlag:(BOOL)isFinishedPlaying {
    if (isFinishedPlaying) {
        [self skipToNextItem];
    }
}

@end
