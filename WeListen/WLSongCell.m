//
//  WLSongCell.m
//  WeListen
//
//  Created by Lancy on 26/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLSongCell.h"

@interface WLSongCell()

@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation WLSongCell

+ (CGFloat)heightWithItem:(WLSongViewItem *)item tableViewManager:(RETableViewManager *)tableViewManager {
    return 60;
}

- (void)cellWillAppear {
    [super cellWillAppear];
    MPMediaItem *item = self.item.mediaItem;
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    self.artworkImageView.image = [artwork imageWithSize:self.artworkImageView.size];
    self.titleLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    self.descriptionLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
}


@end
