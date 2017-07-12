//
//  FindFaceBookContactsViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 5/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindFaceBookContactsViewController : UIViewController
- (IBAction)connectToFaceBookButtonAction:(id)sender;
- (IBAction)skipButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connectToFbHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *connectToFbButtonOutlet;

@end
