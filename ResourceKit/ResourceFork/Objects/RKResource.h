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

@interface RKResource : NSObject

/// The resource file in which the receiver belongs to
@property (nullable, readonly, weak) id <RKResourceFileProtocol> owner;

/// The id of the receiver
@property (readonly) int16_t id;

/// The name of the receiver
@property (nullable, readonly, copy) NSString *name;

/// The type of the receiver
@property (nonnull, readonly, copy) NSString *type;

/// The size of the data of the receiver
@property (readonly) size_t size;

/// The data of the reciever
@property (nonnull, readonly) NSData *data;

/// The parsed object of the received. This will be the data of the
/// receiver if no parser is available.
@property (nonnull, readonly) id object;


/// Instantiates a new instance of RKResource with the specified fields
- (nonnull instancetype)initWithType:(nonnull NSString *)type
                                  id:(int16_t)resourceId
                                name:(nullable NSString *)name
                                size:(size_t)size
                               owner:(nullable id <RKResourceFileProtocol>)owner;

/// Remove the currently cached object data.
- (void)flushCache;

@end


@interface RKResource (RKResourceParsing)

/// Search through the Objective-C runtime for all available parsers.
+ (void)loadParsers;

/// Register a parser with the resource class so that appropriate parsers can be found.
+ (void)registerParser:(nonnull Class)cls forType:(nonnull NSString *)type;

/// Request the parser for the specified resource type
+ (nullable Class)parserForType:(nonnull NSString *)type;

@end
