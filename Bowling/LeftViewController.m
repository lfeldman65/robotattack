//
//  LeftViewController.m
//  Bowling
//
//  Created by Maurice on 11/17/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController ()

@property (nonatomic) CGPoint currentTouchPosition;
@property (nonatomic) CGPoint leftActionCenter;
@property (nonatomic) BOOL leftTouchActive;
@property (retain, nonatomic) AVAudioPlayer *ambientPlayer;


@end


@implementation LeftViewController

BOOL isInLeft;
double xDistance;
double yDistance;
BOOL soundIsOn2;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leftActionCenter = CGPointMake(75.0, 75.0);
    isInLeft = false;
    
    // Flight sound
    
    NSNumber* soundOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundOn"];
    soundIsOn2 = [soundOn boolValue];

    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/rocketFlight.mp3"];
    NSLog(@"Path to play: %@", resourcePath);
    NSError* err;
    
    self.ambientPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:resourcePath] error:&err];
    
    if(err)
    {
        NSLog(@"Failed with reason: %@", [err localizedDescription]);
    }
    else
    {
        self.ambientPlayer.delegate = self;
        self.ambientPlayer.numberOfLoops = -1;
        self.ambientPlayer.currentTime = 0;
        self.ambientPlayer.volume = 1.0;
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistance = self.currentTouchPosition.x - self.leftActionCenter.x;
    yDistance = self.currentTouchPosition.y - self.leftActionCenter.y;
    isInLeft = true;
    if(soundIsOn2)
    {
        [self.ambientPlayer play];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistance = self.currentTouchPosition.x - self.leftActionCenter.x;
    yDistance = self.currentTouchPosition.y - self.leftActionCenter.y;
    isInLeft = true;
   // NSLog(@"Touch Moved Position =(%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isInLeft = false;
    if(soundIsOn2)
    {
        [self.ambientPlayer pause];
    }
}

+(BOOL)isInLeft
{
    return isInLeft;
}

+(double)findDistanceX
{
    return xDistance;
}

+(double)findDistanceY
{
    return yDistance;
}

+(double)findRotationAngle
{
    double angle = atan2(yDistance, xDistance);
 //   NSLog(@"xDistance = %f", xDistance);
 //   NSLog(@"yDistance = %f", yDistance);
 //   NSLog(@"angle = %f", angle*180/M_PI);
    return angle + M_PI/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
