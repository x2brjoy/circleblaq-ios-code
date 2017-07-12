//
//  AddSingleMemberTableViewController.m
//  Sup
//
//  Created by Rahul Sharma on 5/23/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "AddSingleMemberTableViewController.h"
#import  "PicogramSocketIOWrapper.h"
//#import "Favorites.h"
#import "Database.h"
#import "AddSingleMemCellTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "CouchbaseEvents.h"
#import "AppDelegate.h"
#import "ProgressIndicator.h"
#import "FavDataBase.h"
#import "ChatHelper.h"



@interface AddSingleMemberTableViewController ()<UIActionSheetDelegate>
{
    
    
    NSMutableArray *favListArr;
    NSDictionary *userInfo;
    NSManagedObject *friendselected;
}
@property (strong,nonatomic) FavDataBase *favDataBase;

@end

@implementation AddSingleMemberTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Select Contact";
    _favDataBase = [FavDataBase sharedInstance];
//    [self getSupDetailsFromDB];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotResponseAddUser:) name:@"addUsertoGroup" object:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
    self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
       self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [self.tblView reloadData];
}

-(void)getSupDetailsFromDB{
    
   // favListArr = [[NSMutableArray alloc]initWithArray:[Database dataFromTable:@"Favorites" condition:nil orderBy:@"fullName"  ascending:YES]];
    favListArr =[[NSMutableArray alloc]initWithArray:[_favDataBase getDataFavDataFromDB]];
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [_tblView reloadData];
    }];
    
    
}



- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}


-(void)viewDidDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addUsertoGroup" object:nil];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _friendesList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellid =@"addSingleMemeberCell";
    __weak AddSingleMemCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    
     NSManagedObject *friend = [self.friendesList objectAtIndex:indexPath.row];
    
//    userInfo = favListArr[indexPath.row];
//    NSString *imageURL = userInfo[@"image"];
    NSString *imageURL = [friend valueForKey:@"memberImage"];
    if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"])
    {
        cell.imagePic.image = [UIImage imageNamed:@"DefaultContactImage"];
    }
    else{
        NSURL *imageUrl =[NSURL URLWithString:imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
        [cell.imagePic setImageWithURLRequest:request
                             placeholderImage:placeholderImage
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                          
                                          cell.imagePic.image = image;
                                          cell.self.imagePic.layer.cornerRadius = cell.self.imagePic.frame.size.width / 2;
                                          cell.self.imagePic.clipsToBounds = YES;
                                          [cell setNeedsLayout];
                                      } failure:nil];
    }
    
    
    NSLog(@"%@     %@",[friend valueForKey:@"memberid"],[friend valueForKey: @"memberName"]);
    
//    cell.mainLbl.text = userInfo[@"fullName"];
    cell.mainLbl.text = [friend valueForKey:@"memberName"];
//    NSString *decodeStatus = [userInfo[@"status"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    decodeStatus = [ChatHelper decodedStringFrom64:decodeStatus];
//    cell.subLbl.text =decodeStatus;
    
    
    NSString *isAlready = [self checkUserIsalreadyinGroup:[friend valueForKey:@"memberid"]];
    if (isAlready.length>0) {
        cell.subLbl.text = isAlready;
        cell.userInteractionEnabled = NO;
        cell.mainLbl.textColor = [UIColor lightGrayColor];
    }else{
        
        cell.userInteractionEnabled = YES;
        cell.mainLbl.textColor = [UIColor blackColor];
    }
    
    
    if(cell.mainLbl.text.length==0)
    {
        cell.mainLbl.text = [friend valueForKey:@"memberid"];
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    userInfo = favListArr[indexPath.row];
    friendselected = [self.friendesList objectAtIndex:indexPath.row];
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"Add %@ to %@ group?",[friendselected valueForKey:@"memberName"],_groupName ] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add", nil];
    sheet.tag = indexPath.row;
    [sheet showInView:self.view];
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {

        userInfo = favListArr[actionSheet.tag];
        
        PicogramSocketIOWrapper *client = [PicogramSocketIOWrapper sharedInstance];
            [client addMembersToGroup:[friendselected valueForKey:@"memberid"] groupId:_groupId type:@"5" groupName:_groupName groupPic:_groupPic gpCreatedBy:_groupCreatBy docId:_documentId];
        
        [[ProgressIndicator sharedInstance]showPIOnView:self.view withMessage:@"Loading..."];
        
    }
    
    
}

-(NSString *)checkUserIsalreadyinGroup:(NSString *)userNumber{
    
    for (int i=0;i<_groupMembers.count; i++) {
        
        
        if ([userNumber isEqualToString:_groupMembers[i]]) {
            
            return @"Already added to the group";
        }
    }
    
     return @"";
}



-(void)gotResponseAddUser:(NSNotification*)notify{
    
    [[ProgressIndicator sharedInstance]hideProgressIndicator];
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
