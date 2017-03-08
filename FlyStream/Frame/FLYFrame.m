//
//  FLYFrame.m
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYFrame.h"

@implementation FLYFrame

- (instancetype)init {
    self = [super init];
    if (self) {
        _type = kFLYFrameTypeNone;
        _data = nil;
    }
    return self;
}

@end
