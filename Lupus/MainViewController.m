//
//  MainViewController.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 08/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import "MainViewController.h"
#import "Lupus.h"
#import "GameViewController.h"

@interface MainViewController () <MCBrowserViewControllerDelegate>

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (strong, nonatomic) LupusGame *game;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.game disconnect];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segue_game"]) {
        GameViewController *gvc = segue.destinationViewController;
        [gvc setGame:_game];
    }
}

- (IBAction)onCreate:(id)sender
{
    self.game = [LupusGame lupusGameWithHostName:[[UIDevice currentDevice] name] options:nil];
    [self performSegueWithIdentifier:@"segue_game" sender:nil];
}

- (IBAction)onSearch:(id)sender
{
    self.game = [LupusGame lupusGameWithPlayerName:[[UIDevice currentDevice] name]];

    MCBrowserViewController *vc = [self.game browser];
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:true];
    [self.navigationController setNavigationBarHidden:TRUE];
}

#pragma mark - MCBrowserViewController delegate

// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController.browser stopBrowsingForPeers];
    [self.navigationController setNavigationBarHidden:FALSE];
    GameViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"game"];
    [vc setGame:_game];
    [self.navigationController setViewControllers:@[self, vc] animated:TRUE];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController.browser stopBrowsingForPeers];
    [self.navigationController setNavigationBarHidden:FALSE];
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
