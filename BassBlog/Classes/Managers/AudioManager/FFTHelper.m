#import <stdio.h>
#import <Accelerate/Accelerate.h>
#import <MacTypes.h>

#import "FFTHelper.h"

const int FFTHelperChannelsCount = 2;
static const UInt32 FFTHelperInputBufferSize = 16384;
static const UInt32 FFTHelperMaxInputSize = 1024;

UInt32 NextPowerOfTwo(UInt32 x);

@interface FFTHelper()
{
    FFTSetup _fftSetup;
    Float32* _windowBuffer;
    COMPLEX_SPLIT _complexA[2];
    Float32 *_tmpFFTData0[2];
    Float32 *_outFFTData;
    
    UInt32 _numberOfSamples;
}

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation FFTHelper

- (id)init
{
    if (self = [self initWithNumberOfSamples:FFTHelperInputBufferSize])
    {
        
    }
    
    return self;
}

- (instancetype)initWithNumberOfSamples:(UInt32)numberOfSamples
{
    if (self = [super init])
    {
        _numberOfSamples = numberOfSamples;
        
        UInt32 nOver2 = FFTHelperMaxInputSize/2;
        vDSP_Length log2n = Log2Ceil(FFTHelperMaxInputSize);
        
        _fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
        _windowBuffer = (Float32*)malloc(sizeof(Float32)*FFTHelperMaxInputSize);
        
        memset(_windowBuffer, 0, sizeof(sizeof(Float32)*FFTHelperMaxInputSize));
        vDSP_hann_window(_windowBuffer, FFTHelperMaxInputSize, vDSP_HANN_NORM);

        for (int i = 0; i < FFTHelperChannelsCount; i++)
        {
            _complexA[i].realp = (Float32*)malloc(FFTHelperMaxInputSize*sizeof(Float32));
            _complexA[i].imagp = (Float32*)malloc(FFTHelperMaxInputSize*sizeof(Float32));
            
            _tmpFFTData0[i] = (Float32 *)malloc(FFTHelperMaxInputSize*sizeof(Float32));
            
            memset(_tmpFFTData0[i], 0, nOver2*sizeof(Float32));
        }
        
        _outFFTData = (Float32 *)malloc(nOver2*sizeof(Float32));
        memset(_outFFTData, 0, nOver2*sizeof(Float32));
        
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    
    return self;
}

- (void)dealloc
{
    [self.operationQueue cancelAllOperations];
    
    vDSP_destroy_fftsetup(_fftSetup);
    
    for (int i = 0; i < FFTHelperChannelsCount; i++)
    {
        free(_complexA[i].realp);
        free(_complexA[i].imagp);
        free(_tmpFFTData0[i]);
    }
    
    free(_outFFTData);
}

- (void)performComputation:(AudioBufferList *)bufferListInOut completionHandler:(FFTHelperCompletionBlock)completion
{
    AudioBuffer audioBuffer0 = bufferListInOut->mBuffers[0];
    
    UInt32 numSamples = MIN(audioBuffer0.mDataByteSize/sizeof(Float32), _numberOfSamples);
    numSamples = NextPowerOfTwo(numSamples);
    
//    NSLog(@"numSamples: %i", numSamples);
    
    if (!completion || !numSamples)
    {
        return;
    }

    if (self.operationQueue.operationCount > 1)
    {
        [self.operationQueue cancelAllOperations];
    }
    
    UInt32 maxChannels = MIN(FFTHelperChannelsCount, bufferListInOut->mNumberBuffers);
    Float32** channelInputs = (Float32**)malloc(sizeof(Float32)*maxChannels);
    
    for (int i = 0; i < maxChannels; i++)
    {
        channelInputs[i] = (Float32*)malloc(sizeof(Float32)*numSamples);
        
        AudioBuffer audioBuffer = bufferListInOut->mBuffers[i];
        vDSP_vmul((Float32 *)audioBuffer.mData, 1, _windowBuffer, 1, channelInputs[i], 1, numSamples);
    }
    
    [self.operationQueue addOperationWithBlock:^
    {
        for (int i = 0; i < maxChannels; i++)
        {
            channelInputs[i] = (Float32*)malloc(sizeof(Float32)*numSamples);
            
            AudioBuffer audioBuffer = bufferListInOut->mBuffers[i];
            memcpy(channelInputs[i], audioBuffer.mData, sizeof(Float32) * numSamples);
        }
        
        UInt32 steps = numSamples/FFTHelperMaxInputSize;
        
        for (int i = 0; i < steps; i++)
        {
            UInt32 log2FFTSize = Log2Ceil(FFTHelperMaxInputSize);

            UInt32 bins = FFTHelperMaxInputSize>>1;

            Float32 one = 1.f;
            Float32 two= 2.f;
            Float32 fGainOffset = -3.2f;
            Float32 fBins = bins;
            
            UInt32 dataOffset = i * FFTHelperMaxInputSize;
            
            Float32* currentChannelInputs[maxChannels];
            
            for (int i = 0; i < maxChannels; i++)
            {
                currentChannelInputs[i] = channelInputs[i] + dataOffset;
                
                vDSP_vmul(currentChannelInputs[i], 1, _windowBuffer, 1, currentChannelInputs[i], 1, FFTHelperMaxInputSize);
                
                //Convert float array of reals samples to COMPLEX_SPLIT array A
                vDSP_ctoz((COMPLEX*)currentChannelInputs[i], 2, &(_complexA[i]), 1, bins);

                //Perform FFT using fftSetup and A
                //Results are returned in A
                vDSP_fft_zrip(_fftSetup, &(_complexA[i]), 1, log2FFTSize, FFT_FORWARD);

                // compute Z magnitude
                vDSP_zvabs(&(_complexA[i]), 1, _tmpFFTData0[i], 1, bins);
                vDSP_vsdiv(_tmpFFTData0[i], 1, &fBins, _tmpFFTData0[i], 1, bins);

                //        vDSP_zvmags(&(fftHelperRef->complexA[i]), 1, fftHelperRef->tmpFFTData0[i], 1, bins);

                // convert to Db
                vDSP_vdbcon(_tmpFFTData0[i], 1, &one, _tmpFFTData0[i], 1, bins, 1);

                // db correction considering window
    //            vDSP_vsadd(_tmpFFTData0[i], 1, &fGainOffset, _tmpFFTData0[i], 1, bins);
            }

            memcpy(_outFFTData, _tmpFFTData0[0], sizeof(Float32) * bins);

            // stereo analysis ; for this demo, we only support up to 2 channels
            for (int i = 1; i < maxChannels; i++)
            {
                vDSP_vadd(_outFFTData, 1, _tmpFFTData0[i], 1, _tmpFFTData0[0], 1, bins);
            }
            
            Float32 div = maxChannels;
            vDSP_vsdiv(_outFFTData, 1, &div, _outFFTData, 1, bins);
            
        //    NSMutableString *string = [NSMutableString new];
            
            NSMutableArray *spectrumData = [NSMutableArray new];
            
            for (UInt32 i = 0; i < log2FFTSize; i++)
            {
                Float32 f = _outFFTData[i];
                
                [spectrumData addObject:@(f)];
                
        //        [string appendFormat:@"%8.4f ", f];
            }
            
        //    NSLog(@"%@", string);
            
            completion(spectrumData);
        }
        
        for (int i = 0; i < maxChannels; i++)
        {
            free(channelInputs[i]);
        }
        
        free(channelInputs);
    }];
}
@end

UInt32 CountLeadingZeroes(UInt32 arg)
{
    // GNUC / LLVM has a builtin
#if defined(__GNUC__)
    // on llvm and clang the result is defined for 0
#if (TARGET_CPU_X86 || TARGET_CPU_X86_64) && !defined(__llvm__)
    if (arg == 0) return 32;
#endif	// TARGET_CPU_X86 || TARGET_CPU_X86_64
    return __builtin_clz(arg);
#elif TARGET_OS_WIN32
    UInt32 tmp;
    __asm{
        bsr eax, arg
        mov ecx, 63
        cmovz eax, ecx
        xor eax, 31
        mov tmp, eax	// this moves the result in tmp to return.
    }
    return tmp;
#else
#error "Unsupported architecture"
#endif	// defined(__GNUC__)
}

// base 2 log of next power of two greater or equal to x
UInt32 Log2Ceil(UInt32 x)
{
    return 32 - CountLeadingZeroes(x - 1);
}

// next power of two greater or equal to x
UInt32 NextPowerOfTwo(UInt32 x)
{
    return 1 << Log2Ceil(x);
}
