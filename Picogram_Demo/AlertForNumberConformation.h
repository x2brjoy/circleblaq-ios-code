//
//  AlertForNumberConformation.h
//  TrustPalsApp
//
//  Created by Rahul Sharma on 2/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlertForNumberConformationPopUpViewDelegate <NSObject>


- (void)okButtonClicked;
- (void)editButtonClicked;


@end

@interface AlertForNumberConformation : UIView

@property (nonatomic, weak) id<AlertForNumberConformationPopUpViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *popView;
- (IBAction)okBUtton:(id)sender;
- (IBAction)editButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *phnNumber;

- (void)showAlertrPopupWithMobileNumber:(NSString *)phoneNumber onWindow:(UIWindow *)window;

@end
