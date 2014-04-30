//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Egg.h"
#import <Social/Social.h>
#import "AppDelegate.h"



#define ARC4RANDOM_MAX      0x100000000

NSString *const HighestScorePrefKey = @"HighestScore";

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderRing,
    DrawingOrderFox,
    DrawingOrderEgg
};

@implementation MainScene

{
    CCNode *_fox;
    CCPhysicsNode *_physicsNode;
    CCNode *_ring;
    CCNode *_centerNode;
    CCNode *_groundNode;
    CCPhysicsJoint *_eggJoint;
    CCButton *_restartButton;
    CCButton *_shareButton;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highestScoreLabel;
    
    NSInteger _points;
    NSInteger _highestScore;
    BOOL _gameOver;
    CGFloat _omega;
    CGFloat _radius;
    CGFloat _time;
    CGFloat _rotateAngle;
    int _allowToPlaceEgg;
    NSMutableArray *_eggs;
    
    CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject_Jump;
  	SystemSoundID	soundFileObject_Die;
   	SystemSoundID	soundFileObject_New;
   	SystemSoundID	soundFileObject_Score;
   	SystemSoundID	soundFileObject_Disappear;
    SystemSoundID	soundFileObject_Wrong;
    SystemSoundID	soundFileObject_Right;
}

- (void)didLoadFromCCB
{
    // enable touch
    self.userInteractionEnabled = TRUE;
    
    _gameOver = FALSE;
    
    _eggs = [NSMutableArray array];
    _omega = -1.3f;
    _radius = 115.f;
    _time = -3.f;
    _rotateAngle = 0.f;
    
    _ring = DrawingOrderRing;
    _fox.zOrder = DrawingOrderFox;
    
    // set collision delegate. Very important!
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    
    // no real collision, just sensor
    _fox.physicsBody.collisionType = @"fox";
    //_fox.physicsBody.sensor = TRUE;
    
    //_physicsNode.debugDraw = TRUE;
    
    _groundNode.physicsBody.collisionType = @"ground";
    
    // setup sound effect
    
    
    NSURL *jumpSound = [[NSBundle mainBundle] URLForResource:@"Jump" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) jumpSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Jump);
    
    NSURL *dieSound = [[NSBundle mainBundle] URLForResource:@"Punch" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) dieSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Die);
    
    NSURL *scoreSound = [[NSBundle mainBundle] URLForResource:@"Ting" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) scoreSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Score);
    
    NSURL *wrongSound = [[NSBundle mainBundle] URLForResource:@"EggBroken" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) wrongSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Wrong);
    
    NSURL *rightSound = [[NSBundle mainBundle] URLForResource:@"PopRight" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) rightSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Right);
    
    NSURL *newSound = [[NSBundle mainBundle] URLForResource:@"Blip1" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) newSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_New);
    
    // Check highest score
    _highestScore = [[NSUserDefaults standardUserDefaults] integerForKey:HighestScorePrefKey];
    
    if (_highestScore > 0) {
        _highestScoreLabel.string = [NSString stringWithFormat:@"%d", _highestScore];
    } else {
        _highestScoreLabel.string = [NSString stringWithFormat:@"%d", 0];
    }
    
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app hideIAdBanner];
}

- (void)update:(CCTime)delta
{
    if (!_gameOver) {
        
        _time += delta;
        _fox.position = CGPointMake(_radius * cos(_omega * _time), _radius * sin(_omega * _time));
        _rotateAngle = 105.f - atan2(_fox.position.y, _fox.position.x) * 180.f/M_PI;
        _fox.rotation = _rotateAngle;
        
        if ([_eggs count] == 0) {
            [self placeRandomEgg];
        } else {
            // Ask if we can place new egg
            _allowToPlaceEgg = arc4random() % 100;
            if (_allowToPlaceEgg == 0) {
                [self placeRandomEgg];
                NSLog(@"Place egg");
            }
        }
    }
}

- (void)placeRandomEgg
{
    Egg *egg = (Egg *) [CCBReader load:@"Egg"];
    egg.zOrder = DrawingOrderEgg;
    
    
    
    // random 0 - 1 float
    double val = ((double)arc4random() / ARC4RANDOM_MAX);
    // displacement min at PI/4 max at PI*3/4
    float displacement = val* (M_PI*3/4);
    if (displacement < M_PI/4) {
        displacement += M_PI/4;
    }
    
    // Position of new egg
    CGPoint eggPosition = CGPointMake((_radius - 10) * cos(_omega * _time + displacement),
                                      (_radius - 10) * sin(_omega * _time + displacement));
    
    // Place the egg!
    egg.position = eggPosition;
    _rotateAngle = 90.f - atan2(egg.position.y, egg.position.x) * 180.f/M_PI;
    egg.rotation = _rotateAngle;
    egg.scale = 0.7f;
    
    
    //AudioServicesPlaySystemSound(soundFileObject_New);
    
    [_physicsNode addChild:egg];
    
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"NewEgg"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = egg.position;
    // add the particle effect to the same node the egg is on
    [egg.parent addChild:explosion];
    
    [_eggs addObject:egg];
    
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (!_gameOver) {
        
        
        NSLog(@"In touch");
        NSMutableArray *passEggs = nil;
        
        float minDistance = 100000.f;
        Egg *nextJumpEgg = nil;
        for (Egg *egg in _eggs) {
            float tmpDistance = ccpDistance(_fox.position, egg.position);
            if (tmpDistance < minDistance && !egg.isTouch) {
                minDistance = tmpDistance;
                nextJumpEgg = egg;
            } else if (egg.isTouch) {
                if (!passEggs) {
                    passEggs = [NSMutableArray array];
                }
                [passEggs addObject:egg];
            }
        }
        
        // Jump!
        if (nextJumpEgg) {
            
            AudioServicesPlaySystemSound(soundFileObject_Jump);
            
            CGPoint unitVector = ccpNormalize(ccp(nextJumpEgg.position.x, nextJumpEgg.position.y));
            
            
            CCActionMoveBy *moveBy1 = [CCActionMoveBy actionWithDuration:0.6f position:ccpMult(unitVector, 60)];
            CCActionMoveBy *moveBy2 = [CCActionMoveBy actionWithDuration:0.6f position:ccpMult(unitVector, -100)];
            CCActionSequence *moveSequence = [CCActionSequence actionWithArray:@[moveBy1, moveBy2]];
            [nextJumpEgg runAction:moveSequence];
            
        }
        
        
        nextJumpEgg.isTouch = TRUE;
    }
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair goal:(CCNode *)goal fox:(CCNode *)fox
{
    NSLog(@"Goal!!");
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
    // Goal is get
    
    Goal *castGoal = (Goal *) goal;
    castGoal.isGetGoal = TRUE;
    
    AudioServicesPlaySystemSound(soundFileObject_Score);
    
    return TRUE;
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair egg:(CCNode *)egg ground:(CCNode *)ground
{
    NSLog(@"Bing!!");
    
    // If this is not a valid egg to be remove, give minus point
    Egg *castEgg = (Egg *) egg;
    if (!castEgg._goal.isGetGoal) {
        _points--;
        _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
        AudioServicesPlaySystemSound(soundFileObject_Wrong);
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"EggRotten"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        explosion.position = egg.position;
        // add the particle effect to the same node the egg is on
        [egg.parent addChild:explosion];
    } else {
        AudioServicesPlaySystemSound(soundFileObject_Right);
        // load particle effect
        CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"EggExplosion"];
        // make the particle effect clean itself up, once it is completed
        explosion.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        explosion.position = egg.position;
        // add the particle effect to the same node the egg is on
        [egg.parent addChild:explosion];
    }
    
    
    
    
    [_eggs removeObject:egg];
    [egg removeFromParent];
}

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair egg:(CCNode *)egg fox:(CCNode *)fox
{
    if (!_gameOver) {
        NSLog(@"Bang in collision!!");
        AudioServicesPlaySystemSound(soundFileObject_Die);
        [self gameOver];
        NSLog(@"Return from game over!!");
    }
}

- (void)gameOver
{
    if (!_gameOver) {
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _shareButton.visible = TRUE;
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-4, 4)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
        
        for (Egg *egg in _eggs) {
            CGPoint unitVector = ccpNormalize(ccp(egg.position.x, egg.position.y));
            [egg.physicsBody applyImpulse:ccpMult(unitVector, 40)];
            
            unitVector = ccpNormalize(ccp(_fox.position.x, _fox.position.y));
            [_fox.physicsBody applyImpulse:ccpMult(unitVector, 160)];
        }
        
        if (_points > _highestScore) {
            [[NSUserDefaults standardUserDefaults] setInteger:_points forKey:HighestScorePrefKey];
            // load particle effect
            CCParticleSystem *explosion = (CCParticleSystem *) [CCBReader load:@"HighScoreExplosion"];
            // make the particle effect clean itself up, once it is completed
            explosion.autoRemoveOnFinish = TRUE;
            // place the particle effect on the seals position
            explosion.position = _highestScoreLabel.position;
            // add the particle effect to the same node the egg is on
            [_highestScoreLabel.parent addChild:explosion];
        }
        
        AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
        
        [app ShowIAdBanner];
    }
}

- (void)restart
{
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app hideIAdBanner];
    
    CCScene *scene = [CCBReader loadAsScene:@"MenuScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)share
{
    NSString *text = [NSString stringWithFormat:@"This game will help you fall asleep ^.^ I have just scored %d points. Give it a try ;)", _points];
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/AlanSparrow9"];
    NSArray *objectsToShare = @[text, url];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc]
                                            initWithActivityItems:objectsToShare
                                            applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    
    
    [[CCDirector sharedDirector] presentViewController:controller animated:YES completion:nil];
}


@end
