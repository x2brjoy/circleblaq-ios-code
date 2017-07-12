//
//  searchViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 4/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//
#import "SearchViewXib.h"
#import "searchViewController.h"
#import "TopTableViewCell.h"
#import "PeopleTableViewCell.h"
#import "HashTagTableViewCell.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "HashTagViewController.h"
#import "UserProfileViewController.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "FontDetailsClass.h"
#import "ListOfPostsViewController.h"
#import "Helper.h"
#import "InstaVIdeoTableViewController.h"
#import "InstaVideoTableViewCell.h"
#import "SVPullToRefresh.h"
#import "CategoryTableViewCell.h"

@interface searchViewController ()<UISearchBarDelegate,UISearchControllerDelegate,profileViewDelegate,WebServiceHandlerDelegate> {
    
    searchViewCollectionViewCell  *collectionViewCell;
    SearchViewXib *searchXib;
    
    UITextField *textSearchField;
    
    UIView *view ;
    BOOL isSearchBeginEditing;
    
    UIButton *categoryButton;
    UIButton *categoryPostButton;
    UIButton *categoryBackgroundButton;
    UIRefreshControl *refreshControl;
    
    NSMutableArray  *explorePostsresponseData;
    NSMutableArray  *hashTagresponseData;
    NSMutableArray * peopleData;
    NSMutableArray *topResponseData;
    NSArray *contentList;
    NSMutableArray *openSection;
    
    NSInteger index;
    UIActivityIndicatorView  *avForCollectionView;
    NSMutableArray *temp;
    NSMutableDictionary *catSubCatlist;
    NSMutableDictionary *catSubPlottinglist;
    int num;
    
}

@end

@implementation searchViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    num = 5;

     _openSectionIndex = 99;
   
    contentList = [[NSArray alloc]init];
    catSubCatlist = [[NSMutableDictionary alloc]init];
    catSubPlottinglist = [[NSMutableDictionary alloc]init];
    openSection = [[NSMutableArray alloc]init];

    [self addingActivityIndicatorToCollectionViewBackGround];
    explorePostsresponseData = [[NSMutableArray alloc] init];
    
    self.categoryButtonOutlet.selected = YES;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    searchXib = [[SearchViewXib alloc] init];
    searchXib.delegate=self;
    [searchXib showHeader:window];
    
    [self customizingSearchBar];
    [self addingRefreshControl];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onKeyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
   
    
    if (isSearchBeginEditing) {
        [self.searchBar becomeFirstResponder];
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    
    // [self displayHashTagDataIfAvailabele];
    
    [self notificationForDeleteApost];
    [self requestForPostsBasedOnRequirement];
}
-(void)requestForPostsBasedOnRequirement {
    
    //for Home Screen.
    //requestingForPosts.
    
    __weak searchViewController *weakSelf = self;
    self.currentIndex = 0;
    
    // setup infinite scrollinge
    [self.collectionViewOutlet addInfiniteScrollingWithActionHandler:^{
        [weakSelf requestForExplorePosts:weakSelf.currentIndex];
        
    }];
    
    [weakSelf requestForExplorePosts:0];
    
}

-(void)notificationForDeleteApost {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePostFromNotification:) name:@"deletePost" object:nil];
}

-(void)deletePostFromNotification:(NSNotification *)noti {
    NSString *updatepostId = flStrForObj(noti.object[@"deletedPostDetails"][@"postId"]);
    for (int i=0; i <explorePostsresponseData.count;i++) {
        
        if ([flStrForObj(explorePostsresponseData[i][@"postId"]) isEqualToString:updatepostId])
        {
            //NSUInteger atSection = [selectedCellIndexPathForActionSheet section];
            [self removeRelatedDataOfDeletePost:i];
            [self.collectionViewOutlet performBatchUpdates:^{
                NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
                [self.collectionViewOutlet deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            } completion:^(BOOL finished) {
                
            }];
            
            break;
        }
    }
}


-(void)removeRelatedDataOfDeletePost:(NSInteger )atSection {
    
    [explorePostsresponseData removeObjectAtIndex:atSection];
    
    if (explorePostsresponseData.count == 0) {
        
    }
}

-(void)viewWillAppear:(BOOL)animated {
//    // [self requestForUserAlreadySearchedData];

}



-(void)viewWillDisappear:(BOOL)animated {
    [self.searchBar resignFirstResponder];
}



/*---------------------------------------------------------*/
#pragma mark - Pull To refresh
/*---------------------------------------------------------*/
-(void)addingRefreshControl {
    refreshControl = [[UIRefreshControl alloc]init];
    refreshControl.tintColor = [UIColor blackColor];
    [self.collectionViewOutlet addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshData:(id)sender {
   
    self.currentIndex = 0;
    [self requestForExplorePosts:self.currentIndex];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
 
}

/*---------------------------------------------------------*/
#pragma mark - customizing  SearchBar
/*---------------------------------------------------------*/

-(void)customizingSearchBar {
    //searchbar customization.
    [_searchBar setImage:[UIImage imageNamed:@"search_add_contact_icon_off_2x_converted"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    [_searchBar setImage:[UIImage imageNamed:@"search_add_contact_icon_on_2x_converted"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateSelected];
    
    textSearchField = [_searchBar valueForKey:@"_searchField"];
    //textSearchField.backgroundColor = [UIColor colorWithRed:0.8447 green:0.8488 blue:0.8684 alpha:0.75];
    textSearchField.backgroundColor = [UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:0.3f];
    textSearchField.textColor =[UIColor blackColor];
    [textSearchField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                   forKeyPath:@"_placeholderLabel.textColor"];
    [self.searchBar setImage:[UIImage imageNamed:@"search_search_icon_off"]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    [self.searchBar setImage:[UIImage imageNamed:@"search_search_icon_on"]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateSelected];
    _searchBar.showsBookmarkButton =NO;
    isSearchBeginEditing = NO;
    textSearchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //    _searchBar.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:36.0f/255.0f blue:52.0f/255.0f alpha:1.0];
}

/*---------------------------------------------------------*/
#pragma mark - empty data set
/*---------------------------------------------------------*/

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    return activityView;
}


/*---------------------------------------------------------*/
#pragma mark - collectionview delegates
/*---------------------------------------------------------*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //just for count .
    
    
    return  explorePostsresponseData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = @"searchcollectionCellIndentifier";
    collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString *thumbimgUrl = flStrForObj(explorePostsresponseData[indexPath.item][@"thumbnailImageUrl"]);
    NSString *postType = flStrForObj(explorePostsresponseData[indexPath.item][@"postsType"]);
    
    if([postType isEqualToString:@"1"]) {
        collectionViewCell.imageForShowVideoOrNot.hidden = NO;
    }
    else {
        collectionViewCell.imageForShowVideoOrNot.hidden = YES;
    }
    
    collectionViewCell.layer.borderWidth=0.5f;
    collectionViewCell.layer.borderColor=[[UIColor whiteColor] CGColor];
    collectionViewCell.contentView.backgroundColor =[UIColor clearColor];
    
    
    [collectionViewCell.postedImageOutlet sd_setImageWithURL:[NSURL URLWithString:thumbimgUrl]];
    return collectionViewCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((CGRectGetWidth(self.view.frame)/3),(CGRectGetWidth(self.view.frame)/3));
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //it will take to posts in list view.
    InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
    newView.showListOfDataFor = @"ListViewForExplore";
    newView.dataFromExplore = explorePostsresponseData;
    newView.movetoRowNumber =indexPath.item;
    newView.navigationBarTitle =@"Explore";
    [self.navigationController pushViewController:newView animated:YES];
}

/*---------------------------------------------------------*/
#pragma mark - searchbar delegates
/*---------------------------------------------------------*/

#pragma UIsearchbardelegate
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
   self.navigationController.navigationBar.barTintColor =[UIColor colorWithRed:0.9704 green:0.9703 blue:0.9704 alpha:1.0];
    [searchBar setShowsCancelButton:NO animated:YES];
    textSearchField.text =@"";
    self.ScoralableViewOutlet.hidden =YES;
    self.collectionViewOutlet.hidden=NO;
    self.BaseScrollViewOutlet.hidden=YES;
    isSearchBeginEditing = NO;
    view.hidden=NO;
    [searchBar resignFirstResponder];
    textSearchField.placeholder = @"Search";
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.view bringSubviewToFront:self.ScoralableViewOutlet];
    self.navigationController.navigationBar.barTintColor=[UIColor whiteColor];
    [self.searchBar setImage:[UIImage imageNamed:@"search_search_icon_on"]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    [searchBar setShowsCancelButton:YES animated:YES];
    
    self.searchBar.showsBookmarkButton =NO;
    self.searchBar.barTintColor=[UIColor blackColor];
    [textSearchField setValue:[UIColor colorWithRed:0.4961 green:0.4961 blue:0.4961 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [textSearchField setBackgroundColor:[UIColor colorWithRed:0.8447 green:0.8488 blue:0.8684 alpha:0.75]];
    textSearchField.textColor =[UIColor blackColor];
    self.ScoralableViewOutlet.hidden = NO;
    self.collectionViewOutlet.hidden = YES;
    self.BaseScrollViewOutlet.hidden = NO;
    isSearchBeginEditing = YES;
    view.hidden=YES;
    if(num == 5)
    [self requestCategoryList];
    
    
    if(self.placesButtonOutlet.selected)
    {
        textSearchField.placeholder = @"Search Places";
    }
    else if (self.tagButonOutlet.selected) {
        textSearchField.placeholder = @"Search Tags";
        
    }
    else if (self.peopleButtonOutlet.selected)
    {
        textSearchField.placeholder = @"Search People";
        
    }
    else {
        textSearchField.placeholder = @"Search";
        
    }
    
    
    
    return YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.searchBar.showsBookmarkButton=NO;
    [self.searchBar setImage:[UIImage imageNamed:@"search_search_icon_off"]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    [textSearchField setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                   forKeyPath:@"_placeholderLabel.textColor"];
    textSearchField = [_searchBar valueForKey:@"_searchField"];
    textSearchField.backgroundColor = [UIColor colorWithRed:0.8447 green:0.8488 blue:0.8684 alpha:0.75];
    textSearchField.textColor =[UIColor whiteColor];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
    [self performSegueWithIdentifier:@"addContactToDiscoverPeopleSegue" sender:nil];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (![searchText isEqualToString:@""]) {
        [self requestForHashTags:searchText];
    }
    else {
        hashTagresponseData =  nil;
        [self.hashTagTableView reloadData];
    }
    if (![searchText isEqualToString:@""]) {
        [self requestForPeople:searchText];
    }
    else {
        peopleData = nil;
        [self.PeopleTableView reloadData];
    }
    if (![searchText isEqualToString:@""]) {
        [self requestForTop:searchText];
    }
    else {
        topResponseData = nil;
        [self.topTableView reloadData];
    }
}

/*---------------------------------------------------------*/
#pragma mark - service request
/*---------------------------------------------------------*/

-(void)requestCategoryList
{
    NSDictionary *requestDict = @{
                                  mauthToken      :flStrForObj([Helper userToken]),
                                  moffset         :flStrForObj([NSNumber numberWithInteger:index*10]),
                                  mlimit          :flStrForObj([NSNumber numberWithInteger:10])
                                  };
    [WebServiceHandler getCategory:requestDict andDelegate:self];
}


-(void)requestForExplorePosts:(NSInteger )receivedindex {
    
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj([Helper userToken]),
                                  moffset:flStrForObj([NSNumber numberWithInteger:receivedindex*18]),
                                  mlimit:flStrForObj([NSNumber numberWithInteger:18])
                                  };
    [WebServiceHandler getExplorePosts:requestDict andDelegate:self];
}


-(void)requestForUserAlreadySearchedData {
    NSDictionary *requestDict = @{
                                  mauthToken :flStrForObj([Helper userToken]),
                                  };
    [WebServiceHandler getUserSearchHistory:requestDict andDelegate:self];
}

-(void)requestForAddKeyToSearchHistory:(NSString *)addserchKeyToHistory and:(NSString *)type {
    NSDictionary  *requestDict = @{
                                   mauthToken :flStrForObj([Helper userToken]),
                                   mtype :type,
                                   maddToSearchKey :addserchKeyToHistory
                                   };
    [WebServiceHandler addTosearchHistory:requestDict andDelegate:self];
}

-(void)requestForPeople:(NSString *)searchText {
    NSDictionary *requestDict = @{
                                  @"userNameToSearch" :searchText,
                                  mauthToken :flStrForObj([Helper userToken]),
                                  moffset:@"0",
                                  mlimit:@"20"
                                  };
    [WebServiceHandler getSearchPeople:requestDict andDelegate:self];
    [self.PeopleTableView reloadData];
}

-(void)requestForTop:(NSString *)searchText {
    NSDictionary *requestDict = @{
                                  mKeyToSearch :searchText,
                                  mauthToken :flStrForObj([Helper userToken]),
                                  moffset:@"0",
                                  mlimit:@"20"
                                  };
    [WebServiceHandler getTop:requestDict andDelegate:self];
    [self.topTableView reloadData];
}

-(void)requestForHashTags:(NSString *)searchText {
    NSDictionary *requestDict = @{
                                  mhashTag :searchText,
                                  mauthToken :flStrForObj([Helper userToken]),
                                  moffset:@"0",
                                  mlimit:@"20"
                                  };
    [WebServiceHandler getHashTagSuggestion:requestDict andDelegate:self];
}

/*---------------------------------------------------------*/
#pragma mark - scrollable buttons actions
/*---------------------------------------------------------*/

- (IBAction)categoryBtnAction:(id)sender {
    CGRect frame = self.mainScrollView.bounds;
    frame.origin.x = 0 * CGRectGetWidth(self.view.frame);
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    
    self.categoryButtonOutlet.selected = YES;
    self.topButtonOutlet.selected = NO;
    self.peopleButtonOutlet.selected = NO;
    self.tagButonOutlet.selected=NO;
    self.placesButtonOutlet.selected=NO;
    
}

- (IBAction)topButtonAction:(id)sender {
    
    CGRect frame = self.mainScrollView.bounds;
    if(num == 5)
    frame.origin.x = 1 * CGRectGetWidth(self.view.frame);
    else
        frame.origin.x = 0 * CGRectGetWidth(self.view.frame);
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    self.categoryButtonOutlet.selected = NO;
    self.topButtonOutlet.selected = YES;
    self.peopleButtonOutlet.selected = NO;
    self.tagButonOutlet.selected=NO;
    self.placesButtonOutlet.selected=NO;
}

- (IBAction)PeopleButtonAction:(id)sender {
    
    CGRect frame = self.mainScrollView.bounds;
    if(num == 5)
        frame.origin.x = 2 * CGRectGetWidth(self.view.frame);
    else
        frame.origin.x = 1 * CGRectGetWidth(self.view.frame);
    //frame.origin.x = 2 * CGRectGetWidth(self.view.frame);
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    self.categoryButtonOutlet.selected = NO;
    self.topButtonOutlet.selected = NO;
    self.peopleButtonOutlet.selected = YES;
    self.tagButonOutlet.selected=NO;
    self.placesButtonOutlet.selected=NO;
}
- (IBAction)tagButtonAction:(id)sender {
    
    CGRect frame = self.mainScrollView.bounds;
    //frame.origin.x = 3 * CGRectGetWidth(self.view.frame);
    if(num == 5)
        frame.origin.x = 3 * CGRectGetWidth(self.view.frame);
    else
        frame.origin.x = 2 * CGRectGetWidth(self.view.frame);
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    self.categoryButtonOutlet.selected = NO;
    self.topButtonOutlet.selected = NO;
    self.peopleButtonOutlet.selected = NO;
    self.tagButonOutlet.selected=YES;
    self.placesButtonOutlet.selected=NO;
}

- (IBAction)placesButtonAction:(id)sender {
    
    CGRect frame = self.mainScrollView.bounds;
    //frame.origin.x = 4 * CGRectGetWidth(self.view.frame);
    if(num == 5)
        frame.origin.x = 4 * CGRectGetWidth(self.view.frame);
    else
        frame.origin.x = 3 * CGRectGetWidth(self.view.frame);
    [self.mainScrollView scrollRectToVisible:frame animated:YES];
    self.categoryButtonOutlet.selected = NO;
    self.topButtonOutlet.selected = NO;
    self.peopleButtonOutlet.selected = NO;
    self.tagButonOutlet.selected=NO;
    self.placesButtonOutlet.selected=YES;
}

/*--------------------------------------------------*/
#pragma mark - Scrollview Delegate
/*-------------------------------------------------*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.mainScrollView]) {
        
        
        CGPoint offset = scrollView.contentOffset;
        self.movableDividerLeadingConstraintOutlet.constant = scrollView.contentOffset.x/num;
        
        if (num == 5) {
            if( offset.x <=0) {
                //tag button selected.
                self.categoryButtonOutlet.selected = YES;
                self.topButtonOutlet.selected = NO;
                self.peopleButtonOutlet.selected = NO;
                self.tagButonOutlet.selected=NO;
                self.placesButtonOutlet.selected=NO;
                
                textSearchField.placeholder = @"Shopping";
            }
            else if(offset.x == CGRectGetWidth(self.view.frame) ) {
                //topbutton is selected.
                self.categoryButtonOutlet.selected = NO;
                self.topButtonOutlet.selected = YES;
                self.peopleButtonOutlet.selected = NO;
                self.tagButonOutlet.selected=NO;
                self.placesButtonOutlet.selected=NO;
                
                textSearchField.placeholder = @"Search";
            }
            else if( offset.x <=CGRectGetWidth(self.view.frame)*2) {
                //people  button selected.
                self.categoryButtonOutlet.selected = NO;
                self.topButtonOutlet.selected = NO;
                self.peopleButtonOutlet.selected = YES;
                self.tagButonOutlet.selected=NO;
                self.placesButtonOutlet.selected=NO;
                
                textSearchField.placeholder = @"Search People";
            }
            else if( offset.x <=CGRectGetWidth(self.view.frame)*3) {
                //tag button selected.
                self.categoryButtonOutlet.selected = NO;
                self.topButtonOutlet.selected = NO;
                self.peopleButtonOutlet.selected = NO;
                self.tagButonOutlet.selected=YES;
                self.placesButtonOutlet.selected=NO;
                
                textSearchField.placeholder = @"Search Tags";
            }
            else {
                //places button selected.
                self.categoryButtonOutlet.selected = NO;
                self.topButtonOutlet.selected = NO;
                self.peopleButtonOutlet.selected = NO;
                self.tagButonOutlet.selected=NO;
                self.placesButtonOutlet.selected=YES;
                
                textSearchField.placeholder = @"Search Places";
            }
   
        }
        else
        {
            if(offset.x == 0 ) {
                //topbutton is selected.
                self.topButtonOutlet.selected = YES;
                self.peopleButtonOutlet.selected = NO;
                self.tagButonOutlet.selected=NO;
                self.placesButtonOutlet.selected=NO;
                
                textSearchField.placeholder = @"Search";
            }
            else if( offset.x <=CGRectGetWidth(self.view.frame)) {
                //people  button selected.
                self.topButtonOutlet.selected = NO;
                self.peopleButtonOutlet.selected = YES;
                self.tagButonOutlet.selected=NO;
                self.placesButtonOutlet.selected=NO;
                
                textSearchField.placeholder = @"Search People";
            }
            else if( offset.x <=CGRectGetWidth(self.view.frame)*2) {
                //tag button selected.
                self.topButtonOutlet.selected = NO;
                self.peopleButtonOutlet.selected = NO;
                self.tagButonOutlet.selected=YES;
                self.placesButtonOutlet.selected=NO;
                
                textSearchField.placeholder = @"Search Tags";
            }
            else {
                //places button selected.
                self.topButtonOutlet.selected = NO;
                self.peopleButtonOutlet.selected = NO;
                self.tagButonOutlet.selected=NO;
                self.placesButtonOutlet.selected=YES;
                
                textSearchField.placeholder = @"Search Places";
            }
        }
        
        
        // Set offset to adjusted value
        scrollView.contentOffset = offset;
    }
}


- (void)categoryButtonClicked :(id)sender {
    [self dismiss];
    int flag = 0;
    UIButton *selectedHeaderButton = (UIButton *)sender;
    NSInteger selectedIndex = selectedHeaderButton.tag % 100;
    NSLog(@"Selected header is :%ld",(long)selectedIndex);
    // _openSectionIndex = selectedIndex;
    NSString *str = contentList[selectedIndex];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:selectedIndex];
    if (openSection.count) {
        for (NSString *openStr in openSection) {
            if ([openStr isEqualToString:str]) {
                flag = 1;
            }
        }
        if (flag == 1) {
            NSArray *arr = [[NSArray alloc]init];//[NSArray arrayWithObjects:nil];
            [catSubPlottinglist setValue:arr forKey:str];
            _openSectionIndex = 100;
            [openSection  removeObject:str];
            [selectedHeaderButton setImage:[UIImage imageNamed:@"category_open_off"] forState:UIControlStateNormal];
        }
        else{
            NSMutableArray *arrSub = [[NSMutableArray alloc]init];
            
            for (int i= 0; i<[catSubCatlist[str]count]; i++) {
                
                [arrSub addObject:flStrForObj(catSubCatlist[str][i])];
                NSLog(@"InsideLoopSubcategoryName:%@",arrSub);
                
            }
            _openSectionIndex = selectedIndex;
            [catSubPlottinglist setValue:arrSub forKey:str];
            [openSection addObject:str];
            NSLog(@"dic:%@",catSubPlottinglist);
            [selectedHeaderButton setImage:[UIImage imageNamed:@"category_open_on"] forState:UIControlStateNormal];
            
        }
    }else{
        NSMutableArray *arrSub = [[NSMutableArray alloc]init];
        
        for (int i= 0; i<[catSubCatlist[str]count]; i++) {
            
            [arrSub addObject:flStrForObj(catSubCatlist[str][i])];
            NSLog(@"InsideLoopSubcategoryName:%@",arrSub);
            
        }
        _openSectionIndex = selectedIndex;
        [catSubPlottinglist setValue:arrSub forKey:str];
        [openSection addObject:str];
        NSLog(@"dic:%@",catSubPlottinglist);
        [selectedHeaderButton setImage:[UIImage imageNamed:@"category_open_on"] forState:UIControlStateNormal];
        
    }
    //[self.categoryTableView reloadSections:[NSIndexSet indexSetWithIndex:selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self.categoryTableView reloadData];
}

/*-------------------------------------------------------------------------*/
#pragma mark - tableview Delegate and data source.
/*------------------------------------------------------------------------*/

// tableView                         tag

// top tableview           -       10(tag)
//peopleTableView      -       20(tag)
//hashtagtableView     -       30(tag)
//placesTableView       -       40(tag)



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 10) {
        NSString *str = contentList[section];
        return [catSubPlottinglist[str] count];
    }
    if (tableView.tag == 20) {
        return topResponseData.count;
    }
    else if (tableView.tag == 30) {
        return peopleData.count;
    }
    else if (tableView.tag == 40) {
        return hashTagresponseData.count;
    }
    else {
        return 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (tableView.tag == 10 ) {
        static NSString *CellIdentifier = @"categoryTableViewCell";
        CategoryTableViewCell  *categoryTableViewcell ;
        categoryTableViewcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                forIndexPath:indexPath];
        
        
        categoryTableViewcell.backgroundColor = [UIColor whiteColor];
        NSString *headerStr = contentList[indexPath.section];
        categoryTableViewcell.textLabel.font = [UIFont fontWithName:RobotoRegular size:13.0f];
        categoryTableViewcell.textLabel.textColor = [UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:1.0f];
        categoryTableViewcell.textLabel.text =  catSubPlottinglist[headerStr][indexPath.row];
        categoryTableViewcell.textLabel.backgroundColor = [UIColor clearColor];
        
        //categoryTableViewcell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //categoryTableViewcell.accessoryView.frame = CGRectMake(self.view.frame.size.width - 80, 5, 15, 15);
        [categoryTableViewcell.divider bringSubviewToFront:categoryTableViewcell.textLabel];
        [categoryTableViewcell layoutIfNeeded];
        
        return categoryTableViewcell;
    }

    
    if (tableView.tag == 20 ) {
        static NSString *CellIdentifier = @"topTableViewCell";
        TopTableViewCell *topTableViewcell ;
        topTableViewcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                           forIndexPath:indexPath];
        
        topTableViewcell.userNameOutlet.text =  flStrForObj(topResponseData[indexPath.row][@"username"]);
        topTableViewcell.fullNameOutlet.text =   flStrForObj(topResponseData[indexPath.row][@"fullName"]);
        [ topTableViewcell.profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj( topResponseData[indexPath.row][@"profilePicUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
        
        [topTableViewcell layoutIfNeeded];
        topTableViewcell.profileImageViewOutlet.layer.cornerRadius =topTableViewcell.profileImageViewOutlet.frame.size.height/2;
        topTableViewcell.profileImageViewOutlet.clipsToBounds = YES;
        return topTableViewcell;
    }
    else  if (tableView.tag == 30 )
    {
        static NSString *CellIdentifier = @"peopleTableViewCell";
        PeopleTableViewCell *peopleTableViewcell;
        peopleTableViewcell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                              forIndexPath:indexPath];
        
        peopleTableViewcell.userNameLabel.text = flStrForObj(peopleData[indexPath.row][@"username"]);
        peopleTableViewcell.fullnameLabel.text =   flStrForObj(peopleData[indexPath.row][@"fullName"]);
        
        [ peopleTableViewcell.profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj( peopleData[indexPath.row][@"profilePicUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
        
        [peopleTableViewcell layoutIfNeeded];
        peopleTableViewcell.profileImageViewOutlet.layer.cornerRadius =peopleTableViewcell.profileImageViewOutlet.frame.size.height/2;
        peopleTableViewcell.profileImageViewOutlet.clipsToBounds = YES;
        return peopleTableViewcell;
    }
    else if (tableView.tag == 40) {
        HashTagTableViewCell *hashTagTableViewCell;
        static NSString *CellIdentifier = @"hashTagTableViewCell";
        hashTagTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                               forIndexPath:indexPath];
        hashTagTableViewCell.hashtagLabel.text = flStrForObj(hashTagresponseData[indexPath.row][@"hashtag"]);
        
        if ([flStrForObj(hashTagresponseData[indexPath.row][@"Count"]) isEqualToString:@"1"]) {
            hashTagTableViewCell.hashTagCountLabel.text = [flStrForObj(hashTagresponseData[indexPath.row][@"Count"])stringByAppendingString:@" post"];
        }
        else
        {
            hashTagTableViewCell.hashTagCountLabel.text = [flStrForObj(hashTagresponseData[indexPath.row][@"Count"])stringByAppendingString:@" posts"];
            
        }
        
        return hashTagTableViewCell;
    }
    else {
        static NSString *CellIdentifier = @"MyIdentifier";
        AddLocationTableViewCell *cell ;
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                               forIndexPath:indexPath];
        cell.textLabel.font =[UIFont   fontWithName:RobotoRegular size:13];
        if(indexPath.row ==0)  {
            cell.textLabel.text = @"Near Current Location";
            cell.textLabel.textColor =[UIColor colorWithRed:0.2275 green:0.3451 blue:0.6196 alpha:1.0];
            cell.imageView.image =[UIImage imageNamed:@"search_third_blue_location_icon"];
        }
        else {
            cell.imageView.image =[UIImage imageNamed:@"search_third_grey_location_icon"];
            cell.textLabel.text = @"Bird City,Usa";
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
if (tableView.tag == 10) {
    NSString *title = contentList[indexPath.section];
    NSString *subtitle = catSubPlottinglist[title][indexPath.row];
    HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
    newView.requestType = @"CategoryType";
    newView.category = title;
    newView.subCategory = subtitle;
    newView.navTittle =flStrForObj([@"#" stringByAppendingString:subtitle)];
                                   [self.navigationController pushViewController:newView animated:YES];
}
                                   
  if (tableView.tag == 50) {
       [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if(indexPath.row ==0) {
       [self performSegueWithIdentifier:@"nearCurrentLocationSegue" sender:nil];
                               }
 }
                                   
 if (tableView.tag == 40) {
      HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
      newView.navTittle =flStrForObj([@"#" stringByAppendingString:hashTagresponseData[indexPath.row][@"hashtag"])];
      [self.navigationController pushViewController:newView animated:YES];
                                                                          
                                                                          //[self storeSeletedHashTagHistory:hashTagresponseData[indexPath.row]];
  }
                                                                          
  if (tableView.tag == 30) {
  UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
  newView.checkProfileOfUserNmae =flStrForObj(peopleData[indexPath.row][@"username"]);
  newView.checkingFriendsProfile = YES;
  [self.navigationController pushViewController:newView animated:YES];
      
                                                                              
 [self requestForAddKeyToSearchHistory: flStrForObj(peopleData[indexPath.row][@"username"]) and:@"0"];
 }
                                                                          
 if (tableView.tag == 20) {
   UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = flStrForObj(topResponseData[indexPath.row][@"username"]);
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
                                                                              
                                                                              
    [self requestForAddKeyToSearchHistory: flStrForObj(topResponseData[indexPath.row][@"username"]) and:@"0"];
   }
}
 
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
         if (([tableView isEqual:self.categoryTableView])&&(tableView.tag == 10)) {
             return 50;
         }
         return 0.0f;
}
                                     
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
                                         
                                         return 0;
                                     }
                                     
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
                                         if (tableView.tag == 10) {
                                             return contentList.count;
                                         }
                                         else
                                             return 1;
                                     }
                                     
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // creating custom header view
    
    
    UIView *viewN = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    viewN.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, tableView.frame.size.width-50, 20)];
    categoryPostButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 49, tableView.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    categoryBackgroundButton = [[UIButton alloc]init];
    
    //[label setFont:[UIFont boldSystemFontOfSize:13]];
    label.font = [UIFont fontWithName:RobotoRegular size:13.0f];
    NSLog(@"section header:%@",contentList[section]);
    NSString *headerString = contentList[section];//[NSString stringWithFormat:@"header%ld",(long)section];
    
    //[list objectAtIndex:section];
    /* Section header is in 0th index... */
    [label setText:headerString];
    [viewN addSubview:label];
    //[viewN setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    
    categoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [categoryButton setImage:[UIImage imageNamed:@"category_open_off"] forState:UIControlStateNormal];
    [categoryButton setImage:[UIImage imageNamed:@"category_open_on"] forState:UIControlStateSelected];
    
    //[Helper setButton:categoryButton Text:@"+" WithFont:RobotoBold FSize:20 TitleColor:[UIColor blueColor] ShadowColor:nil];
    categoryButton.tag = section+100;
    [categoryButton addTarget:self
                       action:@selector(categoryButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [categoryPostButton setImage:[UIImage imageNamed:@"nextArrow_off"] forState:UIControlStateNormal];
    [categoryPostButton setImage:[UIImage imageNamed:@"nextArrow_on"] forState:UIControlStateSelected];
    //[Helper setButton:categoryPostButton Text:@">" WithFont:RobotoBold FSize:20 TitleColor:[UIColor blueColor] ShadowColor:nil];
    categoryPostButton.tag = section+100;
    [categoryPostButton addTarget:self
                           action:@selector(categoryButtonClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
    [categoryBackgroundButton addTarget:self
                                 action:@selector(categoryButtonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
    
    if ([catSubCatlist[headerString]count]>0){
        categoryButton.frame = CGRectMake(self.view.frame.size.width - 50, 10, 30, 30);
        categoryPostButton.frame = CGRectMake(self.view.frame.size.width - 50, 10, 0, 0);
        categoryBackgroundButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
        categoryBackgroundButton.tag = section+100;
        categoryBackgroundButton.backgroundColor = [UIColor clearColor];
    }
    else
    {
        [categoryButton addTarget:self
                           action:@selector(categoryButtonClicked:)
                 forControlEvents:UIControlEventTouchUpInside];
        categoryButton.frame = CGRectMake(self.view.frame.size.width - 50, 10, 0, 0);
        categoryPostButton.frame = CGRectMake(self.view.frame.size.width - 50, 10, 30, 30);
        categoryBackgroundButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 0);
        categoryBackgroundButton.tag = section+100;
    }
    [viewN addSubview:categoryBackgroundButton];
    [viewN addSubview:lineView];
    [viewN addSubview:categoryButton];
    [viewN addSubview:categoryPostButton];
    
    if (openSection.count) {
        for (NSString *str in openSection) {
            if ([str isEqualToString:headerString]) {
                if ([catSubCatlist[headerString]count]>0){
                    [categoryButton setImage:[UIImage imageNamed:@"category_open_on"] forState:UIControlStateNormal];
                }
            }
        }
    }
    return viewN;
}
                                     
                                     
                                     
                                     
-(void)storeSeletedHashTagHistory:(NSMutableArray *)searchedHashTag {
    
                                           NSMutableArray *hashTagsearchHistory = [[NSMutableArray alloc] init];
                                           NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
                                           if([userDefaults objectForKey:searchedHashTagData]) {
                                               
                                               NSMutableArray *newArray = [[NSMutableArray alloc] init];
                                               //        [newArray addObject:searchedHashTag];
                                               
                                               hashTagsearchHistory = [userDefaults objectForKey:searchedHashTagData];
                                               //[hashTagsearchHistory addObject:searchedHashTag];
                                               
                                               
                                               for (int i =0 ;i <hashTagsearchHistory.count;i++)
                                               {
                                                   [newArray addObject:hashTagsearchHistory[i]];
                                               }
                                               
                                               
                                               NSUserDefaults *userDefaults1 = [NSUserDefaults standardUserDefaults];
                                               [userDefaults1 setObject:newArray forKey:searchedHashTagData];
                                               [userDefaults1 synchronize];
                                           }
                                           else {
                                               // first time (no data available).
                                               NSUserDefaults *userDefaults1 = [NSUserDefaults standardUserDefaults];
                                               [userDefaults1 setObject:searchedHashTag forKey:searchedHashTagData];
                                               [userDefaults1 synchronize];
                                           }
                                       }
                                     
-(void)displayHashTagDataIfAvailabele {
    
    hashTagresponseData = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    hashTagresponseData = [userDefaults objectForKey:searchedHashTagData];
}
                                     
                                     
                                     
        /*------------------------------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
        /*--------------------------------------------------------*/
- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
                                           
    //handling response.
    if (error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        
        // refresh control is for pull to refresh and avForCollectionView is for background for collection view when there is no data.
        [avForCollectionView stopAnimating];
        [refreshControl endRefreshing];
        
        // [self showingMessageForCollectionViewBackground:[error localizedDescription]];
        return;
    }
    
    NSDictionary *responseDict = (NSDictionary*)response;
    //response for hashtagsuggestion api.
    if (requestType == RequestTypeGetCategories ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                NSLog(@"CategoryList:%@",responseDict);
                temp =responseDict[@"data"];//[0][@"data"];
                int count = (int)temp.count;
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                
                for (int i = 0; i<count; i++) {
                    //NSLog(@"categoryName:%@",flStrForObj(temp[i][@"categoryName"]));
                    //                    if(![flStrForObj(temp[i][@"categoryName"]) isEqualToString:@" "] || ![flStrForObj(temp[i][@"categoryName"]) isEqualToString:@"<null>"])
                    NSString *category =flStrForObj(temp[i][@"categoryName"]);
                    if(category.length && ![category isEqualToString:@" "])
                    {
                        
                        NSLog(@"categoryName:%@",flStrForObj(temp[i][@"categoryName"]));
                        [arr addObject:flStrForObj(temp[i][@"categoryName"])];
                        int subCatCount = (int)[temp[i][@"subcategoryname"]count];
                        NSMutableArray *arrSub = [[NSMutableArray alloc]init];
                        for (int j = 0; j<subCatCount; j++) {
                            if(![flStrForObj(temp[i][@"subcategoryname"][j]) isEqualToString:@""])
                            {
                                
                                [arrSub addObject:flStrForObj(temp[i][@"subcategoryname"][j])];
                                NSLog(@"InsideLoopSubcategoryName:%@",arrSub);
                            }
                        }
                        [catSubCatlist setObject:arrSub forKey:flStrForObj(temp[i][@"categoryName"])];
                        NSLog(@"OutsideLoopSubcategoryName:%@",flStrForObj(catSubCatlist));
                    }
                }
                contentList = [arr mutableCopy];
                // catSubPlottinglist = [catSubCatlist mutableCopy];
                //contentList = responseDict[@"data"];
                [self.categoryTableView reloadData];
            }
                break;
                //failure responses.
            case 2021: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2022: {
                [self errorAlert:responseDict[@"message"]];
                
            }
                break;
            default:
                break;
        }
    }

    if (requestType == RequestTypeGetExploreposts) {
        
        [avForCollectionView stopAnimating];
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [self handlingResponseOfExplorePosts:response];
            }
                
                break;
            case 19021: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 19022: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
                
            case 34333: {
                [refreshControl endRefreshing];
                
                
                if(self.collectionViewOutlet.contentSize.height ==0) {
                    [self showingMessageForCollectionViewBackground:responseDict[@"message"]];
                }
            }
                break;
                
        }
    }
    
    //response for hashtagsuggestion api.
    if (requestType == RequestTypeGetHashTagsSuggestion) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                self.hashTagTableView.backgroundView = nil;
                [self hadnlingHashtagApiResponse:responseDict];
            }
                break;
            case 19021: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 19022: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 19023: {
                
                hashTagresponseData =  nil;
                UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
                [noDataAvailableMessageView setCenter:self.view.center];
                UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, 50, 200,100)];
                message.textColor = [UIColor lightGrayColor];
                [message setFont:[UIFont fontWithName:RobotoMedium size:14]];
                message.numberOfLines =0;
                message.textAlignment = NSTextAlignmentCenter;
                message.text = @"No Results Found";
                [noDataAvailableMessageView addSubview:message];
                self.hashTagTableView.backgroundColor = [UIColor whiteColor];
                self.hashTagTableView.backgroundView = noDataAvailableMessageView;
                [self.hashTagTableView reloadData];
            }
                break;
        }
    }
    
    //response for tagFriend api.
    if (requestType == RequestTypeGetSearchPeople) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [self hadnlingPeopleApiResponse:responseDict];
            }
                break;
            case 19031: {
                [self errorAlert:responseDict[@"message"]];
            }
            case 19032: {
                [self errorAlert:responseDict[@"message"]];
            }
        }
    }
    
    //response for tagFriend api.
    if (requestType == RequestTypeGetTop) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [self handlingTopResponseData:responseDict];
            }
                break;
            case 19031: {
                [self errorAlert:responseDict[@"message"]];
            }
            case 19032: {
                [self errorAlert:responseDict[@"message"]];
            }
        }
    }
    
    if (requestType == RequestTypegetUserSearchHistory) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                NSLog(@"searched history is :%@",responseDict);
            }
                break;
        }
    }
    
    if (requestType == RequestTypeAddToSearchHistory) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                NSLog(@"added key to searched history is :%@",responseDict);
            }
                break;
        }
    }
}
                                       
  - (void)errorAlert:(NSString *)message {
      //alert for failure response.
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                      message:message
                                                     delegate:self
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil,nil];
      [alert show];
    }
                                       
        /*---------------------------------------------------------------------*/
#pragma mark -
#pragma mark - Handling Response
        /*----------------------------------------------------------------------*/
                                       
-(void)hadnlingHashtagApiResponse:(NSDictionary *)hashTagDataDictonary {
    if (hashTagDataDictonary) {
        hashTagresponseData =[[NSMutableArray alloc] init];
        hashTagresponseData = hashTagDataDictonary[@"data"];
        [self.hashTagTableView reloadData];
    }
    else {
        hashTagresponseData =  nil;
        [self.hashTagTableView reloadData];
    }
  }
                                       
-(void)hadnlingPeopleApiResponse:(NSDictionary *)tagFriendsData {
    if (tagFriendsData) {
        peopleData =[[NSMutableArray alloc] init];
        peopleData = tagFriendsData[@"users"];
        [self.PeopleTableView reloadData];
    }
    else {
        peopleData = nil;
        [self.PeopleTableView reloadData];
    }
}
                                       
-(void)handlingTopResponseData:(NSDictionary *)topData {
    if (topData) {
        topResponseData =[[NSMutableArray alloc] init];
        topResponseData = topData[@"users"];
        [self.topTableView reloadData];
    }
    else {
        topResponseData = nil;
        [self.topTableView reloadData];
    }
}
                                       
                                       
-(void)handlingResponseOfExplorePosts:(NSMutableDictionary *)receivedData {
    self.collectionViewOutlet.backgroundView = nil;
    [refreshControl endRefreshing];
    if(self.currentIndex == 0) {
        [explorePostsresponseData removeAllObjects];
       
        [explorePostsresponseData  addObjectsFromArray:receivedData[@"data"]];
    }
    else {
        [explorePostsresponseData addObjectsFromArray:receivedData[@"data"]];
        self.currentIndex ++;
    }
    
    if(self.currentIndex == 0 )
    {
        for (NSInteger i = explorePostsresponseData.count-1; i > 0; i--) {
            [explorePostsresponseData exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform(i+1)];
        }
        self.currentIndex ++;
    }
    
    [self stopAnimation];
    
    [self.collectionViewOutlet reloadData];
}
- (void)stopAnimation {
    __weak searchViewController *weakSelf = self;
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.collectionViewOutlet.pullToRefreshView stopAnimating];
        [weakSelf.collectionViewOutlet.infiniteScrollingView stopAnimating];
    });
}
                                       
                                       
- (void)keyboardWillShown:(NSNotification*)notification {
                                           // Get the size of the keyboard.
                                           CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                                           //Given size may not account for screen rotation
                                           int  keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
                                           [self viewMoveUp:keyboardHeight];
}
                                       
-(void)viewMoveUp:(NSInteger )keyboardHeight {
    //moving view position based on keyBoard height and tabBar(this viewController is coming from tabBar).
    self.bottomConstraintOfBaseScrollView.constant = 0;
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.bottomConstraintOfBaseScrollView.constant = keyboardHeight - 50;
                         [self.view layoutIfNeeded];
                     }];
}
                                       
    -(void)onKeyboardHide:(NSNotification *)notification {
        [self viewMoveDown];
    }
                                       
-(void)viewMoveDown {
    //moving view position based on keyBoard height and tabBar(this viewController is coming from tabBar).
    self.bottomConstraintOfBaseScrollView.constant = 0;
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.bottomConstraintOfBaseScrollView.constant = 0;
                         [self.view layoutIfNeeded];
                     }];
}
                                       
-(UIView *)showingMessageForCollectionViewBackground:(NSString *)textmessage {
      UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
      [noDataAvailableMessageView setCenter:self.view.center];
      UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200,100)];
      message.numberOfLines =0;
      message.textAlignment = NSTextAlignmentCenter;
      message.text = textmessage;
      [noDataAvailableMessageView addSubview:message];
      self.collectionViewOutlet.backgroundColor = [UIColor whiteColor];
      self.collectionViewOutlet.backgroundView = noDataAvailableMessageView;
      return noDataAvailableMessageView;
 }
                                       
 -(void)addingActivityIndicatorToCollectionViewBackGround {
            avForCollectionView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            avForCollectionView.frame =CGRectMake(self.view.frame.size.width/2 -12.5, self.view.frame.size.height/2 -12.5, 25,25);
            avForCollectionView.tag  = 1;
            [self.collectionViewOutlet addSubview:avForCollectionView];
            [avForCollectionView startAnimating];
}
                                    
-(void)dismiss
 {
   [self.searchBar resignFirstResponder];
 }
@end
