
#ifndef ShazamTest_FFTHelper_h
#define ShazamTest_FFTHelper_h




#import <Accelerate/Accelerate.h>
#include <MacTypes.h>


typedef struct FFTHelperRef {
    FFTSetup fftSetup;
    COMPLEX_SPLIT complexA[2];
    Float32 *tmpFFTData0[2];
    Float32 *tmpFFTData1[2];
    Float32 *outFFTData;
    Float32 *invertedCheckData;
} FFTHelperRef;

inline UInt32 Log2Ceil(UInt32 x);


FFTHelperRef * FFTHelperCreate(long numberOfSamples);
Float32 * computeFFT(FFTHelperRef *fftHelperRef, Float32 **timeDomainData, long numSamples, int numberChannels);
void FFTHelperRelease(FFTHelperRef *fftHelper);


#endif
