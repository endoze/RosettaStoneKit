//
//  RosettaStone.h
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

@class PropertyTranslator;

@interface RosettaStone : NSObject

/*!
 @brief NSDateFormatter used to convert strings into date objects.
 */
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

/*!
 @brief Returns a shared singleton object.
 */
+ (instancetype)sharedInstance;

/*!
 @brief Register a new property translator with RosettaStone.
 @param propertyTranslater - The property translator you'd like to register with Rosetta Stone.
 @return void
 */
- (void)registerPropertyTranslator:(PropertyTranslator *)propertyTranslator;


/*!
 @brief Translate a dictionary into an instance of the given class
 @param dictionary - The dictionary containing values you'd like translated to a new instance of the specified class.
 @param klass - The target class you'd like to create a new instance of with the values in the dictionary.
 @return id - The class returned is based on the klass parameter.
 */
- (id)translate:(NSDictionary *)dictionary toClass:(Class)klass;

/*!
 @brief Translate an object into a dictionary with values based on the objects properties.
 @param object - The object having properties you'd like translated to a new instance of NSDictionary.
 @return NSDictionary
 */
- (NSDictionary *)translateToDictionary:(id)object;

/*!
 @brief Translate an array of dictionaries into an array of objects with the specified class.
 @param array - The array containing dictionaries you'd like translated to objects of the specified class.
 @param klass - The target class you'd like each object in the dictionary to be.
 @return NSArray
 */
- (NSArray *)translate:(NSArray *)array toArrayOfClass:(Class)klass;

/*!
 @brief Translate an array of objects into an array of dictionaries.
 @param array - The array of objects you'd like translated.
 @return NSArray
 */
- (NSArray *)translateArrayToDictionaries:(NSArray *)array;

@end
