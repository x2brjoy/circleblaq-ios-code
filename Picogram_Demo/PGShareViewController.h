//
//  ShareViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/16/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ListOfTagFriendsTableViewCell.h"
#import <SCRecorder/SCPlayer.h>
#import <SCRecorder/SCVideoPlayerView.h>
#import  <SCRecorder/SCRecordSession.h>
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"


@interface PGShareViewController : UIViewController<UIScrollViewDelegate,UITextViewDelegate,MKMapViewDelegate, CLLocationManagerDelegate,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SCPlayerDelegate> {
@private
    CLLocationManager *locationManager;
}
@property (weak, nonatomic) IBOutlet UICollectionView *placesSuggestionCollectionView;

//constraints outlets
@property (weak, nonatomic) IBOutlet UIView *followersViewOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTopConstraintOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *PlacesSuggestionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *socialMediaViewTopConstraint;
@property (strong, nonatomic) IBOutlet UIView *activityView;
@property (strong, nonatomic) IBOutlet UIScrollView *baseScrollview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightOUtletConstraint;



//imageView outlets
@property (weak, nonatomic) IBOutlet UIImageView *highlatedImageView;

@property (weak, nonatomic) IBOutlet UIImageView *shareImageOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *locationCancelImgaeOutlet;
@property (strong,nonatomic) UIImage *image2;

//label outlets

@property (weak, nonatomic) IBOutlet UILabel *distanceFromLocationOutlet;
@property (weak, nonatomic) IBOutlet UILabel *locationLabelOutlet;
@property (weak, nonatomic) IBOutlet UIButton *tagPeopleButtonOutlet;

//button outlets
@property (strong, nonatomic) IBOutlet UIView *addlocationView;

@property (weak, nonatomic) IBOutlet UIButton *loactionCancelButtonAction;
@property (weak, nonatomic) IBOutlet UIButton *addLocationButtonOutlet;
@property (strong, nonatomic) IBOutlet UIView *socialMediaView;

//textView Outlets
@property (weak, nonatomic) IBOutlet UITextView *captionTextViewOutlet;

//location

@property(nonatomic,strong)CLLocation *currentLocation;
@property (nonatomic,strong) CLLocationManager *locationManager;

//view outlets
@property (weak, nonatomic) IBOutlet UIView *textViewSuperViewOutlet;

@property (weak, nonatomic) IBOutlet UIView *tappedImageView;
@property (weak, nonatomic) IBOutlet UIView *baseScrollView;
@property (weak, nonatomic) IBOutlet UIView *searchViewOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tableviewOutlet;
@property (weak, nonatomic) IBOutlet UITableView *tagFriendsTableView;
@property (weak, nonatomic) IBOutlet UIView *viewForDismissKeyBoard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *tagPeopleView;

//button actions
- (IBAction)tagPeopleButtonAction:(id)sender;
- (IBAction)addLocationButtonAction:(id)sender;
- (IBAction)loactionCancelButtonAction:(id)sender;

- (IBAction)FacebookAction:(id)sender;
- (IBAction)twitterAction:(id)sender;
- (IBAction)instgramAction:(id)sender;
@property (strong, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *instgramSwitch;

@property (weak, nonatomic) IBOutlet UIButton *InstagrambuttonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *TwitterButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *facebookButtonOutlet;
@property NSData* videoData;


@property NSString *postedImagePath;
@property NSString *postedthumbNailImagePath;

@property(nonatomic,strong)NSArray *searchResults;
@property(nonatomic,strong)NSArray *firstResut;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailsOfTaggedFriendsLabelWidthContstraint;
@property (weak, nonatomic) IBOutlet UILabel *detailsOfTaggedFriendsLabel;


@property NSString *pathOfVideo;
@property SCRecordSession *recordsession;
@property (nonatomic,strong) SCPlayer *player;
@property (weak, nonatomic) IBOutlet UIView *viewForVideo;
@property bool sharingVideo;
@property NSString *imageForVideoThumabnailpath;
@property UIImage *videoimg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagPeopleViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *dividerOnTagPeopleView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraintOfAddLocationView;


@end
