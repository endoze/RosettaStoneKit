//
//  NSDictionaryExtensionsSpec.m
//  RosettaStoneKit
//
//  Created by Chris Stephan on 1/16/15.
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

#define EXP_SHORTHAND
#import <Specta/Specta.h>
#import "Expecta.h"

#import "NSDictionary+RosettaStoneExtensions.h"

SpecBegin(NSDictionaryExtensions)
  describe(@"NSDictionaryExtensions", ^{
    describe(@"hasKey:", ^{
      it(@"should return true when a dictionary has a key", ^{
        NSDictionary *dictionary = @{@"key": @"value"};
        
        expect([dictionary rsk_hasKey:@"key"]).to.beTruthy;
      });
      
      it(@"should return false when a dictionary doesn't have a key", ^{
        NSDictionary *dictionary = @{};
        
        expect([dictionary rsk_hasKey:@"key"]).to.beFalsy;
      });
    });
  });
SpecEnd
