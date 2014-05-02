//
//  SharedInfo.m
//  Incredible Eggs
//
//  Created by Alan Sparrow on 5/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SharedInfo.h"

@implementation SharedInfo

+ (SharedInfo *)sharedInfo
{
    static SharedInfo *sharedInfo = nil;
    if (!sharedInfo) {
        sharedInfo = [[super allocWithZone:nil] init];
    }
    
    return sharedInfo;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInfo];
}

@end
