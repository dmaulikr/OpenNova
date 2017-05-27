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

#import "EVObject.h"

@interface EVColrObject : NSObject <EVObject>

@property (atomic, assign) __attribute__((NSObject)) CGColorRef buttonUpColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef buttonDownColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef buttonGreyColor;
@property (atomic, strong) NSString *menuFontName;
@property (atomic, assign) int16_t menuFontSize;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef menuColor1;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef menuColor2;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef gridBright;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef gridDim;
@property (atomic, assign) CGRect progressBarFrame;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef progressBrightColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef progressDimColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef progressOutlineColor;
@property (atomic, assign) CGPoint menuButton1Origin;
@property (atomic, assign) CGPoint menuButton2Origin;
@property (atomic, assign) CGPoint menuButton3Origin;
@property (atomic, assign) CGPoint menuButton4Origin;
@property (atomic, assign) CGPoint menuButton5Origin;
@property (atomic, assign) CGPoint menuButton6Origin;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef floatingMapColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef listTextColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef listBackgroundColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef listHiliteColor;
@property (atomic, assign) __attribute__((NSObject)) CGColorRef escortHiliteColor;
@property (atomic, strong) NSString *buttonFontName;
@property (atomic, assign) int16_t buttonFontSize;
@property (atomic, assign) CGPoint logoOrigin;
@property (atomic, assign) CGPoint rolloverOrigin;
@property (atomic, assign) CGPoint slide1Origin;
@property (atomic, assign) CGPoint slide2Origin;
@property (atomic, assign) CGPoint slide3Origin;

@end
