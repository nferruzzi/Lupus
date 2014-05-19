//
//  Lupus.h
//  Lupus
//
//  Created by Nicola Ferruzzi on 08/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MultipeerConnectivity;

extern NSString * const kLupusServiceType;
extern NSString * const LupusMasterStateChanged;

// Games role
typedef NS_ENUM(NSInteger, LupusPlayerRole) {
    LupusPlayerRole_Unknown,
    LupusPlayerRole_Villico,
    LupusPlayerRole_LupoMannaro,
    LupusPlayerRole_Guardia,
    LupusPlayerRole_Medium,
    LupusPlayerRole_Veggente,
    LupusPlayerRole_TopoMannaro,
    LupusPlayerRole_Massone
};

// Game state
typedef NS_ENUM(NSInteger, LupusMasterState) {
    LupusMasterState_Uninitialized,
    LupusMasterState_WaitingForPlayers,
    LupusMasterState_Started,
};

// Peer state
typedef NS_ENUM(NSInteger, LupusPlayerState) {
    LupusPlayerState_NotJoined,
    LupusPlayerState_Joined,
    LupusPlayerState_JoinedAndReady,
};

@interface MasterState : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, assign) LupusMasterState state;
@property (nonatomic, strong) NSArray *playersState;

@end

@interface PlayerState : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) LupusPlayerRole role;
@property (nonatomic, assign) LupusPlayerState state;

@end

@interface LupusGame : NSObject

@property (nonatomic, assign, readonly, getter = isMaster) BOOL master;
@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;
@property (nonatomic, strong, readonly) MasterState *masterState;
@property (nonatomic, strong, readonly) PlayerState *playerState;

+ (id)lupusGameWithHostName:(NSString *)name
                    options:(NSDictionary *)options;

+ (id)lupusGameWithPlayerName:(NSString *)name;

- (MCBrowserViewController *)browser;
- (void)disconnect;
- (void)setStateForPlayer:(LupusPlayerState)state;

@end

@interface LupusGame (Deck)

+ (id)cardForRole:(LupusPlayerRole)role;
+ (NSArray *)newDeckForPlayersCount:(NSUInteger)players;

@end
