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
typedef NS_ENUM(NSInteger, LupusClientRole) {
    LupusClientRole_Villico,
    LupusClientRole_LupoMannaro,
    LupusClientRole_Guardia,
    LupusClientRole_Medium,
    LupusClientRole_Veggente,
    LupusClientRole_TopoMannaro,
    LupusClientRole_Massone
};

// Game state
typedef NS_ENUM(NSInteger, LupusMasterState) {
    LupusMasterState_Uninitialized,
    LupusMasterState_WaitingForPlayers,
    LupusMasterState_Started,
};

// Peer state
typedef NS_ENUM(NSInteger, LupusClientState) {
    LupusClientState_NotReady,
    LupusClientState_Ready,
};

@interface MasterState : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, assign) LupusMasterState state;
@property (nonatomic, strong) NSArray *playersName;

@end

@interface PlayerState : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, assign) LupusClientRole role;
@property (nonatomic, assign) LupusClientState state;

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

@end

@interface LupusGame (Deck)

+ (id)cardForRole:(LupusClientRole)role;
+ (NSArray *)newDeckForPlayersCount:(NSUInteger)players;

@end
