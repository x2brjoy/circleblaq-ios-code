//
//  ContactData.m
//  Sup
//
//  Created by Rahul Sharma on 04/04/15.
//  Copyright (c) 2015 3embed. All rights reserved.
//

#import "ContactData.h"

@implementation ContactData

-(instancetype)initWithfirstName:(NSString *)firstName
                        lastName:(NSString *)lastName
                     phoneNumber:(NSMutableDictionary *)phoneNumber
                           image:(UIImage *)image
{
    self = [super init];
    if(self)
    {
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumber = phoneNumber;
        _images = image;
    }
        return self;
}

@end
