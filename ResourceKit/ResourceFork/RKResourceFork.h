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

#import <Foundation/Foundation.h>
#import "RKResourceFileProtocol.h"

@interface RKResourceFork : NSObject

/// Returns a resource fork instance that is shared across all resource files in
/// the app. This will allow access to any single resource loaded in any file. Newer
/// files will override resources from older files.
+ (nonnull instancetype)sharedResourceFork;

/// Returns an empty resource fork that is not shared with any other resource file.
+ (nonnull instancetype)emptyResourceFork;


/// Load the file at the specified path as a resource file and add it to the receiver.
/// This will return the resource file for reference.
- (nullable id <RKResourceFileProtocol>)addResourceFileAtPath:(nonnull NSString *)filePath;


/// Get an array of all available types through the ResourceFork. This is a distinct union
/// of all the types from all the resource files added to the receiver.
@property (nonnull, readonly) NSArray <NSString *> *allTypes;


/// Get a list of all the resource files contributing to the resource fork.
@property (nonnull, readonly) NSArray <NSString *> *allFilePaths;

/// Returns an array of all the resources of the specified type.
- (nonnull NSArray <RKResource *> *)resourcesOfType:(nonnull NSString *)type;

/// Returns the data for the resource with the specified type and id.
- (nullable NSData *)dataForResourceOfType:(nonnull NSString *)type id:(int16_t)id;

@end
