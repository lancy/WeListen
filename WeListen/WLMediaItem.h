//
//  WLMediaItem.h
//  WeListen
//
//  Created by Lancy on 9/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AudioToolbox;
@import MediaPlayer;

@interface WLMediaItem : NSObject <NSCoding>

// media property
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *albumTitle;
@property (strong, nonatomic) NSString *artist;
@property (nonatomic) NSTimeInterval playbackDuration;
@property (strong, nonatomic) UIImage *artwork;

// stream property
@property (nonatomic) AudioStreamBasicDescription asdb;

- (id)initWithMPMediaItem:(MPMediaItem *)mediaItem;

@end
