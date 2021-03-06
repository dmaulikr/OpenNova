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

#import "RKNovaSpinResourceParser.h"
#import "RKResource.h"
#import "EVSpinObject.h"

@implementation RKNovaSpinResourceParser

#pragma mark - Auto-Loading

+ (void)register
{
    // Register the parser in the resource class. This will allow the resource
    // to lookup an appropriate parser when required.
    [RKResource registerParser:self forType:@"spïn"];
}


#pragma mark - Data Reading

- (BOOL)parse
{
    EVSpinObject *spin = EVSpinObject.new;
    
    spin.spritesId = self.readDecimalWord;
    spin.masksId = self.readDecimalWord;
    spin.xSize = self.readDecimalWord;
    spin.ySize = self.readDecimalWord;
    spin.xTiles = self.readDecimalWord;
    spin.yTiles = self.readDecimalWord;
    
    self.object = spin;
    
    return YES;
}


@end
