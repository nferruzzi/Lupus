//
//  GameViewController.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 15/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import "GameViewController.h"
#import "Lupus.h"

@interface GameViewController ()
@property (nonatomic, strong) NSArray *arrayJoinedOnly;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barbutton_counter;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barbutton_ready;
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
    
    if (_game.isMaster) {
        BOOL startable = [_arrayJoinedOnly count] == ready && ready > 1;
        self.barbutton_ready.enabled = startable;
    }
    
    NSString *title = [NSString stringWithFormat:@"%ld/%lu", (long)ready, (unsigned long)[_arrayJoinedOnly count]];
    self.barbutton_counter.title = title;
    
    [self.tableView reloadData];
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
    
    // Configure the cell...
    PlayerState *ps = [_arrayJoinedOnly objectAtIndex:indexPath.row];
    cell.textLabel.text = ps.name;
    
    if (ps.state == LupusPlayerState_JoinedAndReady) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // NON FATE I FURBI !!!
    BOOL me = ps == _game.playerState;
    BOOL showCard = _game.isMaster || me;

    cell.imageView.image = nil;

    if (showCard) {
        NSDictionary *card = [LupusGame cardForRole:ps.role];
        NSArray *images = [card objectForKey:@"images"];
        if (images) {
            cell.imageView.image = [UIImage imageNamed:[images objectAtIndex:0]];
        }
    }
    
    cell.backgroundColor = me ? [UIColor yellowColor] : [UIColor whiteColor];

    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
