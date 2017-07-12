//
//  GetPostsByLocationViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 7/20/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "GetPostsByLocationViewController.h"
#import "HashTagViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "HashTagImageCollectionViewCell.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "ProgressIndicator.h"
#import "DetailPostViewController.h"

#import "getPostsByLocationCollectionViewCell.h"

@interface GetPostsByLocationViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,WebServiceHandlerDelegate,SDWebImageManagerDelegate>
{
    NSDictionary  *userDatawhileRegistration;
    NSDictionary  *userData;
    NSString *userToken;
    NSString *userName;
    NSMutableArray *arrayOfThumbNailUrls;
    NSMutableArray *arrayofmainUrls;
    UIActivityIndicatorView  *av;
}

@end

@implementation GetPostsByLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.navTittle;
    //customizing navigationBar.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationItem.hidesBackButton = YES;
    [self createNavLeftButton];
    [self createActivityViewInNavbar];
    
    [[SDImageCache sharedImageCache] setMaxMemoryCost:1024 * 1024 * 1];
    [[SDImageCache sharedImageCache] setMaxCacheAge:3600 * 24 * 7];
    [[SDImageCache sharedImageCache] setShouldDecompressImages:YES];
    [[SDImageCache sharedImageCache] setShouldCacheImagesInMemory:NO];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self clearImageCache];
}

-(void)viewWillAppear:(BOOL)animated {
    
    userDatawhileRegistration =[[NSUserDefaults standardUserDefaults]objectForKey:userDetailkeyWhileRegistration];
    userData =[[NSUserDefaults standardUserDefaults]objectForKey:userDetailKey];
    
    if ( userData[@"username"]) {
        userToken = userData[@"token"];
        userName = userData[@"username"];
    }
    else {
        userToken = userDatawhileRegistration[@"response"][@"authToken"];
        userName = userDatawhileRegistration[@"response"][@"username"];
    }
    
    //removing #from string
    NSString *locationName = self.navTittle;
    
    // Requesting For Post Api.(passing "token" as parameter)
    NSDictionary *requestDict = @{
                                  mauthToken :userToken,
                                  mplace:locationName
                                  };
    [WebServiceHandler RequestTypepostsbasedonLocation:requestDict andDelegate:self];
    
    
    //    ProgressIndicator *loginPI = [ProgressIndicator sharedInstance];
    //    [loginPI showPIOnView:self.view withMessage:@"Fetching Posts"];
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
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:av];
    av.tag  = 1;
    [av startAnimating];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:av];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
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
    return arrayOfThumbNailUrls.count;
}

/**
 *  implementation of collection view cell
 *  @param collectionView collectionView has only image view
 *  @return implemented cell will return.
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
        getPostsByLocationCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"postsByLocationcollectionCellIndentifier" forIndexPath:indexPath];
    
    [collectionViewCell.imageView sd_setImageWithURL:[NSURL URLWithString:[arrayOfThumbNailUrls objectAtIndex:indexPath.row]] placeholderImage:[UIImage sd_animatedGIFNamed:@"loading"]];
    
    collectionViewCell.layer.borderWidth=1.0f;
    collectionViewCell.layer.borderColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor;
    collectionViewCell.contentView.backgroundColor =[UIColor clearColor];
    
    return collectionViewCell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake( CGRectGetWidth(self.view.frame)/3,CGRectGetWidth(self.view.frame)/3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailPostViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"detailPostStoryBoardId"];
    newView.selectedImageUrl = [arrayofmainUrls objectAtIndex:indexPath.item];
    [self.navigationController pushViewController:newView animated:YES];
}

/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    [av stopAnimating];
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
    
    if (requestType == RequestTypebasedonLoaction ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                arrayOfThumbNailUrls =[[NSMutableArray alloc] init];
                arrayofmainUrls = [[NSMutableArray alloc] init];
                NSArray *responseData = response[@"result"];
                for(int i = 0; i< responseData.count;i++) {
                    NSString *thumbNailUrl = responseData[i][@"thumbnailImageUrl"];
                    NSString *mainUrl = responseData[i][@"mainUrl"];
                    [arrayofmainUrls addObject:mainUrl];
                    [arrayOfThumbNailUrls addObject:thumbNailUrl];
                }
                [self.imageCollectionView reloadData];
            }
                break;
                
                //failure response.
            case 1971: {
                [self errAlert:responseDict[@"message"]];
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
