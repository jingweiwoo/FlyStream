//
//  FLYView.h
//  FlyStream
//
//  Created by Jingwei Wu on 04/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLYVideoFrame;
@interface FLYStreamView : UIView

@property (nonatomic) CGSize contentSize;
@property (nonatomic) BOOL isYUV;
@property (nonatomic) BOOL keepLastFrame;

@property (nonatomic, readonly) FLYVideoFrame *lastFrame;
@property (nonatomic, readonly) UIImage *lastFrameImage;

- (void)render:(FLYVideoFrame *)frame;
- (void)clear;

@end
