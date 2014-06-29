//
//  BBSpectrumAnalyzerView.m
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/28/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

#import "BBSpectrumAnalyzerView.h"
#import "BBAudioManager.h"

#import "NSObject+Notification.h"

const CGFloat kDefaultMinDbFS = -110.f;
const CGFloat kDBLogFactor = 4.0f;
const NSUInteger kMaxQueuedDataBlocks = 4;

@interface BBSpectrumAnalyzerView()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) NSMutableArray *spectrumData;
@property (nonatomic, strong) NSMutableArray *spectrumViewsArray;

@end

@implementation BBSpectrumAnalyzerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self commonInit];
    }
    
    return self;
}

- (void)dealloc
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)commonInit
{
    self.clearsContextBeforeDrawing = YES;
    
    self.spectrumData = [NSMutableArray arrayWithCapacity:kMaxQueuedDataBlocks];
    
    [self addSelector:@selector(audioManagerDidChangeSpectrumData:) forNotificationWithName:BBAudioManagerDidChangeSpectrumData];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
    self.displayLink.frameInterval = 2; //30FPS
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)audioManagerDidChangeSpectrumData:(NSNotification *)notification
{
    @synchronized(self)
    {
        if (self.spectrumData.count > kMaxQueuedDataBlocks)
        {
            [self.spectrumData removeObjectAtIndex:0];
        }
        
        NSArray *spectrumData = [BBAudioManager defaultManager].spectrumData;
        if (spectrumData)
        {
            [self.spectrumData addObject:spectrumData];
        }
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
//    static NSTimeInterval timeInterval0 = 0;
//    NSTimeInterval timeInterval1 = [[NSDate date] timeIntervalSince1970];
//    NSLog(@"FPS: %f", 1.f/(timeInterval1 - timeInterval0));
//    timeInterval0 = timeInterval1;

    NSArray *currentSpectrumData = nil;
    
    @synchronized(self)
    {
        if (self.spectrumData.count > 0)
        {
            currentSpectrumData = [[self.spectrumData objectAtIndex:0] copy];
        }
    }
    
    int count = currentSpectrumData.count;
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height;
    
    CGFloat offset = 1.f;
    CGFloat width = (maxWidth - (count - 1) * offset) / count;
    width = floorf(width);
    
    CGFloat restSpace = maxWidth - (count * width + (count - 1) * offset);
    CGFloat x = restSpace/2.f;
    
    UIBezierPath *barBackgroundPath = [UIBezierPath bezierPath];
    UIBezierPath *barFillPath = [UIBezierPath bezierPath];

    for (int i = 0; i < count; i++)
    {
        CGRect frame = CGRectMake(x, 0.f, width, maxHeight);
        
        [barBackgroundPath appendPath:[UIBezierPath bezierPathWithRect:frame]];

        NSNumber *value = currentSpectrumData[i];
        CGFloat floatValue = value.floatValue;

        if (!isnan(floatValue))
        {
            CGFloat height = 0.f;

            if (floatValue <= kDefaultMinDbFS)
            {
                height = 0.5f;
            }
            else if (floatValue >= 0)
            {
                height = maxHeight - 0.5f;
            }
            else
            {
                double normalizedValue = 1.0 - floatValue / (double) kDefaultMinDbFS;
//                normalizedValue = pow(normalizedValue, 1.0/kDBLogFactor);
                height = floor(normalizedValue * maxHeight) + 0.5f;
                
//                NSLog(@"db: %8.4f, h: %8.4f", floatValue, normalizedValue);
            }
            
            frame.origin.y = maxHeight - height;
            frame.size.height = height;
            
            [barFillPath appendPath:[UIBezierPath bezierPathWithRect:frame]];
        }
        
        x += width + offset;
    }
    
    [self.barBackgroundColor setFill];
    [barBackgroundPath fill];
    
    [self.barFillColor setFill];
    [barFillPath fill];
}

@end
