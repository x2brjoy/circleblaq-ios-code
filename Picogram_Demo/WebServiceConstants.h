//
//  WebServiceConstants.h
//  Snappit
//
//  Created by 3Embed on 03/12/15.
//  Copyright (c) 2014 3Embed. All rights reserved.
//

#ifndef Menuse_WebServiceConstants_h
#define Menuse_WebServiceConstants_h
#define PicogramPlacesApi_Key @"AIzaSyBftFk-tvzLdfJXIGd-5sAM7LS7W2liOtI"
// change
//#define iPhoneBaseURL @"http://159.203.143.251:3000/api/"
#define iPhoneBaseURL @"http://34.200.147.144:3000/api"
#define adminGalleryURL @""//@"http://108.166.190.172:81/picogram/fbgallerys1.php?id"
// change
//#define fixedUrlForCloudinary @"http://res.cloudinary.com/dr49tdlw2/image/upload/"
#define fixedUrlForCloudinary @"http://res.cloudinary.com/circleblaq/image/upload/"


 //http://35.161.105.21:3000/api/register

//@"http://159.203.143.251:3000/api/" -- for yayway

typedef enum : NSUInteger {
    RequestTypeCheckPhoneNumber,
    RequestTypeVerify,
    RequestResendCode,
    RequestTypeLogin,
    RequestTypeLoginfaceBookContactSync,
    RequestTypeEmailCheck,
    RequestTypePhoneNumberCheck,
    RequestTypeUserNameCheck,
    RequestTypenewRegister,
    RequestTypeotpGeneration,
    RequestTypePhoneContactSync,
    RequestTypePost,
    RequestTypeFollow,
    RequestTypeFollowMultiple,
    RequestTypeunFollow,
    RequestTypeGetuserPosts,
    RequestTypeSignUp,
    RequestTypemakePostRequest,
    RequestTypeGetHashTagsSuggestion,
    RequestTypeGetTagFriendsSuggestion,
    RequestTypeGetSearchPeople,
    RequestTypeGetExploreposts,
    RequestTypeGetTop,
    RequestTypeGetFollowersList,
    RequestTypeGetFollowingList,
    RequestTypeCloudinaryCredintials,
    RequestTypegetPostsInHOmeScreen,
    RequestTypePostComment,
    RequestTypemakeMemberPosts,
    RequestTypeFeedBack,
    RequestTypemakeUserProfileDetails,
    RequestTypemakeresetPassword,
    RequestTypeGetMemberFollowersList,
    RequestTypeGetMemberFollowingList,
    RequestTypeUserProfileDetails,
    RequestTypeDeletePost,
    RequestTypeSavingProfile,
    RequestTypeEmailCheckInEditProfile,
    RequestTypePhoneNumberCheckEditProfile,
    RequestTypeupdatePhoneNumber,
    RequestTypeEditProfile,
    RequestTypebasedonhashtag,
    RequestTypebasedonLoaction,
    RequestTypePhotosOfYou,
    RequestTypefollowingActivity,
    RequestTypeOwnActivity,
    RequestTypedeleteComments,
    RequestTypereportPost,
     RequestTypegetPhotosOfMember,
    RequestTypeGetCommentsOnPost,
    RequestTypeLikeAPost,
    RequestTypeUnlikeAPost,
    RequestTypeGetAllLikesOnPost,
    RequestTypeDiscoverPeople,
    RequestTypegetUserSearchHistory,
    RequestTypeAddToSearchHistory,
    RequestTypesetPrivateProfile,
    RequestTypeaccceptFollowRequest,
    RequestTypehideFromDiscovery,
    RequestTypeGetFollowRequestForAccept,
    RequestTypeGetPostsDetailsForActivity,
    RequestTypelogDevice,
    RequestTypebusinessPostProduct,
    RequestTypeGetupdradeToBusniessProfile,
    RequestTypeGetCategories,
    RequestTypeGetSubCategories,
    RequestTypeDowngradeFromBusinessProfile,
    RequestTypegetCurrency,
    RequestTypesearchProductsByCategory,
    RequestTypeGetProductsByCategoryAndSubcategory,
    // Chat Start
    RequestTypegetUserFollowRelation,
    RequestTypegetgetCallHistory,
    RequestTypegetUserById
    // Chat End
  
} RequestType;

//methods

// Chat Start

#define mRequestTypegetUserFollowRelation                   @"getUserFollowRelation"
#define mRequestTypegetgetCallHistory                       @"getCallHistory"
#define mRequestTypegetUserById                             @"getUserById"

// Chat End

#define mRequestTypereportPost                  @"reportPost"
#define mRequestTypeLogin                                   @"login"
#define mRequestTypeSignup                                  @"signup"
#define mRequestTypeEmailCheck                              @"emailCheck"
#define mRequestTypePhoneNumberCheck                        @"phoneNumberCheck"
#define mRequestTypeUserNameCheck                           @"usernameCheck"
#define mRequestTypenewRegister                             @"register"
#define mRequestTypeotpGeneration                           @"generateOTP"
#define mRequestTypeLoginfaceBookContactSync                @"facebookContactSync"
#define mRequestTypePhoneContactSync                        @"phoneContactSync"
#define mRequestTypePost                                    @"userPosts"
#define mRequestTypeFollow                                  @"follow"
#define mRequestTypegetFollowRequestsForPrivateUsers        @"getFollowRequestsForPrivateUsers"
#define mRequestTypeUnFollow                                @"unfollow"
#define mRequestTypeFollowMultiple                          @"followMultipleUsers"
#define mRequestTypeGetuserPosts                            @"userPosts"
#define mgetuserPosts                                       @"getuserPosts"
#define mgetHashTagsSuggestion                              @"getHashTagSuggetion"
#define mgetUserNameSuggestion                              @"getUsersForTagging"
#define mgetExplorePosts                                    @"search-explore"

#define mrequesttypesetPrivateProfile                       @"setPrivateProfile"
#define mRequestTypehideFromDiscovery                       @"hideFromDiscovery"
#define mfollowAction                                        @"action"
#define mRequestTypeaccceptFollowRequest                     @"accceptFollowRequest"
#define mRequestTypeupdradeToBusniessProfile                @"updradeToBusniessProfile"
#define mRequestTypebusinessPostProduct                     @"businessPostProduct"
#define mRequestTypeGetCategories                           @"getCategories"
#define mRequestTypeGetSubCategories                        @"getSubCategories"
#define mRequestTypeDowngradeFromBusinessProfile            @"downgradeFromBusinessProfile"
#define mRequestTypeGetCurrency                             @"getCurrency"
#define mRequestTypeSearchProductsByCategory                @"searchProductsByCategory"

#define mgetTop                                             @"search"
#define mgetFollowersList                                   @"getFollowers"
#define mgetFollwingList                                    @"getFollowing"
#define mgetCloudinaryCredintials                           @"getSignature"
#define mgetPostsInHOmeScreen                               @"home"
#define mPostComment                                        @"comments"
#define mMemberPosts                                        @"member-profile"

#define mreportAProblem                                      @"reportAProblem"
#define mMembergetUserProfileBasics                         @"getUserProfileBasics"
#define mgetMemberFollowersList                             @"getMemberFollowers"
#define mgetMemberFollowingList                             @"getMemberFollowing"
#define mgetUserProfileDetails                              @"getUserProfile"
#define mdeletePost                                         @"deletePosts"
#define mRequestTypeSavingProfile                           @"saveProfile"
#define mRequestTypeEmailCheckInEditProfile                 @"check_mail"
#define mRequestTypePhoneNumberCheckInEditProfile           @"checkPhoneNumber"
#define mRequestTypeEditProfile                             @"editProfile"
#define mpostsbasedonhashtag                                @"getPostsOnHashTags"
#define mpostsbasedonLoaction                               @"getPostsByLocation"
#define mPhotosOfYou                                        @"getPhotosOfYou"
#define mRequestTypePhoneNumberUpdate                       @"updatePhoneNumber"
#define mRequestTypresetPassword                            @"resetPassword"


#define mGetCommentsOnPost                      @"getPostComments"
#define mLikeAPost                              @"like"
#define mUnlikeAPost                            @"unlike"
#define mGetAllLikesOnPost                      @"getAllLikes"

#define mdiscoverPeople                         @"discover-people-website"   
#define mgetUserSearchHistory                   @"getUserSearchHistory"
#define maddToSearch                            @"searchHistory"

#define mRequestTypefollowingActivity           @"followingActivity"
#define mRequestTypeOwnActivity                 @"selfActivity"
#define mRequestTypedeleteComments              @"deleteCommentsFromPost"
#define mRequestTypegetPhotosOfMember           @"getPhotosOfMember"
#define mRequestTypegetPostsDetailsForActivity  @"getPostsDetailsForActivity"


#define mDevicePhoneNo                          @"Phone"
#define mDeviceBrand                            @"brand"
#define mContryCode                             @"CountryCode"
#define mOnlyNumber                             @"OnlyNumber"

#define mRequestTypelogDevice                   @"logDevice"

//parameters

#define mEmail                                   @"email"
#define mphoneNumber                             @"phoneNumber"
#define mfbuniqueid                              @"facebookId"
#define mUserName                                @"username"
#define mPswd                                    @"password"
#define mDeviceType                              @"deviceType"
#define mDeviceId                                @"deviceId"
#define mProfileUrl                              @"profilePicUrl"
#define mSignUpType                              @"signUpType"
#define userDetailKey                            @"userDetail"
#define userDetailForBussiness                            @"userDetailBussiness"
#define cloudinartyDetails                       @"cloudinaryDetails"
#define misPrivate                               @"isPrivate"
#define mdeviceToken                             @"deviceToken"


#pragma mark - BusinessProfile
#define mproblemExplaination                        @"problemExplaination"
#define mprice                                      @"price"
#define mproductUrl                                 @"productUrl"
#define mcategory                                   @"category"
#define msubCategory                                @"subCategory"
#define mcurrency                                   @"currency"
#define mproductName                                @"productName"
#define mgetProductsByCategoryAndSubcategory        @"getProductsByCategoryAndSubcategory"
#define mbusinessName                               @"businessName"
#define maboutBusiness                              @"aboutBusiness"

#define userDetailkeyWhileRegistration       @"userDetailWhileRegistration"
#define mpushToken                           @"pushToken"
#define mfaceBookId                          @"facebookId"
#define mauthToken                           @"token"
#define mcontacts                            @"contactNumbers"
#define mtype                                @"type"
#define mmailUrl                             @"mainUrl"
#define mthumbeNailUrl                       @"thumbnailUrl"
#define mpostCaption                         @"postCaption"
#define mhashTags                            @"hashTags"
#define mplace                               @"place"
#define musersTagged                         @"usersTagged"
#define muserNameTofollow                    @"userNameToFollow"
#define muserNameToUnFollow                  @"unfollowUserName"
#define mfaceBookLogin                       @"facebookLogin"
#define mfaceBookId                          @"facebookId"
#define macesstoken                          @"xaccesstoken"
#define mhashTag                             @"hashtag"
#define muserTosearch                        @"userToBeSearched"
#define mKeyToSearch                         @"keyToSearch"
#define mcomment                             @"comment"
#define mposttype                            @"postType"
#define mpostid                              @"postId"
#define mmemberName                          @"membername"
#define mlocation                            @"location"
#define mlatitude                            @"latitude"
#define mlongitude                           @"longitude"
#define moffset                              @"offset"
#define mfullName                            @"fullName"
#define mwebsite                             @"website"
#define mbio                                 @"bio"
#define mgender                              @"gender"
#define mlimit                               @"limit"
#define motp                                 @"otp"
#define mContainerHeight                     @"containerHeight"
#define mcontainerWidth                      @"containerWidth"
#define maddToSearchKey                      @"searchKey"
#define mcommentId                           @"commentId"
#define mmembername                          @"membername"
#define mhasAudio                            @"hasAudio"
#define muserCoordinates                     @"userCoordinates"
#define mfeature                             @"feature"
#define mproblemExplaination                 @"problemExplaination"

#define userprofileDetails                   @"userProfile"

#define mLabel                              @"label"


#define kController                         @"ControllerType"
#endif
