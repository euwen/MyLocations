//
//  UIImage+Resize.m
//  MyLocations
//
//  Created by Youwen Yi on 1/9/15.
//  Copyright (c) 2015 Youwen Yi. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

-(UIImage *)resizedImageWithBounds:(CGSize)bounds{

    CGFloat horizontalRatio = bounds.width/self.size.width;
    CGFloat verticalRatio = bounds.height/self.size.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    
    CGSize newSize = CGSizeMake(self.size.width *ratio, self.size.height * ratio);
    
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;

}

@end
