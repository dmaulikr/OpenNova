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

#import "REResourceBrowserDataSource.h"

@interface REResourceBrowserDataSource () <NSOutlineViewDataSource, NSOutlineViewDelegate>
@end

@implementation REResourceBrowserDataSource {
@private
    __weak NSOutlineView *_outlineView;
    __weak RKResourceFork *_resourceFork;
}

- (nullable instancetype)initWithResourceFork:(nonnull RKResourceFork *)resourceFork forOutlineView:(nonnull NSOutlineView *)outlineView
{
    if (self = [super init]) {
        _outlineView = outlineView;
        _resourceFork = resourceFork;
        
        _outlineView.dataSource = self;
        _outlineView.delegate = self;
    }
    return self;
}


#pragma mark - Data Source

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    if (item && [item isKindOfClass:NSString.class]) {
        // Child Item
        return [[_resourceFork resourcesOfType:item] count];
    }
    else {
        // Root Item
        return _resourceFork.allTypes.count;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    if (item && [item isKindOfClass:NSString.class]) {
        // Child of Item
        return [_resourceFork resourcesOfType:item][index];
    }
    else {
        // Child of Root Item
        return _resourceFork.allTypes[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return (item && [item isKindOfClass:NSString.class]);
}


#pragma mark - Delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([item isKindOfClass:NSString.class] && [tableColumn.identifier isEqualToString:@"RKResourceId"]) {
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"RKResourceTypeCell" owner:nil];
        cell.textField.stringValue = item;
        return cell;
    }
    else if ([item isKindOfClass:RKResource.class] && [tableColumn.identifier isEqualToString:@"RKResourceId"]) {
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"RKResourceTypeCell" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%d", ((RKResource *)item).id];
        return cell;
    }
    else if ([item isKindOfClass:RKResource.class] && [tableColumn.identifier isEqualToString:@"RKResourceName"]) {
        NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"RKResourceTypeCell" owner:nil];
        cell.textField.stringValue = ((RKResource *)item).name;
        return cell;
    }
    return nil;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    id item = [_outlineView itemAtRow:[_outlineView selectedRow]];
    if ([item isKindOfClass:RKResource.class]) {
        !self.resourceSelected ?: self.resourceSelected(item);
    }
}

@end
