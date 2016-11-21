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


@end


@implementation LeftViewController

BOOL isInLeft;
double xDistance;
double yDistance;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.leftActionCenter = CGPointMake(75.0, 75.0);
    isInLeft = false;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    self.currentTouchPosition = [aTouch locationInView:self.view];
    xDistance = self.currentTouchPosition.x - self.leftActionCenter.x;
    yDistance = self.currentTouchPosition.y - self.leftActionCenter.y;
    isInLeft = true;
   // NSLog(@"Touch Began Position =(%f, %f)", self.currentTouchPosition.x, self.currentTouchPosition.y);

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
