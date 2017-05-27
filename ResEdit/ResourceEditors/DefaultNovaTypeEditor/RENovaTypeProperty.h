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

typedef NS_ENUM(NSInteger, EVNovaTypeDataType) {
    EVNovaTypeDataType_NumberMask = 1 << 10,
    EVNovaTypeDataType_StringMask = 1 << 11,
    EVNovaTypeDataType_ColorMask = 1 << 12,
    EVNovaTypeDataType_HexMask = 1 << 13,
    EVNovaTypeDataType_RectMask = 1 << 14,
    EVNovaTypeDataType_PointMask = 1 << 15,
    
    EVNovaTypeDataType_DBYT = 0 | EVNovaTypeDataType_NumberMask,
    EVNovaTypeDataType_DWRD = 1 | EVNovaTypeDataType_NumberMask,
    EVNovaTypeDataType_DLNG = 2 | EVNovaTypeDataType_NumberMask,
    
    EVNovaTypeDataType_HBYT = 0 | EVNovaTypeDataType_HexMask,
    EVNovaTypeDataType_HWRD = 1 | EVNovaTypeDataType_HexMask,
    EVNovaTypeDataType_HLNG = 2 | EVNovaTypeDataType_HexMask,
    
    EVNovaTypeDataType_Color = EVNovaTypeDataType_ColorMask,
    EVNovaTypeDataType_Rect = EVNovaTypeDataType_RectMask,
    EVNovaTypeDataType_Point = EVNovaTypeDataType_PointMask,
    EVNovaTypeDataType_String = EVNovaTypeDataType_StringMask,
};

@interface RENovaTypeProperty : NSObject

@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, assign, readonly) EVNovaTypeDataType type;

+ (instancetype)withDisplayName:(NSString *)displayName forProperty:(NSString *)name ofType:(EVNovaTypeDataType)type;

@end
