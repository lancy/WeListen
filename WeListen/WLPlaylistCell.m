//
//  WLPlaylistCell.m
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLPlaylistCell.h"

@interface WLPlaylistCell ()
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation WLPlaylistCell

+ (CGFloat)heightWithItem:(WLPlaylistViewItem *)item tableViewManager:(RETableViewManager *)tableViewManager {
    return 80;
}

- (void)cellWillAppear {
    [super cellWillAppear];
    MPMediaPlaylist *playlist = self.item.mediaPlaylist;
    MPMediaItem *item = [playlist representativeItem];
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    self.artworkImageView.image = [artwork imageWithSize:self.artworkImageView.size];
    self.titleLabel.text = [playlist valueForProperty:MPMediaPlaylistPropertyName];
}
@end
