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

#import "RERLEEditor.h"
#import <ResourceKit/ResourceKit.h>
#import "REResourceBrowserWindow.h"

@interface RERLEEditor ()
@property (strong) IBOutlet NSView *view;
@property (strong) IBOutlet NSImageView *spriteView;
@property (strong) IBOutlet NSTextField *spriteCountTextField;
@property (strong) IBOutlet NSPopUpButton *currentSpriteFrameMenu;
@property (weak) RKRLEObject *animatedSprite;
@end

@implementation RERLEEditor
@synthesize resource = _resource;

+ (void)registerEditor
{
    [REResourceBrowserWindow registerEditorClass:self forType:@"RLËD"];
    [REResourceBrowserWindow registerEditorClass:self forType:@"rlëD"];
}

- (nonnull instancetype)initWithResource:(nonnull RKResource *)resource
{
    if (self = [super init]) {
        if (![[NSBundle mainBundle] loadNibNamed:@"RERLEEditor" owner:self topLevelObjects:nil]) {
            return nil;
        }
        
        _resource = resource;
        
        self.view.wantsLayer = YES;
        self.view.layer.backgroundColor = NSColor.darkGrayColor.CGColor;
        self.animatedSprite = self.resource.object;
        
        self.spriteCountTextField.stringValue = [NSString stringWithFormat:@"%d", (int)self.animatedSprite.sprites.count];
        
        [self.currentSpriteFrameMenu removeAllItems];
        for (NSInteger i = 0; i < self.animatedSprite.sprites.count; ++i) {
            [self.currentSpriteFrameMenu addItemWithTitle:[NSString stringWithFormat:@"%d", (int)i]];
        }
        [self.currentSpriteFrameMenu selectItemAtIndex:0];
        [self pickSpriteFrame:self.currentSpriteFrameMenu];
    }
    return self;
}

- (IBAction)pickSpriteFrame:(NSPopUpButton *)sender
{
    NSInteger spriteFrame = self.currentSpriteFrameMenu.indexOfSelectedItem;
    RKRLESprite *sprite = self.animatedSprite.sprites[spriteFrame];
    NSImage *spriteImage = [[NSImage alloc] initWithCGImage:sprite.imageValue size:sprite.size];
    self.spriteView.image = spriteImage;
}

@end
