//
//  CollectionViewCell.m
//  Bowling
//
//  Created by Maurice on 10/24/16.
//  Copyright © 2016 Larry Feldman. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

-(void)awakeFromNib
{
    // background color
    
    [super awakeFromNib];
  //  UIView *bgView = [[UIView alloc]initWithFrame:self.bounds];
 //   self.backgroundView = bgView;
  //  self.backgroundView.backgroundColor = [UIColor greenColor];
    
    // selected background
    
    UIView *selectedView = [[UIView alloc]initWithFrame:self.bounds];
 //   self.selectedBackgroundView = selectedView;
 //   self.selectedBackgroundView.backgroundColor = [UIColor yellowColor];

    
}

@end
