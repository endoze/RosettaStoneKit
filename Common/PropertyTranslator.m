//
//  PropertyTranslator.m
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

#import "PropertyTranslator.h"
#import "RosettaStone.h"

@implementation PropertyTranslator

+ (instancetype)propertyTranslatorForClass:(Class)klass fromKey:(NSString *)key toProperty:(NSString *)propertyName
{
  ValueInterpolatorBlock defaultBlock = ^(id propertyValue){
    return propertyValue;
  };
  
  return [self propertyTranslatorForClass:klass fromKey:key toProperty:propertyName withInterpolatorBlock:defaultBlock andReverseInterpolatorBlock:defaultBlock];
}

+ (instancetype)propertyTranslatorForClass:(Class)klass
                              fromArrayKey:(NSString *)arrayKey
                           toArrayProperty:(NSString *)arrayPropertyName
                                 withClass:(Class)arrayClass
{
  ValueInterpolatorBlock defaultArrayBlock = ^(NSArray *array){
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[array count]];
    RosettaStone *stone = [RosettaStone sharedInstance];
    
    for (id object in array) {
      id translatedObject = [stone translate:object toClass:arrayClass];
      [results addObject:translatedObject];
    }
    
    return [results copy];
  };
  
  ValueInterpolatorBlock defaultReverseArrayBlock = ^(NSArray *array){
    NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:[array count]];
    RosettaStone *stone = [RosettaStone sharedInstance];
    
    for (id object in array) {
      NSDictionary *translatedObject = [stone translateToDictionary:object];
      [results addObject:translatedObject];
    }
    
    return [results copy];
  };
  
  return [self propertyTranslatorForClass:klass fromKey:arrayKey toProperty:arrayPropertyName withInterpolatorBlock:defaultArrayBlock andReverseInterpolatorBlock:defaultReverseArrayBlock];
}

+ (instancetype)propertyTranslatorForClass:(Class)klass
                                   fromKey:(NSString *)keyName
                                toProperty:(NSString *)propertyName
                     withInterpolatorBlock:(ValueInterpolatorBlock)valueInterpolatorBlock
{
  PropertyTranslator *propertyTranslator = [PropertyTranslator new];
  
  propertyTranslator.className = NSStringFromClass(klass);
  propertyTranslator.propertyName = propertyName;
  propertyTranslator.valueInterpolatorBlock = valueInterpolatorBlock;
  propertyTranslator.keyName = keyName;
  
  return propertyTranslator;
}

+ (instancetype)propertyTranslatorForClass:(Class)klass
                                   fromKey:(NSString *)keyName
                                toProperty:(NSString *)propertyName
                     withInterpolatorBlock:(ValueInterpolatorBlock)valueInterpolatorBlock
               andReverseInterpolatorBlock:(ValueInterpolatorBlock)reverseInterpolatorBlock
{
  PropertyTranslator *propertyTranslator = [PropertyTranslator new];
  
  propertyTranslator.className = NSStringFromClass(klass);
  propertyTranslator.propertyName = propertyName;
  propertyTranslator.valueInterpolatorBlock = valueInterpolatorBlock;
  propertyTranslator.reverseInterpolatorBlock = reverseInterpolatorBlock;
  propertyTranslator.keyName = keyName;
  
  return propertyTranslator;
}

@end
