//
//  WLArtistsViewController.m
//  WeListen
//
//  Created by Lancy on 27/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLArtistsViewController.h"
#import "RETableViewManager.h"
#import "UIViewController+NowPlayingButton.h"
#import "WLArtistViewItem.h"
#import "WLSongsViewController.h"
@import MediaPlayer;

@interface WLArtistsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) RETableViewManager *tableViewManager;
@property (strong, nonatomic) WLArtistViewItem *currentSelectedItem;

@property (strong, nonatomic) NSArray *artistsCollections;

@end

@implementation WLArtistsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.currentSelectedItem deselectRowAnimated:animated];
    [self updateNowPlayingButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDatas];
    [self setupUserInterface];
}

- (void)setupDatas {
    MPMediaQuery *artistsQuery = [MPMediaQuery artistsQuery];
    self.artistsCollections = [artistsQuery collections];
}


- (void)setupUserInterface {
    if (!self.title) {
        self.title = @"Artists";
    }
    [self updateNowPlayingButton];
    [self setupTableView];
}

- (void)setupTableView {
    self.tableViewManager = [[RETableViewManager alloc] initWithTableView:self.tableView];
    self.tableViewManager[@"WLArtistViewItem"] = @"WLArtistCell";
    RETableViewSection *section = [RETableViewSection section];
    for (MPMediaItemCollection *artistCollection in self.artistsCollections) {
        WLArtistViewItem *item = [[WLArtistViewItem alloc] init];
        item.cellIdentifier = @"WLArtistCell";
        item.artistCollection = artistCollection;
        [item setSelectionHandler:^(WLArtistViewItem *item) {
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
        MPMediaItemCollection *artistCollection = self.currentSelectedItem.artistCollection;
        MPMediaItem *item = artistCollection.representativeItem;
        vc.songsItems = [artistCollection items];
        vc.title = [item valueForKey:MPMediaItemPropertyArtist];
    }
}
@end
