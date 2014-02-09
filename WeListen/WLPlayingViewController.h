//
//  WLPlayingViewController.h
//  WeListen
//
//  Created by Lancy on 26/1/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;

@interface WLPlayingViewController : UIViewController

@property (strong, nonatomic) MPMediaItem *selectedItem;
@property (strong, nonatomic) NSArray *selectedMediaQueue;

@end
