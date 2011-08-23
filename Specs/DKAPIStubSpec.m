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
            
            NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSArray array], @"errors",
                                         [NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"], @"response",
                                         @"ok", @"status",
                                         nil];
            
            return [DKAPIResponse responseWithResponseDictionary:dictionary];
            
        }];

        [DKAPIRequest requestWithURL:url requestMethod:@"GET" parameters:nil finishBlock:^(DKAPIResponse * response, NSError * error) {
            
            expect([response.data objectForKey:@"bar"]).toEqual(@"foo");
            
            completed = YES;
            
        } delegate:nil];

        while(!completed)
            [NSThread sleepForTimeInterval:0.1];
        
    });
    
});

SPEC_END