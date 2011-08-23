//
//  DKAPIRequestSpec.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKAPIRequest.h"

SPEC_BEGIN(DKAPIRequestSpec)

describe(@"-(id) init", ^{
    
    it(@"should create a form data request", ^{
        
        DKAPIRequest * request = [[DKAPIRequest alloc] init];
        
        expect(request.formDataRequest).Not.toBeNil();
        
    });
    
});

SPEC_END