//
//  UIViewController+ConnectionButten.m
//  WeListen
//
//  Created by lancy on 14-3-30.
//  Copyright (c) 2014年 GraceLancy. All rights reserved.
//

#import "UIViewController+ConnectionButten.h"
#import "WLMusicPlayerController.h"

@implementation UIViewController (ConnectionButten)

- (void)updateConnectionButton {
    if (self.navigationController.viewControllers.count == 1
        && self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStyleBordered target:self action:@selector(connectButtonPressed:)];
        [self.navigationItem setLeftBarButtonItem:leftItem animated:NO];
    }
}

- (void)connectButtonPressed:(id)sender {
    [[[WLMusicPlayerController sharedPlayer] connectionCenter] presentBrowserViewControllerInViewController:self];
}

@end
