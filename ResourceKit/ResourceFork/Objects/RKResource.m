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

#import "RKResource.h"
#import <ResourceKit/ResourceKit.h>
#import <objc/runtime.h>
#import "RKResourceParserProtocol.h"

@implementation RKResource {
@private
    __strong id _object;
}

- (nonnull instancetype)initWithType:(nonnull NSString *)type
                                  id:(int16_t)resourceId
                                name:(nullable NSString *)name
                                size:(size_t)size
                               owner:(nullable id <RKResourceFileProtocol>)owner
{
    [[self class] loadParsers];
    if (self = [super init]) {
        _type = type.copy;
        _id = resourceId;
        _name = name.copy;
        _size = size;
        _owner = owner;
    }
    return self;
}


#pragma mark - Computed Properties

- (NSData *)data
{
    return [self.owner dataForResourceOfType:self.type id:self.id];
}

- (id)object
{
    __weak __typeof(self) weakSelf = self;
    return _object ?: (_object = ^id{
        Class RKParser = [RKResource parserForType:weakSelf.type];
        if (!RKParser) {
            return weakSelf.data;
        }
        else {
            return [RKParser parseData:weakSelf.data];
        }
    }());
}

- (void)flushCache
{
    _object = nil;
}


#pragma mark - Equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:RKResource.class]) {
        return NO;
    }
    
    RKResource *subject = (RKResource *)object;
    
    if (subject == self) {
        return YES;
    }
    else if (subject.id == self.id && [subject.type isEqual:self.type]) {
        return YES;
    }
    
    return NO;
}

@end


static const void * RKResourceParsersDictionaryKey = &RKResourceParsersDictionaryKey;

@implementation RKResource (RKResourceParsing)

+ (void)loadParsers
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
                Method method = class_getClassMethod(classes[i], @selector(register));
                if (method) {
                    [classes[i] register];
                }
            }
            
            free(classes);
        }
    });
}

+ (void)registerParser:(Class)cls forType:(NSString *)type
{
    NSMutableDictionary <NSString *, Class> *parsers = objc_getAssociatedObject(self, RKResourceParsersDictionaryKey) ?: [NSMutableDictionary new];
    [parsers setObject:cls forKey:type];
    objc_setAssociatedObject(self, RKResourceParsersDictionaryKey, parsers, OBJC_ASSOCIATION_RETAIN);
}

+ (nullable Class)parserForType:(nonnull NSString *)type
{
    NSDictionary <NSString *, Class> *parsers = objc_getAssociatedObject(self, RKResourceParsersDictionaryKey) ?: [NSMutableDictionary new];
    return parsers[type];
}

@end
