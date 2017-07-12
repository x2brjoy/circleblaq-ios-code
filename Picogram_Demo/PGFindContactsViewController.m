//
//  FindContactsViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGFindContactsViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PGAddContactsViewController.h"
#import "PicogramSocketIOWrapper.h"
@interface PGFindContactsViewController ()<SocketWrapperDelegate>
@property (strong, nonatomic) PicogramSocketIOWrapper *client;
@end

@implementation PGFindContactsViewController
{
    NSString *resultString ;
    NSDictionary *contactDic;
}

#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activityViewIndicator.hidden = YES;
    
    self.client = [PicogramSocketIOWrapper sharedInstance];
    self.client.socketdelegate = self;
    
    //PrivateContacts
    
   
     //_addVc = [[PGAddContactsViewController alloc] init];
   
    /**
     * Here checking the device which user using and if it is not 4s/5/5s then changing the height and width of picoram logo.
     *  The height of 4s is 480 and height of 5/5s is 568.
     *
     */
    if(CGRectGetHeight(self.view.frame) !=480 && CGRectGetHeight(self.view.frame) !=568 && CGRectGetHeight(self.view.frame) !=548) {
        _searchYouContactsButtonHeightConstraint.constant = 50;
    }
}

- (IBAction)skipButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"findContactsToHomeViewTabBarSeguew" sender:nil];
}
- (IBAction)searchYourContactsButtonAction:(id)sender {
    
    [self.searchContctsButtonOutlet setTitle:@"" forState:UIControlStateNormal];
    self.searchContctsButtonOutlet.enabled = NO;
    self.activityViewIndicator.hidden = NO;
    [self .activityViewIndicator startAnimating];
//    [self loadPhoneContacts];
    [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:@"phoneContacts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"syncOnlyPhoneContacs" forKey:@"syncingContacts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"findPhoneContactsSegue" sender:nil];
    //

}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)loadPhoneContacts{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
     if (status == kABAuthorizationStatusDenied) {
        
        // if you got here, user had previously denied/revoked permission for your
        
        // app to access the contacts, and all you can do is handle this gracefully,
        
        // perhaps telling the user that they have to go to settings to grant access
        
        // to contacts
           [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
     if (error) {
        
        NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
        
        if (addressBook) CFRelease(addressBook);
        
        return;
        
    }
      if (status == kABAuthorizationStatusNotDetermined) {
         // present the user the UI that requests permission to contacts ...
         ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
            }
            if (granted) {
                // if they gave you permission, then just carry on
                [self listPeopleInAddressBook:addressBook];
            } else {
                
                // however, if they didn't give you permission, handle it gracefully, for example...
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // BTW, this is not on the main thread, so dispatch UI updates back to the main queue
                    
                    
                    
                    [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                });
            }
            if (addressBook) CFRelease(addressBook);
        });
    } else if (status == kABAuthorizationStatusAuthorized) {
        [self listPeopleInAddressBook:addressBook];
        if (addressBook) CFRelease(addressBook);
    }
}
- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook {
    self.client = [PicogramSocketIOWrapper sharedInstance];
    self.client.socketdelegate = self;
    NSString *phoneNumber;
    NSInteger numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSMutableArray  *onlyPhoneNumbers = [[NSMutableArray alloc] init];;
     for (NSInteger i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSLog(@"Name:%@ %@", firstName, lastName);
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
          phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            NSLog(@"  phone:%@", phoneNumber);
        }
        CFRelease(phoneNumbers);
        NSLog(@"=============================================");
         if (phoneNumber) {
             [onlyPhoneNumbers addObject:phoneNumber];
         }
         
    }
    
     NSLog(@"number of contacts:%lu",(unsigned long)onlyPhoneNumbers.count);
     self.greeting = [onlyPhoneNumbers componentsJoinedByString:@","];
     NSLog(@"%@",self.greeting);
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,+"] invertedSet];
    resultString = [[self.greeting componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSLog (@"Result: %@", resultString);
    
     [self.client syncContacts:resultString];
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
//        
//        
//        [self.client syncContacts:resultString];
//    });
    
    [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:@"phoneContacts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  
    [[NSUserDefaults standardUserDefaults] setObject:@"syncOnlyPhoneContacs" forKey:@"syncingContacts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
   [self performSegueWithIdentifier:@"findPhoneContactsSegue" sender:nil];
//    
//    @try {
//        //[self performSegueWithIdentifier:@"findPhoneContactsSegue" sender:nil];
//    } @catch (NSException *exception) {
//        NSLog(@"exception/:%@",exception);
//        
//    } @finally {
//       
//    }
    
}

- (void)facebookLogin:(NSDictionary *)dictionary {
}


#pragma mark- SocketDelegate
-(void)responseFromChannels:(NSDictionary *)responseDictionary
{

    NSLog(@"Contact Response:%@",responseDictionary);
    contactDic = responseDictionary;
     [self performSegueWithIdentifier:@"findPhoneContactsSegue" sender:nil];
    
   
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"getResponseFromCallChannel" object:nil userInfo:responseDictionary];

   
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
       dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
           if([segue.identifier isEqualToString:@"findPhoneContactsSegue"]) {
            
            PGAddContactsViewController *vc = [segue destinationViewController];
            vc.contactsString = resultString;
            vc.phoneContactsSyncResponseDataa = contactDic;
            
            //sending fb id for registering.
        }});
}

@end
