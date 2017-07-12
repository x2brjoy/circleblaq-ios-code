//
//  FindFaceBookContactsViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 5/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "FindFaceBookContactsViewController.h"
#import "PGAddContactsViewController.h"
#import "FBLoginHandler.h"


@interface FindFaceBookContactsViewController ()<FBLoginHandlerDelegate>

@end

@implementation FindFaceBookContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [self.view layoutIfNeeded];
    _connectToFbButtonOutlet.layer.cornerRadius = 5;
    
    
    /**
     * Here checking the device which user using and if it is not 4s/5/5s then changing the height and width of picoram logo.
     *  The height of 4s is 480 and height of 5/5s is 568.
     *
     */
    if(CGRectGetHeight(self.view.frame) !=480 && CGRectGetHeight(self.view.frame) !=568 && CGRectGetHeight(self.view.frame) !=548) {
        _connectToFbHeightConstraint.constant = 50;
    }
}

- (IBAction)connectToFaceBookButtonAction:(id)sender {
    
    
    //if user already login then no need to request for fb login othewise need to show fb login page.
    
    NSString *listOfFaceBookIds = [[NSUserDefaults standardUserDefaults]
                                   stringForKey:@"preferenceName"];
    
    if (listOfFaceBookIds) {
        // request for facebook contact syncing.
        //getting list of faceBook friends id.
       
        
        [[NSUserDefaults standardUserDefaults] setObject:@"syncOnlyfaceBookContacts" forKey:@"syncingContacts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSegueWithIdentifier:@"findFbContactsSegue" sender:nil];
    }
    else {
        FBLoginHandler *handler = [FBLoginHandler sharedInstance];
        [handler loginWithFacebook:self];
        [handler setDelegate:self];
    }

// //request for fb.
//    FBLoginHandler *handler = [FBLoginHandler sharedInstance];
//    [handler loginWithFacebook:self];
//    [handler setDelegate:self];
}

- (IBAction)skipButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"findFacebookContactsToPhoneContactsSegue" sender:self];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark
#pragma mark - facebook

/**
 *  Facebook login is success
 *
 *  @param userInfo Userdict
 */
- (void)didFacebookUserLoginWithDetails:(NSDictionary*)userInfo {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"syncOnlyfaceBookContacts" forKey:@"syncingContacts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"findFbContactsSegue" sender:nil];
    NSLog(@"FB Data =  %@", userInfo);
    
}

/**
 *  Login failed with error
 *
 *  @param error error
 */
- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
/**
 *  User cancelled
 */
- (void)didUserCancelLogin {
    NSLog(@"USER CANCELED THE LOGIN");
}



#pragma mark - Facebook Methods

/**
 *  Response from Facebook
 *
 *  @param dictionary Details dict
 */

- (void)facebookLogin:(NSDictionary *)dictionary {
}


@end
