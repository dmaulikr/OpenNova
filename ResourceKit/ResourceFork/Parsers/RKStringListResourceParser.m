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

#import "RKStringListResourceParser.h"
#import "RKResource.h"
#import "NSData+Parsing.h"

@implementation RKStringListResourceParser {
@private
    __strong NSMutableArray <NSString *> *_strings;
    __strong NSData * _data;
}

#pragma mark - Auto-Loading

+ (void)register
{
    // Register the parser in the resource class. This will allow the resource
    // to lookup an appropriate parser when required.
    [RKResource registerParser:self forType:@"STR#"];
}


#pragma mark - Top Level

+ (id)parseData:(NSData *)data
{
    RKStringListResourceParser *parser = [[self alloc] initWithData:data];
    return parser ? parser->_strings : nil;
}


#pragma mark - Internal Instantiation

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _data = data.copy;
        _strings = NSMutableArray.new;
        if (![self parse]) {
            return nil;
        }
    }
    return self;
}


#pragma mark - Data Reading

- (BOOL)parse
{
    uint16_t stringCount = _data.readWord;
    for (; stringCount > 0; --stringCount) {
        [_strings addObject:_data.readPString];
    }
    return YES;
}

@end
