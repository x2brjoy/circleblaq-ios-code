//
//  CountryListViewController.m
//  Country List
//
//  Created by Pradyumna Doddala on 18/12/13.
//  Copyright (c) 2013 Pradyumna Doddala. All rights reserved.
//

#import "CountryListViewController.h"
#import "CountryListDataSource.h"
#import "CountryCell.h"
#import "FontDetailsClass.h"
#import "TinderGenericUtility.h"

@interface CountryListViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataRows;
@property (strong, nonatomic) NSMutableArray *filteredResult; // this holds filtered data source
@property (strong, nonatomic)  NSMutableArray *tableData; //this holds actual data source
@end

@implementation CountryListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil delegate:(id)delegate
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        _delegate = delegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.navigationController.title= @"Select Country";
   
    
    CountryListDataSource *dataSource = [[CountryListDataSource alloc] init];
    
    _dataRows = [dataSource countries];
    [_tableView reloadData];
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    CountryCell *cell = (CountryCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[CountryCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text =flStrForObj([[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryName]);
    [cell.textLabel setFont:[UIFont fontWithName:RobotoRegular size:14]];
    cell.textLabel.textColor =[UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    
    cell.detailTextLabel.text = flStrForObj([[_dataRows objectAtIndex:indexPath.row] valueForKey:kCountryCallingCode]);
    cell.detailTextLabel.textColor =[UIColor colorWithRed:0.6471 green:0.6549 blue:0.6667 alpha:1.0];
    [cell.detailTextLabel setFont:[UIFont fontWithName:RobotoRegular size:14]];
   
    return cell;
}

#pragma mark - UITableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(didSelectCountry:)]) {
        [self.delegate didSelectCountry:[_dataRows objectAtIndex:[_tableView indexPathForSelectedRow].row]];
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        NSLog(@"CountryListView Delegate : didSelectCountry not implemented");
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) filterForSearchText:(NSString *) text scope:(NSString *) scope
{
    [_filteredResult removeAllObjects]; // clearing filter array
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"SELF.restaurantName contains[c] %@",text]; // Creating filter condition
    _filteredResult = [NSMutableArray arrayWithArray:[_dataRows filteredArrayUsingPredicate:filterPredicate]]; // filtering result
}

-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterForSearchText:searchString scope:[[[[self searchDisplayController] searchBar] scopeButtonTitles] objectAtIndex:[[[self searchDisplayController] searchBar] selectedScopeButtonIndex] ]];
    
    return YES;
}

-(BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

@end
