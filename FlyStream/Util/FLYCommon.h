//
//  FLYCommon.h
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//


#ifndef FLYCOMMON_H
#define FLYCOMMON_H

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const FLYLocalizedStringTable;

FOUNDATION_EXPORT NSString *const FLYErrorDomainDecoder;
FOUNDATION_EXPORT NSString *const FLYErrorDomainAudioManager;

/**
 * @brief Pre-defined buffer duration
 */
#define BufferDurationMin 2
#define BufferDurationMax 5

/**
 * @brief Error codes
 */
typedef NS_ENUM (NSInteger, FLYErrorCode) {
    ErrorCodeInvalidURL = -1,
    ErrorCodeCannotOpenInput = -2,
    ErrorCodeCannotFindStreamInfo = -3,
    ErrorCodeNoVideoOrAudioStream = -4,
    ErrorCodeNoAudioOutput = -5,
    ErrorCodeNoAudioChannel = -6,
    ErrorCodeNoAudioSampleRate = -7,
    ErrorCodeNoAudioVolume = -8,
};



#endif /* FLYCommon_h */


@interface FLYCommon : NSObject

@end
