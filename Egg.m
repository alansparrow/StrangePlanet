//
//  Egg.m
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Egg.h"

@implementation Egg
@synthesize isTouch, _goal;

- (void)didLoadFromCCB
{
    // no real collision, just sensor
    self.physicsBody.collisionType = @"egg";
    self.isTouch = FALSE;
    self._goal.isGetGoal = FALSE;
    
    NSLog(@"Egg!");
}

@end
