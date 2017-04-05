//
//  FLYAudioManager.h
//  FlyStream
//
//  Created by Jingwei Wu on 05/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FLYAudioManagerFrameReaderBlock)(float *data, UInt32 num, UInt32 channels);

@interface FLYAudioManager : NSObject

@property (nonatomic) FLYAudioManagerFrameReaderBlock frameReaderBlock;
@property (nonatomic) float volume;

- (BOOL)open:(NSError **)error;

- (BOOL)play;
- (BOOL)play:(NSError **)error;
- (BOOL)pause;
- (BOOL)pause:(NSError **)error;
- (BOOL)close;
- (BOOL)close:(NSArray<NSError *> **)errors;

- (double)sampleRate;
- (UInt32)channels;

@end
