//
//  PostedPhotosCollectionViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/7/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PostedPhotosCollectionViewController.h"
#import "WebServiceHandler.h"
#import "DetailPostViewController.h"
#import "UIImage+GIF.h"
#import "TinderGenericUtility.h"
#import "Helper.h"
#import "InstaVIdeoTableViewController.h"
#import "FontDetailsClass.h"

@interface PostedPhotosCollectionViewController ()<WebServiceHandlerDelegate>
{
    PostedPhotoCollectionViewCell *collectionViewCell;
   
    
     NSMutableArray *resp;
    NSArray *responseData;
    UIActivityIndicatorView  *av;
    UIRefreshControl *refreshControl;
    NSMutableDictionary *dataForListView;
}

@end

@implementation PostedPhotosCollectionViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self createNavTaggingButton];
    [self createNavLeftButton];
    self.navigationController.navigationBarHidden=NO;
    
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
   
    [self addingActivityIndicatorToCollectionViewBackGround];
    [self requestForPosts];
    [self addingRefreshControl];
    
    
}

-(void)requestForPosts {
    // Requesting For photos of you Api.(passing "token" as parameter)
    
    if ([[Helper userName] isEqualToString:_getDetailsOfUser]) {
        NSDictionary *requestDict = @{
                                      mauthToken :flStrForObj([Helper userToken]),
                                      mmemberName:flStrForObj([Helper userName])
                                      };
        [WebServiceHandler RequestTypepostsOfYou:requestDict andDelegate:self];
        self.navigationItem.title=@"Photos Of You";
    }
    else {
        //geeting member profile posts .
        NSDictionary *requestDict = @{
                                      mauthToken :flStrForObj([Helper userToken]),
                                      mmemberName:flStrForObj(_getDetailsOfUser)
                                      };
        [WebServiceHandler getPhotosOfMember:requestDict andDelegate:self];
        self.navigationItem.title=[@"Photos Of " stringByAppendingString:_getDetailsOfUser];
    }
}


-(void)addingActivityIndicatorToCollectionViewBackGround
{
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      av.frame =CGRectMake(self.view.frame.size.width/2 -12.5, self.view.frame.size.height/2 -12.5, 25,25);
    av.tag  = 1;
    [self.PostedPhotocollectionView addSubview:av];
    [av startAnimating];
}

-(void)addingRefreshControl {
    refreshControl = [[UIRefreshControl alloc]init];
    [self.PostedPhotocollectionView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshData:(id)sender {
    [self requestForPosts];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark - navigation bar buttons

- (void)createNavLeftButton
{
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    
    
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    
    // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}



- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil];
    self.navigationItem.hidesBackButton=YES;
}

- (void)createNavTaggingButton
{
    UIButton *navNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [navNextButton setImage:[UIImage imageNamed:@"photos_of_you_option_icon_off"]
                   forState:UIControlStateNormal];
    [navNextButton setImage:[UIImage imageNamed:@"photos_of_you_option_icon_on"]
                   forState:UIControlStateSelected];
    
    [navNextButton setTitleColor:[UIColor grayColor]
                        forState:UIControlStateHighlighted];
    
    [navNextButton setFrame:CGRectMake(-10,17,45,45)];
    
    [navNextButton addTarget:self action:@selector(TaggingButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navNextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)TaggingButtonAction:(UIButton *)sender
{
    NSLog(@"tagging button clicked");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tagging Options", nil];
    //  UIActionSheet *acctionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Library",@"Remove", nil];
    
    actionSheet.tag = 200;
    [actionSheet showInView:self.view];
}



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
 *
 *  @param collectionView declaring numberOfItemsInSection in collection view.
 *  @param section    here only one section.
 *
 *  @return number of items in collection view here it is 100.
 */

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return responseData.count;
}

/**
 *  implementation of collection view cell
 *
 *  @param collectionView collectionView has only image view
 *
 *
 *  @return implemented cell will return.
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"collectionCellIndentifier";
    collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSString *thumbNailurl =  responseData[indexPath.row][@"thumbnailImageUrl"];
    
    collectionViewCell.layer.borderWidth= 0.5f;
    collectionViewCell.layer.borderColor=[[UIColor whiteColor] CGColor];
    collectionViewCell.contentView.backgroundColor =[UIColor clearColor];
    
    [collectionViewCell.postedPhotoImageView sd_setImageWithURL:[NSURL URLWithString:thumbNailurl]];
    
    return collectionViewCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
    newView.showListOfDataFor = @"ListViewForPhotosOfYou";
    newView.dataFromExplore = dataForListView[@"data"][indexPath.item];
    newView.movetoRowNumber   = 0;
    newView.navigationBarTitle =@"Photo";
    [self.navigationController pushViewController:newView animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake( CGRectGetWidth(self.view.frame)/3,CGRectGetWidth(self.view.frame)/3);
}

/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    [av stopAnimating];
    [refreshControl endRefreshing];
    
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
    
    if (requestType == RequestTypePhotosOfYou ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                responseData = response[@"data"];
                dataForListView = response;
                for(int i = 0; i< responseData.count;i++) {
                    //if any images are there then we can show collection view other wise no need to show collection view and we need to show noposts available message.
                    [self.PostedPhotocollectionView reloadData];
                }
            }
                break;
                //failure response.
            case 5433: {
                //no photos available.
                [self backGrounViewWithImageAndTitle:@"When People Take Pictures of you,their photos can appear here."];
                
            }
                break;
            case 5435: {
               [self backGrounViewWithImageAndTitle:response[@"message"]];
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
    
    
    if (requestType == RequestTypegetPhotosOfMember  ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                responseData = response[@"data"];
                dataForListView = response;
                for(int i = 0; i< responseData.count;i++) {
                    //if any images are there then we can show collection view other wise no need to show collection view and we need to show noposts available message.
                    [self.PostedPhotocollectionView reloadData];
                }
            }
                break;
                //failure response.
            case 5435: {
                 [self backGrounViewWithImageAndTitle:response[@"message"]];
            }
                break;
            case 5433: {
                // error in reterving data.
                 [self backGrounViewWithImageAndTitle:response[@"message"]];
                
            }
                break;
            case 5436: {
                //no photos of you.
              [self backGrounViewWithImageAndTitle:response[@"message"]];
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

-(void)backGrounViewWithImageAndTitle:(NSString *)mesage{
    
    UIView *viewWhenNoPosts = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *image =[[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"ip5"];
    image.frame =  CGRectMake(self.view.frame.size.width/2 - 45, self.view.frame.size.height/2 - 45, 90, 90);
    [viewWhenNoPosts addSubview:image];
    
    UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
    labelForNoPostsMessage.text = mesage;
    labelForNoPostsMessage.numberOfLines =0;
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    labelForNoPostsMessage.frame = CGRectMake(20, CGRectGetMaxY(image.frame) + 10, self.view.frame.size.width -40, 60);
    [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoRegular size:15]];
    labelForNoPostsMessage.textColor = [UIColor blackColor];
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    [viewWhenNoPosts addSubview:labelForNoPostsMessage];
    self.PostedPhotocollectionView.backgroundView = viewWhenNoPosts;
}

@end
