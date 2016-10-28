//
//  Puzzle.m
//  Bowling
//
//  Created by Kennedy Kok on 10/26/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "Puzzle.h"
#import <UIKit/UIKit.h>

@interface Puzzle()
@property (atomic, strong) NSDictionary* puzzleDictionary;
@end


@implementation Puzzle

-(id) initWithFilePath : (NSString* ) path
{
    if (self == [super init])
    {
        self.puzzleDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSNumber* num = self.puzzleDictionary[@"TilesToComplete"];
        self.numberOfTiles = [num intValue];
        
        self.puzzleArray = self.puzzleDictionary[@"Board"];  // array of dictionaries
        
        for (NSArray *tile in self.puzzleArray)
        {
            NSLog(@"tile = %@", tile);
            for (NSDictionary *dict in tile) {
                
                NSLog(@"dict = %@", dict);
                NSNumber* row = dict[@"Row"];
                NSNumber* section = dict[@"Section"];
                
                if ([dict[@"Text"] isEqualToString:@"Start"])
                {
                    self.startIndexPath = [NSIndexPath indexPathForRow:[row intValue] inSection:[section intValue]];
                }
                else if ([dict[@"Text"] isEqualToString:@"End"])
                {
                    self.endIndexPath = [NSIndexPath indexPathForRow:[row intValue] inSection:[section intValue]];
                }
            }
        }
    }
    
    return self;
}

@end
