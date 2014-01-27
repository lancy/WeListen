//
//  WLSongsViewController.m
//  WeListen
//
//  Created by Lancy on 26/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLSongsViewController.h"
#import "RETableViewManager.h"
#import "WLPlayingViewController.h"
#import "WLSongViewItem.h"
@import MediaPlayer;

NSString * const kShowPlayingViewControllerSegueIdentifier = @"showPlayingVC";

@interface WLSongsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RETableViewManager *tableViewManager;
@property (strong, nonatomic) NSArray *songsItems;

@property (strong, nonatomic) WLSongViewItem *currentSelectedItem;

@end

@implementation WLSongsViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.currentSelectedItem deselectRowAnimated:animated];
    [self updateNowPlayingButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatas];
    [self setupUserInterface];
}

- (void)setupDatas {
    MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
    self.songsItems = [songsQuery items];
}

- (void)setupUserInterface {
    self.title = @"Songs";
    [self updateNowPlayingButton];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    self.tableViewManager[@"WLSongViewItem"] = @"WLSongCell";
    RETableViewSection *section = [RETableViewSection section];
    for (MPMediaItem *mediaItem in self.songsItems) {
        WLSongViewItem *item = [[WLSongViewItem alloc] init];
        item.cellIdentifier = @"WLSongCell";
        item.mediaItem = mediaItem;
        [item setSelectionHandler:^(WLSongViewItem *item) {
            [self performSegueWithIdentifier:kShowPlayingViewControllerSegueIdentifier sender:item];
            self.currentSelectedItem = item;
        }];
        [section addItem:item];
    }
    [self.tableViewManager addSection:section];
}

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowPlayingViewControllerSegueIdentifier]) {
        if (sender) {
            WLSongViewItem *item = sender;
            MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:self.songsItems];
            WLPlayingViewController *vc = segue.destinationViewController;
            vc.mediaItemCollection = collection;
            vc.nowPlayingItem = item.mediaItem;
        } else {
            MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:self.songsItems];
            WLPlayingViewController *vc = segue.destinationViewController;
            vc.mediaItemCollection = collection;
        }
    }
}

@end
