//
//  ConversationListViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 10/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ConversationListViewController.h"
#import "ConversationTableCell.h"
#import "WebServiceHandler.h"
#import "WebServiceConstants.h"
#import "Helper.h"


@interface ConversationListViewController ()<WebServiceHandlerDelegate>

@end

@implementation ConversationListViewController
{
    NSArray *listFollers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated
{
    NSString *token =[Helper userToken];
    
    NSDictionary *request = @{@"token":token};
    
    [WebServiceHandler getFollowersList:request andDelegate:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - webservice Delegate

-(void)didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError *)error{
    if(requestType == RequestTypegetUserFollowRelation)
    {
        listFollers = response[@"followers"];
    }
}


#pragma mark  - table view data source and delegate methods

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return 75;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  1;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ConversationTableViewCell";
    
    __weak ConversationTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                                                                                                 
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"chatScreensegue" sender:nil];
}


- (IBAction)addButtonClicked:(id)sender {
    
    
    
}

- (IBAction)cameraButtonClicked:(id)sender {
}
@end
