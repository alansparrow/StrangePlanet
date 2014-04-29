//
//  Goal.m
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal
@synthesize isGetGoal;

- (void)didLoadFromCCB
{
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
}

@end
