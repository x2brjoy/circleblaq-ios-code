//
//  WebServiceHandler.m
//  Snappit
//
//  Created by 3Embed on 03/12/15.
//  Copyright (c) 2014 3Embed. All rights reserved.
//

#import "WebServiceHandler.h"
#import <AFNetworking/AFNetworking.h>

@implementation WebServiceHandler

#pragma mark - Private Methods

/*
 @method makeRequestFor
 @abstract Private method to make request and forward the response to calling class
 @param requestType - Request Type for the request
 @param request - NSURLRequest for the request
 @param delegate - id<WebServiceHandlerDelegate> calling class object
 @result void
 */


+ (void) makeRequest:(RequestType)requestType
             request:(NSURLRequest*)request
            delegate:(id<WebServiceHandlerDelegate>)delegate
{
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:responseObject error:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:nil error:error];
        }
        
    }];
    
    [operation start];
}

/*
 @method makePostRequestFor
 @abstract Private method to make request and forward the response to calling class
 @param requestType - Request Type for the request
 @param request - NSURLRequest for the request
 @param delegate - id<WebServiceHandlerDelegate> calling class object
 @result void
 */

+ (void) makePostRequest:(RequestType)requestType
                    path:(NSString*)path
                  params:(NSDictionary*)params
                bsaeUrl : (NSString *)baseUrl
                delegate:(id<WebServiceHandlerDelegate>)delegate
{
    NSLog(@"makePostRequest: %@, %@, %@", path, params, baseUrl);
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", nil];
    [manager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        //here is place for code executed in success case
        
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:responseObject error:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        //here is place for code executed in success case
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:nil error:error];
        }
    }];
}


+ (void) makePostRequestFor:(RequestType)requestType
                       path:(NSString*)path
                     params:(NSDictionary*)params
                   bsaeUrl : (NSString *)baseUrl
                   delegate:(id<WebServiceHandlerDelegate>)delegate
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", nil];
    [manager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"JSON: %@", responseObject);
        //here is place for code executed in success case
        
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:responseObject error:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        //here is place for code executed in success case
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:nil error:error];
        }
        
    }];
}

+ (void) getRequest:(RequestType)requestType
               path:(NSString*)path
             params:(NSDictionary*)params
           bsaeUrl : (NSString *)baseUrl
           delegate:(id<WebServiceHandlerDelegate>)delegate
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", nil];
    
    [manager GET:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        {
            [manager.requestSerializer setValue:@"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MjA2LCJuYW1lIjoiamFja2llIiwiZW1haWwiOiJqYWNraWVAZ21haWwuY29tIiwiaWF0IjoxNDYzMDM1MDA0LCJleHAiOjE0NjgyMTkwMDR9.u1WvwFtMITtjMqKMI7e5H4JNPJoRkkXWr0Zxqgmpbnc" forHTTPHeaderField:@"token"];
        }
        //here is place for code executed in success case
        
        
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:responseObject error:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        //here is place for code executed in success case
        if (delegate && [delegate respondsToSelector:@selector(didFinishLoadingRequest:withResponse:error:)]) {
            [delegate didFinishLoadingRequest:requestType withResponse:nil error:error];
        }
    }];
}

#pragma mark - Public Methods

+ (void) signUpId:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeSignUp path:mRequestTypeSignup params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
    
}

+ (void) logId:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeLogin path:mRequestTypeLogin params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
    
}
+ (void) emailCheck:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    NSLog(@"emailcheck: baseUrl: %@", iPhoneBaseURL);
    [self makePostRequest:RequestTypeEmailCheck path:mRequestTypeEmailCheck params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) phoneNumberCheck:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypePhoneNumberCheck path:mRequestTypePhoneNumberCheck params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) userNameCheck:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypeUserNameCheck path:mRequestTypeUserNameCheck params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) newRegistration:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypenewRegister path:mRequestTypenewRegister params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) faceBookContactSync:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeLoginfaceBookContactSync path:mRequestTypeLoginfaceBookContactSync params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) phoneContactSync:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypePhoneContactSync path:mRequestTypePhoneContactSync params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) postImageOrVideo:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypePost path:mRequestTypePost params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) follow:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeFollow path:mRequestTypeFollow params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getFollowRequestsForPrivateUsers:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetFollowRequestForAccept path:mRequestTypegetFollowRequestsForPrivateUsers params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) followMultipleUsers:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeFollowMultiple path:mRequestTypeFollowMultiple params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) unFollow:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeFollow path:mRequestTypeUnFollow params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) generateOtp:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypeotpGeneration path:mRequestTypeotpGeneration params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) getUserPosts:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypemakePostRequest path:mgetuserPosts   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getHashTagSuggestion:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetHashTagsSuggestion path:mgetHashTagsSuggestion params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getUserNameSuggestion:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetTagFriendsSuggestion path:mgetUserNameSuggestion params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getSearchPeople:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetSearchPeople path:@"searchUsers" params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) getExplorePosts:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetExploreposts path:mgetExplorePosts params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) getTop:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetTop path:mgetTop params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getFollowersList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetFollowersList path:mgetFollowersList params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getFollowingList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetFollowingList path:mgetFollwingList params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getCloudinaryCredintials:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeCloudinaryCredintials path:mgetCloudinaryCredintials params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getPostsInHOmeScreen:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypegetPostsInHOmeScreen path:mgetPostsInHOmeScreen params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) commentOnPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypePostComment path:mPostComment params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getMemberPosts:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypemakeMemberPosts path:mMemberPosts   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)feedback:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequestFor:RequestTypeFeedBack path:mreportAProblem   params:params bsaeUrl:@"http://159.203.143.251:3000/api/user" delegate:delegate];
}

+ (void) getUserProfileDetails:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypemakeUserProfileDetails path:mMembergetUserProfileBasics   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}


+ (void)resetPassword:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypemakeresetPassword path:mRequestTypresetPassword   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getMemberFollowersList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetMemberFollowersList path:mgetMemberFollowersList params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getMemberFollowingList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypeGetMemberFollowingList path:mgetMemberFollowingList params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getUserFriendsDetails:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypeUserProfileDetails path:mgetUserProfileDetails
                   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) deletePost:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypeDeletePost path:mdeletePost
                   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) RequestTypeSavingProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate{
    [self makePostRequest:RequestTypeSavingProfile path:mRequestTypeSavingProfile   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) RequestTypeEditProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypeEditProfile path:mRequestTypeEditProfile   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) RequestTypepostsbasedonhashtag:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypebasedonhashtag path:mpostsbasedonhashtag   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) RequestTypepostsbasedonLocation:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypebasedonLoaction path:mpostsbasedonLoaction   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}


+ (void) RequestTypepostsOfYou:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypePhotosOfYou path:mPhotosOfYou   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) RequestTypeEmailCheckEditProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate{
    [self makePostRequest:RequestTypeEmailCheckInEditProfile path:mRequestTypeEmailCheckInEditProfile   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) RequestTypePhoneNumberCheckEditProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate{
    [self makePostRequest:RequestTypePhoneNumberCheckEditProfile path:mRequestTypePhoneNumberCheckInEditProfile   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) RequestTypeupdatePhoneNumber:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate{
    [self makePostRequest:RequestTypeupdatePhoneNumber path:mRequestTypePhoneNumberUpdate   params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}


+ (void) getCommentsOnPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetCommentsOnPost path:mGetCommentsOnPost params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) likeAPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeLikeAPost path:mLikeAPost params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) unlikeAPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeUnlikeAPost path:mUnlikeAPost params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) getAllLikesOnPost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetAllLikesOnPost path:mGetAllLikesOnPost params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) discoverPeople:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeDiscoverPeople path:mdiscoverPeople params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) getUserSearchHistory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypegetUserSearchHistory path:mgetUserSearchHistory params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) addTosearchHistory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeAddToSearchHistory path:maddToSearch params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) followingActivities:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypefollowingActivity path:mRequestTypefollowingActivity params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) ownActivities:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeOwnActivity path:mRequestTypeOwnActivity params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)sendreportPost:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypereportPost path:mRequestTypereportPost params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) deleteComment:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypedeleteComments path:mRequestTypedeleteComments params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void) getPhotosOfMember:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypegetPhotosOfMember path:mRequestTypegetPhotosOfMember params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void)  setPrivateProfile:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypesetPrivateProfile path:mrequesttypesetPrivateProfile params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) accceptFollowRequest:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeaccceptFollowRequest path:mRequestTypeaccceptFollowRequest params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void) hideFromDiscovery:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypehideFromDiscovery path:mRequestTypehideFromDiscovery params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)singlePost:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate {
    [self makePostRequest:RequestTypeGetPostsDetailsForActivity path:mRequestTypegetPostsDetailsForActivity params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)updradeToBusniessProfile:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetupdradeToBusniessProfile path:mRequestTypeupdradeToBusniessProfile params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)businessPostProduct:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypebusinessPostProduct path:mRequestTypebusinessPostProduct params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)getCategory:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetCategories path:mRequestTypeGetCategories params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)getSubCategory:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetSubCategories path:mRequestTypeGetSubCategories params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)downgradeFromBusinessProfile:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeDowngradeFromBusinessProfile path:mRequestTypeDowngradeFromBusinessProfile params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)getCurrency:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypegetCurrency path:mRequestTypeGetCurrency params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)searchProductsByCategory:(NSDictionary *)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypesearchProductsByCategory path:mRequestTypeSearchProductsByCategory params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)getProductsByCategoryAndSubcategory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypeGetProductsByCategoryAndSubcategory path:mgetProductsByCategoryAndSubcategory params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)logDevice:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypelogDevice path:mRequestTypelogDevice params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)getChatList:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate{
    [self makePostRequest:RequestTypegetUserFollowRelation path:mRequestTypegetUserFollowRelation params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}

+ (void)getCallHistory:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate{
    [self makePostRequest:RequestTypegetgetCallHistory path:mRequestTypegetgetCallHistory params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}
+ (void)getUserDetailsbyID:(NSDictionary*)params andDelegate:(id<WebServiceHandlerDelegate>)delegate
{
    [self makePostRequest:RequestTypegetUserById path:mRequestTypegetUserById params:params bsaeUrl:iPhoneBaseURL delegate:delegate];
}



@end
