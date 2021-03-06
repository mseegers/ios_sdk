//
//  ADJPackageHandlerTests.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ADJAdjustFactory.h"
#import "ADJLoggerMock.h"
#import "ADJActivityHandlerMock.h"
#import "ADJRequestHandlerMock.h"
#import "ADJTestsUtil.h"

@interface ADJPackageHandlerTests : XCTestCase

@property (atomic,strong) ADJLoggerMock *loggerMock;
@property (atomic,strong) ADJRequestHandlerMock *requestHandlerMock;
@property (atomic,strong) ADJActivityHandlerMock *activityHandlerMock;

@end

@implementation ADJPackageHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    [ADJAdjustFactory setRequestHandler:nil];
    [ADJAdjustFactory setLogger:nil];

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[ADJLoggerMock alloc] init];
    [ADJAdjustFactory setLogger:self.loggerMock];

    self.requestHandlerMock = [ADJRequestHandlerMock alloc];
    [ADJAdjustFactory setRequestHandler:self.requestHandlerMock];

    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];
    self.activityHandlerMock = [[ADJActivityHandlerMock alloc] initWithConfig:config];

    //  delete previously created Package queue file to make a new queue
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoPackageQueue" logger:self.loggerMock], @"%@", self.loggerMock);
}

- (void)testFirstPackage
{
    //  reseting to make the test order independent
    [self reset];

    //  initialize Package Handler
    id<ADJPackageHandler> packageHandler = [ADJAdjustFactory packageHandlerForActivityHandler:self.activityHandlerMock];

    [NSThread sleepForTimeInterval:2.0];

    //  enable sending packages to Request Handler
    [packageHandler resumeSending];

    //  build and add the first package to the queue
    [packageHandler addPackage:[ADJTestsUtil buildEmptyPackage]];

    //  send the first package in the queue to the mock request handler
    [packageHandler sendFirstPackage];

    //  it's necessary to sleep the activity for a while after each handler call
    //  to let the internal queue act
    [NSThread sleepForTimeInterval:1.0];

    //  check that the request handler mock was created
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJRequestHandler initWithPackageHandler"], @"%@", self.loggerMock);

    //  test that the file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Package queue file not found"], @"%@", self.loggerMock);

    //  check that added first package to a previous empty queue
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Added package 1 (session)"], @"%@", self.loggerMock);

    //TODO add the verbose message

    //  it should write the package queue with the first session package
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Package handler wrote 1 packages"], @"%@", self.loggerMock);

    //  check that the Request Handler was called to send the package
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJRequestHandler sendPackage"],  @"%@", self.loggerMock);

    //  check that the the request handler called the package callback, that foward it to the activity handler
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler finishedTrackingWithResponse"],
            @"%@", self.loggerMock);

    //  check that the package was removed from the queue and 0 packages were written
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Package handler wrote 0 packages"], @"%@", self.loggerMock);
}

- (void) testPaused {

    //  reseting to make the test order independent
    [self reset];

    //  initialize Package Handler
    id<ADJPackageHandler> packageHandler = [ADJAdjustFactory packageHandlerForActivityHandler:self.activityHandlerMock];

    [NSThread sleepForTimeInterval:2.0];

    //  disable sending packages to Request Handler
    [packageHandler pauseSending];

    // build and add a package the queue
    [packageHandler addPackage:[ADJTestsUtil buildEmptyPackage]];

    //  try to send the first package in the queue to the mock request handler
    [packageHandler sendFirstPackage];

    [NSThread sleepForTimeInterval:1.0];

    //  check that the request handler mock was created
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJRequestHandler initWithPackageHandler"], @"%@", self.loggerMock);

    //  check that a package was added
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Added package"], @"%@", self.loggerMock);

    //  check that the mock request handler was NOT called to send the package
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJRequestHandler sendPackage"], @"%@", self.loggerMock);

    //  check that the package handler is paused
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Package handler is paused"], @"%@", self.loggerMock);

}

- (void) testMultiplePackages {

    //  reseting to make the test order independent
    [self reset];

    //  initialize Package Handler
    id<ADJPackageHandler> packageHandler = [ADJAdjustFactory packageHandlerForActivityHandler:self.activityHandlerMock];

    [NSThread sleepForTimeInterval:2.0];

    //  enable sending packages to Request Handler
    [packageHandler resumeSending];

    //  build and add the 3 packages to the queue
    [packageHandler addPackage:[ADJTestsUtil buildEmptyPackage]];
    [packageHandler addPackage:[ADJTestsUtil buildEmptyPackage]];
    [packageHandler addPackage:[ADJTestsUtil buildEmptyPackage]];

    //  create a new package handler to simulate a new launch
    [NSThread sleepForTimeInterval:1.0];
    packageHandler = [ADJAdjustFactory packageHandlerForActivityHandler:self.activityHandlerMock];

    //  try to send two packages without closing the first
    [packageHandler sendFirstPackage];
    [packageHandler sendFirstPackage];

    [NSThread sleepForTimeInterval:1.0];

    //  check that the request handler mock was created
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJRequestHandler initWithPackageHandler"], @"%@", self.loggerMock);

    //  test that the file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Package queue file not found"], @"%@", self.loggerMock);

    //  check that added the third package to the queue and wrote to a file
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Added package 3 (session)"], @"%@", self.loggerMock);

    //  check that it reads the same 3 packages in the file
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Package handler read 3 packages"], @"%@", self.loggerMock);

    //  check that the package handler was already sending one package before
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Package handler is already sending"], @"%@", self.loggerMock);
}

- (void) testClickPackage {
    //  reseting to make the test order independent
    [self reset];

    //  initialize Package Handler
    id<ADJPackageHandler> packageHandler = [ADJAdjustFactory packageHandlerForActivityHandler:self.activityHandlerMock];

    [NSThread sleepForTimeInterval:2.0];

    [packageHandler sendClickPackage:[ADJTestsUtil buildEmptyPackage]];

    [NSThread sleepForTimeInterval:1.0];

    //  check if is sending clickPackage
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Sending click package ("], @"%@", self.loggerMock);

    //  check that it prints it in verbose
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Path:      "], @"%@", self.loggerMock);

    // check if request handler got clikPackage
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJRequestHandler sendClickPackage"], @"%@", self.loggerMock);
}

@end
