//
//  LocationCell.h
//  MyLocations
//
//  Created by Youwen Yi on 1/7/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationCell : UITableViewCell

@property (nonatomic, strong)IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong)IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end