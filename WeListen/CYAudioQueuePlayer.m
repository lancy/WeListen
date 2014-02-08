//
//  CYAudioQueuePlayer.m
//  CYAudioQueuePlayer
//
//  Created by Lancy on 4/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "CYAudioQueuePlayer.h"

static const NSUInteger kNumberOfPlaybackBuffers = 16;
static const UInt32 kBufferByteSize = 2048;

typedef enum {
    AudioQueuePlayerStateInitalized = 0,
    AudioQueuePlayerStatePause,
    AudioQueuePlayerStateBuffering,
    AudioQueuePlayerStatePlaying,
    AudioQueuePlayerStateStopped
} AudioQueuePlayerState;

@interface CYAudioQueuePlayer()

@property (strong, nonatomic) NSMutableArray *packetDatas;
@property (nonatomic) NSUInteger currentEnqueuePacketIndex;

@end

@implementation CYAudioQueuePlayer {
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioQueueBuffers[kNumberOfPlaybackBuffers];
    
    BOOL _inuseBufferFlags[kNumberOfPlaybackBuffers];
    NSUInteger _currentFillingBufferIndex;
    
    pthread_mutex_t _queueBufferInuseMutex;
    pthread_cond_t _queueBufferReadyCondition;
    
    NSUInteger _buffersUsed;
    
    AudioQueuePlayerState _playerState;
    
    OSStatus _errStatus;
    
    dispatch_queue_t _packetEnqueueQueue;
}

- (void)setupQueueWithAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    _packetEnqueueQueue = dispatch_queue_create("com.gracelancy.CYAudioQueuePlayer.enqueuePacket", NULL);
    self.packetDatas = [[NSMutableArray alloc] init];
    self.currentEnqueuePacketIndex = 0;
    _currentFillingBufferIndex = 0;
    
    pthread_mutex_init(&_queueBufferInuseMutex, NULL);
    pthread_cond_init(&_queueBufferReadyCondition, NULL);
    
    _playerState = AudioQueuePlayerStateInitalized;
    
    AudioStreamBasicDescription asbd = audioStreamBasicDescription;
    CheckError(AudioQueueNewOutput(&asbd, // ASBD
                                   audioQueueOutputCallback, // Callback
                                   (__bridge void *)self, // user data
                                   NULL, // run loop
                                   NULL, // run loop mode
                                   0, // flags (always 0)
                                   &_audioQueue), // output: reference to AudioQueue object
               "AudioQueueNewOutput failed");
    
    for (NSUInteger i = 0; i < kNumberOfPlaybackBuffers; ++i) {
        CheckError(AudioQueueAllocateBuffer(_audioQueue, kBufferByteSize, &_audioQueueBuffers[i]), "AudioQueueAllocateBuffer failed");
    }
    AudioQueueAddPropertyListener(_audioQueue, kAudioQueueProperty_IsRunning, audioQueueFinishedPlayingCallback, (__bridge void *)self);
}

- (void)dealloc {
    for (NSUInteger i = 0; i < kNumberOfPlaybackBuffers; ++i) {
        free(_audioQueueBuffers[i]);
    }
    pthread_mutex_destroy(&_queueBufferInuseMutex);
    pthread_cond_destroy(&_queueBufferReadyCondition);
}

#pragma mark - Audio Queue Control

- (BOOL)isPlaying
{
    if (_playerState == AudioQueuePlayerStatePlaying) {
        return YES;
    } else {
        return NO;
    }
}

- (void)startQueue;
{
    _playerState = AudioQueuePlayerStatePlaying;
    CheckError(AudioQueueStart(_audioQueue, NULL), "Audio Queue Start Error");
}


- (void)pauseQueue
{
    _playerState = AudioQueuePlayerStatePause;
    AudioQueuePause(_audioQueue);
}

- (void)stopQueue
{
    _playerState = AudioQueuePlayerStateStopped;
    AudioQueueStop(_audioQueue, TRUE);
}

- (void)disposeQueue
{
    AudioQueueDispose(_audioQueue, TRUE);
}

- (void)enqueuePacketData:(NSData *)packetData {
    [self.packetDatas addObject:packetData];
    dispatch_sync(_packetEnqueueQueue, ^{
        [self enqueueBuffer];
    });
}


#pragma mark -  Audio Queue Output Callback

- (void)enqueueBuffer {
    @synchronized(self) {
        if (self.currentEnqueuePacketIndex >= self.packetDatas.count) {
            return;
        }
        NSData *packetData = self.packetDatas[self.currentEnqueuePacketIndex];
        self.currentEnqueuePacketIndex++;
        UInt32 packetSize = (UInt32)[packetData length];
        void *packetDataPtr = malloc(packetSize);
        [packetData getBytes:packetDataPtr length:packetSize];
        
        AudioQueueBufferRef currentFillingBuffer = _audioQueueBuffers[_currentFillingBufferIndex];
        memcpy((char *)currentFillingBuffer->mAudioData,
               (const char *)(packetDataPtr), packetSize);
        free(packetDataPtr);
        
        
        AudioStreamPacketDescription packetDescs[1];
        packetDescs[0].mDataByteSize = packetSize;
        packetDescs[0].mStartOffset = 0;
        
        _inuseBufferFlags[_currentFillingBufferIndex] = YES;
        _buffersUsed++;
        
        //enqueue buffer
        currentFillingBuffer->mAudioDataByteSize = packetSize;
        currentFillingBuffer->mPacketDescriptionCount = 1;
        _errStatus = AudioQueueEnqueueBuffer(_audioQueue, currentFillingBuffer, 1, packetDescs);
        if (_errStatus) {
            NSLog(@"could not enqueue queue with buffer");
            return;
        }
        
        _currentFillingBufferIndex++;
        if (_currentFillingBufferIndex >= kNumberOfPlaybackBuffers) {
            _currentFillingBufferIndex = 0;
        }
    }
    // wait until next buffer is not in use
    pthread_mutex_lock(&_queueBufferInuseMutex);
    while (_inuseBufferFlags[_currentFillingBufferIndex])
    {
        pthread_cond_wait(&_queueBufferReadyCondition, &_queueBufferInuseMutex);
    }
    pthread_mutex_unlock(&_queueBufferInuseMutex);
}

// audio queue has finished a buffer playing, need to fill a new one
static void audioQueueOutputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer) {
    CYAudioQueuePlayer *audioQueuePlayer = (__bridge CYAudioQueuePlayer *) inUserData;
    [audioQueuePlayer audioCallback:inUserData
               inAudioQueue:inAQ
        audioQueueBufferRef:inCompleteAQBuffer];
}

- (void)audioCallback:(void *)userData
         inAudioQueue:(AudioQueueRef)inAQ
  audioQueueBufferRef:(AudioQueueBufferRef)inCompleteAQBuffer {
    NSUInteger bufIndex = -1;
    for (NSUInteger i = 0; i < kNumberOfPlaybackBuffers; i++) {
        if (inCompleteAQBuffer == _audioQueueBuffers[i]) {
            bufIndex = i;
            break;
        }
    }
    
    if (bufIndex == -1) {
        NSLog(@"something went wrong at queue callback");
        return;
    }
    
    pthread_mutex_lock(&_queueBufferInuseMutex);
    _inuseBufferFlags[bufIndex] = NO;
    _buffersUsed--;
    pthread_cond_signal(&_queueBufferReadyCondition);
    pthread_mutex_unlock(&_queueBufferInuseMutex);
}

#pragma mark - Finshed Playing Callback

void audioQueueFinishedPlayingCallback (
                                        void                  *inUserData,
                                        AudioQueueRef         inAQ,
                                        AudioQueuePropertyID  inID
                                        )
{
    UInt32 isRunning;
    UInt32 dataSize = sizeof(UInt32);
    AudioQueueGetProperty(inAQ, inID, &isRunning, &dataSize);
    if (isRunning == 0) {
        CYAudioQueuePlayer *audioQueuePlayer = (__bridge CYAudioQueuePlayer *) inUserData;
        [audioQueuePlayer didStopPlaying];
    }
}

- (void)didStopPlaying
{
    BOOL isFinished = (self.currentEnqueuePacketIndex < self.packetDatas.count) ? NO : YES;
    if ([self.delegate respondsToSelector:@selector(player:didStopPlayingWithFinishedFlag:)]) {
        [self.delegate player:self didStopPlayingWithFinishedFlag:isFinished];
    }
}

#pragma mark - Generic Error Handler
// generic error handler - if err is nonzero, prints error message and exits program.
static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
        
    char str[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
    exit(1);
}

@end
