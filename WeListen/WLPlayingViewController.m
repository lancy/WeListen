//
//  WLPlayingViewController.m
//  WeListen
//
//  Created by Lancy on 26/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLPlayingViewController.h"

@interface WLPlayingViewController ()
@property (strong, nonatomic) UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *playbackButton;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;

@property (strong, nonatomic) MPMusicPlayerController *musicPlayer;

@end

@implementation WLPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPlayer];
    [self setupInterface];
}

- (void)dealloc {
    [self unObserveNotificationName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification];
    [self unObserveNotificationName:MPMusicPlayerControllerPlaybackStateDidChangeNotification];
    [self.musicPlayer endGeneratingPlaybackNotifications];
}

- (void)setupInterface {
    [self setupNavagationBar];
    [self updateInterfaceWithMediaItem:self.nowPlayingItem];
}

- (void)setupPlayer {
    self.musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    if (self.mediaItemCollection && self.nowPlayingItem) {
        [self.musicPlayer setQueueWithItemCollection:self.mediaItemCollection];
        [self.musicPlayer setNowPlayingItem:self.nowPlayingItem];
        [self.musicPlayer play];
    } else {
        self.nowPlayingItem = [self.musicPlayer nowPlayingItem];
    }
    [self.musicPlayer beginGeneratingPlaybackNotifications];
    [self observeNotificationName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification selector:@selector(handleNowPlayingItemDidChangedNotification:)];
    [self observeNotificationName:MPMusicPlayerControllerPlaybackStateDidChangeNotification selector:@selector(handlePlaybackStateDidChangedNotification:)];
}

- (void)setupNavagationBar {
    self.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 36)];
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationItem setTitleView:self.indexLabel];
}

- (void)updateInterfaceWithMediaItem:(MPMediaItem *)item {
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    self.artworkImageView.image = [artwork imageWithSize:self.artworkImageView.size];
    self.titleLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    self.descriptionLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];
    NSUInteger index = [[self.mediaItemCollection items] indexOfObject:self.nowPlayingItem];
    [self updateIndexLabelWithIndex:index count:self.mediaItemCollection.count];
    [self updatePlaybackButton];
    [self updateRepeatButton];
    [self updateShuffleButton];
}

- (void)updatePlaybackButton {
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        self.playbackButton.selected = YES;
    } else {
        self.playbackButton.selected = NO;
    }
}

- (void)updateRepeatButton {
    NSString *buttonTitle;
    MPMusicRepeatMode mode = [self currentRepeatMode];
    switch (mode) {
        case MPMusicRepeatModeOne:
            buttonTitle = @"Repeat One";
            break;
        case MPMusicRepeatModeAll:
            buttonTitle = @"Repeat All";
            break;
        case MPMusicRepeatModeNone:
        case MPMusicRepeatModeDefault:
        default:
            buttonTitle = @"Repeat None";
            break;
    }
    [self.repeatButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (MPMusicRepeatMode)currentRepeatMode {
    MPMusicRepeatMode mode = self.musicPlayer.repeatMode;
    if (mode == MPMusicRepeatModeDefault) {
        mode = [MPMusicPlayerController iPodMusicPlayer].repeatMode;
    }
    return mode;
}

- (void)updateShuffleButton {
    
    NSString *buttonTitle;
    MPMusicShuffleMode mode = [self currentShuffleMode];
    switch (mode) {
        case MPMusicShuffleModeSongs:
        case MPMusicShuffleModeAlbums:
            buttonTitle = @"Shuffle All";
            break;
        case MPMusicShuffleModeOff:
        case MPMusicShuffleModeDefault:
        default:
            buttonTitle = @"Shuffle Off";
            break;
    }
    [self.shuffleButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (MPMusicShuffleMode)currentShuffleMode {
    MPMusicShuffleMode mode = self.musicPlayer.shuffleMode;
    if (mode == MPMusicShuffleModeDefault) {
        mode = [MPMusicPlayerController iPodMusicPlayer].shuffleMode;
    }
    return mode;
}

- (void)updateIndexLabelWithIndex:(NSUInteger)index count:(NSUInteger)count {
    NSString *indexString = [@(index + 1) stringValue];
    NSString *countString = [@(count) stringValue];
    NSString *content = [NSString stringWithFormat:@"%@ of %@", indexString, countString];
    NSRange ofLocation = [content rangeOfString:@"of"];
    NSRange indexRange = NSMakeRange(0, indexString.length);
    NSRange countRange = NSMakeRange(ofLocation.location + 3, countString.length);
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:content];
    [attrString setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]} range:indexRange];
    [attrString setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:13]} range:countRange];
    self.indexLabel.font = [UIFont systemFontOfSize:13];
    self.indexLabel.attributedText = attrString;
}

- (IBAction)playbackButtonPressed:(id)sender {
    if ([self.musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer pause];
    } else {
        [self.musicPlayer play];
    }
}

- (IBAction)nextButtonPressed:(id)sender {
    [self.musicPlayer skipToNextItem];
}

- (IBAction)previousButtonPressed:(id)sender {
    if ([self.musicPlayer currentPlaybackTime] < 5) {
        [self.musicPlayer skipToPreviousItem];
    } else {
        [self.musicPlayer skipToBeginning];
    }
}

- (IBAction)repeatButtonPressed:(id)sender {
    MPMusicRepeatMode currentMode = [self currentRepeatMode];
    MPMusicRepeatMode newMode = currentMode;
    switch (currentMode) {
        case MPMusicRepeatModeOne:
            newMode = MPMusicRepeatModeAll;
            break;
        case MPMusicRepeatModeAll:
            newMode = MPMusicRepeatModeNone;
            break;
        case MPMusicRepeatModeDefault:
        case MPMusicRepeatModeNone:
        default:
            newMode = MPMusicRepeatModeOne;
            break;
    }
    [self.musicPlayer setRepeatMode:newMode];
    [self updateRepeatButton];
}

- (IBAction)shuffleButtonPressed:(id)sender {
    MPMusicShuffleMode currentMode = [self currentShuffleMode];
    MPMusicShuffleMode newMode = currentMode;
    switch (currentMode) {
        case MPMusicShuffleModeAlbums:
        case MPMusicShuffleModeSongs:
            newMode = MPMusicShuffleModeOff;
            break;
        case MPMusicShuffleModeOff:
        default:
            newMode = MPMusicShuffleModeSongs;
            break;
    }
    [self.musicPlayer setShuffleMode:newMode];
    [self updateShuffleButton];
}

- (void)handleNowPlayingItemDidChangedNotification:(NSNotification *)notification {
    if (notification.object == self.musicPlayer) {
        self.nowPlayingItem = [self.musicPlayer nowPlayingItem];
        [self updateInterfaceWithMediaItem:self.nowPlayingItem];
    }
}

- (void)handlePlaybackStateDidChangedNotification:(NSNotification *)notification {
    if (notification.object == self.musicPlayer) {
        [self updatePlaybackButton];
    }
}

@end
