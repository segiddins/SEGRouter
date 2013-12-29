// SEGRouter.m
// 
// Copyright (c) 2013 Samuel E. Giddins
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
// 
// Redistributions of source code must retain the above copyright notice, this 
// list of conditions and the following disclaimer. Redistributions in binary 
// form must reproduce the above copyright notice, this list of conditions and 
// the following disclaimer in the documentation and/or other materials 
// provided with the distribution. Neither the name of the nor the names of 
// its contributors may be used to endorse or promote products derived from 
// this software without specific prior written permission. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.

#import "SEGRouter.h"

@interface SEGRouter ()

@property (nonatomic, strong) NSMutableSet *mutableRoutes;

@end

@interface SEGRoute ()

@property (nonatomic, strong, readwrite) RKPathTemplate *pathTemplate;

+ (instancetype)routeWithPath:(NSString *)path action:(BOOL (^)(NSDictionary *))action;

@property (nonatomic, strong) NSMutableArray *subroutes;

@property (nonatomic, copy) BOOL (^action)(NSDictionary *);
- (NSArray *)allRoutes;

@property (nonatomic, weak) SEGRoute *parentRoute;

- (void)open:(NSDictionary *)variables;

@end

@implementation SEGRouter

+ (instancetype)routerWithScheme:(NSString *)scheme
{
    NSAssert(scheme, @"Scheme can't be `nil`");
    static NSMutableDictionary *dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionary];
    });
    SEGRouter *router = dictionary[scheme];
    if (!router) {
        router = [self new];
        dictionary[scheme] = router;
    }
    return router;
}

- (id)init
{
    if (!(self = [super init])) return nil;
    self.mutableRoutes = [NSMutableSet set];
    return self;
}

- (NSArray *)routes
{
    return [self.mutableRoutes allObjects];
}

- (void)addRoute:(NSString *)routePath
          action:(BOOL (^)(NSDictionary *))action
       subroutes:(void (^)(SEGRoute *))subrouteCreation
{
    SEGRoute *route = [SEGRoute routeWithPath:routePath action:action];
    if (subrouteCreation) subrouteCreation(route);
    [self.mutableRoutes addObjectsFromArray:[route allRoutes]];
}

- (BOOL)handleURL:(NSURL *)URL
{
    __block NSDictionary *variables;
    __block BOOL success;
    [self.mutableRoutes enumerateObjectsUsingBlock:^(SEGRoute *route, BOOL *stop) {
        if ((success = [route.pathTemplate matchesPath:URL.resourceSpecifier variables:&variables])) {
            [route open:variables];
            *stop = YES;
        }
    }];
    return success;
}

@end

@implementation SEGRoute

+ (instancetype)routeWithPath:(NSString *)path
                       action:(BOOL (^)(NSDictionary *))action
{
    return [self routeWithPathTemplate:[RKPathTemplate pathTemplateWithString:path] action:action];
}

+ (instancetype)routeWithPathTemplate:(RKPathTemplate *)pathTemplate
                               action:(BOOL (^)(NSDictionary *))action
{
    SEGRoute *route =  [[self alloc] init];
    route.pathTemplate = pathTemplate;
    route.action = action;
    return route;
}

- (id)init
{
    if (!(self = [super init])) return nil;
    self.subroutes = [NSMutableArray array];
    return self;
}

- (void)addSubroute:(NSString *)subroute
             action:(BOOL (^)(NSDictionary *))action
          subroutes:(void (^)(SEGRoute *))subrouteCreation
{
    NSString *path = [[self.pathTemplate valueForKey:@"pathTemplate"] stringByAppendingPathComponent:subroute];
    SEGRoute *route = [[self class] routeWithPath:path action:action];
    if (subrouteCreation) subrouteCreation(route);
    route.parentRoute = self;
    [self.subroutes addObject:route];
}

- (void)open:(NSDictionary *)variables
{
    [self.parentRoute open:variables];
    if (self.action) self.action(variables);
}

- (NSArray *)allRoutes
{
    NSMutableArray *routes = [NSMutableArray arrayWithObject:self];
    for (SEGRoute *subroute in self.subroutes) {
        [routes addObjectsFromArray:[subroute allRoutes]];
    }
    return routes;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p: pathTemplate:%@>", NSStringFromClass(self.class), self, self.pathTemplate];
}

@end
