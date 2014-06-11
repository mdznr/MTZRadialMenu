//
//  Example_AppTests.m
//  Example AppTests
//
//  Created by Matt Zanchelli on 6/10/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Example_AppTests : XCTestCase

@end

@implementation Example_AppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
