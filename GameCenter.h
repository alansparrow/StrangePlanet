//
//  GameCenter.h
//  Incredible Eggs
//
//  Created by Alan Sparrow on 5/3/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GameCenter
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end

@interface GameCenter : NSObject
{
    
    NSMutableDictionary* earnedAchievementCache;
    
    //id <GameCenterFilesDelegate, NSObject> __unsafe_unretained delegate;
    
    
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
    
    UIViewController *presentingViewController;
    GKMatch *match;
    BOOL matchStarted;
}

@property (retain) NSMutableDictionary* earnedAchievementCache;

@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (assign) id <GameCenter> delegate;

+ (GameCenter *)sharedInstance;
- (void)authenticateLocalUser;
- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController delegate:(id<GameCenter>)theDelegate;
- (void) reportScore: (int64_t) score forCategory: (NSString*) category;
- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete;

- (void) resetAchievements;


@end
