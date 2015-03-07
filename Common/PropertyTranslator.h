//
//  PropertyTranslator.h
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

#import <Foundation/Foundation.h>

typedef id(^ValueInterpolatorBlock)(id propertyValue);

@interface PropertyTranslator : NSObject

/*!
 @brief This is the class that this property translator is associated with.
 */
@property (nonatomic, copy) NSString *className;

/*!
 @brief This is the key used when pulling values out of an NSDictionary.
 */
@property (nonatomic, copy) NSString *keyName;

/*!
 @brief This is the name of the property that should be used in translating to and from objects.
 */
@property (nonatomic, copy) NSString *propertyName;

/*!
 @brief This block can be used to convert the value pulled out of a dictionary before being
        assigned to an object's property.
 */
@property (nonatomic, copy) ValueInterpolatorBlock valueInterpolatorBlock;

/*!
 @brief This block can be used to convert the value returned from an object's property before
        being assigned to a dictionary's key.
 */
@property (nonatomic, copy) ValueInterpolatorBlock reverseInterpolatorBlock;

/*!
 @brief This is a convenience method to return a new property translator based on the method parameters.
 @return PropertyTranslator
 */
+ (instancetype)propertyTranslatorForClass:(Class)klass fromKey:(NSString *)key toProperty:(NSString *)propertyName;


/*!
 @brief This is a convenience method to return a new property translator based on the method parameters.
 @return PropertyTranslator
 */
+ (instancetype)propertyTranslatorForClass:(Class)klass fromArrayKey:(NSString *)arrayKey toArrayProperty:(NSString *)arrayPropertyName withClass:(Class)arrayClass;

/*!
 @brief This is a convenience method to return a new property translator based on the method parameters.
 @return PropertyTranslator
 */
+ (instancetype)propertyTranslatorForClass:(Class)klass fromKey:(NSString *)key toProperty:(NSString *)propertyName withInterpolatorBlock:(ValueInterpolatorBlock)valueInterpolatorBlock;

/*!
 @brief This is a convenience method to return a new property translator based on the method parameters.
 @return PropertyTranslator
 */
+ (instancetype)propertyTranslatorForClass:(Class)klass fromKey:(NSString *)key toProperty:(NSString *)propertyName withInterpolatorBlock:(ValueInterpolatorBlock)valueInterpolatorBlock andReverseInterpolatorBlock:(ValueInterpolatorBlock)reverseInterpolatorBlock;

@end
