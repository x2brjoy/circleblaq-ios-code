//
//  HashTagViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 6/1/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "HashTagViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "HashTagImageCollectionViewCell.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "ProgressIndicator.h"
#import "DetailPostViewController.h"
#import "UIImageView+WebCache.h"
#import "ShareViewXib.h"
#import "FontDetailsClass.h"
#import "ListOfPostsViewController.h"
#import "Helper.h"
#import "InstaVIdeoTableViewController.h"
#import "TinderGenericUtility.h"

@interface HashTagViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,WebServiceHandlerDelegate,SDWebImageManagerDelegate,shareViewDelegate>
{
    ShareViewXib *shareNib;

    UIActivityIndicatorView  *activityIndicator;
    NSMutableDictionary *dataForListView;
    UIRefreshControl *refreshControl;
}

@end

@implementation HashTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =  self.navTittle ;
    //customizing navigationBar.
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
//    UIView *navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height-1,self.navigationController.navigationBar.frame.size.width,0.5)];
//    [navBorder setBackgroundColor:[UIColor colorWithRed:62.0f/255.0f green:72.0f/255.0f blue:97.0f/255.0f alpha:1.0f]];
//    [navBorder setOpaque:YES];
//    [self.navigationController.navigationBar addSubview:navBorder];
  
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    
    self.navigationItem.hidesBackButton = YES;
    [self createNavLeftButton];
    [self createActivityViewInNavbar];
    
    [[SDImageCache sharedImageCache] setMaxMemoryCost:1024 * 1024 * 1];
    [[SDImageCache sharedImageCache] setMaxCacheAge:3600 * 24 * 7];
    [[SDImageCache sharedImageCache] setShouldDecompressImages:YES];
    [[SDImageCache sharedImageCache] setShouldCacheImagesInMemory:NO];
    if ([_requestType isEqualToString:@"CategoryType"]) {
        if (_subCategory) {
            UILabel *titleLbl = [[UILabel alloc]init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"subcatecategoryIcon.png"];
            attachment.bounds = CGRectMake(0, 0, attachment.image.size.width, attachment.image.size.height);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@",_category]];
            [myString appendAttributedString:attachmentString];
            NSMutableAttributedString *myString1= [[NSMutableAttributedString alloc] initWithString:_subCategory];
            [myString appendAttributedString:myString1];
            
            titleLbl.attributedText = myString;
            [titleLbl sizeToFit];
            titleLbl.textColor = [UIColor blackColor];
            self.navigationItem.titleView = titleLbl;
        }
        
        [self requestForShoppingPost];
        
        
    }else
    [self requestForHashTags];
    [self addingRefreshControl];}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
     [self clearImageCache];
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.viewForNoPostsAvailable.hidden = YES;
    
    
    
//    ProgressIndicator *loginPI = [ProgressIndicator sharedInstance];
//    [loginPI showPIOnView:self.view withMessage:@"Fetching Posts"];
}

-(void)requestForShoppingPost {
    
    NSDictionary *requestDict = @{
                                  mauthToken :[Helper userToken],
                                  mcategory : flStrForObj(_category),
                                  msubCategory:flStrForObj(_subCategory)
                                  };
    [WebServiceHandler getProductsByCategoryAndSubcategory:requestDict andDelegate:self];
    
}


-(void)requestForHashTags {
    //removing #from string
    
    
    NSRange range = NSMakeRange(0,1);
    
    NSString *hashtag = [self.navTittle stringByReplacingCharactersInRange:range withString:@""];
    
    // Requesting For Post Api.(passing "token" as parameter)
    NSDictionary *requestDict = @{
                                  mauthToken :[Helper userToken],
                                  mhashTag:hashtag
                                  };
    [WebServiceHandler RequestTypepostsbasedonhashtag:requestDict andDelegate:self];
}


-(void)addingRefreshControl {
    refreshControl = [[UIRefreshControl alloc]init];
    [self.imageCollectionView addSubview:refreshControl];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshData:(id)sender {
    [self requestForHashTags];
}



#pragma mark
#pragma mark - navigation bar back button

- (void)createNavLeftButton {
    UIButton  *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}


//method for creating activityview in  navigation bar right.
- (void)createActivityViewInNavbar {
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:activityIndicator];
     activityIndicator.tag  = 1;
    [activityIndicator startAnimating];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)createNavRightButton
{
    UIButton *navNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navNextButton setImage:[UIImage imageNamed:@"hashtagh_send_icon_off"]
                   forState:UIControlStateNormal];
    [navNextButton setImage:[UIImage imageNamed:@"hashtagh_send_icon_on"]
                   forState:UIControlStateSelected];
    [navNextButton setTitleColor:[UIColor grayColor]
                        forState:UIControlStateHighlighted];
    
    [navNextButton setFrame:CGRectMake(5,17,45,45)];
    
    navNextButton.titleLabel.font =  [UIFont fontWithName:RobotoRegular size:13];
    
    
    
    [navNextButton addTarget:self action:@selector(shareButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navNextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)shareButtonAction:(UIButton *)sender {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    shareNib = [[ShareViewXib alloc] init];
    shareNib.delegate = self;
    [shareNib showViewWithContacts:window];
}

-(void)cancelButtonClicked
{
    [shareNib removeFromSuperview];
}


/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - collectionView Delegates and DataSource.
/*-----------------------------------------------------*/

/**
 *  declaring numberOfSectionsInCollectionView
 *
 *  @param collectionView declaring numberOfSectionsInCollectionView in collection view.
 *
 *  @return number of sctions in collection view here it is 1.
 */

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

/**
 *  declaring numberOfItemsInSection
 *  @param collectionView declaring numberOfItemsInSection in collection view.
 *  @param section    here only one section.
 *  @return number of items in collection view here it is 100.
 */

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //just for count.
    NSArray *arrayForCount = dataForListView[@"data"];
    return arrayForCount.count;
}


/**
 *  implementation of collection view cell
 *  @param collectionView collectionView has only image view
 *  @return implemented cell will return.
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
  
     HashTagImageCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hashtagcollectionCellIndentifier" forIndexPath:indexPath];
        

    
    NSString *thumbimgUrl = flStrForObj(dataForListView[@"data"][indexPath.row][@"thumbnailImageUrl"]);
    NSString *postType = flStrForObj(dataForListView[@"data"][indexPath.row][@"postsType"]);
    
    if([postType isEqualToString:@"1"]) {
        collectionViewCell.imageForShowVideoOrNot.hidden = NO;
    }
    else {
        collectionViewCell.imageForShowVideoOrNot.hidden = YES;
    }
    
    [collectionViewCell.imageOutlet sd_setImageWithURL:[NSURL URLWithString:thumbimgUrl]];
    
    collectionViewCell.layer.borderWidth=1.0f;
    collectionViewCell.layer.borderColor=[UIColor whiteColor].CGColor;
    collectionViewCell.contentView.backgroundColor =[UIColor clearColor];
    
    return collectionViewCell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake( CGRectGetWidth(self.view.frame)/3,CGRectGetWidth(self.view.frame)/3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
    newView.showListOfDataFor = @"ListViewForHashTags";
    newView.dataForListView = dataForListView;
    newView.movetoRowNumber =indexPath.item;
    if (_category) {
        newView.controllerType = @"Shopping";
        if(_subCategory)
            newView.category = _category;
           newView.subcategory = _subCategory;
            newView.navigationItem.titleView = self.navigationItem.titleView;
    }
    else
        newView.navigationBarTitle = self.navigationItem.title;
    [self.navigationController pushViewController:newView animated:YES];
    
    
    //old process
//    ListOfPostsViewController  *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"listViewVcStoryBoardId"];
//    newView.dataForListView = dataForListView;
//    newView.listViewForPostsOf = @"ListViewForHashTags";
//    newView.movetoRowNumber = indexPath.row;
//    newView.navTitle = self.navTittle;
//    [self.navigationController pushViewController:newView animated:YES];
}

/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
   
     [activityIndicator stopAnimating];
    
    //[self createNavRightButton];
    
      if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    
    //storing the response from server to dictonary.
    NSDictionary *responseDict = (NSDictionary*)response;
    
    //checking the request type and handling respective response code.
    
    if (requestType == RequestTypebasedonhashtag ) {
        
        [refreshControl endRefreshing];
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                dataForListView =  response;
                if(dataForListView.count == 0) {
                    self.viewForNoPostsAvailable.hidden = NO;
                }
                  [self.imageCollectionView reloadData];
            }
                break;
            
            case 2981: {
                UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
                labelForNoPostsMessage.text = @"No photos or videos yet";
                labelForNoPostsMessage.frame = CGRectMake(0, self.view.frame.size.height/2 - 20, self.view.frame.size.width, 40);
                [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoMedium size:15]];
                labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
                labelForNoPostsMessage.textColor = [UIColor lightGrayColor];
                self.imageCollectionView.backgroundView = labelForNoPostsMessage;
            }
                break;
            case 1972: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    if (requestType == RequestTypeGetProductsByCategoryAndSubcategory) {
        [refreshControl endRefreshing];
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                dataForListView =  response;
                if(dataForListView.count == 0) {
                    self.viewForNoPostsAvailable.hidden = NO;
                }
                [self.imageCollectionView reloadData];
            }
                break;
                
            case 2981: {
                UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
                labelForNoPostsMessage.text = @"No photos or videos yet";
                labelForNoPostsMessage.frame = CGRectMake(0, self.view.frame.size.height/2 - 20, self.view.frame.size.width, 40);
                [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoMedium size:15]];
                labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
                labelForNoPostsMessage.textColor = [UIColor lightGrayColor];

                self.imageCollectionView.backgroundView = labelForNoPostsMessage;
            }
                break;
            case 2032: {
                UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
                labelForNoPostsMessage.text = @"No photos or videos yet";
                labelForNoPostsMessage.frame = CGRectMake(0, self.view.frame.size.height/2 - 20, self.view.frame.size.width, 40);
                [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoMedium size:15]];
                labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
                labelForNoPostsMessage.textColor = [UIColor lightGrayColor];

                self.imageCollectionView.backgroundView = labelForNoPostsMessage;
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
        
    }

    
    
}
- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

-(void)dealloc {
    self.imageCollectionView.delegate = nil;
    self.imageCollectionView.dataSource =nil;
    [self clearImageCache];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self clearImageCache];
}

-(void)clearImageCache{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}

@end
