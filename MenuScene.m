//
//  MenuScene.m
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MenuScene.h"
#import "AppDelegate.h"

@implementation MenuScene

- (void)didLoadFromCCB
{
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app ShowIAdBanner];
}

- (void)play
{
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

@end
