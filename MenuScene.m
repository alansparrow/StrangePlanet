//
//  MenuScene.m
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MenuScene.h"

@implementation MenuScene

- (void)didLoadFromCCB
{
    CCButton *_playButton;
}

- (void)play
{
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

@end
