//
//  FLYUtil.m
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYUtil.h"
#import "FLYCommon.h"

@implementation FLYUtil

+ (void)createError:(NSError **)error withDomain:(NSString *)domain andCode:(NSInteger)code andMessage:(NSString *)message {
    if (error == nil) return;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (message != nil)
        userInfo[NSLocalizedDescriptionKey] = message;
    
    *error = [NSError errorWithDomain:domain
                                 code:code
                             userInfo:userInfo];
}

+ (void)createError:(NSError **)error
         withDomain:(NSString *)domain
            andCode:(NSInteger)code
         andMessage:(NSString *)message
        andRawError:(NSError *)rawError {
    if (error == nil) return;
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (message != nil)
        userInfo[NSLocalizedDescriptionKey] = message;
    if (rawError != nil)
        userInfo[NSLocalizedFailureReasonErrorKey] = rawError;
    *error = [NSError errorWithDomain:domain
                                 code:code
                             userInfo:userInfo];
}

+ (NSString *)localizedString:(NSString *)name {
    return NSLocalizedStringFromTable(name, FLYLocalizedStringTable, nil);
}

+ (NSString *)durationStringFromSeconds:(int)seconds {
    NSMutableString *ms = [[NSMutableString alloc] init];
    if (seconds < 0) { [ms appendString:@"∞"]; return ms; }
    
    int h = seconds / 3600;
    [ms appendFormat:@"%d:", h];
    int m = seconds / 60 % 60;
    if (m < 10) [ms appendString:@"0"];
    [ms appendFormat:@"%d:", m];
    int s = seconds % 60;
    if (s < 10) [ms appendString:@"0"];
    [ms appendFormat:@"%d", s];
    return ms;
}

@end
