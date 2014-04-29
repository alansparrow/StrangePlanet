//
//  Egg.h
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/29/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Goal.h"

@interface Egg : CCSprite

@property (nonatomic) BOOL isTouch;

@property (nonatomic) Goal *_goal;

@end
