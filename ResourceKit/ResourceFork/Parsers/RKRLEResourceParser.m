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

#import "RKRLEResourceParser.h"
#import "RKRLESprite.h"
#import "RKRLEObject.h"
#import "RKResource.h"
#import "NSData+Parsing.h"


typedef NS_ENUM(NSUInteger, RLEOpCode)
{
    RLEOpCode_EndOfFrame = 0x00,
    RLEOpCode_LineStart = 0x01,
    RLEOpCode_PixelData = 0x02,
    RLEOpCode_TransparentRun = 0x03,
    RLEOpCode_PixelRun = 0x04,
};


@implementation RKRLEResourceParser {
@private
    __strong NSMutableArray <RKRLESprite *> *_sprites;
    __strong NSData * _data;
    
    CGSize _size;
    uint16_t _bytesPerPixel;
    uint16_t _numberOfFrames;
    uint32_t _bytesPerRow;
}

#pragma mark - Auto-Loading

+ (void)register
{
    // Register the parser in the resource class. This will allow the resource
    // to lookup an appropriate parser when required.
    [RKResource registerParser:self forType:@"RLËD"];
    [RKResource registerParser:self forType:@"rlëD"];
}


#pragma mark - Top Level

+ (id)parseData:(NSData *)data
{
    RKRLEResourceParser *parser = [[self alloc] initWithData:data];
    return parser ? [RKRLEObject.alloc initWithSprites:parser->_sprites ofSize:parser->_size] : nil;
}


#pragma mark - Internal Instantiation

- (instancetype)initWithData:(NSData *)data
{
    if (self = [super init]) {
        _data = data.copy;
        _sprites = NSMutableArray.new;
        if (![self parse]) {
            return nil;
        }
    }
    return self;
}


#pragma mark - Data Reading

- (BOOL)parse
{
    if (![self parsePreamble]) {
        NSLog(@"Failed to parse the preamble for the RLËD. Aborting");
        return NO;
    }
    
    [self prepareBlankSprites];
    
    if (![self parseSpriteFrames]) {
        NSLog(@"Failed to parse the sprite frame for the RLËD. Aborting");
        return NO;
    }
    
    return YES;
}

- (BOOL)parsePreamble
{
    // The first part of the RLË resource is the preamble or header. This begins
    // with the dimensions of the sprite.
    _size = CGSizeMake(_data.readWord, _data.readWord);
    
    // Following the dimensions is the number of bytes per pixel.
    _bytesPerPixel = _data.readWord;
    
    // There are then two bytes which appear to be unused.
    _data.position += 2;
    
    // Followed by the number of frames
    _numberOfFrames = _data.readWord;
    
    // And again there seems to be another run of 6 unused bytes.
    _data.position += 6;
    
    // We're going to assume a colour depth of 16. Anything else will trigger an error.
    if (_bytesPerPixel != 16) {
        NSLog(@"Invalid colour depth in RLËD resource.");
        return NO;
    }
    
    _bytesPerRow = _size.width * 3;
    
    return YES;
}

- (void)prepareBlankSprites
{
    uint32_t transparentColor = 0x00000000; // AARRGGBB
    for (NSUInteger i = 0; i < _numberOfFrames; ++i) {
        [_sprites addObject:[RKRLESprite.alloc initWithSize:_size transparentColor:transparentColor]];
    }
}

- (BOOL)parseSpriteFrames
{
    NSUInteger position = _data.position;
    uint32_t rowStart = 0;
    int32_t currentLine = -1;
    int32_t currentOffset = 0;
    int8_t opcode = 0;
    int32_t count = 0;
    uint16_t pixel = 0;
    int32_t currentFrame = 0;
    uint32_t pixelRun = 0;
    
    RKRLESprite *sprite = _sprites.firstObject;
    
    // Loop forever! The RLËD resource will contain an opcode that tells us where the end of the
    // resource is located.
    for (;;) {
        if ((position = _data.position) >= _data.length) {
            NSLog(@"Early End-of-Resource encountered in RLËD");
            return NO;
        }
        
        if ((rowStart != 0) && ((position - rowStart) & 0x03)) {
            position += 4 - ((position - rowStart) & 0x03);
            _data.position += 4 - (count & 0x03);
        }
        
        count = _data.readDWord;
        opcode = (count & 0xFF000000) >> 24;
        count &= 0x00FFFFFF;
        
        switch (opcode) {
            case RLEOpCode_EndOfFrame: {
                if (currentLine != _size.height - 1) {
                    NSLog(@"Incorrect number of scanlines in RLËD resource.");
                    return NO;
                }
                [sprite render];
                if (++currentFrame >= _numberOfFrames) {
                    // Finished parsing everything successfully.
                    return YES;
                }
                sprite = _sprites[currentFrame];
                currentLine = -1;
                break;
            }
            
            case RLEOpCode_LineStart: {
                ++currentLine;
                currentOffset = currentLine * _bytesPerRow;
                rowStart = (uint32_t)_data.position;
                break;
            }
                
            case RLEOpCode_PixelData: {
                for (uint32_t i = 0; i < count; i+=2) {
                    pixel = _data.readWord;
                    [sprite writePixelDataDepth16:pixel withMask:0xFF atOffset:currentOffset];
                    currentOffset += 3;
                }
                
                if (count & 0x03) {
                    position += 4 - (count & 0x03);
                    _data.position += 4 - (count & 0x03);
                }
                break;
            }
                
            case RLEOpCode_TransparentRun: {
                currentOffset += (count >> ((_bytesPerPixel >> 3) - 1)) * 3;
                break;
            }
                
            case RLEOpCode_PixelRun: {
                pixelRun = _data.readDWord;
                for (uint32_t i = 0; i < count; i+=4) {
                    [sprite writePixelRunDepth16Variant1:pixel withMask:0xFF atOffset:currentOffset];
                    currentOffset += 3;
                    
                    if (i + 2 < count) {
                        [sprite writePixelRunDepth16Variant2:pixel withMask:0xFF atOffset:currentOffset];
                        currentOffset += 3;
                    }
                }
                break;
            }
                
            default: {
                NSLog(@"Invalid opcode encountered in RLËD resource.");
                return NO;
            }
        }
    }
    
    // Unreachable...
    return NO;
}

@end
