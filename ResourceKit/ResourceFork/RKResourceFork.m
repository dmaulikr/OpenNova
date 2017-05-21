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

#import "RKResourceFork.h"
#import "RKRezResourceFile.h"
#import "RKNdatResourceFile.h"
#import "RKResource.h"

@implementation RKResourceFork {
@private
    __strong NSArray <id<RKResourceFileProtocol>> *_files;
    __strong NSArray <NSString *> *_types;
    __strong NSArray <NSString *> *_filePaths;
    __strong NSMutableDictionary <NSString *, NSArray <RKResource *> *> *_resources;
}


#pragma mark - Constructors

+ (nonnull instancetype)sharedResourceFork
{
    static RKResourceFork *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self emptyResourceFork];
    });
    return instance;
}

+ (nonnull instancetype)emptyResourceFork
{
    return [RKResourceFork new];
}


- (instancetype)init
{
    if (self = [super init]) {
        _resources = [NSMutableDictionary new];
    }
    return self;
}


#pragma mark - Loading Resource Files

- (nullable id <RKResourceFileProtocol>)addResourceFileAtPath:(nonnull NSString *)filePath
{
    [self invalidateCalculatedProperties];
    
    id <RKResourceFileProtocol> file = nil;
    
    if ([filePath.pathExtension isEqualToString:RKRezResourceFile.extension]) {
        file = [RKRezResourceFile resourceFileWithPath:filePath];
    }
    else if ([filePath.pathExtension isEqualToString:RKNdatResourceFile.extension]) {
        file = [RKNdatResourceFile resourceFileWithPath:filePath];
    }
    
    if (file) {
        _files = _files ? [_files arrayByAddingObject:file] : @[file];
    }
        
    return file;
}


#pragma mark - Calculated Properties

- (void)invalidateCalculatedProperties
{
    _types = nil;
    _filePaths = nil;
    _resources = [NSMutableDictionary new];
}

- (NSArray<NSString *> *)allTypes
{
    __weak __typeof(self) weakSelf = self;
    return _types ?: (_types = ^NSArray <NSString *> * {
        __strong __typeof(self) self = weakSelf;
        NSMutableArray <NSString *> *types = [NSMutableArray new];
        
        // Do a distinct merge of all the arrays
        for (id <RKResourceFileProtocol> file in self->_files) {
            for (NSString *type in file.allTypes) {
                if (![types containsObject:type]) {
                    [types addObject:type];
                }
            }
        }
        
        // Ensure they are alphabetical
        [types sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        // Ensure its a none mutable array we finally use.
        return types.copy;
    }());
}

- (NSArray<NSString *> *)allFilePaths
{
    __weak __typeof(self) weakSelf = self;
    return _filePaths ?: (_filePaths = ^NSArray <NSString *> * {
        __strong __typeof(self) self = weakSelf;
        NSMutableArray <NSString *> *filePaths = [NSMutableArray new];
        
        for (id <RKResourceFileProtocol> file in self->_files) {
            [filePaths addObject:file.filePath];
        }
        
        // Ensure its a none mutable array we finally use.
        return filePaths.copy;
    }());
}

- (nonnull NSArray <RKResource *> *)resourcesOfType:(nonnull NSString *)type
{
    __weak __typeof(self) weakSelf = self;
    return _resources[type] ?: (_resources[type] = ^NSArray <RKResource *> * {
        __strong __typeof(self) self = weakSelf;
        NSMutableArray <RKResource *> *resources = [NSMutableArray new];
        
        for (id <RKResourceFileProtocol> file in self->_files) {
            if (![file.allTypes containsObject:type]) {
                continue;
            }
            
            NSArray <RKResource *> *fileResources = [file resourcesOfType:type];
            for (RKResource *resource in fileResources) {
                if (![resources containsObject:resource]) {
                    [resources addObject:resource];
                }
            }
        }
        
        [resources sortUsingComparator:^NSComparisonResult(RKResource *obj1, RKResource *obj2) {
            return obj1.id < obj2.id ? NSOrderedAscending : NSOrderedDescending;
        }];
        
        return resources.copy;
    }());
}

- (nullable NSData *)dataForResourceOfType:(nonnull NSString *)type id:(int16_t)id
{
    NSArray <RKResource *> *resources = [self resourcesOfType:type];
    for (RKResource *resource in resources) {
        if (resource.id == id) {
            return resource.data;
        }
    }
    return nil;
}

@end
