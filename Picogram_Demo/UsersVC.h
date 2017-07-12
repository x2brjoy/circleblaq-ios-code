//
//  UsersVC.h
//  LayerIntegratedChat
//
//  Created by Rahul Sharma on 10/7/15.
//  Copyright © 2015 3embed. All rights reserved.
//

//#import <LayerKit/LayerKit.h>
#import <Foundation/Foundation.h>
//#import "Atlas.h"
//#import "Favorites.h"
#import <UIKit/UIKit.h>

@interface UsersVC : NSObject//<ATLParticipant,ATLAvatarItem>


@property(nonatomic) NSString *firstName;
@property(nonatomic) NSString *lastName;
@property(nonatomic) NSString *fullName;
@property(nonatomic) NSString *participantIdentifier;
@property(nonatomic) UIImage *avatarImage;
@property(nonatomic) NSString *avatarInitials;
@property (nonatomic)NSString *avatarImageUrl;

//- (instancetype)initWithParticipantIdentifier:(Favorites *)participantIdentifier participateIdentifiers:(NSString *)identifier ;

//+ (instancetype)userWithParticipantIdentifier:(Favorites *)participantIdentifier;
//+ (instancetype)userWithParticipantIdentifiar:(NSString *)participantIdentifier;


@end
