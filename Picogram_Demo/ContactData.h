//
//  ContactData.h
//  Sup
//
//  Created by Rahul Sharma on 04/04/15.
//  Copyright (c) 2015 3embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContactData : NSObject
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property(strong,nonatomic) NSMutableDictionary *phoneNumber;
@property  (strong, nonatomic) UIImage *images;

- (instancetype)initWithfirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
                      phoneNumber:(NSMutableDictionary *)phoneNumber
                           image : (UIImage *)image;

@end
