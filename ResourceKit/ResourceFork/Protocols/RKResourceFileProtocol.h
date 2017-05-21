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

@class RKResource;

/// The RKResourceFileProtocol is a protocol that can represent any type of resource
/// file. A resource file is one denoted as having a representation of a ResourceFork
/// flattened into the DataFork.
///
/// The reasoning behind having a protocol to represent resource files is that multiple
/// formats exist to represent the ResourceFork and each will require different
/// parsers/decoders/implementations/etc but can all share the same interfaces.
@protocol RKResourceFileProtocol <NSObject>

/// The file extension that is used to represent the resource file.
@property (class, nonnull, nonatomic, readonly) NSString *extension;

/// The file path of the resource file.
@property (nonnull, nonatomic, readonly) NSString *filePath;

/// An array of all resource type codes available in the resource file.
@property (nonnull, nonatomic, readonly) NSArray <NSString *> *allTypes;

/// Create a new instance of the resource file object representing the file at the specified
/// file path.
+ (nullable instancetype)resourceFileWithPath:(nonnull NSString *)filePath;

/// Instantiate the receiver with the specified resource file at the file path.
- (nullable instancetype)initWithFilePath:(nonnull NSString *)filePath;

/// Returns an array of all the resources of the specified type.
- (nonnull NSArray <RKResource *> *)resourcesOfType:(nonnull NSString *)type;

/// Returns the data for the resource with the specified type and id.
- (nullable NSData *)dataForResourceOfType:(nonnull NSString *)type id:(int16_t)id;

@end
