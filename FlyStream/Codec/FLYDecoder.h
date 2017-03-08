//
//  FLYDecoder.h
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYDecoder : NSObject

@property (nonatomic) BOOL isYUV;
@property (nonatomic) BOOL hasVideo;
@property (nonatomic) BOOL hasAudio;
@property (nonatomic) BOOL hasPicture;
@property (nonatomic) BOOL isEOF;

@property (nonatomic) double duration;
@property (nonatomic) NSDictionary *metadata;

@property (nonatomic) UInt32 audioChannels;
@property (nonatomic) float audioSampleRate;

@property (nonatomic) double videoFPS;
@property (nonatomic) double videoTimebase;
@property (nonatomic) double audioTimebase;

- (BOOL)openURL:(NSString *)url error:(NSError **)error;
- (void)close;
- (NSArray *)readFrames;
- (void)seek:(double)position;
- (int)videoWidth;
- (int)videoHeight;
- (BOOL)isYUV;

@end
