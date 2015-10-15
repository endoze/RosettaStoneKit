//
//  RosettaStone.m
//
//  Created by Chris Stephan on 1/15/15.
//  The MIT License (MIT)

// Copyright (c) 2015 Chris Stephan

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RosettaStone.h"
#import "PropertyTranslator.h"
#import <objc/runtime.h>
#import "NSDictionary+Extensions.h"

static NSDateFormatter *defaultDateFormatter;

@interface RosettaStone ()

@property (nonatomic, strong) NSMutableDictionary *propertyTranslatorByClassString;
@property (nonatomic, strong) NSMutableDictionary *propertyMapByClassString;

- (id)objectFromDictionary:(NSDictionary *)dictionary withClass:(Class)klass;
- (NSDictionary *)dictionaryFromObject:(id)object;
- (Class)classOfProperty:(objc_property_t) property;
- (NSDictionary *)propertyMapForClass:(Class)klass;

@end

@implementation RosettaStone

#pragma mark - Initialization

+ (instancetype)sharedInstance
{
  static RosettaStone *_sharedInstance;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _sharedInstance = [self new];
    _sharedInstance.propertyTranslatorByClassString = [NSMutableDictionary new];
    _sharedInstance.propertyMapByClassString = [NSMutableDictionary new];
    defaultDateFormatter = [NSDateFormatter new];
    [defaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
  });
  
  return _sharedInstance;
}

#pragma mark - Public Api

- (void)registerPropertyTranslator:(PropertyTranslator *)propertyTranslator
{
  NSMutableDictionary *propertyTranslatorForClass = [self propertyTranslatorForClass:propertyTranslator.className];
  
  [propertyTranslatorForClass setObject:propertyTranslator forKey:propertyTranslator.propertyName];
}

- (id)translate:(NSDictionary *)dictionary toClass:(Class)klass
{
  return [self objectFromDictionary:dictionary withClass:klass];
}

- (NSDictionary *)translateToDictionary:(id)object
{
  return [self dictionaryFromObject:object];
}

- (NSArray *)translate:(NSArray *)array toArrayOfClass:(Class)klass
{
  __block NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[array count]];
  
  [array enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
    id translatedObject = [self translate:object toClass:klass];
    [results addObject:translatedObject];
  }];
  
  return [results copy];
}

- (NSArray *)translateArrayToDictionaries:(NSArray *)array
{
  __block NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[array count]];
  
  [array enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
    id translatedObject = [self translateToDictionary:object];
    [results addObject:translatedObject];
  }];
  
  return [results copy];
}

#pragma mark - Convenience

- (NSMutableDictionary *)propertyTranslatorForClass:(NSString *)className
{
  NSMutableDictionary *propertyTranslatorForClass;
  
  if ([self.propertyTranslatorByClassString hasKey:className]) {
    propertyTranslatorForClass = [self.propertyTranslatorByClassString objectForKey:className];
  } else {
    propertyTranslatorForClass = [NSMutableDictionary new];
    [self.propertyTranslatorByClassString setObject:propertyTranslatorForClass forKey:className];
  }
  
  return propertyTranslatorForClass;
}

#pragma mark - Overridden Property Accessors

- (NSDateFormatter *)dateFormatter
{
  if (_dateFormatter) {
    return _dateFormatter;
  }
  
  return defaultDateFormatter;
}

#pragma mark - Introspection

- (Class)classOfProperty:(objc_property_t) property
{
  const char *type = property_getAttributes(property);
  NSString *const typeString = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
  
  NSArray *attributes = [typeString componentsSeparatedByString:@","];
  NSString *typeAttribute = [attributes objectAtIndex:0];
  NSString *propertyType = [typeAttribute substringFromIndex:1];
  const char *rawPropertyType = [propertyType UTF8String];
  
  if ([typeAttribute hasPrefix:@"T@"] && [typeAttribute length] > 1) {
    NSString *classString = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length] - 4)];
    Class klass = NSClassFromString(classString);
    
    if (klass) {
      return klass;
    }
  }
  
  if (strcmp(rawPropertyType, @encode(int)) == 0 ||
      strcmp(rawPropertyType, @encode(BOOL)) == 0 ||
      strcmp(rawPropertyType, @encode(long long)) == 0 ||
      strcmp(rawPropertyType, @encode(float)) == 0 ||
      strcmp(rawPropertyType, @encode(double)) == 0) {
    return [NSNumber class];
  }
  
  return nil;
}

- (NSDictionary *)propertyMapForClass:(Class)klass
{
  NSString *className = NSStringFromClass(klass);
  
  if (![self.propertyMapByClassString hasKey:className]) {
    unsigned int propertiesCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &propertiesCount);
    NSMutableDictionary *propertyMap = [NSMutableDictionary dictionary];
    
    for (i = 0; i < propertiesCount; ++i) {
      objc_property_t property = properties[i];
      const char *propName = property_getName(property);
      
      if (propName) {
        NSString *propertyName = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
        Class klass = [self classOfProperty:property];
        
        if (klass) {
          [propertyMap setObject:klass forKey:propertyName];
        }
      }
    }
    free(properties);
    [self.propertyMapByClassString setObject:[propertyMap copy] forKey:className];
  }
  
  return [self.propertyMapByClassString valueForKey:className];
}

#pragma mark - Conversion

- (id)objectFromDictionary:(NSDictionary *)dictionary withClass:(Class)klass
{
  __block id object = [klass new];
  
  NSDictionary *propertyMap = [self propertyMapForClass:klass];
  
  [propertyMap enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, Class propertyClass, BOOL *stop) {
    NSString *className = NSStringFromClass(klass);
    PropertyTranslator *propertyTranslator = [[self propertyTranslatorForClass:className] valueForKey:propertyName];
    
    id propertyValue;
    
    if (propertyTranslator && propertyTranslator.valueInterpolatorBlock) {
      propertyValue = [dictionary valueForKey:propertyTranslator.keyName];
      id returnedValue = propertyTranslator.valueInterpolatorBlock(propertyValue);
      [object setValue:returnedValue forKey:propertyTranslator.propertyName];
    } else {
      propertyValue = [dictionary valueForKey:propertyName];
      Class keyClass = [propertyValue class];
    
      if (propertyValue) {
        if ([propertyClass isSubclassOfClass:[NSDate class]] && ![propertyValue isEqual:[NSNull null]]) {
          NSString *dateString = [dictionary valueForKey:propertyName];
          NSDate *date = [[self dateFormatter] dateFromString:dateString];
          
          [object setValue:date forKey:propertyName];
        } else if ([keyClass isSubclassOfClass:[NSDictionary class]] && ![propertyClass isSubclassOfClass:[NSDictionary class]]) {
          id nestedObjectValue = [self objectFromDictionary:propertyValue withClass:propertyClass];
          [object setValue:nestedObjectValue forKey:propertyName];
        } else {
          [object setValue:propertyValue forKey:propertyName];
        }
      }
    }
  }];
  
  return object;
}

- (NSDictionary *)dictionaryFromObject:(id)object
{
  __block NSMutableDictionary *dictionary = [NSMutableDictionary new];
  Class klass = [object class];
  NSDictionary *propertyMap = [self propertyMapForClass:klass];
  
  [propertyMap enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, Class propertyClass, BOOL *stop) {
    NSString *className = NSStringFromClass(klass);
    PropertyTranslator *propertyTranslator = [[self propertyTranslatorForClass:className] valueForKey:propertyName];
    
    id propertyValue;
    
    if (propertyTranslator && propertyTranslator.reverseInterpolatorBlock) {
      propertyValue = [object valueForKey:propertyTranslator.propertyName];
      id returnedValue = propertyTranslator.reverseInterpolatorBlock(propertyValue);
      [dictionary setValue:returnedValue forKey:propertyTranslator.keyName];
    } else {
      propertyValue = [object valueForKey:propertyName];
      Class keyClass = [propertyValue class];
    
      if (propertyValue) {
        if ([keyClass isSubclassOfClass:[NSDate class]]) {
          NSDate *date = (NSDate *)propertyValue;
          NSString *dateString = [[self dateFormatter] stringFromDate:date];
          
          [dictionary setValue:dateString forKey:propertyName];
        } else if ([propertyClass isSubclassOfClass:[NSArray class]]) {
          NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[propertyValue count]];
          
          for (id object in propertyValue) {
            NSDictionary *translatedObject = [self dictionaryFromObject:object];
            [results addObject:translatedObject];
          }
          [dictionary setValue:[results copy] forKey:propertyName];
        } else if (![self isJsonPrimitive:propertyClass]) {
          id nestedObjectValue = [self dictionaryFromObject:propertyValue];
          [dictionary setValue:nestedObjectValue forKey:propertyName];
        } else {
          [dictionary setValue:propertyValue forKey:propertyName];
        }
      }
    }
  }];
  
  return [dictionary copy];
}

- (BOOL)isJsonPrimitive:(Class)klass
{
  if ([klass isSubclassOfClass:[NSNumber class]] ||
      [klass isSubclassOfClass:[NSString class]] ||
      [klass isSubclassOfClass:[NSDictionary class]]) {
    return YES;
  }
  
  return NO;
}

@end
