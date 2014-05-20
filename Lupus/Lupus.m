//
//  Lupus.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 08/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//
//  MultipeerConnectivity
//  Tutorial: http://nshipster.com/multipeer-connectivity/
//            http://www.appcoda.com/intro-multipeer-connectivity-framework-ios-programming/
//
//  NSCoding
//  Tutorial: http://nshipster.com/nscoding/
//
@import MultipeerConnectivity;
#import "Lupus.h"

// Service type used by bonjour
NSString * const kLupusServiceType = @"dvlr-lupus";

// High level notifications
NSString * const LupusMasterStateChanged = @"LupusMasterStateChanged";

#pragma mark MasterState

@implementation MasterState

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.state = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"state"] integerValue];
        self.playersState = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"playersState"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInteger:_state] forKey:@"state"];
    [aCoder encodeObject:_playersState forKey:@"playersState"];
}

+ (BOOL)supportsSecureCoding
{
    return TRUE;
}

- (NSData *)dump
{
    NSMutableData *md = [NSMutableData new];
    NSKeyedArchiver *ar = [[NSKeyedArchiver alloc] initForWritingWithMutableData:md];
    [ar encodeObject:self forKey:@"master"];
    [ar finishEncoding];
    return md;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<MasterState: %ld, %@>", (long)_state, _playersState];
}

+ (MasterState *)masterStateFromData:(NSData *)data
{
    NSKeyedUnarchiver *ar = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    MasterState *ms = [ar decodeObjectOfClass:[MasterState class] forKey:@"master"];
    [ar finishDecoding];
    return ms;
}

@end

#pragma mark PlayerState

@implementation PlayerState

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
        self.uuid = [aDecoder decodeObjectOfClass:[NSUUID class] forKey:@"uuid"];
        self.role = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"role"] integerValue];
        self.state = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"state"] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_uuid forKey:@"uuid"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_role] forKey:@"role"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_state] forKey:@"state"];
}

+ (BOOL)supportsSecureCoding
{
    return TRUE;
}

- (NSData *)dump
{
    NSMutableData *md = [NSMutableData new];
    NSKeyedArchiver *ar = [[NSKeyedArchiver alloc] initForWritingWithMutableData:md];
    [ar encodeObject:self forKey:@"player"];
    [self encodeWithCoder:ar];
    [ar finishEncoding];
    return md;
}

+ (PlayerState *)playerStateFromData:(NSData *)data
{
    NSKeyedUnarchiver *ar = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    PlayerState *ps = [ar decodeObjectOfClass:[PlayerState class] forKey:@"player"];
    [ar finishDecoding];
    return ps;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<PlayerState: %@, %ld, %ld>", _name, (long)_state, (long)_role];
}

@end

#pragma mark LupusGame

@interface LupusGame () <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate>
@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) MCPeerID *peerID;
@property (nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property (nonatomic, assign) BOOL master;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, strong) NSMutableDictionary *peersState;
@property (nonatomic, strong) MasterState *masterState;
@property (nonatomic, strong) PlayerState *playerState;
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
    self = [self initWithName:name];
    if (self) {
        self.master = TRUE;
        self.masterState = [MasterState new];
        self.masterState.state = LupusMasterState_WaitingForPlayers;
        self.peersState = [NSMutableDictionary dictionary];
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
    self = [self initWithName:name];
    if (self) {
        self.master = FALSE;
        self.playerState = [PlayerState new];
        self.playerState.uuid = [NSUUID UUID];
        self.playerState.name = name;
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

- (void)dealloc
{
    NSLog(@"Dealloc called");
    [self disconnect];
}

#pragma mark UI
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
    // Do no longer accept players when a match has started
    if (_masterState.state == LupusMasterState_Started) {
        invitationHandler(NO, nil);
        return;
    }
    
    MCSession *session = [[MCSession alloc] initWithPeer:_peerID
                                        securityIdentity:nil
                                    encryptionPreference:MCEncryptionNone];
    session.delegate = self;
    [_sessions addObject:session];
    invitationHandler(YES, session);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSAssert(0, @"Error advertising:%@", error);
}

#pragma mark connections
    
- (void)dispatchAsyncNotification:(NSString *)name
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                            object:self];
    });
}
    
- (void)broadcast:(NSData *)data withMode:(MCSessionSendDataMode)mode
{
    for (MCSession *session in _sessions) {
        [session sendData:data
                  toPeers:session.connectedPeers
                 withMode:mode
                    error:nil];
    }
}

- (void)disconnect
{
    [self.advertiser stopAdvertisingPeer];
    
    for (MCSession *session in _sessions) {
        [session disconnect];
    }
    
    self.connected = FALSE;
}

#pragma mark Game Logic

- (void)setStateForPlayer:(LupusPlayerState)state
{
    NSAssert(!_master, @"I'm a master");
    self.playerState.state = state;
    NSData *data = [self.playerState dump];
    [self broadcast:data withMode:MCSessionSendDataReliable];
}
    
- (void)updatePlayersWithMasterState:(MCSessionSendDataMode)mode
{    
    NSAssert(_master, @"I'm a player");
    _masterState.playersState = [_peersState allValues];
    NSData *data = [_masterState dump];
    [self broadcast:data withMode:mode];
    [self dispatchAsyncNotification:LupusMasterStateChanged];
}

- (void)startGame
{
    NSAssert(_master, @"I'm a player");
    self.masterState.state = LupusMasterState_Started;
    
    NSMutableArray *cards = [NSMutableArray arrayWithArray:[LupusGame newDeckForPlayersCount:[self.masterState.playersState count]]];
    
    for (PlayerState *ps in self.masterState.playersState) {
        NSUInteger index = (NSUInteger)arc4random_uniform((u_int32_t)[cards count]);
        NSDictionary *card = [cards objectAtIndex:index];
        ps.role = (LupusPlayerRole)[card[@"role"] integerValue];
        [cards removeObjectAtIndex:index];
    }
    
    [self updatePlayersWithMasterState:MCSessionSendDataReliable];
}

    
#pragma mark MCSession delegate
    
// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    NSLog(@"STATE CHANGE: %@ %d", peerID, (int)state);
    if (_master) {
        if (state == MCSessionStateConnected) {
            // We store it, but we can't really use it because we have no UUID yet
            PlayerState *ps = [PlayerState new];
            ps.name = peerID.displayName;
            [self.peersState setObject:ps forKey:peerID];
        }
        if (state == MCSessionStateNotConnected) {
            [self.peersState removeObjectForKey:peerID];
        }
        [self updatePlayersWithMasterState:MCSessionSendDataUnreliable];
    } else {
        _connected = state == MCSessionStateConnected;
    }
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"RECEIVED DATA FROM %@", peerID);
    if (_master) {
        PlayerState *ps = [PlayerState playerStateFromData:data];
        [self.peersState setObject:ps forKey:peerID];
        NSLog(@"Player state: %@", ps);
        [self updatePlayersWithMasterState:MCSessionSendDataUnreliable];
    } else {
        self.masterState = [MasterState masterStateFromData:data];
        for (PlayerState *ps in _masterState.playersState) {
            if ([ps.uuid isEqual:_playerState.uuid]) {
                self.playerState = ps;
                NSLog(@"New state received: %@", _playerState);
            }
        }
        [self dispatchAsyncNotification:LupusMasterStateChanged];
        NSLog(@"Master state: %@", _masterState);
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

@end

@implementation LupusGame (Deck)

+ (id)cardForRole:(LupusPlayerRole)role
{
    NSDictionary *card;
    
    switch (role) {
        case LupusPlayerRole_Villico:
            card = @{
                @"label": @"Villico",
                @"desc": @"",
                @"images": @[@"villico1, villico2, villico3"],
                @"role": @(LupusPlayerRole_Villico),
            };
            break;

        case LupusPlayerRole_LupoMannaro:
            card = @{
                @"label": @"Lupo Mannaro",
                @"desc": @"",
                @"images": @[@"lupo"],
                @"role": @(LupusPlayerRole_LupoMannaro),
            };
            break;

        case LupusPlayerRole_Guardia:
            card = @{
                @"label": @"Guardia del corpo",
                @"desc": @"",
                @"images": @[@"guardia"],
                @"role": @(LupusPlayerRole_Guardia),
            };
            break;

        case LupusPlayerRole_Medium:
            card = @{
                @"label": @"Medium",
                @"desc": @"",
                @"images": @[@"medium"],
                @"role": @(LupusPlayerRole_Medium),
            };
            break;

        case LupusPlayerRole_Veggente:
            card = @{
                @"label": @"Veggente",
                @"desc": @"",
                @"images": @[@"veggente"],
                @"role": @(LupusPlayerRole_Veggente),
            };
            break;

        case LupusPlayerRole_TopoMannaro:
            card = @{
                @"label": @"Topo Mannaro",
                @"desc": @"",
                @"images": @[@"topo"],
                @"role": @(LupusPlayerRole_TopoMannaro),
            };
            break;
            
        case LupusPlayerRole_Massone:
            card = @{
                @"label": @"Massone",
                @"desc": @"",
                @"images": @[@"massone1"],
                @"role": @(LupusPlayerRole_Massone),
            };
            break;

        default:
            break;
    };

    return card;
}

+ (NSArray *)newDeckForPlayersCount:(NSUInteger)players
{
    NSAssert(players, @"no one plays");
    NSMutableArray *ar = [NSMutableArray arrayWithCapacity:players];
    
    [ar addObject:[self cardForRole:LupusPlayerRole_LupoMannaro]];
    [ar addObject:[self cardForRole:LupusPlayerRole_LupoMannaro]];
    
    if (players >= 8) [self cardForRole:LupusPlayerRole_Medium];
    if (players >= 9) [self cardForRole:LupusPlayerRole_Veggente];
    if (players >= 12) [self cardForRole:LupusPlayerRole_Guardia];
    if (players >= 14) {
        [self cardForRole:LupusPlayerRole_Massone];
        [self cardForRole:LupusPlayerRole_Massone];
    }
    if (players >= 18) {
        [self cardForRole:LupusPlayerRole_TopoMannaro];
    }
    
    while ([ar count] < players) {
        [ar addObject:[self cardForRole:LupusPlayerRole_Villico]];
    }
    
    return [NSArray arrayWithArray:ar];
}


@end
