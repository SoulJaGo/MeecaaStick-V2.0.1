//--------------------------------------------------------------------------------------------------
// (c)2015 Meecaa Corporation. All rights reserved.
// Author: Hank Yue
// 2015.10.21

#ifndef __DECODER_DEF_H__
#define __DECODER_DEF_H__

#define FS  44100
#define RECORD_BUF_SIZE 32768
#define MSG_BUF_SIZE 16

typedef int   INT32;
typedef short int   INT16;   

// Mask this line to prevent GCC compile warning
//#define NULL				0

#define SAFE_DELETE(p)       {if (p) {delete   (p); (p) = NULL;}}
#define SAFE_DELETE_ARRAY(p) {if (p) {delete[] (p); (p) = NULL;}}

#endif
