//
//  DKAPIRequestStub.m
//  DiscoKit
//
//  Created by Keith Pitt on 12/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DKAPIRequestStub.h"

@implementation DKAPIRequestStub

@synthesize stubbedCallback;

+ (DKAPIRequestStub *)requestStubWithBlock:(DKAPIRequestStubCallback)callback {
    
    DKAPIRequestStub * requestStub = [DKAPIRequestStub new];
    requestStub.stubbedCallback = callback;
    
    return [requestStub autorelease];
    
}

- (DKAPIResponse *)responseWithFormDataRequest:(ASIFormDataRequest *)formRequest {
    
    return (DKAPIResponse *)self.stubbedCallback(formRequest);
    
}

@end