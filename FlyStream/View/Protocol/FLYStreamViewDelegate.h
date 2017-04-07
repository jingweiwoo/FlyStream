//
//  FLYStreamViewDelegate.h
//  FlyStream
//
//  Created by Jingwei Wu on 07/04/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FLYStreamViewDelegate <NSObject>

@required
- (void) streamView:(UIView *)view receivedLastFrameInImage:(UIImage *)image;

@optional
// none

@end
