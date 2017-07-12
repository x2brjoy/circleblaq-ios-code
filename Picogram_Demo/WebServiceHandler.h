//
//  WebServiceHandler.h
//  Snappit
//
//  Created by 3Embed on 03/12/15.
//  Copyright (c) 2014 3Embed. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "WebServiceConstants.h"

/*
 @protocol WebServiceHandlerDelegate
 @abstract protocol to be iplemented by the calling class to get the response
*/
@protocol WebServiceHandlerDelegate <NSObject>

/*
 @method didFinishLoadingRequest
 @abstract Method called when web service request is complete
 @param requestType - Request Type for this request
 @param response - id Response of this request. Can be nil in case of an error.
 @param error - NSError - error object in case of any error. Nil in case of success.
*/
@required
- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error;

@end

/*
 @class WebServiceHandler
 @abstract Class to handle request and response of web services
*/

@interface WebServiceHandler : NSObject

/*
 @method getPhotosWithDelegate
 @abstract Method to get photos from the service
 @param delegate - calling class object to recieve the response. Response is delivered WebServiceHandlerDelegate protocol method didFinishLoadingRequest
 @result void
*/


+ (void) signUpId:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) logId:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) emailCheck:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) phoneNumberCheck:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) userNameCheck:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) newRegistration:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) generateOtp:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) faceBookContactSync:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) phoneContactSync:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) postImageOrVideo:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) follow:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) unFollow:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getUserPosts:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getHashTagSuggestion:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getUserNameSuggestion:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getFollowingList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getFollowersList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getCloudinaryCredintials:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getPostsInHOmeScreen:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) commentOnPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getMemberPosts:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getMemberFollowingList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getMemberFollowersList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getUserFriendsDetails:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypeSavingProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypeEditProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypepostsbasedonhashtag:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypepostsOfYou:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypeEmailCheckEditProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypePhoneNumberCheckEditProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypeupdatePhoneNumber:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) RequestTypepostsbasedonLocation:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getExplorePosts:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) deletePost:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getSearchPeople:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
;
+ (void) followMultipleUsers:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getUserProfileDetails:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;

+ (void) getUserSearchHistory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
;
+ (void) addTosearchHistory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getTop:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;

+ (void) getCommentsOnPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) likeAPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) unlikeAPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getAllLikesOnPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) discoverPeople:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) followingActivities:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) ownActivities:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) deleteComment:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getPhotosOfMember:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)  setPrivateProfile:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) accceptFollowRequest:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) hideFromDiscovery:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) getFollowRequestsForPrivateUsers:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)resetPassword:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)singlePost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;

+ (void) feedback:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)updradeToBusniessProfile:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)businessPostProduct:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)getCategory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)getSubCategory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)downgradeFromBusinessProfile:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)getCurrency:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)getProductsByCategoryAndSubcategory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)logDevice:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void) sendreportPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;

+ (void)getChatList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;

+ (void)getCallHistory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;
+ (void)getUserDetailsbyID:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate;

@end
