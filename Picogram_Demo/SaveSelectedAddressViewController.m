//
//  SaveSelectedAddressViewController.m
//  Picogram
//
//  Created by Apple on 14/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "SaveSelectedAddressViewController.h"
#import "businessSetupViewController.h"
#import "TinderGenericUtility.h"
//#import "AddressManageViewController.h"

@interface SaveSelectedAddressViewController ()<UITextFieldDelegate>//WebServiceHandlerDelegate>
{
    NSInteger selectedTagButton;
    CGRect screenSize;
}

@end

@implementation SaveSelectedAddressViewController

#pragma mark - Initial Methods -
- (void)viewDidLoad {
    
    [super viewDidLoad];
    selectedTagButton = 3;
    self.otherButton.selected = YES;
    screenSize = [[UIScreen mainScreen]bounds];
  
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
     [[self navigationController] setNavigationBarHidden:NO animated:YES];
   // [[AMSlideMenuMainViewController getInstanceForVC:self]  disableSlidePanGestureForLeftMenu];
    self.selectedAddressLabel.text = self.selectedAddressDetails[@"address"];
    self.selectedAddressLabelHeightConstraint.constant = [self measureHeightLabel:self.selectedAddressLabel]+8;
    
}
-(void)viewDidAppear:(BOOL)animated
{
    
}

#pragma mark - Custom Methods -

- (CGFloat)measureHeightLabel: (UILabel *)label
{
    CGSize constrainedSize = CGSizeMake(screenSize.size.width-20 , 9999);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:label.font.fontName size:label.font.pointSize], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:label.text attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGRect newFrame = label.frame;
    newFrame.size.height = requiredHeight.size.height;
    return  newFrame.size.height;
}


#pragma mark - UIBUtton Action -

- (IBAction)tagAddressButtonAction:(id)sender
{
    UIButton *tagButton = (UIButton *)sender;
    for (UIView *button in tagButton.superview.subviews)
    {
        if ([button isKindOfClass:[UIButton class]])
        {
            [(UIButton *)button setSelected:NO];
        }
    }
    tagButton.selected = YES;
    selectedTagButton = tagButton.tag;
    
}

- (IBAction)navigationBackButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAddressButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [self sendRequestToSaveAddress];
}

#pragma mark - KeyBoard Methods -

- (void)keyboardHiding:(__unused NSNotification *)inputViewNotification
{
    UIEdgeInsets ei = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    self.scrollView.contentOffset = CGPointMake(0,0);
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.scrollView.scrollIndicatorInsets = ei;
        self.scrollView.contentInset = ei;
    }];
}

- (void)keyboardShowing:(__unused NSNotification *)inputViewNotification
{
    
    CGRect inputViewFrame = [[[inputViewNotification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect inputViewFrameInView = [self.view convertRect:inputViewFrame fromView:nil];
    CGRect intersection = CGRectIntersection(self.scrollView.frame, inputViewFrameInView);
    UIEdgeInsets ei = UIEdgeInsetsMake(0.0,0.0, intersection.size.height, 0.0);
    self.scrollView.scrollIndicatorInsets = ei;
    self.scrollView.contentInset = ei;
}

#pragma mark - UITextField Delegate methods -

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Web Service Call -

-(void)sendRequestToSaveAddress
{
    NSString *addressStr = [NSString stringWithFormat:@"%@\n%@",self.selectedAddressDetails[@"address"],self.flatNumberTextField.text];
    NSLog(@"New address: %@",addressStr);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"passLatestAddress" object:addressStr];
    [[NSUserDefaults standardUserDefaults]setObject:flStrForStr(addressStr) forKey:@"address"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
                               for (UIViewController* viewController in self.navigationController.viewControllers) {
        
                                if ([viewController isKindOfClass:[businessSetupViewController class]] )
                                {
                                    [self.navigationController popToViewController:viewController animated:YES];
                                    return;
                                }
                               }
    
    
}

#pragma mark - Web service Delegate -
//
//-(void)didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError *)error{
//    
//    [[ProgressIndicator sharedInstance]hideProgressIndicator];
//    
//    if (error)
//    {
//        [UIHelper showMessage:error.localizedDescription withTitle:LS(@"Message")delegate:self];
//        return;
//    }
//    
//    NSInteger errFlag = [response[@"errFlag"] integerValue];
//    NSInteger errNum = [response[@"errNum"] integerValue];
//    
//    switch (errFlag) {
//        case 1:
//        {
//            if (errNum == 7 || errNum == 6 || errNum == 78 || errNum == 83)//Session Expired
//            {
//                [[Logout sharedInstance]deleteUserSavedData:response[@"errMsg"]];
//            }
//            else
//            {
//                [UIHelper showMessage:response[@"errMsg"] withTitle:LS(@"Message")delegate:self];
//            }
//        
//        }
//            break;
//            
//        case 0:
//        {
//            if(requestType == RequestTypeAddAddress)
//            {
//                NSString *selectedTagAddress;
//                switch (selectedTagButton) {
//                    case 1:
//                        selectedTagAddress = @"HOME";
//                        break;
//                    case 2:
//                        selectedTagAddress = @"OFFICE";
//                        break;
//                    case 3:
//                        selectedTagAddress = @"OTHER";
//                        break;
//                        
//                    default:
//                        selectedTagAddress = @"OTHER";
//                        break;
//                }
//
//                
//                NSDictionary *dict = @{
//                                       @"aid":response[@"addressid"],
//                                       @"address1":self.selectedAddressLabel.text,
//                                       @"suite_num":self.flatNumberTextField.text,
//                                       @"tag_address":selectedTagAddress,
//                                       @"lat":[NSString stringWithFormat:@"%@",self.selectedAddressDetails[@"lat"]],
//                                       @"long":[NSString stringWithFormat:@"%@",self.selectedAddressDetails[@"log"]],
//                                     };
//                [[Database sharedInstance]makeDataBaseEntryForManageAddress:dict];
//                [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
//                
//                if(self.isFromProviderBookingVC)
//                {
//                    for (UIViewController* viewController in self.navigationController.viewControllers) {
//                        
//                        if ([viewController isKindOfClass:[AddressManageViewController class]] )
//                        {
//                            [self.navigationController popToViewController:viewController animated:YES];
//                            return;
//                        }
//                    }
//                }
//                else
//                {
//                    [self.navigationController popToRootViewControllerAnimated:YES];
//                }
//                
//            }
//            
//        }
//            break;
//            
//        default:
//            break;
//    }
//    
//}


@end
