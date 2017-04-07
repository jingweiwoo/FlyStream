//
//  FLYStreamManager.h
//  FlyStream
//
//  Created by Jingwei Wu on 05/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//
#import <UIKit/UIKit.h>

#pragma mark - Notification
FOUNDATION_EXPORT NSString *const StreamOpenedNotification;
FOUNDATION_EXPORT NSString *const StreamClosedNotification;
FOUNDATION_EXPORT NSString *const StreamEOFNotification;
FOUNDATION_EXPORT NSString *const StreamOpenURLFailedNotification;
FOUNDATION_EXPORT NSString *const StreamBufferStateChangedNotification;
FOUNDATION_EXPORT NSString *const StreamErrorNotification;


#pragma mark - Notification Key
FOUNDATION_EXPORT NSString *const StreamBufferStateNotificationKey;
FOUNDATION_EXPORT NSString *const StreamSeekStateNotificationKey;
FOUNDATION_EXPORT NSString *const StreamErrorNotificationKey;
FOUNDATION_EXPORT NSString *const StreamRawErrorNotificationKey;

#pragma mark - Class interface  - FLYStreamManager
typedef void (^onPauseComplete)();

@class FLYStreamView;

@interface FLYStreamManager : NSObject

@property (readonly) FLYStreamView *streamView;

@property (nonatomic) double position;

@property (nonatomic, readonly) BOOL opening;
@property (nonatomic, readonly) BOOL opened;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) BOOL buffering;
@property (nonatomic, readonly) BOOL isRealTimeVideo;

@property (nonatomic, readonly) NSDictionary *metadata;

+ (instancetype) sharedInstance;

- (instancetype)init __attribute__((unavailable("init not available, call initWithRealTimeVideo:(BOOL)realTimeVideo instead.")));

- (instancetype)initWithRealTimeVideo:(BOOL)realTimeVideo;

- (void)openURL:(NSString *)url;
- (void)close;
- (void)play;
- (void)pause;

@end
