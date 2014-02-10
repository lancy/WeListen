//
//  WLConnectionCenter.m
//  WeListen
//
//  Created by Lancy on 10/2/14.
//  Copyright (c) 2014 GraceLancy. All rights reserved.
//

#import "WLConnectionCenter.h"
@import MultipeerConnectivity;

static NSString * const kServiceType = @"cy-audioservice";

@interface WLConnectionCenter () <MCSessionDelegate, MCBrowserViewControllerDelegate>

@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) MCPeerID *peerId;
@property (strong, nonatomic) MCAdvertiserAssistant *advertiserAssistant;

@end

@implementation WLConnectionCenter

- (id)initWithDelegate:(id<WLConnectionCenterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self setupMCSession];
    }
    return self;
}

- (void)setupMCSession {
    NSString *peerName = [[UIDevice currentDevice] name];
    self.peerId = [[MCPeerID alloc] initWithDisplayName:peerName];
    self.session = [[MCSession alloc] initWithPeer:self.peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType:kServiceType discoveryInfo:nil session:self.session];
    [self.advertiserAssistant start];
}

#pragma mark - send data

- (void)sendSignal:(WLConnectionSignal *)signal {
    if (self.session.connectedPeers.count > 0) {
       NSData *sendData = [NSKeyedArchiver archivedDataWithRootObject:signal];
        NSError *error = nil;
        [self.session sendData:sendData toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        if (error) {
            NSLog(@"ERROR: %@", error);
        }
    }
}

- (void)sendAudioPacketData:(NSData *)packetData {
    if (self.session.connectedPeers.count > 0) {
        WLConnectionSignal *signal = [WLConnectionSignal signalWithType:WLConnectionSignalTypeDataAudioPacket payload:packetData];
        [self sendSignal:signal];
    }
}

#pragma mark - sesstion methods call back

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    WLConnectionSignal *signal = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (signal.type == WLConnectionSignalTypeDataAudioPacket) {
        [self.delegate connectionCenterDidGetAudioPacketData:signal.payload];
    } else {
        [self.delegate connectionCenterDidGetSignal:signal];
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
}


#pragma mark - BrowserViewController

- (void)presentBrowserViewControllerInViewController:(UIViewController *)pressentingViewController {
    MCBrowserViewController *browserVC = [[MCBrowserViewController alloc] initWithServiceType:kServiceType session:self.session];
    browserVC.delegate = self;
    [pressentingViewController presentViewController:browserVC animated:YES completion:nil];
}

- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
