//
//  MenuScene.h
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCNode.h"
#import <GameKit/GameKit.h>
#import <AVFoundation/AVFoundation.h>


@interface MenuScene : CCNode <GKLeaderboardViewControllerDelegate>

@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@end
