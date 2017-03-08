//
//  FLYVideoYUVFrame.h
//  FlyStream
//
//  Created by Jingwei Wu on 02/03/2017.
//  Copyright © 2017 jingweiwu. All rights reserved.
//

#import "FLYVideoFrame.h"

@interface FLYVideoYUVFrame : FLYVideoFrame

@property (nonatomic) NSData *Y;    // Luma
@property (nonatomic) NSData *Cb;   // Chroma Blue
@property (nonatomic) NSData *Cr;   // Chroma Red

@end
