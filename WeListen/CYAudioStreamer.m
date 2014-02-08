//
//  CYAudioStreamer.m
//  CYAudioQueuePlayer
//
//  Created by Lancy on 4/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "CYAudioStreamer.h"

static const int kPacketCapacityByteSize = 2048;

@interface CYAudioStreamer()

@property (strong, nonatomic) AVAssetReader *assetReader;
@property (strong, nonatomic) AVAssetReaderOutput *assetReaderOutput;
@property (nonatomic, readwrite) AudioStreamBasicDescription audioStreamBasicDescription;
@property (strong, nonatomic) NSMutableArray *storePackets;

@end

@implementation CYAudioStreamer

- (NSArray *)packets {
    return [self.storePackets copy];
}

- (id)initWithUrlAsset:(AVURLAsset *)urlAsset delegate:(id<CYAudioStreamerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        NSError *error = nil;
        self.assetReader = [[AVAssetReader alloc] initWithAsset:urlAsset error:&error];
        self.assetReader.timeRange = CMTimeRangeMake(kCMTimeZero, urlAsset.duration);
        AVAssetTrack *track = [urlAsset.tracks objectAtIndex:0];
        self.audioStreamBasicDescription = [self getTrackASDB:track];
        self.assetReaderOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:nil];
        [self.assetReader addOutput:self.assetReaderOutput];
        [self.assetReader startReading];
    }
    return self;
}

- (void)startStreaming {
    self.storePackets = [[NSMutableArray alloc] init];
    dispatch_queue_t streamingQueue = dispatch_queue_create("com.lancy.streamingQueue", NULL);
    dispatch_async(streamingQueue, ^{
        while (self.assetReader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef sampleBuffer = [self.assetReaderOutput copyNextSampleBuffer];
            if (sampleBuffer) {
                CMTime durationTime = CMSampleBufferGetDuration(sampleBuffer);
                if (CMTimeGetSeconds(durationTime) == 0.0) {
                    break;
                }
                
                CMBlockBufferRef blockBuffer;
                AudioBufferList audioBufferList;
                CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(AudioBufferList), NULL, NULL, 0, &blockBuffer);
                CFRelease(blockBuffer);
                
                for (NSUInteger i = 0; i < audioBufferList.mNumberBuffers; i++) {
                    AudioBuffer audioBuffer = audioBufferList.mBuffers[i];
                    
                    NSInteger mod = audioBuffer.mDataByteSize % kPacketCapacityByteSize;
                    NSInteger numberOfPackets;
                    if (mod != 0) {
                        numberOfPackets = audioBuffer.mDataByteSize / kPacketCapacityByteSize + 1;
                    } else {
                        numberOfPackets = audioBuffer.mDataByteSize / kPacketCapacityByteSize;
                    }
                    
                    void *audioBufferPtr = audioBuffer.mData;
                    NSInteger remainedDataSize = audioBuffer.mDataByteSize;
                    for (NSInteger j = 0; j < numberOfPackets; j++) {
                        NSInteger acturalPacketSize;
                        if (remainedDataSize < kPacketCapacityByteSize) {
                            acturalPacketSize = remainedDataSize;
                        } else {
                            acturalPacketSize = kPacketCapacityByteSize;
                        }
                        
                        NSData *data = [NSData dataWithBytes:audioBufferPtr length:acturalPacketSize];
                        [self.storePackets addObject:data];
                        
                        if ([self.delegate respondsToSelector:@selector(streamer:didGetPacketData:)]) {
                            [self.delegate streamer:self didGetPacketData:data];
                        }
                        
                        remainedDataSize -= acturalPacketSize;
                        if (j < numberOfPackets - 1) {
                            audioBufferPtr += kPacketCapacityByteSize;
                        }
                    }
                }
            } // end of if sampleBuffer
            CFRelease(sampleBuffer);
        } // end of while reading
        if ([self.delegate respondsToSelector:@selector(streamerDidFinishedStreaming:)]) {
            [self.delegate streamerDidFinishedStreaming:self];
        }
    });
}

- (void)cancleStreaming {
    if (self.assetReader.status == AVAssetReaderStatusReading) {
        [self.assetReader cancelReading];
    }
}

- (AudioStreamBasicDescription)getTrackASDB:(AVAssetTrack *) track
{
    CMFormatDescriptionRef formDesc = (__bridge CMFormatDescriptionRef)[[track formatDescriptions] objectAtIndex:0];
    const AudioStreamBasicDescription *asbdPointer = CMAudioFormatDescriptionGetStreamBasicDescription(formDesc);
    //because this is a pointer and not a struct we need to move the data into a struct so we can use it
    AudioStreamBasicDescription asbd = {0};
    memcpy(&asbd, asbdPointer, sizeof(asbd));
    //asbd now contains a basic description for the track
    return asbd;
    
}
@end
