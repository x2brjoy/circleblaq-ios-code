//
//  EditGroupnameTableViewController.m
//  Sup
//
//  Created by Rahul Sharma on 5/24/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "EditGroupnameTableViewController.h"
#import "EditGroupNameTableViewCell.h"
#import "PicogramSocketIOWrapper.h"


@interface EditGroupnameTableViewController ()<UITextFieldDelegate>

@end

@implementation EditGroupnameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Edit Group Name";
    _groupName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"storeGroupName"]];
       self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
     [self.navigationController.navigationBar setTranslucent:NO];
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

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EditGroupNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editgpNameCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.editNameText.text = _groupName;
   // cell.editNameText.clearButtonMode = UITextFieldViewModeUnlessEditing;
    cell.editNameText.delegate = self;

    return cell;
}



- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    if (range.location == 24) {
        return YES;
    }
    
    if([textField.text length] ==25){
        return NO;}
    else
        return YES;

    
    
    return YES;
}
-(void)textChanged:(UITextField *)textField
{
    _groupName = textField.text;
}


- (IBAction)cancelBtnCliked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveBtncliked:(id)sender {
    if(_groupName.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Group Name Can't be empty Please enter Name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
   NSString *oldName = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"storeGroupName"]];
   
    if ([oldName isEqualToString:_groupName]) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else{
        
        [[NSUserDefaults standardUserDefaults] setObject:_groupName forKey:@"storeGroupName"];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"sendRequestFrogpName"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
      [[NSNotificationCenter defaultCenter]postNotificationName:@"updateGroupName" object:nil userInfo:nil];
    }
}
@end
