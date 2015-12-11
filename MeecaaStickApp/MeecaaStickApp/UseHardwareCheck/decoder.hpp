//
//  decoder.hpp
//  TestCPPFile
//
//  Created by SoulJa on 15/10/23.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#ifndef decoder_hpp
#define decoder_hpp

#include <stdio.h>
#include "decoder_def.h"
#include "symbol.hpp"
#define INFO_LENGTH_TIME     0.07
// 1 start + 8 data + 1 parity + 2 stop
#define BITS_PER_FRAME       12

class Decoder
{
public:
    Decoder(INT32 recordBufSize, INT32 fs, INT32 msgBufSize)
    {
        double fPointsPerBit;
        INT32 syncSymbolNum;
        
        this->recordBufSize = recordBufSize;
        this->msgBufSize = msgBufSize;
        
        // fPointsPerSymbol is points per symbol in floating format.
        // nPointsPerSymbol is rounding result of it.
        // Currently, it is calculated based on waveform in a sample.
        // Need to replace it by theoretical calculation.
        // There are 448 points in 18 idle cycles.
        fPointsPerSymbol = 448.0 / 18;    //fs * SYMBOL_WIDTH_TIME;
        //nPointsPerSymbol = (INT32)(fPointsPerSymbol + 0.5); // rounding
        nPointsPerSymbol = (INT32)fPointsPerSymbol; // keep align with Matlab
        
        fPointsPerBit = fPointsPerSymbol / 2;
        nPointsPerBit = (INT32)fPointsPerBit;
        
        // Total synchronization points
        // Just considering the synchronization peak, the length of the
        // synchronization array should equals the 2 * idle bits.However, beause there
        // is a little frequency difference in different sticks, we need to reduce
        // the length to avoid the clock skew reduces the synchronization peak.
        // According to the datasheet of EFM32 MCU, the RC clock error rate is 1.5% max.
        // In order to guarantee the clock skew < 0.5 of half idle cycle, the maxim synchronization array should not more than 0.25 / 0.015 = 16 idle cycles.
        syncSymbolNum = 16;
        syncSymbolPoints = (INT32)(syncSymbolNum * fPointsPerSymbol + 0.5);
        
        
        syncSymbols = new char[syncSymbolPoints];
        
        // Create synchronization symbols
        for (int i = 0; i < syncSymbolPoints; ++i)
        {
            // Keep align with Matlab
            if (((INT32)((i+1) / fPointsPerBit) % 2) == 0)
                syncSymbols[i] = 1;
            else
                syncSymbols[i] = -1;
        }
        
        // Create symbol symbols
        symbol00Template = new char[nPointsPerSymbol];
        symbol01Template = new char[nPointsPerSymbol];
        symbol10Template = new char[nPointsPerSymbol];
        symbol11Template = new char[nPointsPerSymbol];
        
        //                              ____
        // Symbol00. Waveform is : ____|
        for (int i = 0; i < nPointsPerSymbol; ++i)
        {
            if (i < nPointsPerBit)
                symbol00Template[i] = -1;
            else
                symbol00Template[i] = 1;
        }
        // For the odd nPointsPerSymbol, middle point is 0
        //if ((nPointsPerSymbol % 2) == 1)
        //    symbol00Template[nPointsPerSymbol/2] = 0;
        
        // Symbol01. Waveform is : ________
        for (int i = 0; i < nPointsPerSymbol; ++i)
        {
            symbol01Template[i] = -1;
        }
        
        //                         ________
        // Symbol10. Waveform is :
        for (int i = 0; i < nPointsPerSymbol; ++i)
        {
            symbol10Template[i] = 1;
        }
        
        //                         ____
        // Symbol11. Waveform is :     |____
        for (int i = 0; i < nPointsPerSymbol; ++i)
        {
            if (i < nPointsPerBit)
                symbol11Template[i] = 1;
            else
                symbol11Template[i] = -1;
        }
        // For the odd nPointsPerSymbol, middle point is 0
        //if ((nPointsPerSymbol % 2) == 1)
        //    symbol11Template[nPointsPerSymbol / 2] = 0;
        
        
        // Symbol numbers
        // +1 for avoiding overflow during converting floating to integer
        symbolNum = (INT32)(fs * INFO_LENGTH_TIME / fPointsPerSymbol + 1);
        
        // Binarization value of recordBuf
        // Used for finding the synchronization peak
        binRecordBuf = new char[recordBufSize];
        
        // Points of useful information
        // points in 60mS
        infoPoints = (INT32)(symbolNum * fPointsPerSymbol + 1);
        
        // Xcorr array length
        
        xcorrSyncArrayLength = recordBufSize + syncSymbolPoints - 1;
        xcorrSync = new INT16[xcorrSyncArrayLength];
        
        xcorrSymbolArrayLength = infoPoints + nPointsPerSymbol - 1;
        
        xcorrSymbol00 = new INT32[xcorrSymbolArrayLength];
        xcorrSymbol01 = new INT32[xcorrSymbolArrayLength];
        xcorrSymbol10 = new INT32[xcorrSymbolArrayLength];
        xcorrSymbol11 = new INT32[xcorrSymbolArrayLength];
        
        symbol = new Symbol[symbolNum];
        
        
    }
    
    ~Decoder()
    {
        
        SAFE_DELETE_ARRAY(syncSymbols)
        SAFE_DELETE_ARRAY(binRecordBuf)
        SAFE_DELETE_ARRAY(symbol00Template)
        SAFE_DELETE_ARRAY(symbol01Template)
        SAFE_DELETE_ARRAY(symbol10Template)
        SAFE_DELETE_ARRAY(symbol11Template)
        SAFE_DELETE_ARRAY(xcorrSync)
        SAFE_DELETE_ARRAY(xcorrSymbol00)
        SAFE_DELETE_ARRAY(xcorrSymbol01)
        SAFE_DELETE_ARRAY(xcorrSymbol10)
        SAFE_DELETE_ARRAY(xcorrSymbol11)
        SAFE_DELETE_ARRAY(symbol)
        
    }
    
public:
    INT32   Decode(INT16* recordBuf, INT16* temperature, char* logBuf);
    INT32   Decode(INT16(&recordBuf)[RECORD_BUF_SIZE], INT16 &temperature, char(&logBuf)[MSG_BUF_SIZE]);
    
private:
    void    PreProcess(INT16* recordBuf, INT32 bufSize);
    void    FindMax(INT32* maxValue, INT32* maxLocation, INT32* buf, INT32 bufLength);
    void    Sort(INT32* data, INT32* index, INT32 size);
    void    NormalizeRecordBuf(INT16* recordBuf);
    void    FindSyncPeak(INT32* maxLocation, INT32* minLocation);
    int     XcorrDecode(INT16* temperature, INT16* recordBuf, INT32 syncPeakLocation);
    void    XcorrSync(INT16* xcorrResult, char* a, char* b, INT32 aSize, INT32 bSize);
    void    XcorrSymbol(INT32* xcorrResult, INT16* a, char* b, INT32 aSize, INT32 bSize);
    void    CalcXcorrSymbols(INT16* recordBuf, INT32 syncPeakLocation);
    void    ReverseArrays(INT16* recordBuf);
    
    INT32   infoPoints;
    INT32   msgBufSize;
    INT32   recordBufSize;
    double  fPointsPerSymbol;
    INT32   nPointsPerSymbol;
    INT32   nPointsPerBit;
    
    INT32   syncSymbolPoints;
    char*   syncSymbols;
    
    char*   symbol00Template;
    char*   symbol01Template;
    char*   symbol10Template;
    char*   symbol11Template;
    
    INT32   xcorrSyncArrayLength;
    INT16*  xcorrSync;
    
    INT32   symbolNum;
    char*   binRecordBuf;
    INT32   xcorrSymbolArrayLength;
    INT32*  xcorrSymbol00;
    INT32*  xcorrSymbol01;
    INT32*  xcorrSymbol10;
    INT32*  xcorrSymbol11;
    Symbol* symbol;
    
};
#endif
