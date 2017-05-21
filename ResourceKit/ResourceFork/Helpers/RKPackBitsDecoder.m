//
// MIT License
//
// Copyright (c) 2016 Tom Hancocks
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "RKPackBitsDecoder.h"

@implementation RKPackBitsDecoder

+ (NSData *)decodeData:(NSData *)packedData withValueSize:(uint32_t)valueSize
{
    NSMutableData *result = [NSMutableData data];
    NSUInteger pos = 0;
    
    while (pos < packedData.length) {
        uint8_t count;
        [packedData getBytes:&count range:NSMakeRange(pos++, sizeof(count))];
        
        if (count >= 0 && count < 128) {
            uint16_t run = (1 + count) * valueSize;
            [result appendData:[packedData subdataWithRange:NSMakeRange(pos, run)]];
            pos += run;
        }
        else if (count >= 128) {
            uint8_t run = 256 - count + 1;
            uint32_t val;
            [packedData getBytes:&val range:NSMakeRange(pos, valueSize)];
            pos += valueSize;
            for (uint8_t i = 0; i < run; i++) {
                [result appendBytes:&val length:valueSize];
            }
        }
        else {
            // no operation
        }
    }
    
    return result;
}

@end
