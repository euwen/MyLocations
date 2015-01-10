//
//  Location.m
//  MyLocations
//
//  Created by Youwen Yi on 1/6/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic latitude;
@dynamic longitude;
@dynamic date;
@dynamic locationDescription;
@dynamic category;
@dynamic placemark;
@dynamic photoId;


-(CLLocationCoordinate2D)coordinate{

    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

-(NSString *)title{
    if([self.locationDescription length] > 0){
        return self.locationDescription;
    }else{
        return @"(No description)";
    }

}

-(NSString *)subtitle{
    return self.category;

}

-(BOOL)hasPhoto{
    return (self.photoId != nil) && ([self.photoId integerValue] != -1);

}

-(NSString *)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
    
}

-(NSString *)photoPath{

    NSString *fileName = [NSString stringWithFormat:@"Photo-%d.png", [self.photoId intValue]];
    return [[self documentsDirectory] stringByAppendingPathComponent:fileName];

}

-(UIImage *)photoImage{

    NSAssert(self.photoId != nil, @"No photo ID set");
    NSAssert([self.photoId intValue] != -1, @"Photo ID is -1");
    
    return [UIImage imageWithContentsOfFile:[self photoPath]];

}

-(void)removePhotoFile{
    NSString *path = [self photoPath];
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:path]) {
        NSError *error;
        
        if (![fileManger removeItemAtPath:path error:&error]) {
            NSLog(@"Error removing file: %@", error);
        }
    }

}

@end

