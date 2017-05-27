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

#import "REDefaultNovaTypeEditor.h"
#import "RENovaTypeProperty.h"
#import <ResourceKit/ResourceKit.h>
#import "RETableColorCellView.h"
#import "RETableRectCellView.h"
#import "RETablePointCellView.h"

@interface REDefaultNovaTypeEditor () <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSTableView *propertiesTableView;
@property (strong) IBOutlet NSView *view;
@end

@implementation REDefaultNovaTypeEditor

@synthesize resource = _resource;

- (nonnull instancetype)initWithResource:(nonnull RKResource *)resource
{
    if (self = [super init]) {
        if (![[NSBundle mainBundle] loadNibNamed:@"REDefaultNovaTypeEditor" owner:self topLevelObjects:nil]) {
            return nil;
        }
        
        _resource = resource;
    }
    return self;
}

- (NSArray <RENovaTypeProperty *> *)properties
{
    return @[];
}


#pragma mark - Data Source / Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.properties.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RENovaTypeProperty *property = self.properties[row];
    
    if ([tableColumn.identifier isEqualToString:@"PropertyName"]) {
        NSTableCellView * cell = [tableView makeViewWithIdentifier:@"PropertyNameCell" owner:nil];
        cell.textField.stringValue = property.displayName;
        return cell;
    }
    else if (property.type & EVNovaTypeDataType_ColorMask)  {
        RETableColorCellView * cell = [tableView makeViewWithIdentifier:@"PropertyColorValueCell" owner:nil];
        [cell setColor:(__bridge CGColorRef)[self.resource.object valueForProperty:property.name]];
        return cell;
    }
    else if (property.type & EVNovaTypeDataType_NumberMask)  {
        NSTableCellView * cell = [tableView makeViewWithIdentifier:@"PropertyBasicValueCell" owner:nil];
        NSNumber *number = [self.resource.object valueForProperty:property.name];
        cell.textField.stringValue = [NSString stringWithFormat:@"%@", number];
        return cell;
    }
    else if (property.type & EVNovaTypeDataType_StringMask)  {
        NSTableCellView * cell = [tableView makeViewWithIdentifier:@"PropertyBasicValueCell" owner:nil];
        cell.textField.stringValue = [self.resource.object valueForProperty:property.name];
        return cell;
    }
    else if (property.type & EVNovaTypeDataType_RectMask)  {
        RETableRectCellView * cell = [tableView makeViewWithIdentifier:@"PropertyRectValueCell" owner:nil];
        [cell setRect:[(NSValue *)[self.resource.object valueForProperty:property.name] rectValue]];
        return cell;
    }
    else if (property.type & EVNovaTypeDataType_PointMask)  {
        RETablePointCellView * cell = [tableView makeViewWithIdentifier:@"PropertyPointValueCell" owner:nil];
        [cell setPoint:[(NSValue *)[self.resource.object valueForProperty:property.name] pointValue]];
        return cell;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 25.0;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

@end
