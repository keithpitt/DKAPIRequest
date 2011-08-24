//
//  DKAPIStubSpec.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKAPIStub.h"
#import "DKAPIRequest.h"

SPEC_BEGIN(DKAPIStubSpec)

context(@"+ (DKAPIStub *)stubWithBlock:", ^{
    
    it(@"should allow you to stub out requests", ^{
    
        __block BOOL completed = NO;

        __block NSURL * url = [NSURL URLWithString:@"http://www.google.com"];

        [DKAPIStub stubWithBlock:^(DKAPIRequest * apiRequest) {
            
            expect([apiRequest.url absoluteString]).toEqual(@"http://www.google.com");
            expect([apiRequest.formDataRequest.url absoluteString]).toEqual(@"http://www.google.com?people=crab");
            
            return [DKAPIResponse responseWithStatus:@"ok"
                                                data:[NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"]
                                              errors:nil];
            
        }];

        [DKAPIRequest requestWithURL:url
                       requestMethod:HTTP_GET_VERB
                          parameters:[NSDictionary dictionaryWithObject:@"crab" forKey:@"people"]
                         finishBlock:^(DKAPIResponse * response, NSError * error) {
            
            expect([response.data objectForKey:@"bar"]).toEqual(@"foo");
            
            completed = YES;
            
        } delegate:nil];

        while(!completed)
            [NSThread sleepForTimeInterval:0.1];
        
    });
    
});

SPEC_END