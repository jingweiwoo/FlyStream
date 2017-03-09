//
//  FLYStreamManager.m
//  FlyStream
//
//  Created by Jingwei Wu on 05/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYStreamManager.h"
#import "FLYStreamView.h"
#import "FLYDecoder.h"
#import "FLYCommon.h"
#import "FLYAudioManager.h"
#import "FLYFrame.h"
#import "FLYVideoFrame.h"
#import "FLYAudioFrame.h"

NSString *const StreamOpenedNotification = @"StreamOpenedNotification";
NSString *const StreamClosedNotification = @"StreamClosedNotification";
NSString *const StreamEOFNotification = @"StreamEOFNotification";
NSString *const StreamOpenURLFailedNotification = @"StreamOpenURLFailedNotification";
NSString *const StreamBufferStateChangedNotification = @"StreamBufferStateChangedNotification";

NSString *const StreamBufferStateNotificationKey = @"StreamBufferStateNotificationKey";
NSString *const StreamSeekStateNotificationKey = @"StreamSeekStateNotificationKey";

#pragma mark - Class implementation  - FLYStreamManager

@interface FLYStreamManager ()

@property (nonatomic) FLYDecoder *decoder;
@property (nonatomic) FLYAudioManager *audioManager;

@property (nonatomic) double minBufferDuration;
@property (nonatomic) double maxBufferDuration;
@property (nonatomic) double duration;

@property (nonatomic) NSMutableArray *vframes;
@property (nonatomic) NSMutableArray *aframes;
@property (nonatomic) FLYAudioFrame *playingAudioFrame;
@property (nonatomic) NSUInteger playingAudioFrameDataPosition;
@property (nonatomic) double bufferedDuration;
@property (nonatomic) double mediaPosition;
@property (nonatomic) double mediaSyncTime;
@property (nonatomic) double mediaSyncPosition;

@property (nonatomic) dispatch_queue_t frameReaderQueue;
@property (nonatomic) BOOL notifiedBufferStart;
@property (nonatomic) BOOL requestSeek;

@end

@implementation FLYStreamManager

- (id)init {
    self = [super init];
    if (self) {
        [self initAll];
    }
    return self;
}

- (void)initAll {
    [self initVariables];
    [self initAudio];
    [self initDecoder];
    [self initView];
}

- (void)initVariables {
    _minBufferDuration = BufferDurationMin;
    _maxBufferDuration = BufferDurationMax;
    _bufferedDuration = 0;
    _mediaPosition = 0;
    _mediaSyncTime = 0;
    _vframes = [NSMutableArray arrayWithCapacity:128];
    _aframes = [NSMutableArray arrayWithCapacity:128];
    _playingAudioFrame = nil;
    _playingAudioFrameDataPosition = 0;
    _opening = NO;
    _buffering = NO;
    _playing = NO;
    _opened = NO;
    _requestSeek = NO;
    _frameReaderQueue = dispatch_queue_create("FrameReader", DISPATCH_QUEUE_SERIAL);
}

- (void)initView {
    FLYStreamView *streamView = [[FLYStreamView alloc] init];
    _streamView = streamView;
}

- (void)initDecoder {
    _decoder = [[FLYDecoder alloc] init];
    _decoder.audioChannels = [_audioManager channels];
    _decoder.audioSampleRate = [_audioManager sampleRate];
}

- (void)initAudio {
    _audioManager = [[FLYAudioManager alloc] init];
    NSError *error = nil;
    if (![_audioManager open:&error]) {
        NSLog(@"failed to open audio, error: %@", error);
    }
}

- (void)clearVariables {
    [_vframes removeAllObjects];
    [_aframes removeAllObjects];
    _playingAudioFrame = nil;
    _playingAudioFrameDataPosition = 0;
    _opening = NO;
    _buffering = NO;
    _playing = NO;
    _opened = NO;
    _bufferedDuration = 0;
    _mediaPosition = 0;
    _mediaSyncTime = 0;
    [_streamView clear];
}

- (void)openURL:(NSString *)url {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        _opening = YES;
        if (![_decoder openURL:url error:&error]) {
            NSLog(@"\nOpen: %@, \nError: %@", url, error);
            _opening = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:StreamOpenURLFailedNotification object:error];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _streamView.isYUV = _decoder.isYUV;
            _streamView.keepLastFrame = _decoder.hasPicture && !_decoder.hasVideo;
            _streamView.contentSize = CGSizeMake(_decoder.videoWidth, _decoder.videoHeight);
            _streamView.contentMode = UIViewContentModeScaleAspectFit;
            
            _duration = _decoder.duration;
            _metadata = _decoder.metadata;
            _opening = NO;
            _buffering = NO;
            _playing = NO;
            _bufferedDuration = 0;
            _mediaPosition = 0;
            _mediaSyncTime = 0;
            
            __weak FLYStreamManager *weakSelf = self;
            _audioManager.frameReaderBlock = ^(float *data, UInt32 frames, UInt32 channels) {
                [weakSelf readAudioFrame:data frames:frames channels:channels];
            };
            
            _opened = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:StreamOpenedNotification object:nil];
        });
    });
}

- (void)close {
    [self pause];
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (_opening || _buffering) return;
        [_decoder close];
        [_audioManager close];
        [self clearVariables];
        [[NSNotificationCenter defaultCenter] postNotificationName:StreamClosedNotification object:nil];
        dispatch_cancel(timer);
    });
    dispatch_resume(timer);
}

- (void)play {
    if (!_opened || _playing) return;
    
    _playing = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self render];
    });
    [_audioManager play];
}

- (void)pause {
    _playing = NO;
    [_audioManager pause];
}

- (void)readFrame {
    dispatch_async(_frameReaderQueue, ^{
        while (_playing && !_decoder.isEOF && !_requestSeek
               && _bufferedDuration < _maxBufferDuration) {
            @autoreleasepool {
                if (!_buffering) _buffering = YES;
                NSArray *fs = [_decoder readFrames];
                if (fs == nil) { break; }
                @synchronized (_vframes) {
                    for (FLYFrame *f in fs) {
                        if (f.type == kFLYFrameTypeVideo) {
                            [_vframes addObject:f];
                            _bufferedDuration += f.duration;
                        }
                    }
                }
                @synchronized (_aframes) {
                    for (FLYFrame *f in fs) {
                        if (f.type == kFLYFrameTypeAudio) {
                            [_aframes addObject:f];
                            if (!_decoder.hasVideo) {
                                _bufferedDuration += f.duration;
                            }
                        }
                    }
                }
            }
        }
        _buffering = NO;
    });
}

- (void)render {
    if (!_playing) return;
    BOOL eof = _decoder.isEOF;
    BOOL noframes = ((_decoder.hasVideo && _vframes.count <= 0) ||
                     (_decoder.hasAudio && _aframes.count <= 0));
    
    // Check if reach the end and play all frames.
    if (noframes && eof) {
        [self pause];
        [[NSNotificationCenter defaultCenter] postNotificationName:StreamEOFNotification object:nil];
        return;
    }
    
    if (!_buffering && !eof && !_requestSeek
        && (noframes || _bufferedDuration < _minBufferDuration)) {
        [self readFrame];
    }
    
    if (noframes && !_notifiedBufferStart) {
        _notifiedBufferStart = YES;
        NSDictionary *userInfo = @{ StreamBufferStateNotificationKey : @(_notifiedBufferStart) };
        [[NSNotificationCenter defaultCenter] postNotificationName:StreamBufferStateChangedNotification
                                                            object:self
                                                          userInfo:userInfo];
        
    } else if (!noframes && _notifiedBufferStart) {
        _notifiedBufferStart = NO;
        NSDictionary *userInfo = @{ StreamBufferStateNotificationKey : @(_notifiedBufferStart) };
        [[NSNotificationCenter defaultCenter] postNotificationName:StreamBufferStateChangedNotification
                                                            object:self
                                                          userInfo:userInfo];
    }
    
    // Render if has picture
    if (_decoder.hasPicture && _vframes.count > 0) {
        FLYVideoFrame *frame = _vframes[0];
        _streamView.contentSize = CGSizeMake(frame.width, frame.height);
        [_vframes removeObjectAtIndex:0];
        [_streamView render:frame];
    }
    
    // Check whether render is neccessary
    if (_vframes.count <= 0 || !_decoder.hasVideo) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self render];
        });
        return;
    }
    
    // Render video
    FLYVideoFrame *frame = nil;
    @synchronized (_vframes) {
        frame = _vframes[0];
        _mediaPosition = frame.position;
        _bufferedDuration -= frame.duration;
        [_vframes removeObjectAtIndex:0];
    }
    [_streamView render:frame];
    
    // Sync audio with video
    double syncTime = [self syncTime];
    NSTimeInterval t = MAX(frame.duration + syncTime, 0.01);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self render];
    });
}

- (double)syncTime {
    const double now = [NSDate timeIntervalSinceReferenceDate];
    
    if (_mediaSyncTime == 0) {
        _mediaSyncTime = now;
        _mediaSyncPosition = _mediaPosition;
        return 0;
    }
    
    double dp = _mediaPosition - _mediaSyncPosition;
    double dt = now - _mediaSyncTime;
    double sync = dp - dt;
    
    if (sync > 1 || sync < -1) {
        sync = 0;
        _mediaSyncTime = 0;
    }
    
    return sync;
}

/*
 * For audioUnitRenderCallback, (DLGPlayerAudioManagerFrameReaderBlock)readFrameBlock
 */
- (void)readAudioFrame:(float *)data frames:(UInt32)frames channels:(UInt32)channels {
    if (!_playing) return;
    while(frames > 0) {
        @autoreleasepool {
            if (_playingAudioFrame == nil) {
                @synchronized (_aframes) {
                    if (_aframes.count <= 0) {
                        memset(data, 0, frames * channels * sizeof(float));
                        return;
                    }
                    
                    FLYAudioFrame *frame = _aframes[0];
                    if (_decoder.hasVideo) {
                        const double dt = _mediaPosition - frame.position;
                        if (dt < -0.1) { // audio is faster than video, silence
                            memset(data, 0, frames * channels * sizeof(float));
                            break;
                        } else if (dt > 0.1) { // audio is slower than video, skip
                            [_aframes removeObjectAtIndex:0];
                            continue;
                        } else {
                            _playingAudioFrameDataPosition = 0;
                            _playingAudioFrame = frame;
                            [_aframes removeObjectAtIndex:0];
                        }
                    } else {
                        _playingAudioFrameDataPosition = 0;
                        _playingAudioFrame = frame;
                        [_aframes removeObjectAtIndex:0];
                        _mediaPosition = frame.position;
                        _bufferedDuration -= frame.duration;
                    }
                }
            }
            
            NSData *frameData = _playingAudioFrame.data;
            NSUInteger pos = _playingAudioFrameDataPosition;
            if (frameData == nil) {
                memset(data, 0, frames * channels * sizeof(float));
                return;
            }
            
            const void *bytes = (Byte *)frameData.bytes + pos;
            const NSUInteger remainingBytes = frameData.length - pos;
            const NSUInteger channelSize = channels * sizeof(float);
            const NSUInteger bytesToCopy = MIN(frames * channelSize, remainingBytes);
            const NSUInteger framesToCopy = bytesToCopy / channelSize;
            
            memcpy(data, bytes, bytesToCopy);
            frames -= framesToCopy;
            data += framesToCopy * channels;
            
            if (bytesToCopy < remainingBytes) {
                _playingAudioFrameDataPosition += bytesToCopy;
            } else {
                _playingAudioFrame = nil;
            }
        }
    }
}

- (UIView *)playerView {
    return _streamView;
}

- (void)setPosition:(double)position {
    _requestSeek = YES;
    dispatch_async(_frameReaderQueue, ^{
        [_decoder seek:position];
        @synchronized (_vframes) {
            [_vframes removeAllObjects];
        }
        @synchronized (_aframes) {
            [_aframes removeAllObjects];
        }
        _bufferedDuration = 0;
        _requestSeek = NO;
    });
}

- (double)position {
    return _mediaPosition;
}

@end

