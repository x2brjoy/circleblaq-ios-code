//
//  ProfileViewXib.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol profileViewDelegate <NSObject>

/**
 *  editprofile button action
 *
 *  @param sender calling editprofilebuttonclicked method in userProfileViewController.
 */

- (void)editProfileButtonClicked;

@end
@interface ProfileViewXib : UIView

/**
 *  declaring  delegate.
 */

@property (nonatomic, weak) id <profileViewDelegate> delegate;

- (void)showAlertrPopupWithMobileNumber:(UIWindow *)window;

/**
 *  editprofile button action
 *
 *  @param sender calling editprofilebuttonclicked
 */
- (IBAction)editProfileButtonAction:(id)sender;

@end
