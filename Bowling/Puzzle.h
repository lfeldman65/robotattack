//
//  Puzzle.h
//  Bowling
//
//  Created by Kennedy Kok on 10/26/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Puzzle : NSObject

-(id) initWithFilePath : (NSString* ) path;

@property (atomic, assign) int numberOfTiles;
@property (atomic, strong) NSArray * puzzleArray;
@property (atomic, strong) NSIndexPath* startIndexPath;
@property (atomic, strong) NSIndexPath * endIndexPath;
@end
