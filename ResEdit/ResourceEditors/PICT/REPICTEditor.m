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


#import "REPICTEditor.h"
#import <ResourceKit/ResourceKit.h>
#import "REResourceBrowserWindow.h"

@interface REPICTEditor ()
@property (strong) IBOutlet NSView *view;
@property (strong) IBOutlet NSImageView *imageView;
@end

@implementation REPICTEditor

@synthesize resource = _resource;

+ (void)registerEditor
{
    [REResourceBrowserWindow registerEditorClass:self forType:@"PICT"];
}

- (nonnull instancetype)initWithResource:(nonnull RKResource *)resource
{
    if (self = [super init]) {
        if (![[NSBundle mainBundle] loadNibNamed:@"REPICTEditor" owner:self topLevelObjects:nil]) {
            return nil;
        }
        
        _resource = resource;
        
        self.view.wantsLayer = YES;
        self.view.layer.backgroundColor = NSColor.darkGrayColor.CGColor;
        self.imageView.image = (NSImage *)self.resource.object;
    }
    return self;
}

@end
