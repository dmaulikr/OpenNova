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

#import <Foundation/Foundation.h>
#import "ClassicMacTypes.h"

typedef NS_ENUM(NSUInteger, RKDataEndianType)
{
    RKDataEndianType_Little,
    RKDataEndianType_Big
};

@interface NSData (Parsing)

/// The endian encoding of the receiver data
@property (assign) RKDataEndianType endianType;

/// The current 'cursor' position inside the data
@property (assign) NSUInteger position;

/// Reads a single byte from the current position in the data. This will increment
/// of the position of the data accordingly.
- (uint8_t)readByte;

/// Reads a single word from the current position in the data. This will increment
/// of the position of the data accordingly.
- (uint16_t)readWord;

/// Reads a double word from the current position in the data. This will increment
/// of the position of the data accordingly.
- (uint32_t)readDWord;

/// Reads a double from the current position in the data. This will increment the
/// position of the data accordingly.
- (double)readFixedPoint;

/// Reads a single Macintosh Rectangle from the current position in the data. This
/// will increment the position of the data accordingly.
- (RKMacRect)readMacRect;
- (RKMacRect)readQuickDrawRect;

/// Reads a stream of bytes from the receiver and returns a new data instance. This
/// will increment the position of the data accordingly.
- (NSData *)readDataOfLength:(uint32_t)length;

@end
