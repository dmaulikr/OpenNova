//
// MIT License
//
// Copyright (c) 2017 Tom Hancocks
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

#import "RKNovaResourceTypeParser.h"
#import "RKResource.h"
#import "NSData+Parsing.h"

@implementation RKNovaResourceTypeParser {
@private
    __strong NSData * _data;
}

+ (void)register {}

#pragma mark - Top Level

+ (id)parseData:(NSData *)data
{
    RKNovaResourceTypeParser *parser = [[self alloc] initWithData:data];
    return parser ? parser.object : nil;
}


#pragma mark - Internal Instantiation

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _data = data.copy;
        [self setup];
        if (![self parse]) {
            return nil;
        }
    }
    return self;
}


#pragma mark - Data Reading

- (void)setup
{
    // Empty implementation - here for the subclasses
}

- (BOOL)parse
{
    NSAssert(NO, @"This needs to be implemented in a subclass");
    return NO;
}


#pragma mark - Nova Types

- (int8_t)readDecimalByte
{
    return _data.readByte;
}

- (int16_t)readDecimalWord
{
    return _data.readWord;
}

- (int32_t)readDecimalLong
{
    return _data.readDWord;
}


- (uint8_t)readHexByte
{
    return _data.readByte;
}

- (uint16_t)readHexWord
{
    return _data.readWord;
}

- (uint32_t)readHexLong
{
    return _data.readDWord;
}



- (CGColorRef)readColor
{
    uint8_t alpha __unused = _data.readByte;
    uint8_t red = _data.readByte;
    uint8_t green = _data.readByte;
    uint8_t blue = _data.readByte;
    return CGColorCreateGenericRGB((1.0 / 255.0) * red, (1.0 / 255.0) * green, (1.0 / 255.0) * blue, 1.0);
}

- (CGRect)readRect
{
    int16_t y = _data.readWord;
    int16_t x = _data.readWord;
    int16_t y2 = _data.readWord;
    int16_t x2 = _data.readWord;
    return CGRectMake(x, y, x2 - x, y2 - y);
}

- (CGPoint)readPoint
{
    return CGPointMake(_data.readWord, _data.readWord);
}

- (NSString *)readStringOfLength:(uint16_t)length
{
    return [[NSString alloc] initWithData:[_data readDataOfLength:length] encoding:NSMacOSRomanStringEncoding];
}

@end
