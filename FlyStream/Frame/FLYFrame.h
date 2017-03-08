//
//  FLYFrame.h
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, FLYFrameType) {
    kFLYFrameTypeNone,
    kFLYFrameTypeVideo,
    kFLYFrameTypeAudio
};

@interface FLYFrame : NSObject

@property (nonatomic) FLYFrameType type;
@property (nonatomic) NSData *data;
@property (nonatomic) double position;
@property (nonatomic) double duration;

@end


