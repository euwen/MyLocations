//
//  FirstViewController.h
//  MyLocations
//
//  Created by Youwen Yi on 12/31/14.
//  Copyright (c) 2014 Youwen Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationDetailsViewController.h"

@interface CurrentLocationViewController : UIViewController<CLLocationManagerDelegate>

@property(nonatomic,weak) IBOutlet UILabel *messageLabel;
@property(nonatomic,weak) IBOutlet UILabel *latitudeLabel;
@property(nonatomic,weak) IBOutlet UILabel *longtitudeLabel;
@property(nonatomic,weak) IBOutlet UILabel *adderssLabel;
@property(nonatomic,weak) IBOutlet UIButton *tagButton;
@property(nonatomic,weak) IBOutlet UIButton *getButton;

@property(nonatomic,strong) NSManagedObjectContext *managedObjectContext;

-(IBAction)getLocation:(id)sender;

@end

