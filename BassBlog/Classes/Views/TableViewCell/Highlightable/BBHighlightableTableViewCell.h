//
//  PTTHighlightableTableViewCell.h
//  BassBlog
//
//  Created by Evgeny Sivko on 09/06/13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "NSObject+Nib.h"


@interface BBHighlightableTableViewCell : UITableViewCell

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *highlightedBackgroundColor;

@end
