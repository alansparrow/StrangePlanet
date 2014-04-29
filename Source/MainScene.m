//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Egg.h"



#define ARC4RANDOM_MAX      0x100000000

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
    CCLabelTTF *_scoreLabel;
    
    NSInteger _points;
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
    _omega = -1.1f;
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
    
    NSURL *wrongSound = [[NSBundle mainBundle] URLForResource:@"UhOh" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) wrongSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Wrong);
    
    NSURL *rightSound = [[NSBundle mainBundle] URLForResource:@"PopRight" withExtension:@"caf"];
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) rightSound;
    // Create a system sound object representing the sound file
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject_Right);
    
}

- (void)update:(CCTime)delta
{
    if (!_gameOver) {
        
        _time += delta;
        _fox.position = CGPointMake(_radius * cos(_omega * _time), _radius * sin(_omega * _time));
        _rotateAngle = 105.f - atan2(_fox.position.y, _fox.position.x) * 180.f/M_PI;
        _fox.rotation = _rotateAngle;
        
        // Ask if we can place new egg
        _allowToPlaceEgg = arc4random() % 100;
        if (_allowToPlaceEgg == 0) {
            [self placeRandomEgg];
            NSLog(@"Place egg");
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
    
    NSLog(@"x: %f, y: %f", egg.position.x, egg.position.y);
    
    [_physicsNode addChild:egg];
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
            

            CCActionMoveBy *moveBy1 = [CCActionMoveBy actionWithDuration:0.6f position:ccpMult(unitVector, 70)];
            CCActionMoveBy *moveBy2 = [CCActionMoveBy actionWithDuration:0.8f position:ccpMult(unitVector, -100)];
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
    } else {
        AudioServicesPlaySystemSound(soundFileObject_Right);
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
        //[self restart];
        NSLog(@"Game over1");
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        NSLog(@"Game over2");
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-4, 4)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
        NSLog(@"Game over3");
        
        for (Egg *egg in _eggs) {
            CGPoint unitVector = ccpNormalize(ccp(egg.position.x, egg.position.y));
            [egg.physicsBody applyImpulse:ccpMult(unitVector, 40)];
            
            unitVector = ccpNormalize(ccp(_fox.position.x, _fox.position.y));
            [_fox.physicsBody applyImpulse:ccpMult(unitVector, 160)];
        }
        
        NSLog(@"Game over4");
    }
}

- (void)restart
{
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}


@end
