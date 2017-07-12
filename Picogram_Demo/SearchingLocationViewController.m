//
//  SearchingLocationViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/21/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "SearchingLocationViewController.h"
#import "PlacesViewController.h"

@interface SearchingLocationViewController ()

@end

@implementation SearchingLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getLocation:(id)sender

{

//    PlacesViewController *places = [[PlacesViewController alloc] initWithNibName:@"PlacesViewController" bundle:nil];
//    
//    places.currentLocation = self.currentLocation;
//    
//    places.callback = ^(NSString *name , CLLocation *locaiton)
//    {
//      _locationTextField.text = name;
////        _taggedLocation = locaiton;
//    };
//    
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:places];
//    
//    [self presentViewController:navigationController animated:YES completion:nil];
    
 
    
   [self performSegueWithIdentifier:@"gettingLocationSegue" sender:nil];

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"gettingLocationSegue"])
    {
        
//        PGLocationViewController *locationController = [segue destinationViewController];
//        locationController.delegate = self;
        
       

        
        PlacesViewController *places =  [[PlacesViewController alloc] init];
        
        places.currentLocation = self.currentLocation;
        
        
        
        places.callback = ^(NSString *name , CLLocation *locaiton)
        {
//            _locationTextField.text = name;
//            _taggedLocation = locaiton;
        };
        
       
        
    }
    
}
@end
