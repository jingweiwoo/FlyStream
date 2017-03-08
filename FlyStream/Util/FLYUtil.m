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
    *error = [NSError errorWithDomain:domain
                                 code:code
                             userInfo:@{NSLocalizedDescriptionKey : message}];
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
