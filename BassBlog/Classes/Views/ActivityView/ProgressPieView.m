//
//  ProgressPieView.m
//  iO
//
//  Created by Nikita Ivaniushchenko on 9/25/13.
//  Copyright (c) 2013 NGTI. All rights reserved.
//

#import "ProgressPieView.h"

#define kProgressPieViewRedrawPeriod    (1.0/30.0)

@interface ProgressPieLayer : CALayer

@property (assign, nonatomic) float progress;
@property (assign, nonatomic) float lineWidth;

@property (strong, nonatomic) UIColor *progressTintColor;
@property (strong, nonatomic) UIColor *trackTintColor;

@end

@implementation ProgressPieLayer

- (id)initWithLayer:(id)aLayer
{
    if ((self = [super initWithLayer:aLayer]))
    {
        // Typically, the method is called to create the Presentation layer.
        // We must copy the parameters to look the same.
        if([aLayer isKindOfClass:self.class])
        {
            ProgressPieLayer *anOtherLayer = aLayer;
            
            self.lineWidth = anOtherLayer.lineWidth;
            self.progressTintColor = anOtherLayer.progressTintColor;
            self.trackTintColor = anOtherLayer.trackTintColor;
        }
    }
    
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"progress"])
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)aContext
{
    CGFloat theRadius = (MIN(self.bounds.size.width, self.bounds.size.height)) / 2.f;
    CGPoint theCenter = CGPointMake(self.bounds.size.width/2.f, self.bounds.size.height/2.f);
    
    if (self.lineWidth != 0.f)
    {
        CGRect circleRect = CGRectMake((self.bounds.size.width - theRadius)/2.f, (self.bounds.size.height - theRadius)/2.f, theRadius, theRadius);
        
        CGFloat internalRadius = theRadius - self.lineWidth;
        CGRect internalCircleRect = CGRectMake((self.bounds.size.width - internalRadius)/2.f, (self.bounds.size.height - internalRadius)/2.f, internalRadius, internalRadius);
        
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
        [clipPath appendPath:[UIBezierPath bezierPathWithOvalInRect:internalCircleRect]];
        
        CGContextAddPath(aContext, clipPath.CGPath);
        CGContextEOClip(aContext);
    }
    
    if (self.progressTintColor && ![self.progressTintColor isEqual:[UIColor clearColor]])
    {
        CGContextSaveGState(aContext);
        
        UIBezierPath *thePiePath = [UIBezierPath bezierPath];
        [thePiePath moveToPoint:theCenter];
        [thePiePath addLineToPoint:CGPointMake(theCenter.x, theCenter.y - theRadius)];
        
        [thePiePath addArcWithCenter:theCenter
                              radius:theRadius
                          startAngle:-M_PI_2
                            endAngle:-M_PI_2 - M_PI * 2.f * (1.f - self.progress)
                           clockwise:YES];
        
        [thePiePath addLineToPoint:theCenter];
        
        CGContextSetFillColorWithColor(aContext, self.progressTintColor.CGColor);
        CGContextAddPath(aContext, thePiePath.CGPath);
        CGContextFillPath(aContext);
        
        CGContextRestoreGState(aContext);
    }
    
    if (self.trackTintColor && ![self.trackTintColor isEqual:[UIColor clearColor]])
    {
        CGContextSaveGState(aContext);
        
        UIBezierPath *thePiePath = [UIBezierPath bezierPath];
        [thePiePath moveToPoint:theCenter];
        [thePiePath addLineToPoint:CGPointMake(theCenter.x, theCenter.y - theRadius)];
        
        [thePiePath addArcWithCenter:theCenter
                              radius:theRadius
                          startAngle:-M_PI_2
                            endAngle:-M_PI_2 + M_PI * 2.f * self.progress
                           clockwise:NO];
        
        [thePiePath addLineToPoint:theCenter];
        
        CGContextSetFillColorWithColor(aContext, self.trackTintColor.CGColor);
        CGContextAddPath(aContext, thePiePath.CGPath);
        CGContextFillPath(aContext);
        
        CGContextRestoreGState(aContext);
    }
}

@end

#pragma mark -
#pragma mark ProgressPieView

@implementation ProgressPieView

@dynamic lineWidth;
@dynamic progressTintColor;
@dynamic trackTintColor;

+ (Class)layerClass
{
    return [ProgressPieLayer class];
}

- (void)commonInit
{
    self.layer.contentsScale = UI_SCREEN_SCALE;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self commonInit];
    }
    
    return self;
}

- (id)init
{
    if ((self = [super init]))
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self commonInit];
    }
    
    return self;
}

- (ProgressPieLayer *)progressPieLayer
{
    return (ProgressPieLayer *)self.layer;
}

- (void)startAnimating
{
    [self.progressPieLayer removeAnimationForKey:@"progressAnimation"];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.duration = 2.0;
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue = [NSNumber numberWithFloat:1.f];
    animation.removedOnCompletion = NO;
    animation.repeatCount = 888;
    [self.progressPieLayer addAnimation:animation forKey:@"progressAnimation"];
    
    self.progressPieLayer.progress = -1.f;
}

- (float)lineWidth
{
    return [self.progressPieLayer lineWidth];
}

- (void)setLineWidth:(float)lineWidth
{
    [self.progressPieLayer setLineWidth:lineWidth];
}

- (UIColor *)progressTintColor
{
    return [self.progressPieLayer progressTintColor];
}

- (void)setProgressTintColor:(UIColor *)aProgressTintColor
{
    [self.progressPieLayer setProgressTintColor:aProgressTintColor];
}

- (UIColor *)trackTintColor
{
    return [self.progressPieLayer trackTintColor];
}

- (void)setTrackTintColor:(UIColor *)aTrackTintColor
{
    [self.progressPieLayer setTrackTintColor:aTrackTintColor];
}

@end
