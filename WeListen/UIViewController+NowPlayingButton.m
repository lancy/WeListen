//
//  UIViewController+NowPlayingButton.m
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "UIViewController+NowPlayingButton.h"
@import MediaPlayer;

@implementation UIViewController (NowPlayingButton)

- (void)updateNowPlayingButton {
    MPMusicPlayerController *player = [MPMusicPlayerController applicationMusicPlayer];
    if (player.nowPlayingItem != nil) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)nowPlayingButtonPressed:(id)sender {
    [self performSegueWithIdentifier:kShowPlayingViewControllerSegueIdentifier sender:nil];
}

@end
