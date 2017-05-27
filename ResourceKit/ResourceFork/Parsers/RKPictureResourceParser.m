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

#import "RKPictureResourceParser.h"
#import "RKResource.h"
#import "NSData+Parsing.h"
#import "RKPackBitsDecoder.h"
#import <Cocoa/Cocoa.h>

#pragma mark - Support

typedef NS_ENUM(uint16_t, RKPictureOpcode)
{
    RKPictureOpcode_nop = 0x0000,
    RKPictureOpcode_clipRegion = 0x0001,
    RKPictureOpcode_directBitsRect = 0x009A,
    RKPictureOpcode_eof = 0x00FF,
    RKPictureOpcode_defHilite = 0x001E,
    RKPictureOpcode_longComment = 0x00A1,
    RKPictureOpcode_extHeader = 0x0C00,
};

typedef struct
{
    int16_t x;
    int16_t y;
    int16_t width;
    int16_t height;
} RKPictRect;

static inline RKPictRect RKPictRectFromMacRect(RKMacRect r)
{
    return (RKPictRect) {
        .x = r.x1,
        .y = r.y1,
        .width = r.x2 - r.x1,
        .height = r.y2 - r.y1,
    };
};

typedef struct {
    uint32_t baseAddress;
    uint16_t rowBytes;
    RKPictRect bounds;
    uint16_t pmVersion;
    uint16_t packType;
    uint32_t packSize;
    uint32_t hRes;
    uint32_t vRes;
    uint16_t pixelType;
    uint16_t pixelSize;
    uint16_t cmpCount;
    uint16_t cmpSize;
    uint32_t planeBytes;
    uint32_t pmTable;
    uint32_t pmReserved;
} RKPictPixMap;



@implementation RKPictureResourceParser {
@private
    __strong NSImage *_currentImage;
    __strong NSData * _data;
    RKMacRect _frame;
    RKPictRect _regionRect;
    double _xRatio;
    double _yRatio;
}

#pragma mark - Auto-Loading

+ (void)register
{
    // Register the parser in the resource class. This will allow the resource
    // to lookup an appropriate parser when required.
    [RKResource registerParser:self forType:@"PICT"];
}


#pragma mark - Top Level

+ (id)parseData:(NSData *)data
{
    RKPictureResourceParser *parser = [[self alloc] initWithData:data];
    return parser ? parser->_currentImage : nil;
}


#pragma mark - Internal Instantiation

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _data = data.copy;
        if (![self parse]) {
            return nil;
        }
    }
    return self;
}


#pragma mark - Data Reading

- (RKPictureOpcode)readOpcode
{
    _data.position += _data.position % sizeof(uint16_t);
    return _data.readWord;
}

- (BOOL)parse
{
    // PICT was a format back in the classic era and was designed under a big endian
    // system and architecture. Therefore all the data in the format is stored as such.
    // Ensure the data we read it as little endian.
    _data.endianType = RKDataEndianType_Little;
    
    // The first 2 bytes appear to be unused so skip them.
    _data.position += 2;
    
    // The first part of the PICT is the frame.
    _frame = _data.readMacRect;
    
    // The next 4 bytes are the version denotion of the PICT. We're only interested in
    // version 2.
    if (_data.readDWord != 0x001102ff) {
        NSLog(@"Picture resource is not version 2. Aborting parse.");
        return NO;
    }
    
    // Ensure we have an extended header here.
    uint16_t opcode = self.readOpcode;
    if (opcode != RKPictureOpcode_extHeader) {
        NSLog(@"Expected an extended header in the picture resource. Aborting parse.");
        return NO;
    }
    
    // The next value is the header version. PICT version 2 has two variants that need to
    // be handled for EV Nova. Annoyingly it seems to use both in its data files. Not sure
    // how that happened?
    uint32_t headerVersion = _data.readDWord;
    if ((headerVersion & 0xFFFF0000) != 0xfffe0000) {
        // Standard Header Version
        
        // Determine the image resolution.
        double y2 = _data.readFixedPoint;
        double x2 = _data.readFixedPoint;
        double w2 = _data.readFixedPoint;
        double h2 = _data.readFixedPoint;
        
        _xRatio = (RKMacRectGetWidth(_frame) / (w2 - x2));
        _yRatio = (RKMacRectGetHeight(_frame) / (h2 - y2));
    }
    else {
        // Extended Header Version
        
        _data.position += sizeof(uint32_t) * 2;

        RKMacRect rect = _data.readMacRect;
        
        _xRatio = (RKMacRectGetWidth(_frame) / RKMacRectGetWidth(rect));
        _yRatio = (RKMacRectGetHeight(_frame) / RKMacRectGetHeight(rect));
    }
    
    // Ensure the ratio of the image is a valid one. We don't really seem to ever
    // use this ratio or need it, but it serves as a good verification that the
    // picture is valid.
    if (_xRatio <= 0 || _yRatio <= 0) {
        NSLog(@"Invalid ratio in picture. Aborting parse.");
        return NO;
    }
    
    // The final 4 bytes of the header also appear to be unused.
    _data.position += 4;
    
    // We're now at a point of parsing out the main picture body. PICT does this in a
    // slightly strange way. It uses "opcodes" and a series of instructions on how to
    // produce the picture. There are a lot of these in the PICT specification, and
    // from what I have been able to determine the vast majority are unused by EV Nova.
    RKPictureOpcode op;
    
    while (_data.position < _data.length && (op = self.readOpcode) != RKPictureOpcode_eof) {
        switch (op) {
            case RKPictureOpcode_clipRegion:
                [self readRegionWithRect:&_regionRect];
                break;
                
            case RKPictureOpcode_directBitsRect:
                [self parseDirectBitsRect];
                break;
                
            case RKPictureOpcode_longComment:
                [self parseLongComment];
                break;
                
            case RKPictureOpcode_nop:
            case RKPictureOpcode_extHeader:
            case RKPictureOpcode_defHilite:
                break;
                
            default:
                NSLog(@"Encountered an unhandled opcode: %04x", op);
                return NO;
        }
    }
    
    return YES;
}


#pragma mark - Helpers

- (void)readRegionWithRect:(RKPictRect *)rect
{
    NSAssert(rect, @"Picture regions require that a RKPICTRect structure be supplied.");
    uint16_t size = _data.readWord;
    
    // Read the ratio correct rect for the region
    rect->x = ((uint16_t)_data.readWord / _xRatio);
    rect->y = ((uint16_t)_data.readWord / _yRatio);
    rect->width = ((uint16_t)_data.readWord / _xRatio) - rect->x;
    rect->height = ((uint16_t)_data.readWord / _yRatio) - rect->y;
    
    uint32_t points = (size - 10) / 4;
    _data.position += (sizeof(uint16_t) * 2 * points);
}

- (RKPictPixMap *)parsePixMap
{
    RKPictPixMap *px = calloc(1, sizeof(*px));
    px->baseAddress = _data.readDWord;
    
    uint16_t rowBytesRaw = _data.readWord;
    px->rowBytes = rowBytesRaw & 0x7FFF;
    
    px->bounds = RKPictRectFromMacRect(_data.readMacRect);
    
    px->pmVersion = _data.readWord;
    px->packType = _data.readWord;
    px->packSize = _data.readDWord;
    
    px->hRes = _data.readFixedPoint;
    px->vRes = _data.readFixedPoint;
    
    px->pixelType = _data.readWord;
    px->pixelSize = _data.readWord;
    px->cmpCount = _data.readWord;
    px->cmpSize = _data.readWord;
    
    px->planeBytes = _data.readDWord;
    px->pmTable = _data.readDWord;
    px->pmReserved = _data.readDWord;
    return px;
}

- (void)parseDirectBitsRect
{
    RKPictPixMap *px = self.parsePixMap;
    RKPictRect sourceRect = RKPictRectFromMacRect(_data.readMacRect);
    RKPictRect destinationRect = RKPictRectFromMacRect(_data.readMacRect);
    
    // The next 2 bytes represent the "mode" for the direct bits packing. However
    // this doesn't seem to be required with the images included in EV Nova.
    _data.position += 2;
    
    // Ensure the packing type is the correct value. We're only interested in pack
    // type 3 and 4.
    if (!(px->packType == 3 || px->packType == 4)) {
        NSLog(@"Unsupported pack type: %d", px->packType);
        abort();
    }
    
    uint8_t *raw = NULL;
    uint16_t *pxShortArray = NULL;
    uint32_t *pxArray = NULL;
    
    if (px->packType == 3) {
        raw = calloc(px->rowBytes, sizeof(*raw));
        pxShortArray = calloc(sourceRect.height * (px->rowBytes + 1) / 2, sizeof(*pxShortArray));
    }
    else if (px->packType == 4) {
        raw = calloc(px->cmpCount * px->rowBytes / 4, sizeof(*raw));
        pxArray = calloc(sourceRect.height * (px->rowBytes + 3) / 4, sizeof(*pxArray));
    }
    
    
    uint32_t pxBufOffset = 0;
    uint16_t packedBytesCount = 0;
    
    for (uint32_t scanline = 0; scanline < sourceRect.height; ++scanline) {
        
        // Narrow pictures don't use the pack bits compression. Not certain what the deciding factor
        // for such a thing is, but low numbers of rowBytes seem to be the cause. Setting this to the
        // highest value found that doesn't have compression.
        if (px->rowBytes <= 4) { // No PackBits Compression
            [[_data readDataOfLength:px->rowBytes] getBytes:raw length:sourceRect.width * 2];
        }
        else { // Pack Bits Compression
            packedBytesCount = px->rowBytes > 250 ? _data.readWord : _data.readByte;
            
            // Read a single scanline from the data. This will need to be decoded.
            NSData *encodedScanline = [_data readDataOfLength:packedBytesCount];
            if (px->packType == 3) {
                NSData *decodedScanline = [RKPackBitsDecoder decodeData:encodedScanline withValueSize:sizeof(uint16_t)];
                [decodedScanline getBytes:raw length:sourceRect.width * 2];
            }
            else {
                NSData *decodedScanline = [RKPackBitsDecoder decodeData:encodedScanline withValueSize:1];
                [decodedScanline getBytes:raw length:sourceRect.width * 2];
            }
        }
        
        if (px->packType == 3) {
            // Store the decoded pixel data.
            for (uint32_t i = 0; i < sourceRect.width; ++i) {
                pxShortArray[pxBufOffset + i] = (uint16_t)(((0xFF & raw[2*i]) << 8) | (0xFF & raw[2*i+1]));
            }
        }
        else {
            if (px->cmpCount == 3) {
                // RGB Data
                for (int32_t i = 0; i < sourceRect.width; ++i) {
                    pxArray[pxBufOffset + i] = 0xFF000000
                    | (raw[i] & 0xFF) << 16
                    | (raw[px->bounds.width + i] & 0xFF) << 8
                    | (raw[2 * px->bounds.width + i] & 0xFF);
                }
            }
            else {
                // ARGB Data
                for (int32_t i = 0; i < sourceRect.width; ++i) {
                    pxArray[pxBufOffset + i] =
                    (raw[i] & 0xFF) << 24
                    | (raw[px->bounds.width + i] & 0xFF) << 16
                    | (raw[2 * px->bounds.width + i] & 0xFF) << 8
                    | (raw[3 * px->bounds.width + i] & 0xFF);
                }
            }
        }
        
        
        pxBufOffset += sourceRect.width;
    }
    
    // Finally we need to unpack all of the pixel data. This is due to the pixels being
    // stored in an RGB 555 format. CoreGraphics does not expose a way of cleanly/publically
    // parsing this type of encoding so we need to convert it to a more modern
    // representation, such as RGBA 8888
    uint32_t sourceLength = destinationRect.width * destinationRect.height;
    uint32_t rgbCount = sourceLength * 4;
    uint8_t *rgbRaw = calloc(rgbCount, sizeof(*rgbRaw));
    
    if (px->packType == 3) {
        for (uint32_t p = 0, i = 0; i < sourceLength; ++i) {
            rgbRaw[p++] = ((pxShortArray[i] & 0x7c00) >> 10) << 3;
            rgbRaw[p++] = ((pxShortArray[i] & 0x03e0) >> 5) << 3;
            rgbRaw[p++] = ((pxShortArray[i] & 0x001f) << 3);
            rgbRaw[p++] = UINT8_MAX;
        }
    }
    else {
        for (uint32_t p = 0, i = 0; i < sourceLength; ++i) {
            rgbRaw[p++] = (pxArray[i] & 0xFF0000) >> 16;
            rgbRaw[p++] = (pxArray[i] & 0xFF00) >> 8;
            rgbRaw[p++] = (pxArray[i] & 0xFF);
            rgbRaw[p++] = (pxArray[i] & 0xFF000000) >> 24;
        }
    }
    
    
    CGImageRef image = [self cgImageWithRGBData:rgbRaw frame:destinationRect];
    _currentImage = [[NSImage alloc] initWithCGImage:image size:CGSizeMake(destinationRect.width, destinationRect.height)];
    
    // Clean up memory
    CGImageRelease(image);
    free(pxArray);
    free(pxShortArray);
    free(rgbRaw);
    free(raw);
    free(px);
}


- (void)parseLongComment
{
    int16_t kind __unused = _data.readWord;
    int16_t length = _data.readWord;
    
    _data.position += length;
}


#pragma mark - Image Construction

- (CGImageRef)cgImageWithRGBData:(uint8_t *)rgb frame:(RKPictRect)frame
{
    const size_t componentsPerPixel = 4;
    const size_t bitsPerComponent = 8;
    const size_t bytesPerRow = ((bitsPerComponent * frame.width) / 8) * componentsPerPixel;
    
    CGColorSpaceRef colorSpace = colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(rgb, frame.width, frame.height, bitsPerComponent, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGImageRef image = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    return image;
}


@end
