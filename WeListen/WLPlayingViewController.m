//
//  WLPlayingViewController.m
//  WeListen
//
//  Created by Lancy on 26/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLPlayingViewController.h"
#import "WLMusicPlayerController.h"

@interface WLPlayingViewController ()
@property (strong, nonatomic) UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *playbackButton;
@property (weak, nonatomic) IBOutlet UIButton *repeatButton;
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton;

@property (strong, nonatomic) WLMusicPlayerController *musicPlayer;

@end

@implementation WLPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPlayer];
    [self setupInterface];
}

- (void)dealloc {
}

- (void)setupInterface {
    [self setupNavagationBar];
    [self updateInterfaceWithMediaItem:self.musicPlayer.nowPlayingItem];
}

- (void)setupPlayer {
    self.musicPlayer = [WLMusicPlayerController sharedPlayer];
    if (self.selectedMediaQueue && self.selectedItem) {
        [self.musicPlayer setMediaQueue:self.selectedMediaQueue];
        if (self.selectedItem != self.musicPlayer.nowPlayingItem) {
            [self.musicPlayer setNowPlayingItem:self.selectedItem];
            [self.musicPlayer play];
        }
    }
    @weakify(self);
    [[RACObserve(self.musicPlayer, nowPlayingItem) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        if (x) {
            [self updateInterfaceWithMediaItem:x];
        }
    }];
    RAC(self.playbackButton, selected) = [[RACObserve(self.musicPlayer, playbackState) takeUntil:self.rac_willDeallocSignal] map:^id(NSNumber *stateValue) {
        return @([stateValue integerValue] == WLMusicPlaybackStatePlaying);
    }];
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
    [self updateIndexLabelWithIndex:self.musicPlayer.indexOfNowPlayingItem count:self.musicPlayer.mediaQueue.count];
    [self updatePlaybackButton];
    [self updateRepeatButton];
    [self updateShuffleButton];
}

- (void)updatePlaybackButton {
    if (self.musicPlayer.playbackState == WLMusicPlaybackStatePlaying) {
        self.playbackButton.selected = YES;
    } else {
        self.playbackButton.selected = NO;
    }
}

- (void)updateRepeatButton {
    NSString *buttonTitle;
    WLMusicRepeatMode mode = self.musicPlayer.repeatMode;
    switch (mode) {
        case WLMusicRepeatModeOne:
            buttonTitle = @"Repeat One";
            break;
        case WLMusicRepeatModeAll:
            buttonTitle = @"Repeat All";
            break;
        case WLMusicRepeatModeNone:
        default:
            buttonTitle = @"Repeat None";
            break;
    }
    [self.repeatButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)updateShuffleButton {
    
    NSString *buttonTitle;
    WLMusicShuffleMode mode = self.musicPlayer.shuffleMode;
    switch (mode) {
        case WLMusicShuffleModeOn:
            buttonTitle = @"Shuffle On";
            break;
        case WLMusicShuffleModeOff:
        default:
            buttonTitle = @"Shuffle Off";
            break;
    }
    [self.shuffleButton setTitle:buttonTitle forState:UIControlStateNormal];
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
    if ([self.musicPlayer playbackState] == WLMusicPlaybackStatePlaying) {
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
    WLMusicRepeatMode currentMode = self.musicPlayer.repeatMode;
    WLMusicRepeatMode newMode = currentMode;
    switch (currentMode) {
        case WLMusicRepeatModeOne:
            newMode = WLMusicRepeatModeAll;
            break;
        case WLMusicRepeatModeAll:
            newMode = WLMusicRepeatModeNone;
            break;
        case WLMusicRepeatModeNone:
        default:
            newMode = WLMusicRepeatModeOne;
            break;
    }
    [self.musicPlayer setRepeatMode:newMode];
    [self updateRepeatButton];
}

- (IBAction)shuffleButtonPressed:(id)sender {
    WLMusicShuffleMode currentMode = self.musicPlayer.shuffleMode;
    WLMusicShuffleMode newMode = currentMode;
    switch (currentMode) {
        case WLMusicShuffleModeOn:
            newMode = WLMusicShuffleModeOff;
            break;
        case WLMusicShuffleModeOff:
        default:
            newMode = WLMusicShuffleModeOn;
            break;
    }
    [self.musicPlayer setShuffleMode:newMode];
    [self updateShuffleButton];
}

@end
