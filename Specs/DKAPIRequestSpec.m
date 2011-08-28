//
//  DKAPIRequestSpec.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKAPIRequest.h"
#import "DKAPIStub.h"

SPEC_BEGIN(DKAPIRequestSpec)

describe(@"-(id) init", ^{
    
    it(@"should create a form data request", ^{
        
        DKAPIRequest * request = [[DKAPIRequest alloc] init];
        
        expect(request.formDataRequest).Not.toBeNil();
        
        [request release];
        
    });
    
});

describe(@"- (void)startAsynchronous", ^{
    
    it(@"should not call the finish block for a successful response", ^{
        
        __block BOOL completed = NO;
        
        [DKAPIStub stubWithBlock:^(DKAPIRequest * request) {
           
            return [DKAPIResponse responseWithStatus:@"ok" data:nil errors:nil];
            
        }];
        
        DKAPIRequest * request = [[DKAPIRequest alloc] initWithURL:[NSURL URLWithString:@"http://testing_url"]
                                                     requestMethod:HTTP_GET_VERB 
                                                        parameters:nil];
    
        request.finishBlock = ^(DKAPIResponse *response, NSError *error){
            expect(error).toBeNil();
            expect(response).Not.toBeNil();
            completed = YES;
        };    
        
        [request startAsynchronous];
        
        [request release];
        
        while(completed == NO) {
            [NSThread sleepForTimeInterval:0.1];
        }
    
    });
    
    it(@"should not call the finish blockr with a response object for an unsuccessful response", ^{
    
        __block BOOL completed = NO;
        
        [DKAPIStub stubWithBlock:^(DKAPIRequest * request) {
            
            return [DKAPIResponse responseWithStatus:@"nok" data:nil errors:nil];
            
        }];
        
        DKAPIRequest * request = [[DKAPIRequest alloc] initWithURL:[NSURL URLWithString:@"http://testing_url"]
                                                     requestMethod:HTTP_GET_VERB 
                                                        parameters:nil];
        
        request.finishBlock = ^(DKAPIResponse *response, NSError *error){
            expect(error).Not.toBeNil();
            expect(response).toBeNil();
            completed = YES;
        };    
        
        [request startAsynchronous];
        
        [request release];
        
        while(completed == NO) {
            [NSThread sleepForTimeInterval:0.1];
        }
    
    });
    
});

SPEC_END