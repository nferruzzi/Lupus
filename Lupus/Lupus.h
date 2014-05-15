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
    LupusRoleVillico,
    LupusRoleLupoMannaro,
    LupusRoleGuardia,
    LupusRoleMedium,
    LupusRoleVeggente,
    LupusRoleTopoMannaro,
    LupusRoleMassone
};

@interface LupusGame : NSObject

@property (nonatomic, assign, readonly, getter = isMaster) BOOL master;
@property (nonatomic, assign, readonly, getter = isConnectedToMaster) BOOL connectedToMaster;
@property (nonatomic, strong, readonly) NSString *name;

+ (id)lupusGameWithHostName:(NSString *)name
                    options:(NSDictionary *)options;

+ (id)lupusGameWithPlayerName:(NSString *)name;

- (MCBrowserViewController *)browser;

@end

@interface LupusGame (Deck)

+ (id)cardForRole:(LupusRole)role;
+ (NSArray *)newDeckForPlayersCount:(NSUInteger)players;

@end
