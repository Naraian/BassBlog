//
//  BBTimeProfiler.m
//  BassBlog
//
//  Created by Evgeny Sivko on 02.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//

#import "BBTimeProfiler.h"


#ifdef DEBUG

@interface BBTimeProfiler ()
{
   NSTimeInterval _timeMark;
}

@end

@implementation BBTimeProfiler

- (void)markTime {
    
    _timeMark = CACurrentMediaTime();
}

- (void)logElapsedTimeFor:(NSString *)format, ... {
    
    if (_timeMark == 0. || format.length == 0) {
        return;
    }
    
    va_list arguments;
    va_start(arguments, format);
    
    NSString *description = [[NSString alloc] initWithFormat:format arguments:arguments];
    
    NSTimeInterval prevTimeMark = _timeMark;
    
    [self markTime];
    
    BB_DBG(@"%@ = %f sec", description, _timeMark - prevTimeMark);
}

@end

#endif