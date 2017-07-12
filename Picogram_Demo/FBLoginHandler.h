//
//  FBLoginHandler.h
//  FBShareSample
//
//  Created by "Surender Rathore" on 17/12/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FBSDKLoginKit/FBSDKLoginManagerLoginResult.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginButton.h>

@protocol FBLoginHandlerDelegate <NSObject>

/**
 *  Facebook login is success
 *
 *  @param userInfo Userdict
 */
- (void)didFacebookUserLoginWithDetails:(NSDictionary*)userInfo;
/**
 *  Login failed with error
 *
 *  @param error error
 */
- (void)didFailWithError:(NSError *)error;
/**
 *  User cancelled
 */
- (void)didUserCancelLogin;

@end

@interface FBLoginHandler : UIView

@property (nonatomic, weak) id<FBLoginHandlerDelegate> delegate;

+ (id)sharedInstance;
/**
 *  Login with facebook
 */
- (void)loginWithFacebook:(UIViewController *)viewController;

@property  NSString *facebookIdsInStringFormat;
- (NSString *)getDetailsFromFacebookUpdate;
@end
