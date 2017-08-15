//
//  RosettaStoneSpec.m
//  RosettaStoneKit
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

#define EXP_SHORTHAND
#import <Specta/Specta.h>
#import "Expecta.h"
#import <RosettaStoneKit/RosettaStoneKit.h>
#import <objc/runtime.h>

#import "Game.h"
#import "TestModel.h"
#import "TestUser.h"

SpecBegin(RosettaStoneSpec)
  describe(@"RosettaStone", ^{
    describe(@"sharedInstance", ^{
      it(@"should always return the same instance", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        expect(stone).to.equal([RosettaStone sharedInstance]);
      });
    });
    
    describe(@"registerCase:", ^{
      it(@"should register a PropertyTranslator under a specific className/propertyName", ^{
        PropertyTranslator *propertyTranslator = [PropertyTranslator propertyTranslatorForClass:[TestModel class]
                                           fromKey:@"id"
                                        toProperty:@"ID"];
        RosettaStone *stone = [RosettaStone sharedInstance];
        [stone registerPropertyTranslator:propertyTranslator];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        PropertyTranslator *expectedPropertyTranslator = [[[stone performSelector:@selector(propertyTranslatorByClassString)] valueForKey:propertyTranslator.className] valueForKey:propertyTranslator.propertyName];
        #pragma clang diagnostic pop
        
        expect(propertyTranslator).to.equal(expectedPropertyTranslator);
      });
    });
    
    describe(@"translate:toClass:", ^{
      it(@"should pass back an instance of the specified class", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDictionary *objectDictionary = @{@"name": @"bob", @"ID": @20};
        TestModel *model = [stone translate:objectDictionary toClass:[TestModel class]];
        expect(model).to.beInstanceOf([TestModel class]);
      });
      
      it(@"should have the name and ID properties set", ^{
        PropertyTranslator *propertyTranslator = [PropertyTranslator propertyTranslatorForClass:[TestModel class]
                                           fromKey:@"id"
                                        toProperty:@"ID"];
        RosettaStone *stone = [RosettaStone sharedInstance];
        [stone registerPropertyTranslator:propertyTranslator];
        NSDictionary *objectDictionary = @{@"name": @"bob", @"id": @20};
        TestModel *model = [stone translate:objectDictionary toClass:[TestModel class]];
        expect(model.name).to.equal(@"bob");
        expect(model.ID).to.equal(@20);
      });
      
      it(@"should resolve nested objects recursively", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDictionary *userDictionary = @{@"testModel": @{@"name": @"bob", @"ID": @20}};
        TestUser *user = [stone translate:userDictionary toClass:[TestUser class]];
        expect(user.testModel).to.beInstanceOf([TestModel class]);
      });
      
      it(@"should support arrays of custom objects", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        PropertyTranslator *collectionTranslator = [PropertyTranslator propertyTranslatorForClass:[TestUser class] fromArrayKey:@"games" toArrayProperty:@"games" withClass:[Game class]];
        [stone registerPropertyTranslator:collectionTranslator];
        NSDictionary *userDictionary = @{@"games": @[ @{@"name": @"foosball championship", @"gameId": @10}, @{@"name": @"ping pong championship", @"gameId": @11} ]};
        TestUser *user = [stone translate:userDictionary toClass:[TestUser class]];
        expect([user.games firstObject]).to.beInstanceOf([Game class]);
      });

      it(@"should translate dates from strings", ^{
        NSString *dateString = @"2015-10-15T19:24:40.669Z";
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDictionary *gameDictionary = @{@"name": @"foosball championship", @"gameId": @11, @"date": dateString};
        Game *game = [stone translate:gameDictionary toClass:[Game class]];
        expect([game date]).to.equal(date);
      });
      
      it(@"should handle null values for object types", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDictionary *userDictionary = @{@"testModel": [NSNull null]};
        TestUser *user = [stone translate:userDictionary toClass:[TestUser class]];
        expect([user testModel]).to.equal(nil);
      });
      
      it(@"should handle null values for array types", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        PropertyTranslator *collectionTranslator = [PropertyTranslator propertyTranslatorForClass:[TestUser class] fromArrayKey:@"games" toArrayProperty:@"games" withClass:[Game class]];
        [stone registerPropertyTranslator:collectionTranslator];
        NSDictionary *userDictionary = @{@"games": [NSNull null]};
        TestUser *user = [stone translate:userDictionary toClass:[TestUser class]];
        expect([user games]).to.equal(@[]);
      });
    });
    
    describe(@"translateToDictionary:", ^{
      it(@"should pass back an instance of NSDictionary", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        TestModel *model = [TestModel new];
        model.name = @"bob";
        model.ID = @20;
        NSDictionary *objectDictionary = [stone translateToDictionary:model];
        expect(objectDictionary).to.beKindOf([NSDictionary class]);
      });
      
      it(@"should have the name and id properties set", ^{
        PropertyTranslator *propertyTranslator = [PropertyTranslator propertyTranslatorForClass:[TestModel class]
                                           fromKey:@"id"
                                        toProperty:@"ID"];
        RosettaStone *stone = [RosettaStone sharedInstance];
        [stone registerPropertyTranslator:propertyTranslator];
        TestModel *model = [TestModel new];
        model.name = @"bob";
        model.ID = @20;
        NSDictionary *objectDictionary = [stone translateToDictionary:model];
        NSDictionary *expectedDictionary = @{
          @"name": @"bob",
          @"id": @20,
          @"integerCount": @0,
          @"doubleCount": @0,
          @"floatCount": @0,
          @"active": @0
        };
        expect(objectDictionary).to.equal(expectedDictionary);
      });
      
      it(@"should resolve nested objects recursively", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        TestUser *user = [TestUser new];
        TestModel *model = [TestModel new];
        model.name = @"bob";
        model.ID = @20;
        user.testModel = model;
        NSDictionary *userDictionary = [stone translateToDictionary:user];
        NSDictionary *expectedDictionary = @{
          @"name": @"bob",
          @"id": @20,
          @"integerCount": @0,
          @"doubleCount": @0,
          @"floatCount": @0,
          @"active": @0
        };
        expect(userDictionary[@"testModel"]).to.equal(expectedDictionary);
      });
      
      it(@"should support arrays of custom objects", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        TestUser *user = [TestUser new];
        Game *foosball = [Game new];
        foosball.name = @"foosball championship";
        foosball.gameId = @10;
        Game *pingPong = [Game new];
        pingPong.name = @"ping pong championship";
        pingPong.gameId = @11;
        user.games = @[foosball, pingPong];
        NSDictionary *userDictionary = [stone translateToDictionary:user];
        NSArray *games = @[
           @{@"name": @"foosball championship", @"gameId": @10},
           @{@"name": @"ping pong championship", @"gameId": @11}
        ];
        expect(userDictionary[@"games"]).to.equal(games);
      });

      it(@"should translate dates to strings", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDate *now = [NSDate new];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        Game *game = [Game new];
        game.name = @"foosball championship";
        game.date = now;
        game.gameId = @25;
        NSDictionary *gameDictionary = [stone translateToDictionary:game];
        expect([gameDictionary objectForKey:@"date"]).to.equal([dateFormatter stringFromDate:now]);
      });
      
      it(@"should handle nil property values", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDate *now = [NSDate new];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        Game *game = [Game new];
        game.date = now;
        game.gameId = @25;
        NSDictionary *gameDictionary = [stone translateToDictionary:game];
        expect([gameDictionary objectForKey:@"name"]).to.equal(nil);
      });
      
      it(@"should handle nil array property values", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        TestUser *user = [TestUser new];
        NSDictionary *userDictionary = [stone translateToDictionary:user];
        expect(userDictionary[@"games"]).to.equal(@[]);
      });
    });
    
    describe(@"classOfProperty:", ^{
      it(@"should return TestModel for a TestModel property", ^{
        unsigned int propertiesCount;
        objc_property_t *properties = class_copyPropertyList([TestUser class], &propertiesCount);
        objc_property_t property = properties[0];
        
        RosettaStone *stone = [RosettaStone sharedInstance];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        Class klass = [stone performSelector:@selector(classOfProperty:) withObject:(__bridge id)(property)];
        #pragma clang diagnostic pop
        
        expect(klass).to.equal([TestModel class]);
      });
    
      it(@"should return NSNumber for an integer property", ^{
        unsigned int propertiesCount;
        objc_property_t *properties = class_copyPropertyList([TestModel class], &propertiesCount);
        objc_property_t property = properties[2];
        
        RosettaStone *stone = [RosettaStone sharedInstance];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        Class klass = [stone performSelector:@selector(classOfProperty:) withObject:(__bridge id)(property)];
        #pragma clang diagnostic pop
        
        expect(klass).to.equal([NSNumber class]);
      });
    
      it(@"should return NSNumber for a double property", ^{
        unsigned int propertiesCount;
        objc_property_t *properties = class_copyPropertyList([TestModel class], &propertiesCount);
        objc_property_t property = properties[3];
        
        RosettaStone *stone = [RosettaStone sharedInstance];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        Class klass = [stone performSelector:@selector(classOfProperty:) withObject:(__bridge id)(property)];
        #pragma clang diagnostic pop
        
        expect(klass).to.equal([NSNumber class]);
      });
    
      it(@"should return NSNumber for a float property", ^{
        unsigned int propertiesCount;
        objc_property_t *properties = class_copyPropertyList([TestModel class], &propertiesCount);
        objc_property_t property = properties[4];
        
        RosettaStone *stone = [RosettaStone sharedInstance];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        Class klass = [stone performSelector:@selector(classOfProperty:) withObject:(__bridge id)(property)];
        #pragma clang diagnostic pop
        
        expect(klass).to.equal([NSNumber class]);
      });
    
      it(@"should return NSNumber for a BOOL property", ^{
        unsigned int propertiesCount;
        objc_property_t *properties = class_copyPropertyList([TestModel class], &propertiesCount);
        objc_property_t property = properties[5];
        
        RosettaStone *stone = [RosettaStone sharedInstance];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        Class klass = [stone performSelector:@selector(classOfProperty:) withObject:(__bridge id)(property)];
        #pragma clang diagnostic pop
        
        expect(klass).to.equal([NSNumber class]);
      });
    });
    
    describe(@"propertyMapForClass:", ^{
      it(@"should return a dictionary with the correct property names and property classes",^{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary: @{
          @"name": [NSString class],
          @"ID": [NSNumber class],
          @"integerCount": [NSNumber class],
          @"doubleCount": [NSNumber class],
          @"floatCount": [NSNumber class],
          @"active": [NSNumber class]
        }];
        RosettaStone *stone = [RosettaStone sharedInstance];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        NSDictionary *propertyMap = [stone performSelector:@selector(propertyMapForClass:) withObject:[TestModel class]];
        #pragma clang diagnostic pop
        
        expect(propertyMap).to.equal(dictionary);
      });
      
      it(@"should return a cached copy of a property map for a class it's already translated", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        NSDictionary *propertyMap = [stone performSelector:@selector(propertyMapForClass:) withObject:[TestModel class]];
        NSDictionary *secondPropertyMap = [stone performSelector:@selector(propertyMapForClass:) withObject:[TestModel class]];
        #pragma clang diagnostic pop
        
        expect(propertyMap).to.beIdenticalTo(secondPropertyMap);
      });
    });
    
    describe(@"dateFormatter", ^{
      it(@"should return the default formatter if one hasn't been set", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDateFormatter *formatter = [stone dateFormatter];
        
        expect(formatter.dateFormat).to.equal(@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
      });
      
      it(@"should return the formatter when the proeprty is set", ^{
        RosettaStone *stone = [RosettaStone sharedInstance];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [stone setDateFormatter:formatter];
        
        expect(formatter.dateFormat).to.equal([[stone dateFormatter] dateFormat]);
      });
    });
  });
SpecEnd
