//
//  Lupus.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 08/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//
//  Tutorial: http://nshipster.com/multipeer-connectivity/
//            http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/
//
@import MultipeerConnectivity;
#import "Lupus.h"

NSString * const kLupusServiceType = @"dvlr-lupus";

#pragma mark LupusGame

@interface LupusGame () <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>
@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, assign) BOOL master;
@property (nonatomic, assign) BOOL connectedToMaster;
@end

@implementation LupusGame

- (id)initWithHostName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.sessions = [NSMutableArray new];
        self.master = TRUE;
        self.peerID = [[MCPeerID alloc] initWithDisplayName:name];
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:_peerID
                                                            discoveryInfo:nil
                                                              serviceType:kLupusServiceType];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];
    }
    return self;
}

- (id)initWithPlayerName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.sessions = [NSMutableArray new];
        self.master = TRUE;
        self.peerID = [[MCPeerID alloc] initWithDisplayName:name];
        MCSession *session = [[MCSession alloc] initWithPeer:_peerID
                                            securityIdentity:nil
                                        encryptionPreference:MCEncryptionNone];
        session.delegate = self;
        self.sessions = [NSMutableArray arrayWithArray:@[session]];
    }
    return self;
}

+ (id)lupusGameWithHostName:(NSString *)name
                    options:(NSDictionary *)options
{
    LupusGame *lp = [[LupusGame alloc] initWithHostName:[[UIDevice currentDevice] name]];
    return lp;
}

+ (id)lupusGameWithPlayerName:(NSString *)name
{
    LupusGame *lp = [[LupusGame alloc] initWithPlayerName:name];
    return lp;
}

- (MCBrowserViewController *)browser
{
    MCBrowserViewController *vc = [[MCBrowserViewController alloc] initWithServiceType:kLupusServiceType
                                                                               session:[_sessions lastObject]];
    return vc;
}

#pragma mark advertiser

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    MCSession *session = [_sessions lastObject];
    if (!session) {
        session = [[MCSession alloc] initWithPeer:_peerID
                                 securityIdentity:nil
                             encryptionPreference:MCEncryptionNone];
        session.delegate = self;
        [_sessions addObject:session];
    }
    invitationHandler(YES, session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSAssert(0, @"Error advertising:%@", error);
}

#pragma mark session

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"STATE CHANGE: %@ %ld", peerID, state);
    self.connectedToMaster = state == MCSessionStateConnected;
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSAssert(0, @"not supported");
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSAssert(0, @"not supported");
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSAssert(0, @"not supported");
}

@end
