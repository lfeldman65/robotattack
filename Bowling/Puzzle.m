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

@end


@implementation Puzzle


-(id) init
{
    if (self == [super init])
    {
        self.puzzleDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
        
        self.puzzleDictionary[@"TilesToComplete"] = [NSNumber numberWithInt:0];
        
        
        NSMutableArray * rows = [NSMutableArray arrayWithCapacity:10];
        
        for (int i=0; i < 8;  i++)
        {
            [rows addObject:[NSMutableArray arrayWithCapacity:10]];
        }
    
        self.puzzleDictionary[@"Board"] = rows;
        self.puzzleArray = rows;
        
    }
    
    return self;
}


-(id) initWithFilePath : (NSString* ) path
{
    if (self == [self init])
    {
        if (path.length > 0)
        {
            self.puzzleDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
            
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
        
    }
    
    return self;
}


-(BOOL) saveToFile: (NSString*) path
{
    self.puzzleDictionary[@"TilesToComplete"] = [NSNumber numberWithInt:self.numberOfTiles];
    
    return  [self.puzzleDictionary writeToFile:path atomically:YES];
    
    
}

@end
