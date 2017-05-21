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

#import "REStringListEditor.h"
#import <ResourceKit/ResourceKit.h>

@interface REStringListEditor () <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSTableView *stringsTableView;
@property (strong) IBOutlet NSView *view;
@property (strong) NSArray <NSString *> *strings;
@end

@implementation REStringListEditor

@synthesize resource = _resource;

- (nonnull instancetype)initWithResource:(nonnull RKResource *)resource
{
    if (self = [super init]) {
        if (![[NSBundle mainBundle] loadNibNamed:@"REStringListEditor" owner:self topLevelObjects:nil]) {
            return nil;
        }
        
        _resource = resource;
        self.strings = resource.object;
        [self.stringsTableView reloadData];
    }
    return self;
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.strings.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"StringIndex"]) {
        NSTableCellView * cell = [tableView makeViewWithIdentifier:@"StringIndexCell" owner:nil];
        cell.textField.stringValue = [NSString stringWithFormat:@"%d", (int)row];
        return cell;
    }
    else {
        NSTableCellView * cell = [tableView makeViewWithIdentifier:@"StringValueCell" owner:nil];
        cell.textField.stringValue = self.strings[row];
        return cell;
    }
}

@end
