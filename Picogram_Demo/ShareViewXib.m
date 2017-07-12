//
//  ShareViewXib.m
//
//
//  Created by Rahul Sharma on 4/18/16.
//
//
#import <QuartzCore/QuartzCore.h>
#import "ShareViewXib.h"
#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "PicogramSocketIOWrapper.h"
#import "ProgressIndicator.h"
#import "MSSend.h"
#import "MSReceive.h"
#import "Message.h"
#import "Helper.h"


#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatHelper.h"
#import <AVKit/AVKit.h>
#import "SOMessagingViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "CouchbaseEvents.h"
#import "MSReceive.h"
#import "ContacDataBase.h"
#import "MacroFile.h"


int keyboardHeight;
BOOL keyBoardOpened;
UITextField *textSearchField;




int numberOfitemsSelected;
@implementation ShareViewXib
{
    BOOL cancel;
    BOOL isFilterd;
    NSMutableArray *filterd;
    int s1;
    //    int s;
    NSManagedObject *userInfo;
    
    NSMutableArray *selectedUsers;
    NSString *GroupName;
    NSString *groupID;
    NSString *message;
    int indexForChat;
}
@synthesize delegate;
@synthesize showContactView,chatAvaliable;
- (instancetype)init {
    
    
    self = [super init];
    self = [[[NSBundle mainBundle] loadNibNamed:@"ShareViewXib"
                                          owner:self
                                        options:nil] firstObject];
    
    UINib *cellNib = [UINib nibWithNibName:@"cellXib" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cell"];
    
    
    [self.searchBarOutlet setImage:[UIImage imageNamed:@"search_add_contact_icon_on_2x_converted"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    textSearchField = [self.searchBarOutlet valueForKey:@"_searchField"];
    textSearchField.backgroundColor = [UIColor whiteColor];
    textSearchField.textColor =[UIColor grayColor];
    textSearchField.clearsOnBeginEditing =YES;
    
    [textSearchField setValue:[UIColor grayColor]
                   forKeyPath:@"_placeholderLabel.textColor"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    return self;
}



- (void)showViewWithContacts:(UIWindow *)window {
    [self getChatDoc];
    chatAvaliable = 0;
    
    cancel = NO;
    isFilterd = NO;
    s1 = 0;
    self.msgTextField.hidden = YES;
    [showContactView bringSubviewToFront:_testView];
    self.hightOfTextField.constant = 0;
    self.sendtoLabelHeight.constant = 0;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(creatnewGroupPost:) name:@"PostChatCreate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadListViewPost:) name:@"NewChatCreated" object:nil];
    
    
    selectedUsers = [[NSMutableArray alloc]init];
    //    userInfo = [[NSDictionary alloc]init];
    _selectedArray = [[NSMutableArray alloc]init];
    
    numberOfitemsSelected=0;

//    self.ShowContavtViewbottomConstraint.constant = -240;
//    [UIView animateWithDuration:1 animations:^{
//        self.ShowContavtViewbottomConstraint.constant = 0;
//        
//        [showContactView layoutIfNeeded];
//    }completion:nil];
    [window addSubview:self];
    self.frame = window.frame;
    
//    [UIView animateWithDuration:3
//                          delay:0.4
//                        options:UIViewAnimationOptionTransitionCurlUp
//                     animations:^(void) {
//                         self.ShowContavtViewbottomConstraint.constant = 0;
//                     }
//                     completion:NULL];
    
    self.ShowContavtViewbottomConstraint.constant = -240;

    [self layoutIfNeeded];
    
    [UIView animateWithDuration:0.75f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.ShowContavtViewbottomConstraint.constant = 0;

                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
    
  
}

#pragma mark - Couch Db Data

-(void)getChatDoc
{
    _totalRows = [NSMutableArray new];
    
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
        CBLQuery *query = [bgDB createAllDocumentsQuery];
        
        query.allDocsMode = kCBLAllDocs;
        query.descending = YES;
        //query.indexUpdateMode = kCBLUpdateIndexBefore;
        // query.descending = NO;
        // [query startKey];
        NSString *contaDocID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:contacDBDocumentID]];
        NSString *favDocID =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:favDBdocumentID]];
        _result = [query run:&error];
        
        
        for (NSInteger count = 0; count < _result.count; count++) {
            if ([[_result rowAtIndex:count].documentID isEqualToString:contaDocID]) {
            }else if ([[_result rowAtIndex:count].documentID isEqualToString:favDocID]){
            }else{
                [_totalRows addObject:[_result rowAtIndex:count]];
                
            }
            
        }
    });
    
}


-(void)didGroupExist
{
    
    for(int i=0;i<[_totalRows count];i++)
    {
        NSMutableArray *groupMembers = [NSMutableArray new];
        int check = 0;
        CBLQueryRow *row;
        row= [_totalRows objectAtIndex:i];
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        NSArray *objs = [getDocument.properties objectForKey:@"groupMembers"];
        groupMembers = [objs mutableCopy];
        NSInteger index = [groupMembers indexOfObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]];
        if(index < [groupMembers count] && index >= 0)
        [groupMembers removeObjectAtIndex:index];
        NSInteger countG = [groupMembers count];
        if(countG == [selectedUsers count])
        {
            
            for(int j=0;j<[groupMembers count]; j++)
            {
                for(int k=0;k<[groupMembers count]; k++)
                {
                    NSString *name = [NSString stringWithFormat:@"%@",groupMembers[j]];
                    userInfo = selectedUsers[k];
                    if(![name isEqualToString:[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"memberid"]]])
                    {
                        //                    check=0;
                        //                    break;
                    }else
                    {
                        check= check+1;
                    }
                }
            }
        }
        if(check == [groupMembers count])
        {
            chatAvaliable = 1;
            indexForChat = i;
            break;
        }
    }
    
    
}



#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //    [textField becomeFirstResponder];
    
    return  YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.searchButtonOutlet.enabled = YES;
    
    if (keyBoardOpened) {
        [self.searchBarOutlet resignFirstResponder];
        [self viewMoveDown];
    }
    
    
    self.searchBarOutlet.hidden=YES;
    self.sendToLabelOutlet.hidden=NO;
    self.groupName.hidden = NO;
    [self.msgTextField becomeFirstResponder];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    
    [textField addTarget:self action:@selector(textChangedLabel:) forControlEvents:UIControlEventEditingChanged];
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return newLength <= 100000;
}

-(void)textChangedLabel:(UITextField *)textField
{
    NSString *nameString = textField.text;
    message =nameString;
    
    
}


- (IBAction)cancelButtonAction:(id)sender {
    self.searchButtonOutlet.enabled = YES;
    
    [delegate cancelButtonClicked];
}

#pragma mark - search bar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //    [textSearchField resignFirstResponder];
}
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//
//    [_collectionView reloadData];
//}






- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    isFilterd = YES;
    filterd = [[NSMutableArray alloc]init];
    if(searchText.length != 0 )
    {
        self.groupName.hidden = YES;
        for(int i=0; i<[_friendesListShow count]; i++)
        {
            NSManagedObject *friends = [self.friendesListShow objectAtIndex:i];
            NSString *memberName = [friends valueForKey:@"memberName"];
            NSString *memberFullName = @"";
            
            NSString *fullName = [friends valueForKey:@"memberFullName"];
            if(fullName==nil || fullName==(id)[NSNull null] || [fullName isEqualToString:@"<null>"])
            {
                memberFullName = [friends valueForKey:@"memberFullName"];
            }
            
            if ([memberName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound  || [memberFullName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound   ) {
                
                NSManagedObject *userDetail;
                userDetail = [self.friendesListShow objectAtIndex:i];
                [filterd addObject:userDetail];
                
            }
            
            
        }
    }
    else
    {
        isFilterd =NO;
        cancel = YES;
    }
    
    
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        
        [_collectionView reloadData];
    }];
    
}

#pragma mark - CollectionView Delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if(isFilterd == NO)
    {
        return [_friendesListShow count];
    }
    else
        return [filterd count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AllContactsCollectionViewCell *allContactsCollectionCell;
    allContactsCollectionCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    //    static NSString *cellid =@"cell";
    //    __weak AllContactsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
    NSManagedObject *friends;
    if(isFilterd == YES)
    {
        friends = [filterd objectAtIndex:indexPath.row];
    }
    else
        friends =  [self.friendesListShow objectAtIndex:indexPath.row];
    
    if([selectedUsers count]>1)
    {
        [_sendButtonOutlet setTitle:@"Send To Group" forState:UIControlStateNormal];
    }
    else{
        [_sendButtonOutlet setTitle:@"Send" forState:UIControlStateNormal];
    }
    
    
    
    NSString *imageURL = [friends valueForKey:@"memberImage"];
    if(imageURL==nil || imageURL==(id)[NSNull null] || [imageURL isEqualToString:@"(null)"])
    {
        allContactsCollectionCell.imageView.image = [UIImage imageNamed:@"DefaultContactImage"];
    }
    else{
        NSURL *imageUrl =[NSURL URLWithString:imageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
        
        [allContactsCollectionCell.imageView setImageWithURLRequest:request
                                                   placeholderImage:placeholderImage
                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                
                                                                allContactsCollectionCell.imageView.image = image;
                                                            } failure:nil];
    }
    
    allContactsCollectionCell.username.text = [friends valueForKey:@"memberName"];
    
    NSString *fullName = [friends valueForKey:@"memberFullName"];
    if(fullName==nil || fullName==(id)[NSNull null] || [fullName isEqualToString:@"<null>"])
    {
        allContactsCollectionCell.userFullname.text = @"";
    }
    else
    {
        allContactsCollectionCell.userFullname.text = [friends valueForKey:@"memberFullName"];
    }
    
    //  allContactsCollectionCell.imageView.layer.cornerRadius = allContactsCollectionCell.imageView.frame.size.width / 2;
    
//    allContactsCollectionCell.imageView.layer.cornerRadius = allContactsCollectionCell.imageView.bounds.size.width / 2;
//    allContactsCollectionCell.imageView.clipsToBounds = YES;
//    
//    
    
    
    //    allContactsCollectionCell.imageView.layer.borderWidth = 1 ;
    //    allContactsCollectionCell.imageView.layer.borderColor =[[UIColor grayColor
    //                                                             ] CGColor];
    
    
    int s=0;
    
    if([selectedUsers count] != 0)
    {
        self.msgTextField.hidden = NO;
        
        self.showContactViewHeightConstraint.constant = 240;
        self.textFieldHeight.constant = 40;
        self.sendtoLabelHeight.constant = 25;
        
    }
    else{
        self.msgTextField.hidden = YES;
        
        self.sendtoLabelHeight.constant = 0;
        self.showContactViewHeightConstraint.constant = 200;
        self.textFieldHeight.constant = 0;
        
    }
    
    for(int i=0; i<[selectedUsers count];i++)
    {
        NSManagedObject *obj = [selectedUsers objectAtIndex:i];
        if([obj isEqual:friends])
        {
            s=1;
        }
    }
    if (s ==0)  {
        allContactsCollectionCell.backgroundColor = [UIColor clearColor];
        allContactsCollectionCell.imageView.layer.borderColor =  [[UIColor whiteColor] CGColor];;
        allContactsCollectionCell.imageView.layer.borderWidth = 1 ;
    }else{
        
        allContactsCollectionCell.imageView.layer.borderColor = [[UIColor blueColor] CGColor];
        allContactsCollectionCell.imageView.layer.borderWidth = 2 ;
    }
    
    [allContactsCollectionCell layoutIfNeeded];
    
    
    return allContactsCollectionCell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int s=0;
    self.searchButtonOutlet.enabled = YES;
    
    if(isFilterd || cancel)
    {
        [self viewMoveDown];
        cancel = NO;
    }else
    {
        if (keyBoardOpened) {
            [self.msgTextField resignFirstResponder];
            [self viewMoveDown];
        }
    }
    [self.searchBarOutlet resignFirstResponder];

    self.searchBarOutlet.hidden=YES;
    self.sendToLabelOutlet.hidden=NO;
    self.groupName.hidden = NO;
    
    
    // allContactsCollectionCell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    for(int i=0; i<[selectedUsers count];i++)
    {
        NSDictionary *obj = [selectedUsers objectAtIndex:i];
        if(isFilterd)
        {
            [[self searchBarOutlet] endEditing:YES];
            [_searchBarOutlet resignFirstResponder];
            //            [_msgTextField becomeFirstResponder];
            userInfo = [filterd objectAtIndex:indexPath.row];
        }
        else
        {
            userInfo = [self.friendesListShow objectAtIndex:indexPath.row];
        }
        if([obj isEqual:userInfo])
        {
            
            
            s=1;
            
            if(isFilterd)
            {
                userInfo = [filterd objectAtIndex:indexPath.row];
                
            }
            else
            {
                userInfo = [self.friendesListShow objectAtIndex:indexPath.row];
            }
            [selectedUsers removeObjectAtIndex:i];
            if(selectedUsers.count == 0)
            {
                [self.msgTextField resignFirstResponder];
                //                [self resignFirstResponder];
            }
            
            self.groupName.text = @"";
            for(int j=0; j<[selectedUsers count];j++)
            {
                
                userInfo = [selectedUsers objectAtIndex:j];
                if(self.groupName.text.length == 0)
                {
                    self.groupName.text = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"memberName"]];
                }
                else
                    self.groupName.text = [NSString stringWithFormat:@"%@,%@",self.groupName.text ,[userInfo valueForKey:@"memberName"]];
            }
            
            if ([selectedUsers count] == 0 ) {
                self.sendButtonOutlet.hidden = YES;
                self.cancelButtonOutlet.hidden = NO;
            }
            NSLog(@"unselected item at:%ld",(long)indexPath.row);
        }
    }
    if(s==0)
    {
        if(isFilterd)
        {
            [[self searchBarOutlet] endEditing:YES];
            [_searchBarOutlet resignFirstResponder];
            userInfo = [filterd objectAtIndex:indexPath.row];
        }
        else
        {
            userInfo = [self.friendesListShow objectAtIndex:indexPath.row];
        }
        [_selectedArray addObject:indexPath];
        
        if(self.groupName.text.length == 0)
        {
            self.groupName.text = [NSString stringWithFormat:@"%@",[userInfo valueForKey:@"memberName"]];
        }
        else
            self.groupName.text = [NSString stringWithFormat:@"%@,%@",self.groupName.text ,[userInfo valueForKey:@"memberName"]];
        
        [selectedUsers addObject:userInfo];
        
        if ([selectedUsers count] != 0 ) {
            
            self.sendButtonOutlet.hidden = NO;
            self.cancelButtonOutlet.hidden = YES;
        }
        NSLog(@"selected item at:%ld",(long)indexPath.row);
        
    }
    NSIndexPath *inde = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    NSArray *reload = [NSArray arrayWithObject:inde];
    if(isFilterd)
    {
        [collectionView reloadData];
    }
    else
        [collectionView reloadItemsAtIndexPaths:reload];
    isFilterd = NO;
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // self.showContactViewHeightConstraint.constant =200;
    //    numberOfitemsSelected--;
    //    if (numberOfitemsSelected == 0 ) {
    //        self.sendButtonOutlet.hidden = YES;
    //        self.cancelButtonOutlet.hidden = NO;
    //    }
    //    NSLog(@"unselected item at:%ld",(long)indexPath.row);
    //    allContactsCollectionCell = (AllContactsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //    allContactsCollectionCell.backgroundColor = [UIColor clearColor];
    //    allContactsCollectionCell.imageView.layer.borderColor = nil;
}

#pragma mark - TapGesture Action

-(void)viewMoveDown {
    [UIView animateWithDuration:0.4
                     animations:^{
                         CGRect frameOfView = self.showContactView.frame;
                         frameOfView.origin.y = frameOfView.origin.y +(keyboardHeight);
                         self.showContactView.frame = frameOfView;
                         
                         CGRect frameOfClearView = self.clearViewTopOfAddContactView.frame;
                         frameOfClearView.origin.y = 0;
                         self.clearViewTopOfAddContactView.frame = frameOfClearView;
                         
                     }];
}


- (IBAction)tapGestureAction:(id)sender {
    CGPoint location = [sender locationInView:self];
    id tappedView = [self hitTest:location withEvent:nil];
    //    if(keyBoardOpened) {
    //        [UIView animateWithDuration:0.4
    //                         animations:^{
    //                             CGRect frameOfView = self.showContactView.frame;
    //                             frameOfView.origin.y = frameOfView.origin.y + keyboardHeight;
    //                             self.showContactView.frame = frameOfView;
    //
    //                             CGRect frameOfClearView = self.clearViewTopOfAddContactView.frame;
    //                             frameOfClearView.origin.y =0;
    //                             self.clearViewTopOfAddContactView.frame = frameOfClearView;
    //                              [self endEditing:YES];
    //                             [self layoutIfNeeded];
    //                         }];
    //        return;
    //    }
    //    if(keyBoardOpened) {
    //        [UIView animateWithDuration:0.5
    //                         animations:^{
    //                             [_msgTextField becomeFirstResponder];
    //                             [self layoutIfNeesellectedded];
    //                         }
    //                         completion:nil];
    //    }
    
    if ([tappedView isEqual:self.clearViewTopOfAddContactView]) {
        
        
        self.ShowContavtViewbottomConstraint.constant = 0;
        
        [UIView animateWithDuration:0.75 animations:^{
            self.ShowContavtViewbottomConstraint.constant = -240;
            
            [self layoutIfNeeded];
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        
        //        [UIView animateWithDuration:0.5
        //                         animations:^{
        //                              [self removeFromSuperview];
        //                               [self layoutIfNeeded];
        //                            }
        //                         completion:nil];
        
    }
    //    [self removeFromSuperview];
}

- (IBAction)searchButtonAction:(id)sender {
    
    self.searchButtonOutlet.enabled = NO;
    
    if (keyBoardOpened) {
        [self viewMoveDown];
    }
    [self.msgTextField resignFirstResponder];
    self.searchBarOutlet.hidden=NO;
    self.sendToLabelOutlet.hidden=YES;
    self.groupName.hidden = YES;
    [self.searchBarOutlet becomeFirstResponder];
    
    
}
- (void)keyboardWillShown:(NSNotification*)notification
{
    // Get the size of the keyboard.
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    
    keyBoardOpened = YES;
    
    [self viewMoveUp];
    
    
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    keyBoardOpened = NO;
}

-(void)viewMoveUp
{
    //moving view position based on keyBoard height and tabBar(this viewController is coming from tabBar).
    [UIView animateWithDuration:0.4
                     animations:^{
                         CGRect frameOfView = self.showContactView.frame;
                         frameOfView.origin.y = frameOfView.origin.y -(keyboardHeight);
                         self.showContactView.frame = frameOfView;
                         
                         CGRect frameOfClearView = self.clearViewTopOfAddContactView.frame;
                         frameOfClearView.origin.y = -(keyboardHeight);
                         self.clearViewTopOfAddContactView.frame = frameOfClearView;
                         
                     }];
}

-(NSString *)randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString1 = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString1 appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString1;
}





-(void)reloadListViewPost:(NSNotification*)userNotification{
    
    [self getAllChatDocuments];
    
}

-(void)getAllChatDocuments {
    
    _totalRows = [NSMutableArray new];
    _totalDocumentID = [NSMutableArray new];
    CBLManager *manager = [CBLManager sharedInstance];
    CBLManager* bgMgr = [manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSError *error;
        CBLDatabase* bgDB = [bgMgr databaseNamed:@"couchbasenew" error: &error];
        CBLQuery *query = [bgDB createAllDocumentsQuery];
        
        query.allDocsMode = kCBLAllDocs;
        query.descending = YES;
        NSString *contaDocID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:contacDBDocumentID]];
        NSString *favDocID =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:favDBdocumentID]];
        _result = [query run:&error];
        
        
        for (NSInteger count = 0; count < _result.count; count++) {
            if ([[_result rowAtIndex:count].documentID isEqualToString:contaDocID]) {
            }else if ([[_result rowAtIndex:count].documentID isEqualToString:favDocID]){
            }else{
                [_totalRows addObject:[_result rowAtIndex:count]];
                CBLQueryRow *row = [_result rowAtIndex:count]; //[_totalRows objectAtIndex:count];
                CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
                [_totalDocumentID addObject:row.documentID];
                [self addObserverForDoc:getDocument];
                
                
            }
            
        }
        
        
        
        [self firstTimeReorderTableView:_totalDocumentID];
        
        _docCount = _result.count;
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSNumber *value = [[NSUserDefaults standardUserDefaults]objectForKey:@"isComingfromPush"];
            if (value.boolValue == YES) {
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isComingfromPush"];
                
                NSString *fromNum =[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"StoredocIdFromPush"]];
                
                NSString *fromDocID  = [self getDocumentIDWithSenderID:fromNum];
                int rowIndex = 0 ;
                for (int i= 0; i<_totalDocumentID.count; i++) {
                    NSString *docIDS = [_totalDocumentID objectAtIndex:i];
                    if ([docIDS isEqualToString:fromDocID]) {
                        rowIndex = i;
                    }
                }
                //  NSLog(@"doc indexpath =%d",rowIndex);
                //                NSIndexPath *path =[NSIndexPath indexPathForRow:rowIndex inSection:0];
                //                [_tableviewOutlet selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionNone];
                //                [self tableView:self.tableviewOutlet didSelectRowAtIndexPath:path];
            };
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"PostChatCreate" object:nil userInfo:nil];
            
        }];
        
    });
    
}

-(void)firstTimeReorderTableView:(NSMutableArray *)totalDocumentId{
    
    
    NSMutableArray *getPrevArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:StorDocIDArray]];
    
    for (int i=0; i<getPrevArr.count; i++) {
        NSLog(@"first reload , storeID =%@",getPrevArr[i]);
    }
    
    
    if (getPrevArr.count ==0) {
        [[NSUserDefaults standardUserDefaults] setObject:_totalDocumentID forKey:StorDocIDArray];
    }
    
    if (getPrevArr.count == _totalDocumentID.count) {
        
        [_totalDocumentID removeAllObjects];
        [_totalDocumentID addObjectsFromArray:[getPrevArr copy]];
        /*Store DocumentID Array*/
        [[NSUserDefaults standardUserDefaults] setObject:_totalDocumentID forKey:StorDocIDArray];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        for (int i=0;i<_totalDocumentID.count; i++) {
            
            for (int j=0; j<_totalRows.count; j++) {
                
                CBLQueryRow *row = [_totalRows objectAtIndex:j];
                
                if ([row.documentID isEqualToString:_totalDocumentID[i]]) {
                    
                    [temp addObject:_totalRows[j]];
                }
            }
            
        }
        
        [_totalRows removeAllObjects];
        [_totalRows addObjectsFromArray:[temp copy]];
    }
    
}

-(void)addObserverForDoc:(CBLDocument*)getDoc{
    
    [[NSNotificationCenter defaultCenter] addObserverForName: kCBLDocumentChangeNotification
                                                      object: getDoc
                                                       queue: nil
                                                  usingBlock: ^(NSNotification *n) {
                                                      CBLDatabaseChange* change = n.userInfo[@"change"];
                                                      //[self setNeedsDisplay: YES];  // redraw the view
                                                      
                                                      [self reOrderListView:change.documentID];
                                                      
                                                  }
     ];
    
    
}

-(NSString*)getDocumentIDWithSenderID:(NSString *)senderID{
    NSString *reciverName_DoId;
    
    for (int i=0;i<_totalRows.count ;i++) {
        CBLQueryRow *row = [_totalRows objectAtIndex:i];
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        NSString *reciverName = [getDocument.properties objectForKey:@"receivingUser"];
        if ([senderID isEqualToString:reciverName]) {
            
            reciverName_DoId = row.documentID;
        }
    }
    
    return reciverName_DoId;
    
}

-(void)reOrderListView:(NSString *)documentID{
    
    NSMutableArray *temp = [[NSMutableArray alloc]initWithArray:[_totalDocumentID copy]];
    
    for (int i=0;i<_totalRows.count;i++)
    {
        // NSString *docID = _totalDocumentID[i];
        NSString *docID = temp[i];
        
        if ([docID isEqualToString:documentID])
        {
            CBLQueryEnumerator *resetEnumerator = _totalRows[i];
            NSMutableArray *tempArr = [NSMutableArray new];
            tempArr = [_totalRows mutableCopy];
            [tempArr removeObjectAtIndex:i];
            
            NSMutableArray *temp2 = [NSMutableArray new];
            [temp2 addObject:resetEnumerator];
            [temp2 addObjectsFromArray:tempArr];
            
            _totalRows  =[NSMutableArray new];
            _totalRows = [temp2 mutableCopy];
            
            [_totalDocumentID removeAllObjects];
            _totalDocumentID = [NSMutableArray new];
            
            for (int i=0;i<_totalRows.count;i++) {
                CBLQueryRow *row = [_totalRows objectAtIndex:i];
                [_totalDocumentID addObject:row.documentID];
            }
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:_totalDocumentID forKey:StorDocIDArray];
    
    //    if(s == 0)
    //    {
    //        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(creatnewGroupPost:) name:@"CreatNewGroup" object:nil];
    //        s=1;
    //    }
}

-(void)reOrderTableViewNewMsgCame{
    
    NSMutableArray *getPrevArr = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:StorDocIDArray]];
    [_totalDocumentID removeAllObjects];
    [_totalDocumentID addObjectsFromArray:[getPrevArr copy]];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for (int i=0;i<_totalDocumentID.count; i++) {
        
        for (int j=0; j<_totalRows.count; j++) {
            
            CBLQueryRow *row = [_totalRows objectAtIndex:j];
            
            if ([row.documentID isEqualToString:_totalDocumentID[i]]) {
                
                [temp addObject:_totalRows[j]];
            }
        }
        
    }
    
    [_totalRows removeAllObjects];
    [_totalRows addObjectsFromArray:[temp copy]];
    
    
}


-(void)updateTableView:(NSNotification *)userNotificaton{
    
    
    [self reOrderTableViewNewMsgCame];
    
    
    
}

#pragma mark - Create Chat Button

- (IBAction)sendButtonAction:(id)sender {
    [self didGroupExist];
    if(chatAvaliable == 1)
    {
        CBLQueryRow *row;
        
        row= [_totalRows objectAtIndex:indexForChat];
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        CBLDocument *currentDocument = getDocument;
        
        NSString  *groupId = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupID"]];
        
        
        
        MSSend *messageStorage = [MSSend sharedInstance];
        messageStorage.delegate = self;
        
        if(s1== 0)
        {
            NSString *valueToSave = @"Yes";
            [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"SharePost"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [messageStorage sendPost:_friendesPost onDocument:currentDocument groupId:groupId];
            if (message) {
                [messageStorage sendMessage:message onDocument:currentDocument groupId:groupId];
            }
            
            s1=1;
        }
        
        NSArray *stringArray = [[NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupPic"]] componentsSeparatedByString: @","];
        NSString *imageURL1 = [stringArray firstObject];
        
        NSDictionary *detail = @{@"GroupImage": imageURL1,
                                 @"GroupMembers":[getDocument.properties objectForKey:@"groupName"]
                                 };
        [delegate sendButtonClicked:detail];
        
    }
    else{
        
        self.searchButtonOutlet.enabled = YES;
        
        UIButton *yy = (UIButton*)sender;
        yy.enabled = NO;
        NSString *imagesUrl;
        //    NSDictionary *details = [selectedUsers firstObject];
//        if([selectedUsers count] != 1)
//        {
            GroupName =[NSString stringWithFormat:@"%@",[Helper userName]];
//        }
        
        if(![[userInfo valueForKey:@"memberImage"] isEqualToString:@"<null>"] && [selectedUsers count] == 1)
        {
            imagesUrl = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"userprofilePicUrl"]];
        }
        
        //    imagesUrl = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"image"]];
        NSLog(@"Create chat Button");
        
        NSMutableArray *sendNum = [NSMutableArray new];
        for (int i =0; i<selectedUsers.count; i++) {
            userInfo = selectedUsers[i];
            [sendNum addObject:[NSString stringWithFormat:@"%@",[userInfo valueForKey:@"memberid"]]];
            if(GroupName.length)
            {
                GroupName = [NSString stringWithFormat:@"%@,%@",GroupName ,[userInfo valueForKey:@"memberName"] ];
                if(![[userInfo valueForKey:@"memberImage"] isEqualToString:@"<null>"])
                {
                    if(imagesUrl.length ==0)
                    {
                        imagesUrl = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"memberImage"]];
                    }
                    else{
                        imagesUrl = [NSString stringWithFormat:@"%@,%@",imagesUrl, [userInfo valueForKey:@"memberImage"]];
                    }
                }
            }
            else{
                GroupName = [NSString stringWithFormat:@"%@" ,[userInfo valueForKey:@"memberName"] ];
                
            }
        }
        
        NSString *userNo = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        [sendNum addObject:userNo];
        groupID  = [self randomStringWithLength:20];
        PicogramSocketIOWrapper *sock = [PicogramSocketIOWrapper sharedInstance];
        
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            if(imagesUrl.length !=0)
            {
                [sock creatNewGroup:GroupName groupMembers:[sendNum copy] groupId:groupID groupPic:imagesUrl type:@"1"];
            }
            else
            {
                [sock creatNewGroup:GroupName groupMembers:[sendNum copy] groupId:groupID groupPic:@"" type:@"1"];
            }
        }];
    }
    
    
}



-(void)creatnewGroupPost:(NSNotification*)notification{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        
        
        CBLQueryRow *row;
        
        row= [_totalRows firstObject];
        NSLog(@"%@",_totalRows);
        
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        CBLDocument *currentDocument = getDocument;
        
        NSString  *groupId = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupID"]];
        
        
        
        MSSend *messageStorage = [MSSend sharedInstance];
        messageStorage.delegate = self;
        
        if(s1== 0)
        {
            NSString *valueToSave = @"Yes";
            [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"SharePost"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            Message *msg = [messageStorage sendPost:_friendesPost onDocument:currentDocument groupId:groupId];
            if (message) {
                [messageStorage sendMessage:message onDocument:currentDocument groupId:groupId];
            }
            
            s1=1;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // [self sendMessage:msg];
            
            
        }];
        
    }];
    CBLQueryRow *row;
    
    row= [_totalRows firstObject];
    
    CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
    NSArray *stringArray = [[NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupPic"]] componentsSeparatedByString: @","];
    NSString *imageURL1 = [stringArray firstObject];
    
    NSDictionary *detail = @{@"GroupImage": imageURL1,
                             @"GroupMembers":[getDocument.properties objectForKey:@"groupName"]
                             };
    
    [delegate sendButtonClicked:detail];
    
    //    [self performSelector:@selector(creatGroup)
    //               withObject:self
    //               afterDelay:3.0];
    //
    
    
    
}

-(void)creatGroup
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        
        
        CBLQueryRow *row;
        
        row= [_totalRows firstObject];
        NSLog(@"%@",_totalRows);
        
        CBLDocument *getDocument = [CBObjects.sharedInstance.database documentWithID:row.documentID];
        CBLDocument *currentDocument = getDocument;
        
        NSString  *groupId = [NSString stringWithFormat:@"%@",[getDocument.properties objectForKey:@"groupID"]];
        
        
        
        MSSend *messageStorage = [MSSend sharedInstance];
        messageStorage.delegate = self;
        
        if(s1== 0)
        {
            NSString *valueToSave = @"Yes";
            [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"SharePost"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [messageStorage sendPost:_friendesPost onDocument:currentDocument groupId:groupId];
            if (message) {
                [messageStorage sendMessage:message onDocument:currentDocument groupId:groupId];
            }
            s1=1;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            //             [self sendMessage:msg];
            //            [self sendMessage:msg1];
        }];
        
    }];
    
    
    //    [delegate sendButtonClicked];
    
    
}

@end
