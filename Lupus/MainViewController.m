//
//  MainViewController.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 08/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import "MainViewController.h"
#import "Lupus.h"

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onCreate:(id)sender
{
    self.view.backgroundColor = [UIColor redColor];
    self.game = [LupusGame lupusGameWithHostName:[[UIDevice currentDevice] name] options:nil];
}

- (IBAction)onSearch:(id)sender
{
    self.view.backgroundColor = [UIColor greenColor];
    self.game = [LupusGame lupusGameWithPlayerName:[[UIDevice currentDevice] name]];
    MCBrowserViewController *vc = [self.game browser];
    vc.delegate = self;
    [self presentViewController:vc
                       animated:true
                     completion:^{
                         [vc.browser startBrowsingForPeers];
                     }];
}

// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController.browser stopBrowsingForPeers];
    [browserViewController dismissViewControllerAnimated:true completion:nil];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController.browser stopBrowsingForPeers];
    [browserViewController dismissViewControllerAnimated:true completion:nil];
}

@end
