//
//  AlertForNumberConformation.m
//  TrustPalsApp
//
//  Created by Rahul Sharma on 2/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "AlertForNumberConformation.h"

@implementation AlertForNumberConformation


@synthesize popView;
@synthesize delegate;

- (instancetype)init{
    
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"AlertForNumberConformationView"
                                          owner:self
                                        options:nil] firstObject];
    self = [super init];
    return self;
   
}

- (void)showAlertrPopupWithMobileNumber:(NSString *)phoneNumber onWindow:(UIWindow *)window {
    
  _phnNumber.text=phoneNumber;
    self.frame = window.frame;
    [window addSubview:self];
    
    [self layoutIfNeeded];
    
}

- (IBAction)okBUtton:(id)sender
{
    [delegate okButtonClicked];
}

- (IBAction)editButtonAction:(id)sender {
    
    [delegate editButtonClicked];
}

@end
