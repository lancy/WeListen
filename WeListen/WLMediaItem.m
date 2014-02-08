//
//  WLMediaItem.m
//  WeListen
//
//  Created by Lancy on 9/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLMediaItem.h"

static NSString * const WLMediaItemPropertyKeyTitle = @"title";
static NSString * const WLMediaItemPropertyKeyAlbumTitle = @"albumTitle";
static NSString * const WLMediaItemPropertyKeyArtist = @"artist";
static NSString * const WLMediaItemPropertyKeyPlaybackDuration = @"playbackDuration";
static NSString * const WLMediaItemPropertyKeyArtwork = @"artwork";
static NSString * const WLMediaItemPropertyKeyASDB = @"asdb";

@implementation WLMediaItem

- (id)initWithMPMediaItem:(MPMediaItem *)mediaItem {
    self = [super init];
    if (self) {
        self.title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];
        self.albumTitle = [mediaItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        self.artist = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
        self.playbackDuration = [[mediaItem valueForKey:MPMediaItemPropertyPlaybackDuration] doubleValue];
        self.artwork = [[mediaItem valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:CGSizeMake(320, 320)];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.title = [aDecoder decodeObjectForKey:WLMediaItemPropertyKeyTitle];
        self.albumTitle = [aDecoder decodeObjectForKey:WLMediaItemPropertyKeyAlbumTitle];
        self.artist = [aDecoder decodeObjectForKey:WLMediaItemPropertyKeyArtist];
        self.playbackDuration = [aDecoder decodeDoubleForKey:WLMediaItemPropertyKeyPlaybackDuration];
        self.artwork = [aDecoder decodeObjectForKey:WLMediaItemPropertyKeyArtwork];
        
        NSData *asdbData = [aDecoder decodeObjectForKey:WLMediaItemPropertyKeyASDB];
        AudioStreamBasicDescription buffer;
        [asdbData getBytes:&buffer length:sizeof(buffer)];
        self.asdb = buffer;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:WLMediaItemPropertyKeyTitle];
    [aCoder encodeObject:self.albumTitle forKey:WLMediaItemPropertyKeyAlbumTitle];
    [aCoder encodeObject:self.artist forKey:WLMediaItemPropertyKeyArtist];
    [aCoder encodeDouble:self.playbackDuration forKey:WLMediaItemPropertyKeyPlaybackDuration];
    [aCoder encodeObject:self.artwork forKey:WLMediaItemPropertyKeyArtwork];
    
    AudioStreamBasicDescription buffer = self.asdb;
    NSData *asdbData = [NSData dataWithBytes:&buffer length:sizeof(buffer)];
    [aCoder encodeObject:asdbData forKey:WLMediaItemPropertyKeyASDB];
}

@end
