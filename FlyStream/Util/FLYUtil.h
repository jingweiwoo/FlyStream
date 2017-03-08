//
//  FLYUtil.h
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLYUtil : NSObject

+ (void)createError:(NSError **)error withDomain:(NSString *)domain andCode:(NSInteger)code andMessage:(NSString *)message;

+ (NSString *)localizedString:(NSString *)name;

+ (NSString *)durationStringFromSeconds:(int)seconds;

@end
