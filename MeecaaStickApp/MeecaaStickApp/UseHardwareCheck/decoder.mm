//--------------------------------------------------------------------------------------------------
// (c)2015 Meecaa Corporation. All rights reserved.
// This class implement the decode for the data got from MIC line
// Decode flow:
// 1. Store the record data record_buf.
// 2. Instantiate Decoder. E.g. Decoder micDecoder.
// 3. Call micDecoder.decode() function. The recordBuf[] is the source record data. recordBufLength is the length of recordBuf[]. 
//    temperature is a int32 value, that is the real temperature * 100. 
//    debugBuf[] is used for recording the debug information, and debugBufSize is its size in byte. Recomm  
//--------------------------------------------------------------------------------------------------
// Author: Hank Yue
// 2015.10.21
#include "decoder.hpp"
#include "stdio.h"
#include "string.h"
#include "limits.h"
#include "assert.h"
#include "decoder_def.h"
#include "symbol.hpp"


void Decoder::PreProcess(INT16* recordBuf, INT32 bufSize)
{
    for (int i = 0; i < bufSize; ++i)
    {
        if (SHRT_MIN == recordBuf[i])
            recordBuf[i] = SHRT_MIN + 1;
        
    }
}

void Decoder::FindMax(INT32* maxValue, INT32* maxLocation, INT32* buf, INT32 bufLength)
{
    *maxValue = buf[0];
    *maxLocation = 0;
    
    for (int i = 1; i < bufLength; ++i)
    {
        if (buf[i] > *maxValue)
        {
            *maxValue = buf[i];
            *maxLocation = i;
        }
    }
}

void Decoder::Sort(INT32* data, INT32* index, INT32 size)
{
    // bubble sort
    INT32 temp;
    
    for (int i = 0; i < size - 1; ++i)
        for (int j = i + 1; j < size; ++j)
            if (data[i]>data[j])
            {
                temp    = data[i];
                data[i] = data[j];
                data[j] = temp;
                
                temp = index[i];
                index[i] = index[j];
                index[j] = temp;
                
            }
    
}

int Decoder::XcorrDecode(INT16* temperature, INT16* recordBuf, INT32 syncPeakLocation)
{
    double fCurDecodeLocation;
    INT32 nCurDecodeLocation;
    INT32 nCurXcorrLocation;
    INT32 maxClkSkewTh;
    
    INT32 maxXcorrSymbol00Value;
    INT32 maxXcorrSymbol01Value;
    INT32 maxXcorrSymbol10Value;
    INT32 maxXcorrSymbol11Value;
    
    INT32 maxXcorrSymbol00Location;
    INT32 maxXcorrSymbol01Location;
    INT32 maxXcorrSymbol10Location;
    INT32 maxXcorrSymbol11Location;
    
    INT32 maxValues[4];
    INT32 maxMaxXcorrSymbolLocation;
    
    INT32 sortIndex[4];
    
    INT32 correctXcorrPeakLocation;
    
    INT32 clkSkew;
    INT32 preClkSkew;
    
    double fClkAdjustPoints;
    
    INT32 firstStartLocation;
    INT32 exportLocation;
    
    char decodedArray[4][BITS_PER_FRAME];
    char dataArray[4];
    char checkSum;
    char parity;
    
    // The synchronization peak is too late in the waveform, means the waveform is not completed
    // And if it is < 0, mostly means there is not correct record
    if ((syncPeakLocation < 0) || (syncPeakLocation + infoPoints >= recordBufSize))
        return -1;
    
    // Calculate Xcorr Arrays
    CalcXcorrSymbols(recordBuf, syncPeakLocation);
    
    fCurDecodeLocation = 0;
    
    for (int symbolId = 0; symbolId < symbolNum; ++symbolId)
    {
        // Start decode a symbol from the nearest bit boundary
        // Keep align with Matlib
        nCurDecodeLocation = (INT32)fCurDecodeLocation;
        
        // if exceeding the boundry, jump out of the loop
        if (nCurDecodeLocation >= infoPoints)
            break;
        
        // Corresponding xcorr location
        nCurXcorrLocation = nCurDecodeLocation + (nPointsPerSymbol - 1);
        
        // jump to next symbol
        fCurDecodeLocation = fCurDecodeLocation + fPointsPerSymbol;
        
        // For the point at location R, The xcorr peak is at R + (TemplateLength - 1).
        // Find the peak location from - max_clock_skew_th_points to + max_clock_skew_th_points.
        maxClkSkewTh = nPointsPerBit / 2;
        FindMax(&maxXcorrSymbol00Value, &maxXcorrSymbol00Location, &xcorrSymbol00[nCurXcorrLocation - maxClkSkewTh], 2 * maxClkSkewTh + 1);
        FindMax(&maxXcorrSymbol01Value, &maxXcorrSymbol01Location, &xcorrSymbol01[nCurXcorrLocation - maxClkSkewTh], 2 * maxClkSkewTh + 1);
        FindMax(&maxXcorrSymbol10Value, &maxXcorrSymbol10Location, &xcorrSymbol10[nCurXcorrLocation - maxClkSkewTh], 2 * maxClkSkewTh + 1);
        FindMax(&maxXcorrSymbol11Value, &maxXcorrSymbol11Location, &xcorrSymbol11[nCurXcorrLocation - maxClkSkewTh], 2 * maxClkSkewTh + 1);
        
        maxValues[0] = xcorrSymbol00[nCurXcorrLocation];
        maxValues[1] = xcorrSymbol01[nCurXcorrLocation];
        maxValues[2] = xcorrSymbol10[nCurXcorrLocation];
        maxValues[3] = xcorrSymbol11[nCurXcorrLocation];
        
        sortIndex[0] = 0;
        sortIndex[1] = 1;
        sortIndex[2] = 2;
        sortIndex[3] = 3;
        
        Sort(maxValues, sortIndex, 4);
        
        if (sortIndex[3] == 0)
        {
            symbol[symbolId].preDecodedValue = 0;
            symbol[symbolId].curDecodedValue = 0;
            maxMaxXcorrSymbolLocation = maxXcorrSymbol00Location;
        }
        else if (sortIndex[3] == 1)
        {
            symbol[symbolId].preDecodedValue = 0;
            symbol[symbolId].curDecodedValue = 1;
            maxMaxXcorrSymbolLocation = maxXcorrSymbol01Location;
        }
        else if (sortIndex[3] == 2)
        {
            symbol[symbolId].preDecodedValue = 1;
            symbol[symbolId].curDecodedValue = 0;
            maxMaxXcorrSymbolLocation = maxXcorrSymbol10Location;
        }
        else if (sortIndex[3] == 3)
        {
            symbol[symbolId].preDecodedValue = 1;
            symbol[symbolId].curDecodedValue = 1;
            maxMaxXcorrSymbolLocation = maxXcorrSymbol11Location;
        }
        else
        {
            assert(0);
        }
        
        // record second max decode value
        if (sortIndex[2] == 0)
        {
            symbol[symbolId].preSecondDecodedValue = 0;
            symbol[symbolId].curSecondDecodedValue = 0;
        }
        else if (sortIndex[2] == 1)
        {
            symbol[symbolId].preSecondDecodedValue = 0;
            symbol[symbolId].curSecondDecodedValue = 1;
        }
        else if (sortIndex[2] == 2)
        {
            symbol[symbolId].preSecondDecodedValue = 1;
            symbol[symbolId].curSecondDecodedValue = 0;
        }
        else if (sortIndex[2] == 3)
        {
            symbol[symbolId].preSecondDecodedValue = 1;
            symbol[symbolId].curSecondDecodedValue = 1;
        }
        else
        {
            assert(0);
        }
        
        // Second max : max rate
        symbol[symbolId].secondMaxToMaxRate = (double)maxValues[2] / maxValues[3];
        
        // Do not need to plus 1 in C
        correctXcorrPeakLocation = maxClkSkewTh;
        clkSkew = maxMaxXcorrSymbolLocation - correctXcorrPeakLocation;
        
        symbol[symbolId].clkSkew = clkSkew;
        
        if (symbolId == 0)
            preClkSkew = 0;
        else
            preClkSkew = symbol[symbolId-1].clkSkew;
        
        // Mark the potential error locations
        if (symbolId == 0)
        {
            if ((symbol[symbolId].preDecodedValue != 1) || (symbol[symbolId].curDecodedValue != 1))
                symbol[symbolId].potentialError = 1;
            else
                symbol[symbolId].potentialError = 0;
        }
        else
        {
            if (symbol[symbolId - 1].curDecodedValue != symbol[symbolId].preDecodedValue)
            {
                symbol[symbolId - 1].potentialError = 1;
                symbol[symbolId].potentialError = 1;
                
            }
            else
            {
                symbol[symbolId].potentialError = 0;
            }
            
        }
        
        // Error correction
        // Can only correct 1 bit error.
        // Cases can be corrected:
        // OK, ERROR
        // ERROR, OK
        // OK, ERROR, OK
        // ERROR, OK, ERROR
        // For the cases more than 4 continuous elements, can split it to previous cases
        if (symbolId >= 2)
        {
            if (symbol[symbolId - 1].potentialError == 1)
            {
                if (symbol[symbolId].potentialError == 1)
                {
                    if (symbol[symbolId - 1].secondMaxToMaxRate > symbol[symbolId].secondMaxToMaxRate)
                    {
                        symbol[symbolId - 1].preDecodedValue = symbol[symbolId - 2].curDecodedValue;
                        symbol[symbolId - 1].curDecodedValue = symbol[symbolId].preDecodedValue;
                        
                        // Do not want to clear it to 0.
                        // After all, it is corrected one.
                        symbol[symbolId - 1].potentialError = -1;
                        
                        symbol[symbolId].potentialError = 0;
                        
                        // Previous bit might be error. Do not use it for adjusting the clock
                        preClkSkew = 0;
                        
                    }
                    else
                    {
                        symbol[symbolId].preDecodedValue = symbol[symbolId].preSecondDecodedValue;
                        symbol[symbolId].curDecodedValue = symbol[symbolId].curSecondDecodedValue;
                        
                        symbol[symbolId - 1].potentialError = 0;
                        symbol[symbolId].potentialError = -1;
                    }
                }
                // so previous sumbol should be wrong
                else if (symbol[symbolId].potentialError == 0)
                {
                    symbol[symbolId - 1].preDecodedValue = symbol[symbolId - 2].curDecodedValue;
                    symbol[symbolId - 1].curDecodedValue = symbol[symbolId].preDecodedValue;
                    
                    symbol[symbolId - 1].potentialError = -1;
                    
                    // error in last bit.Do not use the skew value in last symbol
                    preClkSkew = 0;
                    
                }
                
            }
            
        }
        
        symbol[symbolId].judgeDecodeLocation = nCurDecodeLocation;
        symbol[symbolId].judgeXcorrLocation = nCurXcorrLocation;
        
        // Adjust the local clock as + / -2.5%
        if (preClkSkew > 0)
            fClkAdjustPoints = 0.025 / (1.0 / fPointsPerSymbol);
        else if (preClkSkew < 0)
            fClkAdjustPoints = -0.025 / (1.0 / fPointsPerSymbol);
        else
            fClkAdjustPoints = 0;
        
        fCurDecodeLocation += fClkAdjustPoints;
        
    }
    
    // Post decode
    // Do Correction again
    
    // Mark the potential error location
    if ((symbol[0].preDecodedValue != 1) || (symbol[0].curDecodedValue != 1))
        symbol[0].potentialError = 1;
    else
        symbol[0].potentialError = 0;
    
    
    for (INT32 symbolId = 1; symbolId < symbolNum; ++symbolId)
    {
        if (symbol[symbolId - 1].curDecodedValue != symbol[symbolId].preDecodedValue)
        {
            symbol[symbolId].potentialError = 1;
            symbol[symbolId - 1].potentialError = 1;
        }
        else
        {
            // Shouldn't clear the potential error bit, because we have not ensure it is OK
            //symbol[symbolId].potentialError = 0;
        }
        
    }
    
    // Error correction
    // Can only correct 1 bit error.
    // Cases can be corrected:
    // OK, ERROR;
    // ERROR, OK;
    // OK, ERROR, OK
    // ERROR, OK, ERROR
    // For the cases more than 4 continuous elements, can split it to previous cases
    for (INT32 symbolId = 1; symbolId < symbolNum-1; ++symbolId)
    {
        if (symbol[symbolId - 1].potentialError == 1)
        {
            if (symbol[symbolId].potentialError == 1)
            {
                if (symbol[symbolId - 1].secondMaxToMaxRate > symbol[symbolId].secondMaxToMaxRate)
                {
                    symbol[symbolId - 1].preDecodedValue = symbol[symbolId - 2].curDecodedValue;
                    symbol[symbolId - 1].curDecodedValue = symbol[symbolId].preDecodedValue;
                }
                else if (symbol[symbolId + 1].potentialError == 0)
                {
                    symbol[symbolId].preDecodedValue = symbol[symbolId - 1].curDecodedValue;
                    symbol[symbolId].curDecodedValue = symbol[symbolId + 1].preDecodedValue;
                }
                else
                {
                    symbol[symbolId].preDecodedValue = symbol[symbolId].preSecondDecodedValue;
                    symbol[symbolId].curDecodedValue = symbol[symbolId].curSecondDecodedValue;
                    
                }
                symbol[symbolId - 1].potentialError = 0;
                symbol[symbolId].potentialError = 0;
                
            }
            // so previous sumbol should be wrong
            else if (symbol[symbolId].potentialError == 0)
            {
                symbol[symbolId - 1].preDecodedValue = symbol[symbolId - 2].curDecodedValue;
                symbol[symbolId - 1].curDecodedValue = symbol[symbolId].preDecodedValue;
                
                symbol[symbolId - 1].potentialError = 0;
                
            }
            
        }
        
    }
    
    
    // Export
    firstStartLocation = -1;
    
    for (int i = 0; i < symbolNum; ++i)
    {
        if (symbol[i].curDecodedValue == 0)
        {
            firstStartLocation = i;
            break;
        }
    }
    
    // Can't find start symbol.
    // Decode failed.
    if (firstStartLocation == -1)
        return 1;
    
    exportLocation = firstStartLocation;
    
    // There are 4 bytes info
    for (int byteId = 0; byteId < 4; ++byteId)
    {
        for (int bitId = 0; bitId < BITS_PER_FRAME; ++bitId)
        {
            decodedArray[byteId][bitId] = symbol[exportLocation].curDecodedValue;
            exportLocation++;
            
        }
        
    }
    
    for (int byteId = 0; byteId < 4; ++byteId)
    {
        // start bit is not 0
        if (decodedArray[byteId][0] != 0)
            return 2;
        
        // stop bits are not 1
        if ((decodedArray[byteId][BITS_PER_FRAME-2] != 1) || (decodedArray[byteId][BITS_PER_FRAME - 1] != 1))
            return 3;
        
        parity = 0;
        dataArray[byteId] = 0;
        for (int i = 0; i < 8; ++i)
        {
            parity += decodedArray[byteId][i + 1];
            dataArray[byteId] |= (decodedArray[byteId][i + 1] << i);
        }
        
        if ((parity%2) != decodedArray[byteId][BITS_PER_FRAME - 3])
            return 4;
        
        
    }
    
    checkSum = dataArray[0] + dataArray[1];
    if (dataArray[2] != checkSum)
        return 5;
    
    if (0x55 != dataArray[3])
        return 6;
    
    *temperature = (((INT16)dataArray[1]) << 8) | (((INT16)dataArray[0]) & 0x00ff);
    
    
    return 0;
}

void Decoder::NormalizeRecordBuf(INT16* recordBuf)
{
    for (int i = 0; i < recordBufSize; ++i)
    {
        if (recordBuf[i] > 0)
            binRecordBuf[i] = 1;
        else if (recordBuf[i] < 0)
            binRecordBuf[i] = -1;
        else
            binRecordBuf[i] = 0;
    }
}

// For synchonization array
void Decoder::XcorrSync(INT16* xcorrResult, char* a, char* b, INT32 aSize, INT32 bSize)
{
    int aStart;
    int bSize_1;
    int aSize_1;
    
    bSize_1 = bSize - 1;
    aSize_1 = aSize - 1;
    // aArray length >> bArray length
    // XcorrId = AId + BId - 1
    // Split aArray to thress blocks
    
    // From bSize-1 ~ aSize-bSize
    for (int xcorrId = bSize_1; xcorrId <= aSize_1; ++xcorrId)
    {
        aStart = xcorrId - bSize_1;
        xcorrResult[xcorrId] = 0;
        for (int j = 0; j < bSize; ++j)
        {
            xcorrResult[xcorrId] += b[j] * a[aStart + j];
            
        }
    }
    
    // From 0 ~ bSize-2
    for (int xcorrId = 0; xcorrId < bSize_1; ++xcorrId)
    {
        xcorrResult[xcorrId] = 0;
        /*
         for (int j = bSize - 1 - xcorrId; j < bSize; ++j)
         {
         xcorrResult[xcorrId] += b[j] * a[xcorrId - ((bSize - 1) - j)];
         }
         */
    }
    
    // From aSize ~ aSize+bSize-2
    for (int xcorrId = aSize; xcorrId < aSize + bSize_1; ++xcorrId)
    {
        xcorrResult[xcorrId] = 0;
        /*
         for (int j = 0; j < aSize + bSize -1 - xcorrId; ++j)
         {
         xcorrResult[xcorrId] += b[j] * a[xcorrId - (bSize - 1) + j];
         }
         */
    }
}

// For xcorr symbol array
void Decoder::XcorrSymbol(INT32* xcorrResult, INT16* a, char* b, INT32 aSize, INT32 bSize)
{
    
    // aArray length >> bArray length
    // XcorrId = AId + BId - 1
    // Split aArray to thress blocks
    
    // From bSize-1 ~ aSize-bSize
    for (int xcorrId = bSize - 1; xcorrId <= aSize - 1; ++xcorrId)
    {
        xcorrResult[xcorrId] = 0;
        for (int j = 0; j < bSize; ++j)
        {
            xcorrResult[xcorrId] += b[j] * a[xcorrId - (bSize - 1) + j];
        }
    }
    
    // From 0 ~ bSize-2
    for (int xcorrId = 0; xcorrId < bSize - 1; ++xcorrId)
    {
        xcorrResult[xcorrId] = 0;
        for (int j = bSize - 1 - xcorrId; j < bSize; ++j)
        {
            xcorrResult[xcorrId] += b[j] * a[xcorrId - ((bSize - 1) - j)];
        }
    }
    
    // From aSize ~ aSize+bSize-2
    for (int xcorrId = aSize; xcorrId < aSize + bSize - 1; ++xcorrId)
    {
        xcorrResult[xcorrId] = 0;
        for (int j = 0; j < aSize + bSize - 1 - xcorrId; ++j)
        {
            xcorrResult[xcorrId] += b[j] * a[xcorrId - (bSize - 1) + j];
        }
    }
}

void Decoder::FindSyncPeak(INT32* maxOrigIndex, INT32* minOrigIndex)
{
    INT32 maxXcorrIndex;
    INT32 minXcorrIndex;
    
    INT32 maxValue;
    INT32 minValue;
    
    XcorrSync(xcorrSync, binRecordBuf, syncSymbols, recordBufSize, syncSymbolPoints);
    
    maxValue = xcorrSync[0];
    minValue = xcorrSync[0];
    
    for (int i = 1; i < xcorrSyncArrayLength; ++i)
    {
        if (xcorrSync[i] > maxValue)
        {
            maxValue = xcorrSync[i];
            maxXcorrIndex = i;
        }
        if (xcorrSync[i] < minValue)
        {
            minValue = xcorrSync[i];
            minXcorrIndex = i;
        }
        
    }
    
    // Relationship of a point in original buf and xcorr buf
    *maxOrigIndex = maxXcorrIndex - (syncSymbolPoints - 1);
    *minOrigIndex = minXcorrIndex - (syncSymbolPoints - 1);
}

void Decoder::CalcXcorrSymbols(INT16* recordBuf, INT32 syncPeakLocation)
{
    XcorrSymbol(xcorrSymbol00, &recordBuf[syncPeakLocation], symbol00Template, infoPoints, nPointsPerSymbol);
    XcorrSymbol(xcorrSymbol01, &recordBuf[syncPeakLocation], symbol01Template, infoPoints, nPointsPerSymbol);
    XcorrSymbol(xcorrSymbol10, &recordBuf[syncPeakLocation], symbol10Template, infoPoints, nPointsPerSymbol);
    XcorrSymbol(xcorrSymbol11, &recordBuf[syncPeakLocation], symbol11Template, infoPoints, nPointsPerSymbol);
    
}

void Decoder::ReverseArrays(INT16* recordBuf)
{
    
    for (int i = 0; i < recordBufSize; ++i)
    {
        recordBuf[i] = -recordBuf[i];
    }
    
}

// Return   -1: Synchronization peak location is too late
//          1:  Decode Error
INT32 Decoder::Decode(INT16* recordBuf, INT16* temperature, char* logBuf)
{
    int ret;
    INT32 maxSyncPeakLocation;
    INT32 minSyncPeakLocation;
    
    // Preprocess
    PreProcess(recordBuf, recordBufSize);
    
    // Normalize recordBuf
    NormalizeRecordBuf(recordBuf);
    
    // Find the synchronizaton peak
    // Return the location in the recordBuf that corresponding to the xcorr peak
    FindSyncPeak(&maxSyncPeakLocation, &minSyncPeakLocation);
    
    ret = XcorrDecode(temperature, recordBuf, maxSyncPeakLocation);
    
    // Decode successully as CTIA standard
    if (ret == 0)
    {
        if (msgBufSize >= 16)
            strcpy(logBuf, "CTIA");
        return 0;
    }
    
    // Reverse arrays to avoid calcuate the Xcorr again
    ReverseArrays(recordBuf);
    
    ret = XcorrDecode(temperature, recordBuf, minSyncPeakLocation);
    
    // Decode successully as OMTP standard
    if (ret == 0)
    {
        if (msgBufSize >= 16)
            strcpy(logBuf, "OMTP");
        return 0;
    }
    
    // Sorry, decode failed
    if (msgBufSize >= 16)
        strcpy(logBuf, "Decode failed!");
    
    return ret;
    
}   


INT32   Decoder::Decode(INT16 (&recordBuf)[RECORD_BUF_SIZE], INT16 &temperature, char (&logBuf)[MSG_BUF_SIZE])
{
    return Decode(recordBuf, &temperature, logBuf);
}


     
    

