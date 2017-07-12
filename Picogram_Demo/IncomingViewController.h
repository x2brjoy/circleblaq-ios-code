//
//  IncomingViewController.h
//  Sup
//
//  Created by Rahul Sharma on 4/4/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "soundHelper.h"

@interface IncomingViewController : UIViewController

{
    int value;
}
@property (weak, nonatomic) IBOutlet UIImageView *callerImageView;
@property (weak, nonatomic) IBOutlet UILabel *callerName;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIImageView *sliderOne;
@property (strong, nonatomic) IBOutlet UIImageView *sliderTwo;
@property (strong, nonatomic) IBOutlet UIImageView *sliderThree;
@property (strong, nonatomic) IBOutlet UIButton *acceptCallButton;
@property (strong, nonatomic) IBOutlet UIButton *rejectCallButton;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UIButton *endCallButton;
- (IBAction)endCallAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *rejectLbl;
@property (weak, nonatomic) IBOutlet UILabel *acceptLbl;

@property (weak, nonatomic) IBOutlet UILabel *callTitleLbl;

- (IBAction)acceptCallButtonAction:(id)sender;
- (IBAction)rejectCallButtonAction:(id)sender;

- (IBAction)messageButtonAction:(id)sender;

@property (strong) NSMutableArray *friendesList;

@end
