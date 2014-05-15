//
//  GameViewController.h
//  Lupus
//
//  Created by Nicola Ferruzzi on 15/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LupusGame;

@interface GameViewController : UITableViewController

@property (nonatomic, weak) LupusGame *game;

@end
