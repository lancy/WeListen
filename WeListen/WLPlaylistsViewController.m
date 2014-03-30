//
//  WLPlaylistsViewController.m
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLPlaylistsViewController.h"
#import "UIViewController+NowPlayingButton.h"
#import "UIViewController+ConnectionButten.h"
#import "RETableViewManager.h"
#import "WLPlaylistViewItem.h"
#import "WLPlayingViewController.h"
#import "WLSongsViewController.h"
@import MediaPlayer;

@interface WLPlaylistsViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RETableViewManager *tableViewManager;
@property (strong, nonatomic) NSArray *playlistsCollections;
@property (strong, nonatomic) WLPlaylistViewItem *currentSelectedItem;

@end


@implementation WLPlaylistsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.currentSelectedItem deselectRowAnimated:animated];
    [self updateNowPlayingButton];
    [self updateConnectionButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatas];
    [self setupUserInterface];
}

- (void)setupDatas {
    MPMediaQuery *query = [MPMediaQuery playlistsQuery];
    self.playlistsCollections = [query collections];
}

- (void)setupUserInterface {
    self.title = @"Playlist";
    [self updateNowPlayingButton];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    self.tableViewManager[@"WLPlaylistViewItem"] = @"WLPlaylistCell";
    RETableViewSection *section = [RETableViewSection section];
    for (MPMediaPlaylist *playlist in self.playlistsCollections) {
        WLPlaylistViewItem *item = [[WLPlaylistViewItem alloc] init];
        item.cellIdentifier = @"WLPlaylistCell";
        item.mediaPlaylist = playlist;
        [item setSelectionHandler:^(WLPlaylistViewItem *item) {
            self.currentSelectedItem = item;
            [self performSegueWithIdentifier:kShowSongsViewControllerSegueIdentifier sender:item];
        }];
        [section addItem:item];
    }
    [self.tableViewManager addSection:section];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowPlayingViewControllerSegueIdentifier]) {
    } else if ([segue.identifier isEqualToString:kShowSongsViewControllerSegueIdentifier]) {
        WLSongsViewController *vc = segue.destinationViewController;
        vc.hidesBottomBarWhenPushed = YES;
        MPMediaPlaylist *playlist = self.currentSelectedItem.mediaPlaylist;
        vc.songsItems = playlist.items;
        vc.title = [playlist valueForKey:MPMediaPlaylistPropertyName];
    }
}
@end
