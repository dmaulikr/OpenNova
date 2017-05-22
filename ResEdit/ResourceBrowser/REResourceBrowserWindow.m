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

#import <objc/runtime.h>
#import "REResourceBrowserWindow.h"
#import "REResourceBrowserDataSource.h"
#import <ResourceKit/ResourceKit.h>
#import "REPICTEditor.h"
#import "REStringListEditor.h"
#import "RESpinEditor.h"
#import "REResourceEditorProtocol.h"

static void *REResourceEditorsKey = &REResourceEditorsKey;

@interface REResourceBrowserWindow ()
@property (nullable, strong) IBOutlet NSOutlineView *browserOutlineView;
@property (nullable, strong) IBOutlet NSView *placeholderView;
@property (nullable, strong) IBOutlet NSView *containerView;
@property (nullable, strong) IBOutlet NSTextField *resourceIdLabel;
@property (nullable, strong) IBOutlet NSTextField *resourceNameLabel;

@property (nullable, strong) RKResourceFork *resourceFork;
@property (nonnull, strong) REResourceBrowserDataSource *dataSource;
@property (nullable, strong) id <REResourceEditorProtocol> resourceEditor;
@end

@implementation REResourceBrowserWindow

#pragma mark - File Access

+ (void)openResourceFileWithCompletion:(nonnull void(^)(REResourceBrowserWindow *_Nonnull window))handler
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    openPanel.prompt = @"Open";
    openPanel.title = @"Open Resource File...";
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseDirectories = NO;
    
    if ([openPanel runModal] != NSModalResponseOK) {
        return;
    }
    
    NSString *filePath = openPanel.URL.relativePath;
    RKResourceFork *resourceFork = [RKResourceFork emptyResourceFork];
    if ( [resourceFork addResourceFileAtPath:filePath] == nil ) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            REResourceBrowserWindow *window = nil;
            !handler ?: handler((window = [[self alloc] initWithResourceFork:resourceFork]));
            [window showWindow:nil];
        });
    });
}

- (nullable instancetype)initWithResourceFork:(nonnull RKResourceFork *)resourceFork
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [REResourceBrowserWindow loadEditors];
    });
    
    if (self = [super initWithWindowNibName:NSStringFromClass(self.class)]) {
        self.resourceFork = resourceFork;
    }
    return self;
}


#pragma mark - Window Controller

- (void)windowDidLoad
{
    self.window.title = self.resourceFork.allFilePaths.firstObject.lastPathComponent;
    self.window.representedFilename = self.resourceFork.allFilePaths.firstObject;
    
    self.dataSource = [[REResourceBrowserDataSource alloc] initWithResourceFork:self.resourceFork forOutlineView:self.browserOutlineView];
    
    __weak __typeof(self) weakSelf = self;
    self.dataSource.resourceSelected = ^(RKResource * _Nullable resource) {
        [weakSelf loadResource:resource];
    };
    
    [self loadResource:nil];
    [super windowDidLoad];
}


#pragma mark - Container

- (void)removeContainerView
{
    [self.containerView removeConstraints:self.containerView.constraints];
    [self.containerView.subviews.firstObject removeFromSuperview];
}

- (void)showContainerView:(NSView *)view
{
    view = view ?: self.placeholderView;
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:view];
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": view}];
    constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": view}]];

    [self.containerView addConstraints:constraints];
}


#pragma mark - Resource Editors

+ (void)loadEditors
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        int classCount = 0;
        classCount = objc_getClassList(NULL, classCount);
        if (classCount) {
            Class *classes = (__unsafe_unretained Class *)calloc(classCount, sizeof(*classes));
            objc_getClassList(classes, classCount);
            
            // Step through the classes and search for ones that conform to RKResourceParserProtocol
            for (int i = 0; i < classCount; ++i) {
                Method method = class_getClassMethod(classes[i], @selector(registerEditor));
                if (method) {
                    [classes[i] registerEditor];
                }
            }
            
        }
    });
}

+ (void)registerEditorClass:(Class)aEditorClass forType:(NSString *)resourceType
{
    NSMutableDictionary <NSString *, Class> *editors = objc_getAssociatedObject(self, REResourceEditorsKey);
    editors = editors ?: NSMutableDictionary.new;
    [editors setObject:aEditorClass forKey:resourceType];
    objc_setAssociatedObject(self, REResourceEditorsKey, editors, OBJC_ASSOCIATION_RETAIN);
}

+ (Class)resourceEditorForType:(NSString *)resourceType
{
    NSDictionary <NSString *, Class> *editors = objc_getAssociatedObject(self, REResourceEditorsKey);
    return editors[resourceType];
}

- (void)loadResource:(RKResource *)resource
{
    if (!resource) {
        self.resourceIdLabel.hidden = YES;
        self.resourceNameLabel.hidden = YES;
        [self showContainerView:self.placeholderView];
        return;
    }
    
    self.resourceIdLabel.hidden = NO;
    self.resourceNameLabel.hidden = NO;
    
    self.resourceIdLabel.stringValue = [NSString stringWithFormat:@"%d", resource.id];
    self.resourceNameLabel.stringValue = [NSString stringWithFormat:@"%@", resource.name];
    
    [self removeContainerView];
    
    Class EditorClass = [[self class] resourceEditorForType:resource.type];
    if (EditorClass) {
        self.resourceEditor = [[EditorClass alloc] initWithResource:resource];
        [self showContainerView:self.resourceEditor.view];
    }
    else {
        [self showContainerView:self.placeholderView];
    }
}

@end
