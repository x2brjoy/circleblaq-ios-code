//
//  UsersVC.m
//  LayerIntegratedChat
//
//  Created by Rahul Sharma on 10/7/15.
//  Copyright © 2015 3embed. All rights reserved.
//

#import "UsersVC.h"
#import "Database.h"

@implementation UsersVC

//- (instancetype)initWithParticipantIdentifier:(Favorites *)participantIdentifier participateIdentifiers:(NSString *)identifier {
//    self = [super init];
//    if (self) {
//        
//        if(!participantIdentifier)
//        {
//            NSArray *obj = [self participantObj:identifier];
//            if([obj count] == 0)
//            {
//                _avatarImageUrl = @"";
//                _participantIdentifier = identifier;
//                _firstName = identifier;
//                _lastName = identifier;
//                _fullName = identifier;
//                _avatarInitials = [identifier substringToIndex:1];
//            }
//            else{
//                for (Favorites *favObj in obj) {
//                    
//                    _avatarImageUrl = favObj.image;
//                _participantIdentifier = favObj.supNumber;
//                _firstName = favObj.fullName;
//                _fullName = favObj.fullName;
//                if(favObj.fullName.length>1)
//                {
//                    _avatarInitials = [favObj.fullName substringToIndex:1];
//                }
//                }
//            }
//        }
//        else{
//            _participantIdentifier = participantIdentifier.supNumber;
//            _fullName = participantIdentifier.fullName;
//            _firstName = participantIdentifier.fullName;
//            
//            if(participantIdentifier.fullName.length>1)
//            {
//                _avatarInitials = [participantIdentifier.fullName substringToIndex:1];
//            }
//        }
//    }
//    return self;
//}

//+ (instancetype)userWithParticipantIdentifier:(Favorites *)participantIdentifier {
//    return [[self alloc] initWithParticipantIdentifier:participantIdentifier participateIdentifiers:nil];
//}

//+(instancetype)userWithParticipantIdentifiar:(NSString *)identifier
//{
////    return [[self alloc] initWithParticipantIdentifier:nil participateIdentifiers:identifier];
//}

-(NSArray *)participantObj :(NSString *)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"supNumber = %@",identifier];
    NSArray *favObj = [Database favoriteObjectWithMatchingPhoneNumber:predicate];
    if(favObj.count==0)
    {
        return nil;
    }
    return favObj;
}

@end
