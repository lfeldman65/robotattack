//
//  LeftViewController.h
//  Bowling
//
//  Created by Maurice on 11/17/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LeftViewController : UIViewController <AVAudioPlayerDelegate>

+(BOOL)isInLeft;
+(double)findDistanceX;
+(double)findDistanceY;
+(double)findRotationAngle;

@end
