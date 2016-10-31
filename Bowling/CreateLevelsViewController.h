//
//  CreateLevelsViewController.h
//  Bowling
//
//  Created by Kennedy Kok on 10/28/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Puzzle.h"

@interface CreateLevelsViewController : UIViewController
@property (strong, nonatomic) Puzzle* currentPuzzle;
@property (assign, nonatomic) int currentLevel;
@end
