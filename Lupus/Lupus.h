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

// Games role
typedef NS_ENUM(NSInteger, LupusRole) {
    LupusRole_Villico,
    LupusRole_LupoMannaro,
    LupusRole_Guardia,
    LupusRole_Medium,
    LupusRole_Veggente,
    LupusRole_TopoMannaro,
    LupusRole_Massone
};

// Game state
typedef NS_ENUM(NSInteger, LupusGameState) {
    LupusGameState_Uninitialized,
    LupusGameState_WaitingForPlayers,
    LupusGameState_Started,
};

// Peer state
typedef NS_ENUM(NSInteger, LupusPeerState) {
    LupusPeerState_NotReady,
    LupusPeerState_Ready,
};

@interface LupusGame : NSObject

@property (nonatomic, assign, readonly, getter = isMaster) BOOL master;
@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;

@property (nonatomic, strong, readonly) NSArray *playersName;
@property (nonatomic, assign, readonly) LupusGameState gameState;
@property (nonatomic, assign, readonly) LupusRole peerRole;
@property (nonatomic, assign) LupusPeerState peerState;

+ (id)lupusGameWithHostName:(NSString *)name
                    options:(NSDictionary *)options;

+ (id)lupusGameWithPlayerName:(NSString *)name;

- (MCBrowserViewController *)browser;

@end

@interface LupusGame (Deck)

+ (id)cardForRole:(LupusRole)role;
+ (NSArray *)newDeckForPlayersCount:(NSUInteger)players;

@end
