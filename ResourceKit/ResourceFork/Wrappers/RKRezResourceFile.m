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

#import "RKRezResourceFile.h"
#import "Rez.h"
#import "Allocations.h"
#import "RKResource.h"

@implementation RKRezResourceFile {
@private
    __strong NSArray <NSString *> *_Nullable _types;
    __strong NSMutableDictionary <NSString *, NSArray <RKResource *> *> *_resources;
    RezResourceFile *_Nullable _file;
}

@synthesize filePath = _filePath;

#pragma mark - Resource File Information

+ (NSString *)extension
{
    return @"rez";
}


#pragma mark - Creation

+ (instancetype)resourceFileWithPath:(NSString *)filePath
{
    return [[self alloc] initWithFilePath:filePath];
}

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (!filePath) {
        return nil;
    }

    if (self = [super init]) {
        _file = RezOpenFile(filePath.UTF8String);
        if (!_file) {
            return nil;
        }
        
        _resources = NSMutableDictionary.new;
        _filePath = filePath.copy;
    }

    return self;
}


#pragma mark - Destruction

- (void)dealloc
{
    RezClosefile(_file);
}


#pragma mark - Accessors

- (NSArray<NSString *> *)allTypes
{
    return _types ?: (_types = ^ NSArray <NSString *> * {
        NSMutableArray *types = [NSMutableArray new];
        
        for (uint32_t i = 0; i < _file->header->typeCount; ++i) {
            RezResourceType *type = RezGetResourceTypeAtIndex(_file, i);
            char *typeCode = New(5);
            strncpy(typeCode, type->code, 4);
            [types addObject:[NSString stringWithFormat:@"%s", typeCode]];
            free(typeCode);
        }
        
        return types;
    }());
}

- (nonnull NSArray <RKResource *> *)resourcesOfType:(nonnull NSString *)typeCode
{
    // TODO: This needs to be made more efficient and cleaner.
    return _resources[typeCode] ?: (_resources[typeCode] = ^NSArray <RKResource *> *{
        NSMutableArray <RKResource *> *resources = [NSMutableArray new];
        
        const char *typeCodeMacOS = [typeCode cStringUsingEncoding:NSMacOSRomanStringEncoding];
        RezResourceType *type = RezGetResourceTypeForCode(_file, typeCodeMacOS);
        
        if (!type) {
            return @[];
        }
        
        for (uint32_t i = 0; i < type->resourceCount; ++i) {
            RezResourceHeader *resourceHeader = RezGetResourceHeaderOfTypeAtIndex(_file, typeCodeMacOS, i);
            
            NSString *name = [NSString stringWithFormat:@"%s", resourceHeader->name];
            
            RKResource *resource = [[RKResource alloc] initWithType:typeCode
                                                                 id:resourceHeader->id
                                                               name:name
                                                               size:resourceHeader->size
                                                              owner:self];
            [resources addObject:resource];
        }
        
        return resources.copy;
    }());
}

- (nullable NSData *)dataForResourceOfType:(nonnull NSString *)type id:(int16_t)id
{
    uint8_t *raw = NULL;
    size_t size = 0;
    
    RezGetResourceDataOfTypeAndId(_file, type.UTF8String, id, &raw, &size);
    
    return [NSData dataWithBytes:raw length:size];
}

@end
