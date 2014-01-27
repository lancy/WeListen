//
//  WLSongViewItem.h
//  WeListen
//
//  Created by Lancy on 26/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "RETableViewItem.h"
@import MediaPlayer;

@interface WLSongViewItem : RETableViewItem

@property (strong, nonatomic) MPMediaItem *mediaItem;

@end
