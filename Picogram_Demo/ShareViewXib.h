//
//  ShareViewXib.h
//  
//
//  Created by Rahul Sharma on 4/18/16.
//
//

#import <UIKit/UIKit.h>
#import "AllContactsCollectionViewCell.h"
#import <CoreData/CoreData.h>
#import "SOMessagingViewController.h"


#import "UsersVC.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "CouchbaseEvents.h"
#import "MSReceive.h"
#import "suggestionViewController.h"

#import "Database.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "MBProgressHUD.h"
#import "FavDataBase.h"
#import "ContacDataBase.h"
#import "MacroFile.h"
#import "SuggestionNavigationController.h"
#import "PicogramSocketIOWrapper.h"

@protocol shareViewDelegate <NSObject>
-(void)cancelButtonClicked;
-(void)sendButtonClicked:(NSDictionary *)Data;
@end

@interface ShareViewXib : UIView<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,SocketWrapperDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,MessageStorageDelegate,CouchBaseEventsDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) id <shareViewDelegate> delegate;

- (void)showViewWithContacts:(UIWindow *)window;
@property (weak, nonatomic) IBOutlet UIView *showContactView;
- (IBAction)cancelButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)tapGestureAction:(id)sender;

- (IBAction)searchButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *searchButtonOutlet;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarOutlet;
@property (weak, nonatomic) IBOutlet UILabel *sendToLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *clearViewTopOfAddContactView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButtonOutlet;

- (IBAction)sendButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendButtonOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showContactViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ShowContavtViewbottomConstraint;

@property (strong) NSMutableArray *friendesListShow;
@property (strong) NSMutableArray *friendesPost;
@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldHeight;

@property (strong, nonatomic) NSMutableArray *totalRows;
@property (strong ,nonatomic)NSMutableArray *totalDocumentID;
@property (strong, nonatomic) CBLQueryEnumerator *result;
@property(assign, nonatomic) NSInteger docCount;
@property (strong, nonatomic) IBOutlet UILabel *groupName;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendtoLabelHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hightOfTextField;
@property (strong, nonatomic) IBOutlet UITextField *msgTextField;

@property (strong, nonatomic) IBOutlet UIView *testView;
@property ( nonatomic) int chatAvaliable;
@end
