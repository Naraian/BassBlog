//
//  BBTimeProfiler.h
//  BassBlog
//
//  Created by Evgeny Sivko on 02.06.13.
//  Copyright (c) 2013 BassBlog. All rights reserved.
//


#define TIME_PROFILER_PROPERTY_DECLARATION
#define TIME_PROFILER_PROPERTY_IMPLEMENTATION
#define TIME_PROFILER_MARK_TIME
#define TIME_PROFILER_LOG(format, ...)

#ifdef DEBUG

#undef TIME_PROFILER_PROPERTY_DECLARATION
#define TIME_PROFILER_PROPERTY_DECLARATION \
@property (nonatomic, strong) BBTimeProfiler *timeProfiler;

#undef TIME_PROFILER_PROPERTY_IMPLEMENTATION
#define TIME_PROFILER_PROPERTY_IMPLEMENTATION \
- (BBTimeProfiler *)timeProfiler { \
    if (_timeProfiler == nil) { \
        _timeProfiler = [BBTimeProfiler new]; \
    } \
    return _timeProfiler; \
}

#undef TIME_PROFILER_MARK_TIME
#define TIME_PROFILER_MARK_TIME [self.timeProfiler markTime];

#undef TIME_PROFILER_LOG
#define TIME_PROFILER_LOG(format, ...) \
[self.timeProfiler logElapsedTimeFor:format, ##__VA_ARGS__];

@interface BBTimeProfiler : NSObject
           
- (void)markTime;
           
- (void)logElapsedTimeFor:(NSString *)format, ...;

@end

#endif