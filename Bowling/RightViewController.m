//
//  RightViewController.m
//  Bowling
//
//  Created by Maurice on 11/17/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "RightViewController.h"

@interface RightViewController ()

@property (nonatomic) CGPoint currentTouchPosition;
@property (nonatomic) CGPoint rightActionCenter;
@property (nonatomic) BOOL rightTouchActive;
@property (retain, nonatomic) AVAudioPlayer *ambientPlayer;


@end

@implementation RightViewController

BOOL isInRight;
double xDistanceR;
double yDistanceR;
BOOL soundIsOn3;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rightActionCenter = CGPointMake(65.0, 65.0);
    isInRight = false;
    
    // Flight sound
    
    NSNumber* soundOn = [[NSUserDefaults standardUserDefaults] objectForKey:@"soundOn"];
    soundIsOn3 = [soundOn boolValue];
    
    NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    resourcePath = [resourcePath stringByAppendingString:@"/shooting.mp3"];
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
    xDistanceR = self.currentTouchPosition.x - self.rightActionCenter.x;
    yDistanceR = self.currentTouchPosition.y - self.rightActionCenter.y;
    isInRight = true;

    if(soundIsOn3)
    {
        [self.ambientPlayer play];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistanceR = self.currentTouchPosition.x - self.rightActionCenter.x;
    yDistanceR = self.currentTouchPosition.y - self.rightActionCenter.y;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isInRight = false;
    if(soundIsOn3)
    {
        [self.ambientPlayer pause];
    }
}

+(BOOL)isInRight
{
    return isInRight;
}

+(double)findDistanceX
{
    return xDistanceR;
}

+(double)findDistanceY
{
    return yDistanceR;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
