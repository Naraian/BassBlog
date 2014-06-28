

#include <stdio.h>


#import "FFTHelper.h"


FFTHelperRef * FFTHelperCreate(long numberOfSamples)
{
    FFTHelperRef *helperRef = (FFTHelperRef*) malloc(sizeof(FFTHelperRef));
    vDSP_Length log2n = log2f(numberOfSamples);    
    helperRef->fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    int nOver2 = numberOfSamples/2;
    
    for (int i = 0; i < 2; i++)
    {
        helperRef->complexA[i].realp = (Float32*)malloc(nOver2*sizeof(Float32));
        helperRef->complexA[i].imagp = (Float32*)malloc(nOver2*sizeof(Float32));
        
        helperRef->tmpFFTData0[i] = (Float32 *)malloc(numberOfSamples*sizeof(Float32));
        helperRef->tmpFFTData1[i] = (Float32 *)malloc(numberOfSamples*sizeof(Float32));
        
        memset(helperRef->tmpFFTData0[i], 0, nOver2*sizeof(Float32) );
        memset(helperRef->tmpFFTData1[i], 0, nOver2*sizeof(Float32) );
    }
    
    helperRef->outFFTData = (Float32 *)malloc(nOver2*sizeof(Float32));
    memset(helperRef->outFFTData, 0, nOver2*sizeof(Float32));

    helperRef->invertedCheckData = (Float32*)malloc(numberOfSamples*sizeof(Float32));
    
    return  helperRef;
}

inline UInt32 CountLeadingZeroes(UInt32 arg)
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
inline UInt32 Log2Ceil(UInt32 x)
{
    return 32 - CountLeadingZeroes(x - 1);
}

// next power of two greater or equal to x
inline UInt32 NextPowerOfTwo(UInt32 x)
{
    return 1 << Log2Ceil(x);
}

Float32 * computeFFT(FFTHelperRef *fftHelperRef, Float32 **timeDomainData, long numSamples, int numberChannels)
{
    numSamples = NextPowerOfTwo(numSamples);
	UInt32 log2FFTSize = Log2Ceil(numSamples);
    
    UInt32 bins = numSamples>>1;
    
    Float32 one(1.f), two(2.f), fGainOffset(-3.2f), fBins(bins);
    
    for (int i = 0; i < numberChannels; i++)
    {
        //Convert float array of reals samples to COMPLEX_SPLIT array A
        vDSP_ctoz((COMPLEX*)timeDomainData[i], 2, &(fftHelperRef->complexA[i]), 1, bins);
        
        //Perform FFT using fftSetup and A
        //Results are returned in A
        vDSP_fft_zrip(fftHelperRef->fftSetup, &(fftHelperRef->complexA[i]), 1, log2FFTSize, FFT_FORWARD);
        
        // compute Z magnitude
        vDSP_zvabs(&(fftHelperRef->complexA[i]), 1, fftHelperRef->tmpFFTData0[i], 1, bins);
        vDSP_vsdiv(fftHelperRef->tmpFFTData0[i], 1, &fBins, fftHelperRef->tmpFFTData0[i], 1, bins);
        
//        vDSP_zvmags(&(fftHelperRef->complexA[i]), 1, fftHelperRef->tmpFFTData0[i], 1, bins);
        
        // convert to Db
        vDSP_vdbcon(fftHelperRef->tmpFFTData0[i], 1, &one, fftHelperRef->tmpFFTData0[i], 1, bins, 1);
        
        // db correction considering window
        vDSP_vsadd(fftHelperRef->tmpFFTData0[i], 1, &fGainOffset, fftHelperRef->tmpFFTData0[i], 1, bins);
    }
    
    memcpy(fftHelperRef->outFFTData, fftHelperRef->tmpFFTData0[0], sizeof(Float32) * bins);
    
    // stereo analysis ; for this demo, we only support up to 2 channels
    for (int i = 1; i < numberChannels; i++)
    {
        vDSP_vadd(fftHelperRef->outFFTData, 1, fftHelperRef->tmpFFTData0[i], 1, fftHelperRef->tmpFFTData0[0], 1, bins);
    }
    
    Float32 div(numberChannels);
    
    vDSP_vsdiv(fftHelperRef->outFFTData, 1, &div, fftHelperRef->outFFTData, 1, bins);
    
    return fftHelperRef->outFFTData;
}

void FFTHelperRelease(FFTHelperRef *fftHelper) {
    vDSP_destroy_fftsetup(fftHelper->fftSetup);
//    free(fftHelper->complexA.realp);
//    free(fftHelper->complexA.imagp);
//    free(fftHelper->outFFTData);
//    free(fftHelper->invertedCheckData);
//    free(fftHelper);
    fftHelper = NULL;
}

