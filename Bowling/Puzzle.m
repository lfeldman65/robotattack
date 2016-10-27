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
        
        self.puzzleArray = self.puzzleDictionary[@"Board"];
        
        
        int rowNumber = 0;
        for (NSArray* row in self.puzzleArray)
        {
            for (NSDictionary* dict in row)
            {
                NSNumber* column = dict[@"Column"];
                
                if ([dict[@"Text"] isEqualToString:@"Start"])
                {
                    self.startIndexPath = [NSIndexPath indexPathForRow:[column intValue] inSection:rowNumber];
                }
                else if ([dict[@"Text"] isEqualToString:@"End"])
                {
                    self.endIndexPath = [NSIndexPath indexPathForRow:[column intValue] inSection:rowNumber];
                }
                
                
            }
            
            rowNumber++;
        }
        
        
        
    }
    
    return self;
}

@end
