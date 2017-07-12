//
//  SelectAddressViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 29/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAddressViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *navigationLeftButton;


@property (weak, nonatomic) IBOutlet UIView *topAddressView;
@property (weak, nonatomic) IBOutlet UILabel *selectedAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property BOOL isFromProviderBookingVC;
- (IBAction)confirmLocationButtonAction:(id)sender;
- (IBAction)navigationBackButtonAction:(id)sender;


@end
