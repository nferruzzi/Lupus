//
//  Lupus.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 08/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import "Lupus.h"

@import MultipeerConnectivity;

@interface Lupus () <MCSessionDelegate>

@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCPeerID *userPeer;
@end

@implementation Lupus

+ (Lupus *)shared
{
    static dispatch_once_t onceToken;
    static Lupus *lupus;
    dispatch_once(&onceToken, ^{
        lupus = [[Lupus alloc] init];
    });
 
    return lupus;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *name = [[UIDevice currentDevice] name];
        self.userPeer = [[MCPeerID alloc] initWithDisplayName:name];
    }
    return self;
}

- (void)createGame:(NSDictionary *)options
{
    NSAssert(_session, @"clean the previous session first");
    
    self.session = [[MCSession alloc] initWithPeer:_userPeer
                                  securityIdentity:nil
                              encryptionPreference:MCEncryptionOptional];
    self.session.delegate = self;
}

- (void)showGames
{
    
}

#pragma mark delegate

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
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
