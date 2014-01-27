//
//  WLPlayerAgent.h
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MediaPlayer;

@interface WLPlayerAgent : NSObject

+ (WLPlayerAgent *)sharedAgent;

@property (strong, nonatomic) MPMediaItem *nowPlayingItem;
@property (strong, nonatomic) MPMediaItemCollection *nowPlayingItemCollection;

@end
