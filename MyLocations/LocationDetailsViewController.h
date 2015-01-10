//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Youwen Yi on 1/5/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CategoryPickViewController.h"

@class Location;

@interface LocationDetailsViewController : UITableViewController
<UITextViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CategoryPickViewControllerDelegate,
UIActionSheetDelegate>

@property(nonatomic,assign)CLLocationCoordinate2D coordinate;
@property(nonatomic,strong)CLPlacemark *placemark;

//to store the data to core data
@property(nonatomic, strong)NSManagedObjectContext *managedObjectContext;

@property(nonatomic, strong) Location *locationToEdit;

@property(nonatomic, strong)IBOutlet UIImageView *imageView;
@property(nonatomic, strong)IBOutlet UILabel *photoLabel;

@end
