//
//  FLYVedioFrame.m
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYVideoFrame.h"

@implementation FLYVideoFrame

- (id)init {
    self = [super init];
    if (self) {
        self.type = kFLYFrameTypeVideo;
    }
    return self;
}

- (BOOL)prepareRender:(GLuint)program {
    return NO;
}

@end
