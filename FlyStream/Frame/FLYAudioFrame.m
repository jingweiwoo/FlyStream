//
//  FLYAudioFrame.m
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYAudioFrame.h"

@implementation FLYAudioFrame

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = kFLYFrameTypeAudio;
    }
    return self;
}

@end
