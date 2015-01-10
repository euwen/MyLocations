//
//  CategoryPickViewController.h
//  MyLocations
//
//  Created by Youwen Yi on 1/6/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryPickViewController;

@protocol CategoryPickViewControllerDelegate <NSObject>

@required
-(void)categoryPick:(CategoryPickViewController *)picker didPickCatergory:(NSString *)categoryName;

@end


@interface CategoryPickViewController : UITableViewController

@property(nonatomic, weak) id <CategoryPickViewControllerDelegate> delegate;

@property(nonatomic,strong)NSString *selectedCategoryName;

@end
