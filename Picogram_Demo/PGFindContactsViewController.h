//
//  FindContactsViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PGAddContactsViewController.h"

@interface PGFindContactsViewController : UIViewController

@property (weak,nonatomic) NSString *greeting;

@property (weak, nonatomic) IBOutlet UIButton *learnMoreButtonAction;
- (IBAction)searchYourContactsButtonAction:(id)sender;
- (IBAction)skipButtonAction:(id)sender;
//@property (nonatomic,strong) NSString *syncContactsOf;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchYouContactsButtonHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *searchContctsButtonOutlet;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewIndicator;

@end
