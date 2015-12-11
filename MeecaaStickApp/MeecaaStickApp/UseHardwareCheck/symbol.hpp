//
//  symbol.hpp
//  TestCPPFile
//
//  Created by SoulJa on 15/10/23.
//  Copyright © 2015年 SoulJa. All rights reserved.
//

#ifndef symbol_hpp
#define symbol_hpp

#include <stdio.h>
#include "decoder_def.h"

class Symbol
{
public:
    Symbol()
    {
        preDecodedValue     = -1;
        curDecodedValue     = -1;
        preSecondDecodedValue = -1;
        curSecondDecodedValue = -1;
        flag                = -1;
        judgeDecodeLocation = -1;
        judgeXcorrLocation  = -1;
        clkSkew             = -1;
        secondMaxToMaxRate  = -1;
        potentialError      = -1;
        
    }
    
    ~Symbol()
    {
        
        
    }
    
public:
    char    preDecodedValue;
    char    curDecodedValue;
    char    preSecondDecodedValue;
    char    curSecondDecodedValue;
    char    flag;
    INT32   judgeDecodeLocation;
    INT32   judgeXcorrLocation;
    INT32   clkSkew;
    double  secondMaxToMaxRate;
    char    potentialError;
};

#endif
