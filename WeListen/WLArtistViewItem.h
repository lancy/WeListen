//
//  WLArtistViewItem.h
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "RETableViewItem.h"
@import MediaPlayer;

@interface WLArtistViewItem : RETableViewItem

@property (strong, nonatomic) MPMediaItemCollection *artistCollection;

@end
