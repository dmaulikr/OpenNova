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

#import "RKRLESprite.h"

@interface RKRLESprite ()
@property (nonatomic, assign) uint8_t *data;
@property (nonatomic, assign) uint8_t *mask;
@property (nonatomic, assign) uint8_t *rgbRaw;
@end


@implementation RKRLESprite

- (instancetype)initWithSize:(CGSize)size transparentColor:(uint32_t)transparentColor
{
    if (self = [super init]) {
        self->_size = size;
        self->_transparentColor = transparentColor;
        
        [self prepare];
    }
    return self;
}

- (void)dealloc
{
    free(self.data);
    free(self.mask);
    free(self.rgbRaw);
    CGImageRelease(self->_imageValue);
}

#pragma mark - Setup

- (void)prepare
{
    size_t size = self.size.width * self.size.height * 3;
    
    self.data = malloc(size);
    self.mask = malloc(size);
    
    for (NSUInteger i = 0; i < (size / 3); ++i) {
        self.data[3 * i] = self.transparentColor & 0xff;
        self.data[3 * i + 1] = (self.transparentColor >> 8) & 0xff;
        self.data[3 * i + 2] = (self.transparentColor >> 16) & 0xff;
        
        self.mask[3 * i] = 0x00;
        self.mask[3 * i + 1] = 0x00;
        self.mask[3 * i + 2] = 0x00;
    }
}

#pragma mark - Construction

- (void)writePixelDataDepth8:(uint8_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset
{
    self.data[offset] = pixel;
    self.data[offset + 1] = pixel;
    self.data[offset + 2] = pixel;
    
    self.mask[offset] = mask;
    self.mask[offset + 1] = mask;
    self.mask[offset + 2] = mask;
}

- (void)writePixelDataDepth16:(uint16_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset
{
    self.data[offset] = (pixel & 0x001F) << 3;
    self.data[offset + 1] = (pixel & 0x03E0) >> 2;
    self.data[offset + 2] = (pixel & 0x7C00) >> 7;
    
    self.mask[offset] = mask;
    self.mask[offset + 1] = mask;
    self.mask[offset + 2] = mask;
}

- (void)writePixelRunDepth8:(uint8_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset
{
    [self writePixelDataDepth8:pixel withMask:mask atOffset:offset];
}

- (void)writePixelRunDepth16Variant1:(uint32_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset
{
    self.data[offset] = (pixel & 0x001F0000) << 13;
    self.data[offset + 1] = (pixel & 0x03E00000) >> 18;
    self.data[offset + 2] = (pixel & 0x7C000000) >> 23;
    
    self.mask[offset] = mask;
    self.mask[offset + 1] = mask;
    self.mask[offset + 2] = mask;
}

- (void)writePixelRunDepth16Variant2:(uint32_t)pixel withMask:(uint8_t)mask atOffset:(uint32_t)offset
{
    self.data[offset] = (pixel & 0x0000001F) << 3;
    self.data[offset + 1] = (pixel & 0x000003E0) >> 2;
    self.data[offset + 2] = (pixel & 0x00007C00) >> 7;
    
    self.mask[offset] = mask;
    self.mask[offset + 1] = mask;
    self.mask[offset + 2] = mask;
}


#pragma mark - Image Construction

- (void)render
{
    free(self.rgbRaw);
    
    size_t size = self.size.width * self.size.height * 4;
    size_t dataSize = self.size.width * self.size.height * 3;
    self.rgbRaw = malloc(size);
    
    for (NSUInteger i = 0, j = 0; i < dataSize; i+=3, j+=4) {
        self.rgbRaw[j+0] = self.data[i+2];
        self.rgbRaw[j+1] = self.data[i+1];
        self.rgbRaw[j+2] = self.data[i+0];
        self.rgbRaw[j+3] = (self.mask[i+0] + self.mask[i+1] + self.mask[i+2]) / 3;
    }
    
    [self constructCGImageWithRGBData:self.rgbRaw];
}

- (void)constructCGImageWithRGBData:(uint8_t *)rgb
{
    const size_t componentsPerPixel = 4;
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = ((bitsPerComponent * self.size.width) / 8) * componentsPerPixel;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(rgb, self.size.width, self.size.height, bitsPerComponent, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    self->_imageValue = CGBitmapContextCreateImage(ctx);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(ctx);
}

@end
