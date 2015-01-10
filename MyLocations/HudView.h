//
//  HudView.h
//  MyLocations
//
//  Created by Youwen Yi on 1/6/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HudView : UIView

+(instancetype)hudInView:(UIView*)view animated:(BOOL)animated;

@property(nonatomic,strong) NSString *text;

@end
