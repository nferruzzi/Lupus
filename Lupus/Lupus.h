//
//  Lupus.h
//  Lupus
//
//  Created by Nicola Ferruzzi on 08/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lupus : NSObject

+ (Lupus *)shared;

- (void)createGame:(NSDictionary *)options;
- (void)showGames;

@end
