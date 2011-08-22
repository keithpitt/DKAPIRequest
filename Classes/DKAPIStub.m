//
//  DKAPIRequestStub.m
//  DiscoKit
//
//  Created by Keith Pitt on 12/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIStub.h"

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

+ (DKAPIResponse *)performWithFormDataRequest:(ASIFormDataRequest *)formDataRequest {
    
    // Do we have any stubs?
    if ([[self stubs] count] == 0)
        return false;
    
    // Grab the next stub
    DKAPIStub * stub = (DKAPIStub *)[stubs lastObject];
    
    // Run the stub
    DKAPIResponse * response = [stub responseWithFormDataRequest:formDataRequest];
    
    // Release the stub
    [stub release];
    
    // Remove it from list
    [stubs removeObject:response];
    
    return response;
    
}

- (id)initWithBlock:(DKAPIStubBlock)block {
    
    if ((self = [super init]))
        self.stubBlock = block;
    
    return self;
    
}

- (DKAPIResponse *)responseWithFormDataRequest:(ASIFormDataRequest *)formRequest {
    
    return (DKAPIResponse *)self.stubBlock(formRequest);
    
}

- (void)dealloc {
    
    self.stubBlock = nil;
    
    [super dealloc];
    
}

@end