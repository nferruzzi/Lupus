//
//  GameViewController.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 15/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import "GameViewController.h"
#import "Lupus.h"
#import "ShowCardViewController.h"

@interface GameViewController () <UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *arrayJoinedOnly;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barbutton_counter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barbutton_ready;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barbutton_message;
@property (assign, nonatomic) BOOL cardShow;
@end

@implementation GameViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (!_game.isMaster) {
        [_game setStateForPlayer:LupusPlayerState_Joined];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(onBack:)];

    // Configure first time
    [self onMasterStateChanged:nil];
    
    self.navigationController.toolbarHidden = FALSE;
    self.toolbarItems = _toolbar.items;
    [self.toolbar removeFromSuperview];
    
    if (_game.isMaster) {
        [self.barbutton_ready setTitle:@"Start!"];
        [self.barbutton_ready setAction:@selector(onStart:)];
    }
    
    [self.barbutton_message setTarget:self];
    [self.barbutton_message setAction:@selector(onMessage:)];
}

- (void)onBack:(id)sender
{
    [self.game disconnect];
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMasterStateChanged:)
                                                 name:LupusMasterStateChanged
                                               object:_game];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onMasterStateChanged:(NSNotification *)notification
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        PlayerState *ps = evaluatedObject;
        return ps.state >= LupusPlayerState_Joined;
    }];

    self.arrayJoinedOnly = [_game.masterState.playersState filteredArrayUsingPredicate:predicate];

    if (!_game.isMaster) {
        self.barbutton_ready.enabled = _game.playerState.state != LupusPlayerState_JoinedAndReady;
    }

    NSInteger ready = 0;
    for (PlayerState *ps in _arrayJoinedOnly) {
        if (ps.state == LupusPlayerState_JoinedAndReady) ++ready;
    }
    
    BOOL startable = [_arrayJoinedOnly count] == ready && ready > 1;

    if (_game.isMaster) {
        self.barbutton_ready.enabled = startable;
    }
    
    NSString *message;
    BOOL started = FALSE;

    _barbutton_message.enabled = FALSE;
    
    switch (_game.masterState.state) {
        case LupusMasterState_Started:
            if (_game.isMaster) {
                message = @"Game started!";
            } else {
                NSDictionary *card = [LupusGame cardForRole:_game.playerState.role];
                message = [card objectForKey:@"label"];
                _barbutton_message.enabled = TRUE;
            }
            started = TRUE;
            break;
            
        case LupusMasterState_WaitingForPlayers:
            if (startable)
                message = @"Ready to go!";
            else
                message = @"Waiting for players";
            break;
            
        default:
            break;
    }
    
    _barbutton_message.title = message;

    
    NSString *title = [NSString stringWithFormat:@"%ld/%lu", (long)ready, (unsigned long)[_arrayJoinedOnly count]];
    self.barbutton_counter.title = title;
    
    [self.tableView reloadData];
    
    if (!_cardShow && started) {
        _cardShow = TRUE;
        [self performSegueWithIdentifier:@"segue_card" sender:nil];
    }
}

- (IBAction)onReady:(id)sender
{
    NSAssert(!_game.isMaster, @"I'm a master");
    [_game setStateForPlayer:LupusPlayerState_JoinedAndReady];
}

- (IBAction)onStart:(id)sender
{
    NSAssert(_game.isMaster, @"I'm a player");
    [_game startGame];
}

- (void)onMessage:(id)sender
{
    NSDictionary *card = [LupusGame cardForRole:_game.playerState.role];

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Ruolo"
                                                 message:[card objectForKey:@"desc"]
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:@"Capito", nil];
    [av show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_card"]) {
        ShowCardViewController *vc = segue.destinationViewController;
        vc.role = _game.playerState.role;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_arrayJoinedOnly count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"player"
                                                            forIndexPath:indexPath];
    
    // NON FATE I FURBI !!!
    PlayerState *ps = [_arrayJoinedOnly objectAtIndex:indexPath.row];
    BOOL me = ps == _game.playerState;
    BOOL showCard = _game.isMaster || me;

    cell.textLabel.text = ps.name;
    
    if (ps.state == LupusPlayerState_JoinedAndReady) {
        if (me && _game.masterState.state == LupusMasterState_Started) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.imageView.image = nil;

    if (showCard) {
        NSDictionary *card = [LupusGame cardForRole:ps.role];
        NSArray *images = [card objectForKey:@"images"];
        if (images) {
            cell.imageView.image = [UIImage imageNamed:[images objectAtIndex:0]];
        }
    }
    
    cell.backgroundColor = me ? [UIColor yellowColor] : [UIColor whiteColor];
    cell.selectionStyle = me ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_game.masterState.state == LupusMasterState_Started) {
        PlayerState *ps = [_arrayJoinedOnly objectAtIndex:indexPath.row];
        if (ps == _game.playerState) {
            [self performSegueWithIdentifier:@"segue_card" sender:nil];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:FALSE];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
