#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>

typedef void(^FFTHelperCompletionBlock)(NSArray *fftData);

@interface FFTHelper : NSObject

- (instancetype)initWithNumberOfSamples:(UInt32)numberOfSamples;
- (void)performComputation:(AudioBufferList *)bufferListInOut completionHandler:(FFTHelperCompletionBlock)completion;

@end

UInt32 Log2Ceil(UInt32 x);
