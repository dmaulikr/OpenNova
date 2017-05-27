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

#import <Foundation/Foundation.h>

@interface RKRLESprite : NSObject

@property (atomic, assign, readonly) CGSize size;
@property (atomic, assign, readonly) uint32_t transparentColor;
@property (atomic, assign, readonly) CGImageRef imageValue;

- (instancetype)initWithSize:(CGSize)size transparentColor:(uint32_t)transparentColor;

- (void)writePixelDataDepth8:(uint8_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset;
- (void)writePixelDataDepth16:(uint16_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset;
- (void)writePixelRunDepth8:(uint8_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset;
- (void)writePixelRunDepth16Variant1:(uint32_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset;
- (void)writePixelRunDepth16Variant2:(uint32_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset;

- (void)render;


@end
