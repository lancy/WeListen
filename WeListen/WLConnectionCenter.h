//
//  WLConnectionCenter.h
//  WeListen
//
//  Created by Lancy on 10/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLConnectionSignal.h"

@class WLConnectionCenter;

@protocol WLConnectionCenterDelegate

- (void)connectionCenterDidGetSignal:(WLConnectionSignal *)signal;
- (void)connectionCenterDidGetAudioPacketData:(NSData *)packetData;

@end

@interface WLConnectionCenter : NSObject

@property (weak, nonatomic) id<WLConnectionCenterDelegate> delegate;

- (id)initWithDelegate:(id<WLConnectionCenterDelegate>)delegate;

- (void)presentBrowserViewControllerInViewController:(UIViewController *)pressentingViewController;

- (void)sendSignal:(WLConnectionSignal *)signal;
- (void)sendAudioPacketData:(NSData *)packetData;

@end
