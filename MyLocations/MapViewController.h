//
//  MapViewController.h
//  MyLocations
//
//  Created by Youwen Yi on 1/8/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong)NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

-(IBAction)showUser;

-(IBAction)showLocations;

@end
