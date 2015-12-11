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
#include "symbol.hpp"
#include "stdio.h"
#include "decoder_def.h"


     
    

