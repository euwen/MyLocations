//
//  FirstViewController.m
//  MyLocations
//
//  Created by Youwen Yi on 12/31/14.
//  Copyright (c) 2014 Youwen Yi. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController{
    CLLocationManager *_locationManager;
    CLLocation *_location;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    
    //for geo location display
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performanceReverseGeocoding;
    NSError *_lastGeocodingError;

}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self=[super initWithCoder:aDecoder])) {
        _locationManager = [[CLLocationManager alloc]init];
        _geocoder = [[CLGeocoder alloc]init];
    }
    return self;

}


-(IBAction)getLocation:(id)sender{
    
    if (_updatingLocation) {
        [self stopLocationManager];

    }else{
        _location = nil;
        _lastLocationError=nil;
        
        _placemark = nil;
        _lastGeocodingError = nil;
        
        
        [self startLocationManager];
    
    }
    
    
    [self updateLabels];
    [self configureGetButton];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"TagLocation"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        LocationDetailsViewController *controller=(LocationDetailsViewController*)navigationController.topViewController;
        
        controller.coordinate = _location.coordinate;
        controller.placemark = _placemark;
        
        controller.managedObjectContext = self.managedObjectContext;
    }

}

#pragma mark -CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Localizaiton failed:%@",error);
    
    if (error.code==kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    _lastLocationError = error;
    
    [self updateLabels];
    [self configureGetButton];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    
    NSLog(@"Locaiton updated, current location: %@", newLocation);
    
    if ([newLocation.timestamp timeIntervalSinceNow]<-5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy<0) {
        return;
    }
    
    //avoid non-stop location update on ipad, itouch, etc.
    CLLocationDistance distance=MAXFLOAT;
    
    if (_location!=nil) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    //stop locaiton update if meet the accuracy requirement
    if (_location==nil||_location.horizontalAccuracy>newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy<=_locationManager.desiredAccuracy) {
            NSLog(@"Localization done");
            [self stopLocationManager];
            [self configureGetButton];
        }
        
    }
    
    if (distance>0) {
        _performanceReverseGeocoding=NO;
    }
    
    //for geo location reverse coding
    if ((!_performanceReverseGeocoding)) {
        NSLog(@"...Going to geocode");
        _performanceReverseGeocoding = YES;//avoid over use the service
        
        [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"...Found placemarks: %@, error:%@", placemarks,error);
            
            _lastLocationError = error;
            if (error==nil&&[placemarks count]>0) {
                _placemark = [placemarks lastObject];
            } else {
                _placemark=nil;
            }
            
            _performanceReverseGeocoding=NO;
            [self updateLabels];
        }];
        
    }else if (distance<1.0){
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        
        if (timeInterval>10) {
            NSLog(@"Force stop!");
            [self stopLocationManager];
            [self updateLabels];
            [self configureGetButton];
            
        }
    
    }
 
}

//update the labels shown on the screen
-(void)updateLabels{

    if (_location != nil) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", _location.coordinate.latitude];
        self.longtitudeLabel.text = [NSString stringWithFormat:@"%.8f", _location.coordinate.longitude];
        self.tagButton.hidden = NO;
        self.messageLabel.text = @"GPS Coordinates";
        
        //for geo location reverse coding
        if(_placemark!=nil){
            self.adderssLabel.text = [self stringFromPlacemark:_placemark];
            
        }else if (_performanceReverseGeocoding){
            self.adderssLabel.text = @"Searching...";
            
        }else if (_lastLocationError!=nil){
            self.adderssLabel.text = @"Sorry...";
            
        }else{
            self.adderssLabel.text = @"Not found";
        }
        
        
    } else {
        self.latitudeLabel.text = @"";
        self.longtitudeLabel.text = @"";
        self.adderssLabel.text = @"";
        self.tagButton.hidden = YES;
        
        //show the error message
        NSString *statusMessage;
        if (_lastLocationError!=nil) {
            if ([_lastLocationError.domain isEqualToString:kCLErrorDomain]&&_lastLocationError.code==kCLErrorDenied) {
                statusMessage = @"Sorry, User denied location function";
            } else {
                statusMessage=@"Sorry, cannot get location";
            }
            
        } else if(![CLLocationManager locationServicesEnabled]){
            statusMessage = @"Sorry, User denied location function";
            
        } else if(_updatingLocation){
            statusMessage = @"Searching ...";
        
        }else{
            statusMessage = @"Press the button to start";
        }
        
        self.messageLabel.text = statusMessage;
    }
}

//location
-(NSString*)stringFromPlacemark:(CLPlacemark*)thePlacemark{
    //return [NSString stringWithFormat:@"%@ %@\n%@ %@ %@", thePlacemark.subThoroughfare,thePlacemark.thoroughfare,thePlacemark.locality,thePlacemark.administrativeArea,thePlacemark.postalCode];
    
    if (thePlacemark.subThoroughfare != nil) {
        return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@", thePlacemark.subThoroughfare, thePlacemark.thoroughfare,thePlacemark.subLocality,thePlacemark.locality, thePlacemark.administrativeArea, thePlacemark.country];
    }else{
        return [NSString stringWithFormat:@"%@, %@, %@, %@, %@", thePlacemark.thoroughfare,thePlacemark.subLocality,thePlacemark.locality, thePlacemark.administrativeArea, thePlacemark.country];
    
    }
    
}

-(void)stopLocationManager{
    
    //to avoid the location manager stop before the interval
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
    
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _updatingLocation = NO;
    
}

-(void)startLocationManager{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        
        //required for iOS 8
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        
        //set the localizaiton interval
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

-(void)didTimeOut:(id)obj{

    NSLog(@"oops, time out!");
    
    if (_location==nil) {
        [self stopLocationManager];
        _lastLocationError=[NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        [self updateLabels];
        [self configureGetButton];
    }

}

-(void)configureGetButton{
    if (_updatingLocation) {
        [self.getButton setTitle:@"Stop Searching" forState:UIControlStateNormal];
        
    } else {
        [self.getButton setTitle:@"Get Location" forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLabels];
    
    [self configureGetButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
