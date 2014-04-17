//
//  PTTHighlightableTableViewCell.h
//  BassBlog
//
//  Created by Evgeny Sivko on 09/06/13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "NSObject+Nib.h"


@interface BBHighlightableTableViewCell : UITableViewCell
{
    UIColor *highlightedBackgroundColor;
    UIColor *selectedBackgroundColor;
    UIColor *backgroundColor;
}

@end
