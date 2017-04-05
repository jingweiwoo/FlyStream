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
    ErrorCodeCannotSetAudioCategory = -9,
    ErrorCodeCannotSetAudioActive = -10,
    ErrorCodeCannotInitAudioUnit = -11,
    ErrorCodeCannotCreateAudioComponent = -12,
    ErrorCodeCannotGetAudioStreamDescription = -13,
    ErrorCodeCannotSetAudioRenderCallback = -14,
    ErrorCodeCannotUninitAudioUnit = -15,
    ErrorCodeCannotDisposeAudioUnit = -16,
    ErrorCodeCannotDeactivateAudio = -17,
    ErrorCodeCannotStartAudioUnit = -18,
    ErrorCodeCannotStopAudioUnit = -19,
};


#endif /* FLYCommon_h */


@interface FLYCommon : NSObject

@end
