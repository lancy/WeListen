//
//  WLArtistCell.m
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLArtistCell.h"

@interface WLArtistCell ()
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation WLArtistCell

+ (CGFloat)heightWithItem:(WLArtistViewItem *)item tableViewManager:(RETableViewManager *)tableViewManager {
    return 80;
}

- (void)cellWillAppear {
    [super cellWillAppear];
    MPMediaItemCollection *collection = self.item.artistCollection;
    MPMediaItem *item = [collection representativeItem];
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    self.artworkImageView.image = [artwork imageWithSize:self.artworkImageView.size];
    self.titleLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
    if (collection.items.count > 1) {
        self.descriptionLabel.text = [NSString stringWithFormat:@"%d songs", collection.items.count];
    } else {
        self.descriptionLabel.text = @"1 song";
    }
}
@end
