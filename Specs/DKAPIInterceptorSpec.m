//
//  DKAPIInterceptorSpec.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKAPIInterceptor.h"
#import "DKAPIResponse.h"
#import "DKAPIRequest.h"

#import "MockInterceptor.h"

SPEC_BEGIN(DKAPIInterceptorSpec)

afterEach(^{
   
    [[DKAPIInterceptor interceptors] removeAllObjects];
    
});

context(@"+ (void)addInterceptor:", ^{
    
    it(@"should add an interceptor", ^{
        
        MockInterceptor * mockInterceptor = [MockInterceptor new];
        
        [DKAPIInterceptor addInterceptor:mockInterceptor];
        
        expect([[DKAPIInterceptor interceptors] count]).toEqual(1);
        
        [mockInterceptor release];
        
    });
    
});

context(@"+ (void)removeInterceptor:", ^{
    
    it(@"should remove an interceptor", ^{
        
        MockInterceptor * mockInterceptor = [MockInterceptor new];
        
        [DKAPIInterceptor addInterceptor:mockInterceptor];
        [DKAPIInterceptor removeInterceptor:mockInterceptor];
        
        expect([[DKAPIInterceptor interceptors] count]).toEqual(0);
        
        [mockInterceptor release];
        
    });
    
});

context(@"+ (BOOL)performDelegation:withObject:withObject:", ^{
    
    __block id mockInterceptor;
    
    __block DKAPIRequest * apiRequest = [DKAPIRequest new];
    __block DKAPIResponse * apiResponse = [DKAPIResponse new];
    
    beforeEach(^{
        
        mockInterceptor = [OCMockObject mockForProtocol:@protocol(DKAPIInterceptorProtocol)];
        
        [DKAPIInterceptor addInterceptor:mockInterceptor];
        
    });
    
    it(@"should perform the selector on each interceptor", ^{
        
        [[mockInterceptor expect] interceptedAPIRequest:apiRequest handleAPIResponse:apiResponse];
        
        [DKAPIInterceptor performDelegation:@selector(interceptedAPIRequest:handleAPIResponse:) withObject:apiRequest withObject:apiResponse];
        
    });
    
    it(@"should return YES if they all return TRUE", ^{
        
        BOOL yes = YES;
        
        [[[mockInterceptor expect] andReturnValue:OCMOCK_VALUE(yes)] interceptedAPIRequest:apiRequest handleAPIResponse:apiResponse];
        
        BOOL result = [DKAPIInterceptor performDelegation:@selector(interceptedAPIRequest:handleAPIResponse:) withObject:apiRequest withObject:apiResponse];
        
        expect(result).toBeTruthy();
        
    });
    
    it(@"should return NO if one returns NO", ^{
        
        BOOL no = NO;
        
        [[[mockInterceptor expect] andReturnValue:OCMOCK_VALUE(no)] interceptedAPIRequest:apiRequest handleAPIResponse:apiResponse];
        
        BOOL result = [DKAPIInterceptor performDelegation:@selector(interceptedAPIRequest:handleAPIResponse:) withObject:apiRequest withObject:apiResponse];
        
        expect(result).toBeFalsy();
        
    });
    
});

SPEC_END