//
//  SEGRouterExampleTests.m
//  SEGRouterExampleTests
//
//  Created by Samuel E. Giddins on 12/16/13.
//  Copyright (c) 2013 Samuel E. Giddins. All rights reserved.
//

#import <XCTest/XCTest.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#import <SEGRouter.h>

@interface SEGRouterExampleTests : XCTestCase

@property SEGRouter *router;

@end

@implementation SEGRouterExampleTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.router = [[SEGRouter alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNewRouterHasEmptyRoutesArray
{
    expect(self.router.routes).to.equal([NSArray array]);
}

- (void)testAddingNewRouteCallsSubrouteCreationBlock
{
    __block BOOL subrouteCalled = NO;
    [self.router addRoute:@"hi" action:^BOOL(NSDictionary *vars) {
        return YES;
    } subroutes:^(SEGRoute *route) {
        subrouteCalled = YES;
    }];
    expect(subrouteCalled).to.beTruthy();
}

- (void)testAddingNewRouteAddsRoute
{
    [self.router addRoute:@"hi" action:^BOOL(NSDictionary *vars) {
        return YES;
    } subroutes:^(SEGRoute *route) {
    }];
    expect(self.router.routes).to.haveCountOf(1);
}

- (void)testAddingNewRouteWithNilBlocksDoesntRaise
{
    expect(^{[self.router addRoute:@"hi" action:nil subroutes:nil];}).notTo.raise(nil);
}

- (void)testRoutePathTemplateIsOfCorrectType
{
    [self.router addRoute:@"hi" action:^BOOL(NSDictionary *vars) {
        return YES;
    } subroutes:^(SEGRoute *route) {
    }];
    SEGRoute *route = self.router.routes.firstObject;
    expect(route.pathTemplate).to.beKindOf([RKPathTemplate class]);
}

- (void)testRouteWithNoInterpolationIsSelectedWhenOnlyOption
{
    __block BOOL actionCalled = NO;
    [self.router addRoute:@"hi" action:^BOOL(NSDictionary *vars) {
        actionCalled = YES;
        return YES;
    } subroutes:^(SEGRoute *route) {
    }];
    NSURL *url = [NSURL URLWithString:@"scheme:hi"];
    expect([self.router handleURL:url]).to.beTruthy();
    expect(actionCalled).to.beTruthy();
}

- (void)testRouteWithNoInterpolationIsSelectedWhenOnlyMatch
{
    __block BOOL hiActionCalled = NO, byeActionCalled = NO;
    [self.router addRoute:@"hi" action:^BOOL(NSDictionary *vars) {
        hiActionCalled = YES;
        return YES;
    } subroutes:^(SEGRoute *route) {
    }];
    [self.router addRoute:@"bye" action:^BOOL(NSDictionary *vars) {
        byeActionCalled = YES;
        return YES;
    } subroutes:^(SEGRoute *route) {
    }];
    NSURL *url = [NSURL URLWithString:@"scheme:hi"];
    expect([self.router handleURL:url]).to.beTruthy();
    expect(hiActionCalled).to.beTruthy();
    expect(byeActionCalled).to.beFalsy();
}

- (void)testHandlingURLWithNoMathcesReturnsNo
{
    __block BOOL actionCalled = NO;
    [self.router addRoute:@"hi" action:^BOOL(NSDictionary *vars) {
        actionCalled = YES;
        return YES;
    } subroutes:^(SEGRoute *route) {
    }];
    NSURL *url = [NSURL URLWithString:@"scheme:bye"];
    expect([self.router handleURL:url]).to.beFalsy();
    expect(actionCalled).to.beFalsy();
}

@end
