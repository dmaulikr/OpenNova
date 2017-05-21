//
//  NSData+Parsing.m
//  ResourceKit
//
//  Created by Hancocks, Thomas (Developer) on 30/01/2017.
//  Copyright © 2017 Tom Hancocks. All rights reserved.
//

#import "NSData+Parsing.h"
#import <objc/runtime.h>

static const void * RKDataPositionKey = &RKDataPositionKey;
static const void * RKDataEndianKey = &RKDataEndianKey;

#if defined(BIG_ENDIAN)
#   define READ_DATA(_type) \
        _type data = 0; \
        [self getBytes:&data range:NSMakeRange(self.position, sizeof(data))]; \
        self.position += sizeof(data); \
        if (sizeof(data) == 2 && self.endianType != RKDataEndianType_Big) { \
            data = OSSwapHostToBigInt16(data); \
        } else if (sizeof(data) == 4 && self.endianType != RKDataEndianType_Big) { \
            data = OSSwapHostToBigInt32(data); \
        }
#elif defined(LITTLE_ENDIAN)
#   define READ_DATA(_type) \
        _type data = 0; \
        [self getBytes:&data range:NSMakeRange(self.position, sizeof(data))]; \
        self.position += sizeof(data); \
        if (sizeof(data) == 2 && self.endianType == RKDataEndianType_Big) { \
            data = OSSwapHostToLittleInt16(data); \
        } else if (sizeof(data) == 4 && self.endianType == RKDataEndianType_Big) { \
            data = OSSwapHostToLittleInt32(data); \
        }
#endif

@implementation NSData (Parsing)

#pragma mark - Properties

- (NSUInteger)position
{
    NSNumber *value = objc_getAssociatedObject(self, RKDataPositionKey);
    return value.unsignedIntegerValue;
}

- (void)setPosition:(NSUInteger)position
{
    objc_setAssociatedObject(self, RKDataPositionKey, @(position), OBJC_ASSOCIATION_ASSIGN);
}

- (RKDataEndianType)endianType
{
    NSNumber *value = objc_getAssociatedObject(self, RKDataEndianKey);
    return value.integerValue;
}

- (void)setEndianType:(RKDataEndianType)endianType
{
    objc_setAssociatedObject(self, RKDataEndianKey, @(endianType), OBJC_ASSOCIATION_ASSIGN);
}


#pragma mark - Data

- (uint8_t)readByte
{
    READ_DATA(uint8_t);
    return data;
}

- (uint16_t)readWord
{
    READ_DATA(uint16_t);
    return data;
}

- (uint32_t)readDWord
{
    READ_DATA(uint32_t);
    return data;
}

- (double)readFixedPoint
{
    return self.readDWord / (double)(1 << 16);
}

- (RKMacRect)readMacRect
{
    return RKMacRectMake(self.readWord, self.readWord, self.readWord, self.readWord);
}

- (RKMacRect)readQuickDrawRect
{
    int16_t y1 = self.readWord;
    int16_t x1 = self.readWord;
    int16_t y2 = self.readWord;
    int16_t x2 = self.readWord;
    
    return (RKMacRect) {
        .x1 = x1,
        .y1 = y1,
        .x2 = x2 - x1,
        .y2 = y2 - y1,
    };
}

- (NSData *)readDataOfLength:(uint32_t)length
{
    NSData *data = [self subdataWithRange:NSMakeRange(self.position, length)];
    self.position += length;
    return data;
}




@end
