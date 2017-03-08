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
FOUNDATION_EXPORT NSString *const StreamBufferStateChangedNotification;


#pragma mark - Notification Key
FOUNDATION_EXPORT NSString *const StreamBufferStateNotificationKey;
FOUNDATION_EXPORT NSString *const StreamSeekStateNotificationKey;

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

@property (nonatomic, readonly) NSDictionary *metadata;

- (void)openURL:(NSString *)url;
- (void)close;
- (void)play;
- (void)pause;

@end
