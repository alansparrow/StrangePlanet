//
//  SharedInfo.h
//  Incredible Eggs
//
//  Created by Alan Sparrow on 5/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedInfo : NSObject
{
    bool isMusicPlayed;
}

@property (nonatomic) bool isMusicPlayed;

+ (SharedInfo *)sharedInfo;

@end
