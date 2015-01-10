//
//  LocationCell.m
//  MyLocations
//
//  Created by Youwen Yi on 1/7/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import "LocationCell.h"

@implementation LocationCell

@synthesize descriptionLabel, addressLabel, imageView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
