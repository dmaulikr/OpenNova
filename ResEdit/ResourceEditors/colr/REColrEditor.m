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

#import "REColrEditor.h"
#import "RENovaTypeProperty.h"
#import "REResourceBrowserWindow.h"

@implementation REColrEditor

+ (void)registerEditor
{
    [REResourceBrowserWindow registerEditorClass:self forType:@"cölr"];
}

- (NSArray<RENovaTypeProperty *> *)properties
{
    return @[
        [RENovaTypeProperty withDisplayName:@"Button Text Color" forProperty:@"buttonUpColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Hilited Button Text Color" forProperty:@"buttonDownColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Disabled Button Text Color" forProperty:@"buttonGreyColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Menu Font" forProperty:@"menuFontName" ofType:EVNovaTypeDataType_String],
        [RENovaTypeProperty withDisplayName:@"Menu Font Size" forProperty:@"menuFontSize" ofType:EVNovaTypeDataType_DWRD],
        [RENovaTypeProperty withDisplayName:@"Menu 1" forProperty:@"menuColor1" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Menu 2" forProperty:@"menuColor2" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Grid Bright" forProperty:@"gridBright" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Grid Dim" forProperty:@"gridDim" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Progress Bar" forProperty:@"progressBarFrame" ofType:EVNovaTypeDataType_Rect],
        [RENovaTypeProperty withDisplayName:@"Progress Bright" forProperty:@"progressBrightColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Progress Dim" forProperty:@"progressDimColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Progress Outline" forProperty:@"progressOutlineColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Menu Button 1" forProperty:@"menuButton1Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Menu Button 2" forProperty:@"menuButton2Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Menu Button 3" forProperty:@"menuButton3Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Menu Button 4" forProperty:@"menuButton4Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Menu Button 5" forProperty:@"menuButton5Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Menu Button 6" forProperty:@"menuButton6Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Floating Map Color" forProperty:@"floatingMapColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"List Text Color" forProperty:@"listTextColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"List Background Color" forProperty:@"listBackgroundColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"List Hilite Color" forProperty:@"listHiliteColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Escort Hilite Color" forProperty:@"escortHiliteColor" ofType:EVNovaTypeDataType_Color],
        [RENovaTypeProperty withDisplayName:@"Button Font" forProperty:@"buttonFontName" ofType:EVNovaTypeDataType_String],
        [RENovaTypeProperty withDisplayName:@"Button Font Size" forProperty:@"buttonFontSize" ofType:EVNovaTypeDataType_DWRD],
        [RENovaTypeProperty withDisplayName:@"Logo" forProperty:@"logoOrigin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Rollover" forProperty:@"rolloverOrigin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Slider 1" forProperty:@"slide1Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Slider 2" forProperty:@"slide2Origin" ofType:EVNovaTypeDataType_Point],
        [RENovaTypeProperty withDisplayName:@"Slider 3" forProperty:@"slide3Origin" ofType:EVNovaTypeDataType_Point]
    ];
}

@end
