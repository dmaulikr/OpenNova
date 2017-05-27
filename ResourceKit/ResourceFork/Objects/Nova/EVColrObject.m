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

#import "EVColrObject.h"

@implementation EVColrObject

- (void)dealloc
{
    CGColorRelease(self.buttonUpColor);
    CGColorRelease(self.buttonDownColor);
    CGColorRelease(self.buttonGreyColor);
    CGColorRelease(self.menuColor1);
    CGColorRelease(self.menuColor2);
    CGColorRelease(self.gridBright);
    CGColorRelease(self.gridDim);
    CGColorRelease(self.progressBrightColor);
    CGColorRelease(self.progressDimColor);
    CGColorRelease(self.progressOutlineColor);
    CGColorRelease(self.floatingMapColor);
    CGColorRelease(self.listTextColor);
    CGColorRelease(self.listBackgroundColor);
    CGColorRelease(self.listHiliteColor);
    CGColorRelease(self.escortHiliteColor);
}

- (nullable id)valueForProperty:(nonnull NSString *)property
{
    if ([property isEqualToString:@"buttonUpColor"]) {
        return (__bridge id)self.buttonUpColor;
    }
    else if ([property isEqualToString:@"buttonDownColor"]) {
        return (__bridge id)self.buttonDownColor;
    }
    else if ([property isEqualToString:@"buttonGreyColor"]) {
        return (__bridge id)self.buttonGreyColor;
    }
    else if ([property isEqualToString:@"menuFontName"]) {
        return self.menuFontName;
    }
    else if ([property isEqualToString:@"menuFontSize"]) {
        return @(self.menuFontSize);
    }
    else if ([property isEqualToString:@"menuColor1"]) {
        return (__bridge id)self.menuColor1;
    }
    else if ([property isEqualToString:@"menuColor2"]) {
        return (__bridge id)self.menuColor2;
    }
    else if ([property isEqualToString:@"gridBright"]) {
        return (__bridge id)self.gridBright;
    }
    else if ([property isEqualToString:@"gridDim"]) {
        return (__bridge id)self.gridDim;
    }
    else if ([property isEqualToString:@"progressBarFrame"]) {
        return [NSValue valueWithRect:self.progressBarFrame];
    }
    else if ([property isEqualToString:@"progressBrightColor"]) {
        return (__bridge id)self.progressBrightColor;
    }
    else if ([property isEqualToString:@"progressDimColor"]) {
        return (__bridge id)self.progressDimColor;
    }
    else if ([property isEqualToString:@"progressOutlineColor"]) {
        return (__bridge id)self.progressOutlineColor;
    }
    else if ([property isEqualToString:@"menuButton1Origin"]) {
        return [NSValue valueWithPoint:self.menuButton1Origin];
    }
    else if ([property isEqualToString:@"menuButton2Origin"]) {
        return [NSValue valueWithPoint:self.menuButton2Origin];
    }
    else if ([property isEqualToString:@"menuButton3Origin"]) {
        return [NSValue valueWithPoint:self.menuButton3Origin];
    }
    else if ([property isEqualToString:@"menuButton4Origin"]) {
        return [NSValue valueWithPoint:self.menuButton4Origin];
    }
    else if ([property isEqualToString:@"menuButton5Origin"]) {
        return [NSValue valueWithPoint:self.menuButton5Origin];
    }
    else if ([property isEqualToString:@"menuButton6Origin"]) {
        return [NSValue valueWithPoint:self.menuButton6Origin];
    }
    else if ([property isEqualToString:@"floatingMapColor"]) {
        return (__bridge id)self.floatingMapColor;
    }
    else if ([property isEqualToString:@"listTextColor"]) {
        return (__bridge id)self.listTextColor;
    }
    else if ([property isEqualToString:@"listBackgroundColor"]) {
        return (__bridge id)self.listBackgroundColor;
    }
    else if ([property isEqualToString:@"listHiliteColor"]) {
        return (__bridge id)self.listHiliteColor;
    }
    else if ([property isEqualToString:@"escortHiliteColor"]) {
        return (__bridge id)self.escortHiliteColor;
    }
    else if ([property isEqualToString:@"buttonFontName"]) {
        return self.buttonFontName;
    }
    else if ([property isEqualToString:@"buttonFontSize"]) {
        return @(self.buttonFontSize);
    }
    else if ([property isEqualToString:@"logoOrigin"]) {
        return [NSValue valueWithPoint:self.logoOrigin];
    }
    else if ([property isEqualToString:@"rolloverOrigin"]) {
        return [NSValue valueWithPoint:self.rolloverOrigin];
    }
    else if ([property isEqualToString:@"slide1Origin"]) {
        return [NSValue valueWithPoint:self.slide1Origin];
    }
    else if ([property isEqualToString:@"slide2Origin"]) {
        return [NSValue valueWithPoint:self.slide2Origin];
    }
    else if ([property isEqualToString:@"slide3Origin"]) {
        return [NSValue valueWithPoint:self.slide3Origin];
    }
    else {
        return nil;
    }
}

@end
