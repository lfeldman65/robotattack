//
//  RightViewController.h
//  Bowling
//
//  Created by Maurice on 11/17/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RightViewController : UIViewController <AVAudioPlayerDelegate>

+(BOOL)isInRight;
+(double)findDistanceX;
+(double)findDistanceY;

@end
