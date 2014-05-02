//
//  MenuScene.m
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MenuScene.h"
#import "AppDelegate.h"
#import "GCHelper.h"
#import "AppInfo.h"

@implementation MenuScene

- (void)didLoadFromCCB
{
    [[GCHelper sharedInstance] authenticateLocalUser];
    [[GCHelper sharedInstance] setIdentifier:GC_INDENTIFIER];
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app ShowIAdBanner];
}

- (void)play
{
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)share_menu
{
    NSString *text = [NSString stringWithFormat:@"Save these incredible eggs from the fox prince!! No harm in trying ;)"];
    NSURL *url = [NSURL URLWithString:@"http://goo.gl/wJXxT8"];
    NSArray *objectsToShare = @[text, url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]
                                            initWithActivityItems:objectsToShare
                                            applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    
    
    [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:nil];
    
}

- (void)rate
{
    
}

- (void)gameCenter
{
    [self showGameCenterButtonPressed];
}

- (void)showGameCenterButtonPressed {
    
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    if (leaderboardViewController != NULL)
    {
        leaderboardViewController.category = GC_INDENTIFIER;
        leaderboardViewController.timeScope = GKLeaderboardTimeScopeWeek;
        leaderboardViewController.leaderboardDelegate = self;
        [[CCDirector sharedDirector] presentViewController: leaderboardViewController animated: YES completion:nil];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
}




@end
