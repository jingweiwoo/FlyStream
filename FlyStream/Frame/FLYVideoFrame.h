//
//  FLYVedioFrame.h
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYFrame.h"
#import <OpenGLES/ES2/gl.h>

typedef NS_ENUM(NSInteger, FLYVideoFrameType) {
    kFLYVideoFrameTypeNone,
    kFLYVideoFrameTypeRGB,
    kFLYVideoFrameTypeYUV,
};

@interface FLYVideoFrame : FLYFrame

@property (nonatomic) FLYVideoFrameType videoType;
@property (nonatomic) int width;
@property (nonatomic) int height;

- (BOOL)prepareRender:(GLuint)program;

@end

