//
//  ShowCardViewController.m
//  Lupus
//
//  Created by Nicola Ferruzzi on 20/05/14.
//  Copyright (c) 2014 Nicola Ferruzzi. All rights reserved.
//

#import "ShowCardViewController.h"

@interface ShowCardViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iv_card;
@property (weak, nonatomic) IBOutlet UIImageView *iv_copertina;
@property (weak, nonatomic) IBOutlet UIButton *button_close;

@end

@implementation ShowCardViewController

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
    // Do any additional setup after loading the view.
    NSDictionary *card = [LupusGame cardForRole:_role];
    NSArray *imgs = [card objectForKey:@"images"];
    NSString *img = [imgs objectAtIndex:arc4random_uniform((u_int32_t)[imgs count])];
    UIImage *image = [UIImage imageNamed:img];

    self.iv_card.alpha = 0.0f;
    self.iv_card.image = image;
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

- (IBAction)onButtonClose:(id)sender
{
    [self dismissViewControllerAnimated:TRUE
                             completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.iv_copertina.alpha = 0.0f;
                         self.iv_card.alpha = 1.0f;
                        }
                     completion:^(BOOL finished) {
                        }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.iv_copertina.alpha = 1.0f;
                         self.iv_card.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}
@end
