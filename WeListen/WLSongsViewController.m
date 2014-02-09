//
//  WLSongsViewController.m
//  WeListen
//
//  Created by Lancy on 26/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLSongsViewController.h"
#import "RETableViewManager.h"
#import "WLSongViewItem.h"
#import "WLPlayingViewController.h"
#import "UIViewController+NowPlayingButton.h"
@import MediaPlayer;

@interface WLSongsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RETableViewManager *tableViewManager;
@property (strong, nonatomic) WLSongViewItem *currentSelectedItem;

@end

@implementation WLSongsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.currentSelectedItem deselectRowAnimated:animated];
    [self updateNowPlayingButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatas];
    [self setupUserInterface];
}

- (void)setupDatas {
    if (!self.songsItems) {
        MPMediaQuery *songsQuery = [MPMediaQuery songsQuery];
        self.songsItems = [songsQuery items];
    }
}

- (void)setupUserInterface {
    if (!self.title) {
        self.title = @"Songs";
    }
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowPlayingViewControllerSegueIdentifier]) {
        if (sender) {
            WLSongViewItem *item = sender;
            WLPlayingViewController *vc = segue.destinationViewController;
            vc.selectedMediaQueue = self.songsItems;
            vc.selectedItem = item.mediaItem;
        }
    }
}

@end
