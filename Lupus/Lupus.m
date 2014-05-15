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

#pragma mark session

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"STATE CHANGE: %@ %d", peerID, (int)state);
    if (peerID == _peerID) {
        self.connectedToMaster = state == MCSessionStateConnected;
    }
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

#pragma mark Deck

@end

@implementation LupusGame (Deck)

+ (id)cardForRole:(LupusRole)role
{
    NSDictionary *card;
    
    switch (role) {
        case LupusRoleVillico:
            card = @{
                @"label": @"Villico",
                @"desc": @"",
                @"images": @[@"villico1, villico2, villico3"],
                @"role": @(LupusRoleVillico),
            };
            break;

        case LupusRoleLupoMannaro:
            card = @{
                @"label": @"Lupo Mannaro",
                @"desc": @"",
                @"images": @[@"lupo"],
                @"role": @(LupusRoleLupoMannaro),
            };
            break;

        case LupusRoleGuardia:
            card = @{
                @"label": @"Guardia del corpo",
                @"desc": @"",
                @"images": @[@"guardia"],
                @"role": @(LupusRoleGuardia),
            };
            break;

        case LupusRoleMedium:
            card = @{
                @"label": @"Medium",
                @"desc": @"",
                @"images": @[@"medium"],
                @"role": @(LupusRoleMedium),
            };
            break;

        case LupusRoleVeggente:
            card = @{
                @"label": @"Veggente",
                @"desc": @"",
                @"images": @[@"veggente"],
                @"role": @(LupusRoleVeggente),
            };
            break;

        case LupusRoleTopoMannaro:
            card = @{
                @"label": @"Topo Mannaro",
                @"desc": @"",
                @"images": @[@"topo"],
                @"role": @(LupusRoleTopoMannaro),
            };
            break;
            
        case LupusRoleMassone:
            card = @{
                @"label": @"Massone",
                @"desc": @"",
                @"images": @[@"massone1"],
                @"role": @(LupusRoleMassone),
            };
            break;
    };

    return card;
}

+ (NSArray *)newDeckForPlayersCount:(NSUInteger)players
{
    NSAssert(players, @"no one plays");
    NSMutableArray *ar = [NSMutableArray arrayWithCapacity:players];
    
    [ar addObject:[self cardForRole:LupusRoleLupoMannaro]];
    [ar addObject:[self cardForRole:LupusRoleLupoMannaro]];
    
    if (players >= 8) [self cardForRole:LupusRoleMedium];
    if (players >= 9) [self cardForRole:LupusRoleVeggente];
    if (players >= 12) [self cardForRole:LupusRoleGuardia];
    if (players >= 14) {
        [self cardForRole:LupusRoleMassone];
        [self cardForRole:LupusRoleMassone];
    }
    if (players >= 18) {
        [self cardForRole:LupusRoleTopoMannaro];
    }
    
    while ([ar count] < players) {
        [ar addObject:[self cardForRole:LupusRoleVillico]];
    }
    
    return [NSArray arrayWithArray:ar];
}


@end
