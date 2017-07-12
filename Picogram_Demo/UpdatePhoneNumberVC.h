//
//  UpdatePhoneNumberVC.h
//  Picogram
//
//  Created by Rahul Sharma on 7/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UpdatePhoneNumberVC : UIViewController


@property (weak, nonatomic) IBOutlet UIButton *countryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) NSString *controllerName;
- (IBAction)countrySelectionButton:(id)sender;
@property NSString *otpRecieved;
@property NSString *phoneNumberWithCountryCode;
@end
