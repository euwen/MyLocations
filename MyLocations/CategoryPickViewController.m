//
//  CategoryPickViewController.m
//  MyLocations
//
//  Created by Youwen Yi on 1/6/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import "CategoryPickViewController.h"

@interface CategoryPickViewController ()

@end

@implementation CategoryPickViewController{

    NSArray *_categories;
    NSIndexPath *_selectedIndexPath;
}

@synthesize delegate, selectedCategoryName;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _categories = @[
                    @"No Category",
                    @"Apple Store",
                    @"Bar",
                    @"Book Store",
                    @"Club",
                    @"Grocery Store",
                    @"Historic Building",
                    @"Icecream Vendor",
                    @"Landmark",
                    @"Park"];
    
    // Do any additional setup after loading the view.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"PickedCategory"]) {
        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        self.selectedCategoryName = _categories[indexPath.row];
    }

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

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [_categories count];

}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSString *categoryName = _categories[indexPath.row];
    
    cell.textLabel.text = categoryName;
    
    if ([categoryName isEqualToString:self.selectedCategoryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row!=_selectedIndexPath.row) {
        UITableViewCell *newCell=[tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        _selectedIndexPath = indexPath;
    }
    
    NSString *categoryName = [_categories objectAtIndex:indexPath.row];
    [self.delegate categoryPick:self didPickCatergory:categoryName];

}

@end
