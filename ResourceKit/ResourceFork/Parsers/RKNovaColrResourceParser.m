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

#import "RKNovaColrResourceParser.h"
#import "RKResource.h"
#import "EVColrObject.h"

@implementation RKNovaColrResourceParser

#pragma mark - Auto-Loading

+ (void)register
{
    // Register the parser in the resource class. This will allow the resource
    // to lookup an appropriate parser when required.
    [RKResource registerParser:self forType:@"cölr"];
}


#pragma mark - Data Reading

- (BOOL)parse
{
    EVColrObject *colr = EVColrObject.new;
    
    colr.buttonUpColor = self.readColor;
    colr.buttonDownColor = self.readColor;
    colr.buttonGreyColor = self.readColor;
    colr.menuFontName = [self readStringOfLength:64];
    colr.menuFontSize = self.readDecimalWord;
    colr.menuColor1 = self.readColor;
    colr.menuColor2 = self.readColor;
    colr.gridBright = self.readColor;
    colr.gridDim = self.readColor;
    colr.progressBarFrame = self.readRect;
    colr.progressBrightColor = self.readColor;
    colr.progressDimColor = self.readColor;
    colr.progressOutlineColor = self.readColor;
    colr.menuButton1Origin = self.readPoint;
    colr.menuButton2Origin = self.readPoint;
    colr.menuButton3Origin = self.readPoint;
    colr.menuButton4Origin = self.readPoint;
    colr.menuButton5Origin = self.readPoint;
    colr.menuButton6Origin = self.readPoint;
    colr.floatingMapColor = self.readColor;
    colr.listTextColor = self.readColor;
    colr.listBackgroundColor = self.readColor;
    colr.listHiliteColor = self.readColor;
    colr.escortHiliteColor = self.readColor;
    colr.buttonFontName = [self readStringOfLength:64];
    colr.buttonFontSize = self.readDecimalWord;
    colr.logoOrigin = self.readPoint;
    colr.rolloverOrigin = self.readPoint;
    colr.slide1Origin = self.readPoint;
    colr.slide2Origin = self.readPoint;
    colr.slide3Origin = self.readPoint;
    
    self.object = colr;
    
    return YES;
}

@end
