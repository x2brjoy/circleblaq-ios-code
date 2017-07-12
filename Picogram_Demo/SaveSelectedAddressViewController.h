//
//  SaveSelectedAddressViewController.h
//  iServe_AutoLayout
//
//  Created by Apple on 14/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SaveSelectedAddressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *selectedAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *flatNumberTextField;

@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *officeButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectedAddressLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;

@property (strong, nonatomic) NSDictionary *selectedAddressDetails;
@property (strong, nonatomic) NSString *selectedaddress;
@property BOOL isFromProviderBookingVC;


- (IBAction)tagAddressButtonAction:(id)sender;
- (IBAction)navigationBackButtonAction:(id)sender;
- (IBAction)saveAddressButtonAction:(id)sender;

@end
