//
//  NSObject+Nib.h
//  BassBlog
//
//  Created by Evgeny Sivko on 01/12/2012.
//  Copyright (c) 2012 BassBlog. All rights reserved.
//

@interface NSObject (Nib)

+ (id)instanceFromNib:(UINib *)nibOrNil;

+ (NSString *)nibName;

+ (UINib *)nib;

@end
