//
//  SaloonInfoViewController.h
//  Zuri
//
//  Created by Rahul_Sharma on 24/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol saloonDetailsEnteredDelegate<NSObject>
-(void)saloondetalis:(NSString *)nameOfSaloon address:(NSString *)addressOfSaloon caption:(NSString *)caption;
@end
@interface SaloonInfoViewController : UIViewController
@property (nonatomic, weak) id <saloonDetailsEnteredDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *stylistNameTextField;
@property (weak, nonatomic) IBOutlet UIView *stlishNameTextFieldSuperView;
@property (weak, nonatomic) IBOutlet UITextField *stylistAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (strong,nonatomic)  NSString *selectedProduct;
@end
