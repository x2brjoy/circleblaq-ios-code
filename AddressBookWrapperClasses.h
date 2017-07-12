//
//  AddressBookWrapperClasses.h
//  Sup
//
//  Created by Rahul Sharma on 9/24/15.
//  Copyright © 2015 3embed. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UpdateContactStringDelegate <NSObject>
-(void)updateContact: (NSMutableArray *)contactString;
-(void)reloadFavtableView;
@end

@interface AddressBookWrapperClasses : NSObject

/**
 *  @brief get shared instance of AddressBook
 *
 *  @return 
 */
+ (instancetype) sharedInstance:(BOOL)isContactModified;
@property (nonatomic,strong) NSMutableArray *firstTimePhoneNumbers;
@property (nonatomic,strong) NSMutableArray *modifiedPhoneNumbers;
@property (weak, nonatomic) id <UpdateContactStringDelegate> updateDelegate;

-(void)sendLeftnumberToServer;
-(void)checkContacisChanged;

@end
