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

- (int16_t)readWord
{
    return _data.readWord;
}

- (int32_t)readDwrd
{
    return _data.readDWord;
}


@end
