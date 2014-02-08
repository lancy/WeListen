//
//  CYAudioSessionManager.m
//  CYAudioQueuePlayer
//
//  Created by Lancy on 5/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "CYAudioSessionManager.h"
@import AVFoundation;

@interface CYAudioSessionManager() <AVAudioPlayerDelegate>

@end

@implementation CYAudioSessionManager

- (id)init
{
    if (self = [super init]) {
        [self initAudioSession];
    }
    return self;
}

- (void)initAudioSession {
    // Registers this class as the delegate of the audio session to listen for audio interruptions
    [[AVAudioSession sharedInstance] setDelegate:self];
    //Set the audio category of this app to playback.
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (setCategoryError) {
        //RESPOND APPROPRIATELY
        NSLog(@"audio sessiont set category error = %@", setCategoryError);
    }
    
    // Registers the audio route change listener callback function
    // An instance of the audio player/manager is passed to the listener
//    AudioSessionAddPropertyListener ( kAudioSessionProperty_AudioRouteChange,
//                                     audioRouteChangeListenerCallback, self );
    
    //Activate the audio session
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error: &activationError];
    if (activationError) {
        NSLog(@"audio session active error = %@", activationError);
        //RESPOND APPROPRIATELY
    }
}

@end
