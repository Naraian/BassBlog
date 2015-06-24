//
//  BBMixesTableSectionHeaderView.h
//  BassBlog
//
//  Created by Evgeny Sivko on 16.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "NSObject+Nib.h"


@interface BBMixesTableSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) IBOutlet UILabel *label;

+ (CGFloat)height;

@end
