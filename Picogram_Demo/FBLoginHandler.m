                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
//
//  FBLoginHandler.m
//  FBShareSample
//
//  Created by Surender Rathore on 17/12/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//


#import "FBLoginHandler.h"
#import <Accounts/Accounts.h>
#import "PGAddContactsViewController.h"

@interface FBLoginHandler ()

@property (strong, nonatomic) NSArray *readPermission;
@property (strong, nonatomic) NSDictionary *parameters;

@end

@implementation FBLoginHandler

static FBLoginHandler *share;

+ (id)sharedInstance {
    
    if (!share) {
        share  = [[self alloc] init];
    }
    return share;
}
- (instancetype)init {
    
    if (self = [super init]) {
        self.readPermission = @[@"public_profile", @"email", @"user_friends"];
        self.parameters = @{@"fields": @"id, name, first_name, last_name, picture.type(large), email"};
    }
    return self;
}

/**
 *  Login with facebook
 */
- (void)loginWithFacebook:(UIViewController *)viewController
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [login setLoginBehavior:FBSDKLoginBehaviorNative];
    [login logInWithReadPermissions:self.readPermission
                 fromViewController:viewController
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                
                                if (error)
                                {
                                    NSLog(@"Login error : %@",[error localizedDescription]);
                                    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailWithError:)])
                                    {
                                        [self.delegate didFailWithError:error];
                                    }
                                }
                                else if (result.isCancelled)
                                {
                                    NSLog(@"Cancelled");
                                    if (self.delegate && [self.delegate respondsToSelector:@selector(didUserCancelLogin)])
                                    {
                                        [self.delegate didUserCancelLogin];
                                    }
                                }
                                else
                                    {
                                    NSLog(@"Logged in");
                                    [self getDetailsFromFacebook];
                                    //[self inviteFaceBookFriends];
                                    //[self fetchUserInfo];
                                }
                                
                            }];
}

-(void)fetchUserInfo
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id,name,link,first_name, last_name, picture.type(large), email, birthday, bio ,location ,friends ,hometown , friendlists,user_friends"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error)
             {
                 NSLog(@"result : %@",result);
             }
         }];
        
    }
}


-(void)inviteFaceBookFriends  {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/{friendlist-id}"
                                  parameters:self.parameters
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
    }];
}

/**
 *  Get User details
 */
- (void)getDetailsFromFacebook {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                       parameters:self.parameters];
        
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
        {
            if (error) {
                NSLog(@"Getting details error : %@",[error localizedDescription]);
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFailWithError:)])
                {
                    [self.delegate didFailWithError:error];
                }
            }
            else {
                NSLog(@"Fetched user:%@", result);
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFacebookUserLoginWithDetails:)])
                {
                       NSMutableArray *arrayOfFacebookIds =[[NSMutableArray alloc] init];
                       NSArray *faceBookid = result[@"friends"][@"data"];
                       NSLog(@"id of facebook friends....%@",faceBookid);
                        for(int i = 0; i< faceBookid.count;i++) {
                       NSString *faceBookFriendId = faceBookid[i][@"id"];
                        NSLog(@"onlyId:%@",faceBookFriendId);
                        [arrayOfFacebookIds addObject:faceBookFriendId];
                    }
                    
                   self.facebookIdsInStringFormat = [arrayOfFacebookIds componentsJoinedByString:@","];
                    NSLog(@"%@",self.facebookIdsInStringFormat);
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.facebookIdsInStringFormat forKey:@"preferenceName"];
                     [[NSUserDefaults standardUserDefaults] synchronize];

                    
                    [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"userFbDetails"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                      [self.delegate didFacebookUserLoginWithDetails:result];
                }
            }
        }];
    }
}

- (NSString *)getDetailsFromFacebookUpdate {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                       parameters:self.parameters];
        
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
         {
             if (error) {
                 NSLog(@"Getting details error : %@",[error localizedDescription]);
                 if (self.delegate && [self.delegate respondsToSelector:@selector(didFailWithError:)])
                 {
                     [self.delegate didFailWithError:error];
                 }
             }
             else {
                 NSLog(@"Fetched user:%@", result);
                 
                 if (self.delegate && [self.delegate respondsToSelector:@selector(didFacebookUserLoginWithDetails:)])
                 {
                     NSMutableArray *arrayOfFacebookIds =[[NSMutableArray alloc] init];
                     NSArray *faceBookid = result[@"friends"][@"data"];
                     NSLog(@"id of facebook friends....%@",faceBookid);
                     for(int i = 0; i< faceBookid.count;i++) {
                         NSString *faceBookFriendId = faceBookid[i][@"id"];
                         NSLog(@"onlyId:%@",faceBookFriendId);
                         [arrayOfFacebookIds addObject:faceBookFriendId];
                     }
                     
                     self.facebookIdsInStringFormat = [arrayOfFacebookIds componentsJoinedByString:@","];
                     NSLog(@"%@",self.facebookIdsInStringFormat);
                     
                     [[NSUserDefaults standardUserDefaults] setObject:self.facebookIdsInStringFormat forKey:@"preferenceName"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     
                     [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"userFbDetails"];
                     [[NSUserDefaults standardUserDefaults] synchronize];
                     
                     [self.delegate didFacebookUserLoginWithDetails:result];
                 }
             }
         }];
        return self.facebookIdsInStringFormat;
    }
    return 0;
}



@end
