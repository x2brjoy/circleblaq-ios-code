//
//  selectPostAsTableViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 10/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "selectPostAsTableViewController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "Helper.h"
#import "ProgressIndicator.h"

@interface selectPostAsTableViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,WebServiceHandlerDelegate>
{
   BOOL isSearching;
   NSArray *contentList;
   NSArray *filteredContentList;
   NSString *selectedKey;
   int index;
  UIActivityIndicatorView *avForTable;
    NSMutableArray *temp;
    NSMutableDictionary *catSubCatlist;
  
}

@end

@implementation selectPostAsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _listSerachBar.delegate = self;
    
    [self createNavLeftButton];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    index = 0;
    //contentList = [[NSArray alloc] initWithObjects:@"abc", @"abcd", @"xyz", @"amc", @"rio", @"new", nil];
    
    contentList = [[NSArray alloc]init];
    catSubCatlist = [[NSMutableDictionary alloc]init];
    if ([self.title isEqualToString:@"Currency"]) {
       // _listSerachBar.hidden = YES;
     
        CGRect frame = _listSerachBar.bounds;
        frame.size.height = 0;
        _listSerachBar.frame = frame;
    }
    if ([self.title isEqualToString:@"Category"])
    {
        [self requestCategoryList];
        ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];
        [HomePI showPIOnView:self.view withMessage:@"Loading..."];
    }
    if ([self.title isEqualToString:@"Sub-category"])
    {
        contentList = [_subCategoryArray copy];
    }
     if ([self.title isEqualToString:@"Currency"])
     {
         [self requestGetCurrency];
         ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];
         
         [HomePI showPIOnView:self.view withMessage:@"Loading..."];
    }
    
    filteredContentList = [[NSArray alloc] init];
}

/*----------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar buttons
/*-----------------------------------*/

- (void)createNavLeftButton {
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

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearching) {
     return [filteredContentList count];
    }
    else
    return [contentList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell" forIndexPath:indexPath];
    //NSString *str = [NSString stringWithFormat:@"New%ld",(long)indexPath.row];
   // cell.textLabel.text = str;
    if (isSearching) {
        cell.textLabel.text = [filteredContentList objectAtIndex:indexPath.row];
    }
    else {
        //NSDictionary *dic = contentList[indexPath.row];
        cell.textLabel.text =contentList[indexPath.row];//[contentList objectAtIndex:indexPath.row];
    }
    
    UIView *boarderLine = [[UIView alloc] initWithFrame:CGRectMake(20,43,self.view.frame.size.width,0.5)];
    
    boarderLine.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:boarderLine];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isSearching) {
        selectedKey = filteredContentList[indexPath.row];
    }
    else
        selectedKey = contentList[indexPath.row];
   // if (catSubCatlist[selectedKey]>0) {
    NSLog(@"port1");
        if (self.callBack) {
            NSLog(@"port1.1 Data:%@",catSubCatlist);
            self.callBack(selectedKey,_titleStr,catSubCatlist[selectedKey]);
            [self.navigationController popViewControllerAnimated:YES];
        }
   // }
    else
    {
    if (self.callBackOnlyCategory)
    {
        self.callBackOnlyCategory(selectedKey,_titleStr);
       [self.navigationController popViewControllerAnimated:YES];
        
    }
}
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
    //349
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text change - %d",isSearching);
    
    //Remove all objects first.
   // [filteredContentList removeAllObjects];
   

    if([searchText length] != 0) {
        isSearching = YES;
        [self searchTableList];
    }
    else {
        isSearching = NO;
    }
     [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    //[self searchTableList];
}

- (void)searchTableList {
    
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    _listSerachBar.text];
    
    filteredContentList = [contentList filteredArrayUsingPredicate:resultPredicate];
    
}

#pragma mark - defaultBackground
-(void)defaultBackground
{
avForTable = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
avForTable.frame =CGRectMake(self.view.frame.size.width/2 -12.5, self.view.frame.size.height/2 -12.5, 25,25);
[self.tableView addSubview:avForTable];
[avForTable startAnimating];
}
#pragma mark - WebServices

-(void)requestCategoryList
{
    NSDictionary *requestDict = @{
                                  mauthToken      :flStrForObj([Helper userToken]),
                                  moffset         :flStrForObj([NSNumber numberWithInteger:index*10]),
                                  mlimit          :flStrForObj([NSNumber numberWithInteger:10])
                                };
    [WebServiceHandler getCategory:requestDict andDelegate:self];
}

-(void)requestSubCategoryList
{
    NSDictionary *requestDict = @{
                                  mauthToken      :flStrForObj([Helper userToken]),
                                  moffset         :flStrForObj([NSNumber numberWithInteger:index*10]),
                                  mlimit          :flStrForObj([NSNumber numberWithInteger:10])
                                  };
    [WebServiceHandler getSubCategory:requestDict andDelegate:self];
}

-(void)requestGetCurrency
{
    NSDictionary *requestDict = @{
                                  mauthToken      :flStrForObj([Helper userToken]),
                                };
    [WebServiceHandler getCurrency:requestDict andDelegate:self];
}


- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    [avForTable stopAnimating];
    
    if (error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        
        self.tableView.backgroundView = [self showErrorMessage:[error localizedDescription]];
        
        return;
    }
    
    
    NSDictionary *responseDict = (NSDictionary*)response;
    
    if (requestType == RequestTypeGetCategories ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                NSLog(@"CategoryList:%@",responseDict);
                temp =responseDict[@"data"];//[0][@"data"];
                int count = (int)temp.count;
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                
                for (int i = 0; i<count; i++) {
                    //NSLog(@"categoryName:%@",flStrForObj(temp[i][@"categoryName"]));
                    
//                    if(category.length && ![category isEqualToString:@" "])
//                    {
//                        
//                        NSLog(@"categoryName:%@",flStrForObj(temp[i][@"categoryName"]));
                    
                    
                    if( flStrForObj(temp[i][@"categoryName"]).length && ![flStrForObj(temp[i][@"categoryName"]) isEqualToString:@" "])
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
                //contentList = responseDict[@"data"];
                [self.tableView reloadData];
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
    
    if (requestType == RequestTypeGetSubCategories ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                NSLog(@"SubCategoryList:%@",responseDict);
               // temp =responseDict[@"data"];//[0][@"data"];
                //contentList = responseDict[@"data"];
                //[self.tableView reloadData];
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
    if (requestType == RequestTypegetCurrency ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                //NSLog(@"currency:%@",responseDict[@"data"][@"currency"]);
                //NSString *currency = response[@"data"][@"currency"];
                //contentList = [currency componentsSeparatedByString: @","];
                //NSLog(@"seperated string:%@",contentList);

               // temp =responseDict[@"data"];//[0][@"data"];
               
                contentList = [[NSArray alloc] initWithObjects:@"INR", @"USD", nil];
                //contentList = responseDict[@"data"];
                [self.tableView reloadData];
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
    
    
    
}
- (void)errorAlert:(NSString *)message {
    //showing error alert for failure response.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}

-(void)refreshTable:(id)sender {
//    //reload table
//    
//    [refreshControlForFollowing beginRefreshing];
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = self.tableView;
    
}

-(UIView *)showErrorMessage:(NSString *)errorMessage {
    UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [noDataAvailableMessageView setCenter:self.view.center];
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200, 60)];
    message.textAlignment = NSTextAlignmentCenter;
    message.numberOfLines = 0;
    message.text = errorMessage;
    [noDataAvailableMessageView addSubview:message];
    
    return noDataAvailableMessageView;
}

@end
