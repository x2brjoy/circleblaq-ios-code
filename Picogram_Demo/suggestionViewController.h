//
//  suggestionViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 05/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface suggestionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISearchBar *userSerachView;
@property (strong, nonatomic) IBOutlet UITextField *searchTxtfld;

@property (strong, nonatomic) IBOutlet UITableView *tableViewOutlet;

- (IBAction)newMessageButton:(id)sender;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewOutlet;

- (IBAction)createChatButton:(id)sender;

-(void)favoritesSetUp;

@property (strong) NSMutableArray *friendesList;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *creatChatButtonOutlet;

@end
