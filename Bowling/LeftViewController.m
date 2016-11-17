//
//  LeftViewController.m
//  Bowling
//
//  Created by Maurice on 11/17/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "LeftViewController.h"

@interface LeftViewController ()

@property (nonatomic) float charVelocityX;
@property (nonatomic) float charVelocityY;
@property (nonatomic) CGPoint currentTouchPosition;
@property (nonatomic) CGPoint leftActionCenter;
@property (nonatomic) BOOL leftTouchActive;


@end


@implementation LeftViewController

BOOL isInLeft;
double xDistance;
double yDistance;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leftActionCenter = CGPointMake(65.0, 65.0);
    isInLeft = false;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistance = self.currentTouchPosition.x - self.leftActionCenter.x;
    yDistance = self.currentTouchPosition.y - self.leftActionCenter.y;
    isInLeft = true;
    NSLog(@"Touch Began Position =(%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistance = self.currentTouchPosition.x - self.leftActionCenter.x;
    yDistance = self.currentTouchPosition.y - self.leftActionCenter.y;
    self.charVelocityX = 0;
    self.charVelocityY = 0;
    NSLog(@"Touch Moved Position =(%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   isInLeft = false;
   self.charVelocityX = 0;
   self.charVelocityY = 0;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
