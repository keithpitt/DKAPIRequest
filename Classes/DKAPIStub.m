//
//  DKAPIRequestStub.m
//  DiscoKit
//
//  Created by Keith Pitt on 12/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIStub.h"

#import "DKAPIRequest.h"

@implementation DKAPIStub

@synthesize stubBlock;

static NSMutableArray * stubs;

+ (NSMutableArray *)stubs {
    
    if (stubs == nil)
        stubs = [[NSMutableArray alloc] init];
    
    return stubs;
    
}

+ (DKAPIStub *)stubWithBlock:(DKAPIStubBlock)callback {
    
    // Create the API Stub
    DKAPIStub * stub = [[DKAPIStub alloc] initWithBlock:callback];
    
    [[self stubs] addObject:stub];
    
    return [stub autorelease];
    
}

+ (DKAPIResponse *)performWithAPIRequest:(DKAPIRequest *)apiRequest {
    
    // Do we have any stubs?
    if ([[self stubs] count] == 0)
        return false;
    
    // Grab the next stub
    DKAPIStub * stub = (DKAPIStub *)[stubs lastObject];
    
    // Run the stub
    DKAPIResponse * response = [stub responseWithAPIRequest:apiRequest];
    
    // Remove it from list
    [stubs removeObject:response];
    
    return response;
    
}

- (id)initWithBlock:(DKAPIStubBlock)block {
    
    if ((self = [super init]))
        self.stubBlock = block;
    
    return self;
    
}

- (DKAPIResponse *)responseWithAPIRequest:(DKAPIRequest *)apiRequest {
    
    return (DKAPIResponse *)self.stubBlock(apiRequest);
    
}

- (void)dealloc {
    
    self.stubBlock = nil;
    
    [super dealloc];
    
}

@end