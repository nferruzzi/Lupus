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

// Comment to get multiple clients per session.
// Note: there is no sessions limits but there is a maximum number of clients per session
// if you undef then you have to manage the limit when the advertiser receive an
// invitation.
#define PERCLIENT_SESSION

// Service type used by bonjour
NSString * const kLupusServiceType = @"dvlr-lupus";

#pragma mark LupusGame

@interface LupusGame () <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>
@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, assign) BOOL master;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, strong) NSArray *playersName;
@property (nonatomic, assign) LupusGameState gameState;
@property (nonatomic, assign) LupusRole peerRole;
@property (nonatomic, strong) NSMutableDictionary *peersState;
@end

@implementation LupusGame

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.sessions = [NSMutableArray new];
        self.peerID = [[MCPeerID alloc] initWithDisplayName:name];
    }
    return self;
}

- (id)initWithHostName:(NSString *)name
{
    self = [self init];
    if (self) {
        self.gameState = LupusGameState_WaitingForPlayers;
        self.peersState = [NSMutableDictionary dictionary];
        self.master = TRUE;
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
    self = [self init];
    if (self) {
        self.master = FALSE;
        MCSession *session = [[MCSession alloc] initWithPeer:_peerID
                                            securityIdentity:nil
                                        encryptionPreference:MCEncryptionNone];
        session.delegate = self;
        [self.sessions addObject:session];
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
    NSAssert(_master == FALSE, @"I'm a master");
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

#ifdef PERCLIENT_SESSION
    {
#else
    if (!session) {
#endif
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

#pragma mark master to peers
    
- (NSData *)masterDataToPeer:(MCPeerID *)target
{
    NSMutableArray *players = [NSMutableArray array];
    for (MCSession *session in _sessions) {
        for (MCPeerID *peer in session.connectedPeers) {
            if (target != peer)
                [players addObject:peer.displayName];
        }
    }
    
    NSDictionary *payload = @{
        @"name":_peerID.displayName,
        @"gameState": @(_gameState),
        @"players":players
    };

    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload
                                                   options:0
                                                     error:&error];
    NSAssert(!error, @"error: %@", error);
    return data;
}
    
- (void)loadMasterData:(NSData *)data
{
    NSAssert(_master == FALSE, @"I'm a master");
    NSError *error;
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSAssert(!error, @"Error: %@", error);
    NSAssert([payload isKindOfClass:[NSDictionary class]], @"don't know what expect");
}
    
#pragma mark peer to master

- (NSData *)peerDataToMaster
{
    NSAssert(_master == FALSE, @"I'm a master");
    NSAssert(_connected, @"Not connected");
    
    NSDictionary *payload = @{
        @"peerState": @(_peerState)
    };
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload
                                                   options:0
                                                     error:&error];
    NSAssert(!error, @"Error: %@", error);
    return data;
}
    
- (void)loadPeerData:(NSData *)data fromPeer:(MCPeerID *)peer
{
    NSAssert(_master == TRUE, @"I'm not a master");
    NSError *error;
    NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    NSAssert(!error, @"Error: %@", error);
    NSAssert([payload isKindOfClass:[NSDictionary class]], @"don't know what expect");
}
    
#pragma mark peer state logic
    
- (void)setPeerState:(LupusPeerState)peerState
{
    _peerState = peerState;
    NSData *data = [self peerDataToMaster];
    MCSession *session = [self.sessions lastObject];
    [session sendData:data
              toPeers:session.connectedPeers
             withMode:MCSessionSendDataReliable
                error:nil];
}

#pragma mark session
    
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"STATE CHANGE: %@ %d", peerID, (int)state);
    if (_master) {
        for (MCSession *session in _sessions) {
            for (MCPeerID *peer in session.connectedPeers) {
                NSData *data = [self masterDataToPeer:peer];
                [session sendData:data
                          toPeers:@[peer]
                         withMode:MCSessionSendDataUnreliable
                            error:nil];
            }
        }
        if (state == MCSessionStateNotConnected) {
            [self.peersState removeObjectForKey:peerID];
        }
    } else {
        _connected = state == MCSessionStateConnected;
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"RECEIVED DATA FROM %@", peerID);
    if (_master) {
        [self loadPeerData:data fromPeer:peerID];
    } else {
        [self loadMasterData:data];
    }
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

#pragma mark Deck

- (NSDictionary *)saveState
{
    return nil;
}

@end

@implementation LupusGame (Deck)

+ (id)cardForRole:(LupusRole)role
{
    NSDictionary *card;
    
    switch (role) {
        case LupusRole_Villico:
            card = @{
                @"label": @"Villico",
                @"desc": @"",
                @"images": @[@"villico1, villico2, villico3"],
                @"role": @(LupusRole_Villico),
            };
            break;

        case LupusRole_LupoMannaro:
            card = @{
                @"label": @"Lupo Mannaro",
                @"desc": @"",
                @"images": @[@"lupo"],
                @"role": @(LupusRole_LupoMannaro),
            };
            break;

        case LupusRole_Guardia:
            card = @{
                @"label": @"Guardia del corpo",
                @"desc": @"",
                @"images": @[@"guardia"],
                @"role": @(LupusRole_Guardia),
            };
            break;

        case LupusRole_Medium:
            card = @{
                @"label": @"Medium",
                @"desc": @"",
                @"images": @[@"medium"],
                @"role": @(LupusRole_Medium),
            };
            break;

        case LupusRole_Veggente:
            card = @{
                @"label": @"Veggente",
                @"desc": @"",
                @"images": @[@"veggente"],
                @"role": @(LupusRole_Veggente),
            };
            break;

        case LupusRole_TopoMannaro:
            card = @{
                @"label": @"Topo Mannaro",
                @"desc": @"",
                @"images": @[@"topo"],
                @"role": @(LupusRole_TopoMannaro),
            };
            break;
            
        case LupusRole_Massone:
            card = @{
                @"label": @"Massone",
                @"desc": @"",
                @"images": @[@"massone1"],
                @"role": @(LupusRole_Massone),
            };
            break;
    };

    return card;
}

+ (NSArray *)newDeckForPlayersCount:(NSUInteger)players
{
    NSAssert(players, @"no one plays");
    NSMutableArray *ar = [NSMutableArray arrayWithCapacity:players];
    
    [ar addObject:[self cardForRole:LupusRole_LupoMannaro]];
    [ar addObject:[self cardForRole:LupusRole_LupoMannaro]];
    
    if (players >= 8) [self cardForRole:LupusRole_Medium];
    if (players >= 9) [self cardForRole:LupusRole_Veggente];
    if (players >= 12) [self cardForRole:LupusRole_Guardia];
    if (players >= 14) {
        [self cardForRole:LupusRole_Massone];
        [self cardForRole:LupusRole_Massone];
    }
    if (players >= 18) {
        [self cardForRole:LupusRole_TopoMannaro];
    }
    
    while ([ar count] < players) {
        [ar addObject:[self cardForRole:LupusRole_Villico]];
    }
    
    return [NSArray arrayWithArray:ar];
}


@end
