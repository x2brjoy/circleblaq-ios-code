//
//  EditProfileViewController.h
//  Pods
//
//  Created by Rahul Sharma on 5/5/16.
//
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController<UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImageViewOutlet;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UITextField *bioTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *genderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTopConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewOutlet;
- (IBAction)emailAddressButtonAction:(id)sender;
- (IBAction)phoneNumberButtonAction:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *businessNameLbl;
@property (strong, nonatomic) IBOutlet UITextView *aboutBusinessTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgconstraint;
@property BOOL necessarytocallEditProfile;
@property UIImage *profilepic;
@property (weak, nonatomic) IBOutlet UILabel *editLabel;
@property (strong,nonatomic) UIImagePickerController *imgpicker;

@property (weak, nonatomic) IBOutlet UIView *viewForActivityIndicator;

@property (weak, nonatomic) IBOutlet UIView *viewForDetails;
@property NSString *profilepicurl;


@property NSString *pushingVcFrom;

@property (weak, nonatomic) IBOutlet UITextView *bioTextViewOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bussinessBioTextViewSuperViewHeightConstr;
@property (strong, nonatomic) IBOutlet UIImageView *businessIconImg;

@property (strong, nonatomic) IBOutlet UITextView *aboutbussinessTextViewOutlet;
@property (strong, nonatomic) IBOutlet UIView *businessViewOutlet;
@property (strong, nonatomic) IBOutlet UIView *editBaseviewOutlet;

@end
