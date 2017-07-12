//
//  AskingPermissonViewController.h
//  Picogram
//
//  Created by Rahul_Sharma on 09/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AskingPermissonViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *permissionButton;
- (IBAction)permissionButonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property NSString *message;
@property NSString *tittle;
@property NSString *buttonTitle;
@property NSString *navBarTitle;

@end
