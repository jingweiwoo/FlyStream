//
//  FLYVideoRGBFrame.h
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYVideoFrame.h"

@interface FLYVideoRGBFrame : FLYVideoFrame

@property (nonatomic) NSUInteger linesize;
@property (nonatomic) BOOL hasAlpha;

@end
