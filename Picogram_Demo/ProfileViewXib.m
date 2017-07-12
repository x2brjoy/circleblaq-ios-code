//
//  ProfileViewXib.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ProfileViewXib.h"

@implementation ProfileViewXib

@synthesize delegate;

- (instancetype)init{
    
    self = [super init];
    self = [[[NSBundle mainBundle] loadNibNamed:@"ContentView"
                                          owner:self
                                        options:nil] firstObject];
    return self;
}

- (void)showAlertrPopupWithMobileNumber:(UIWindow *)window {
    
    
    CGRect frameOfSelf = self.frame;
    frameOfSelf.size.width = CGRectGetWidth(window.frame);
    self.frame = frameOfSelf;
//    
//    
//    
//    self.frame = window.frame;
//    [window addSubview:self];
    [self layoutIfNeeded];
}


- (IBAction)editProfileButtonAction:(id)sender
{
    [delegate editProfileButtonClicked];
}

@end
