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

#import "RESpinEditor.h"
#import "RENovaTypeProperty.h"
#import "REResourceBrowserWindow.h"

@implementation RESpinEditor

+ (void)registerEditor
{
    [REResourceBrowserWindow registerEditorClass:self forType:@"spïn"];
}

- (NSArray<RENovaTypeProperty *> *)properties
{
    return @[[RENovaTypeProperty withDisplayName:@"Sprites ID" forProperty:@"spritesId" ofType:EVNovaTypeDataType_DWRD],
             [RENovaTypeProperty withDisplayName:@"Masks ID" forProperty:@"masksId" ofType:EVNovaTypeDataType_DWRD],
             [RENovaTypeProperty withDisplayName:@"X Size" forProperty:@"xSize" ofType:EVNovaTypeDataType_DWRD],
             [RENovaTypeProperty withDisplayName:@"Y Size" forProperty:@"ySize" ofType:EVNovaTypeDataType_DWRD],
             [RENovaTypeProperty withDisplayName:@"X Tiles" forProperty:@"xTiles" ofType:EVNovaTypeDataType_DWRD],
             [RENovaTypeProperty withDisplayName:@"Y Tiles" forProperty:@"yTiles" ofType:EVNovaTypeDataType_DWRD],
             ];
}

@end
