//
//  RightViewController.m
//  Bowling
//
//  Created by Maurice on 11/17/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "RightViewController.h"

@interface RightViewController ()

@property (nonatomic) float charVelocityX;
@property (nonatomic) float charVelocityY;
@property (nonatomic) CGPoint currentTouchPosition;
@property (nonatomic) CGPoint rightActionCenter;
@property (nonatomic) BOOL rightTouchActive;

@end

@implementation RightViewController

BOOL isInRight;
double xDistanceR;
double yDistanceR;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rightActionCenter = CGPointMake(65.0, 65.0);
    isInRight = false;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistanceR = self.currentTouchPosition.x - self.rightActionCenter.x;
    yDistanceR = self.currentTouchPosition.y - self.rightActionCenter.y;
    isInRight = true;
   // NSLog(@"Touch Began Position =(%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistanceR = self.currentTouchPosition.x - self.rightActionCenter.x;
    yDistanceR = self.currentTouchPosition.y - self.rightActionCenter.y;
    self.charVelocityX = 0;
    self.charVelocityY = 0;
  //  NSLog(@"Touch Moved Position =(%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isInRight = false;
    self.charVelocityX = 0;
    self.charVelocityY = 0;
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
