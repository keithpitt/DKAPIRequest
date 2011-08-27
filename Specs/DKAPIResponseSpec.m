//
//  DKAPIResponseSpec.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKAPIResponse.h"
#import "ASIHTTPRequest.h"
#import "DKAPIRequest.h"

SPEC_BEGIN(DKAPIResponseSpec)

context(@"- (id)initWithHTTPRequest:(ASIHTTPRequest *)apiRequest:", ^{
    
    __block DKAPIResponse * response;
    __block id mockedHTTPRequest;
    __block DKAPIRequest * apiRequest;
    
    beforeEach(^{
        
        response = [DKAPIResponse new];
        
        apiRequest = [DKAPIRequest new];
        
        mockedHTTPRequest = [OCMockObject niceMockForClass:[ASIHTTPRequest class]];
        [[[mockedHTTPRequest stub] andReturn:[NSURL URLWithString:@"http://www.mockedhttprequest.com"]] url];
        
        
    });
    
    it(@"should set the headers" , ^{
        
        NSMutableDictionary * headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"json", @"Content-Type", nil];
        [[[mockedHTTPRequest stub] andReturn:headers] responseHeaders];
        
        [response initWithHTTPRequest:mockedHTTPRequest apiRequest:apiRequest];
        
        expect(response.headers).toEqual(headers);
        
        [headers release];
        
    });
    
    it(@"should set the content type", ^{
        
        NSMutableDictionary * headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"http", @"Content-Type", nil];
        [[[mockedHTTPRequest stub] andReturn:headers] responseHeaders];
        
        [response initWithHTTPRequest:mockedHTTPRequest apiRequest:apiRequest];
        
        expect(response.contentType).toEqual(@"http");
        
        [headers release];
        
    });
    
    it(@"should set the status code", ^{
        
        int statusCode = 404;
        
        [[[mockedHTTPRequest stub] andReturnValue:OCMOCK_VALUE(statusCode)] responseStatusCode];
        
        [response initWithHTTPRequest:mockedHTTPRequest apiRequest:apiRequest];
        
        expect(response.statusCode).toEqual(statusCode);
        
    });
    
    it(@"should set the response object if the content type is JSON and the status code is 200", ^{
        
        int statusCode = 200;
        
        // Stub status code
        [[[mockedHTTPRequest stub] andReturnValue:OCMOCK_VALUE(statusCode)] responseStatusCode];
        
        // Stub headers
        NSMutableDictionary * headers = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"json", @"Content-Type", nil];
        [[[mockedHTTPRequest stub] andReturn:headers] responseHeaders];
        
        // Stub response string
        NSString * responseString = @"{ \"response\": { \"foo\": \"bar\" } \"status\": \"ok\" \"errors\": [ \"Error 1\" ] }";
        [[[mockedHTTPRequest stub] andReturn:responseString] responseString];
        
        [response initWithHTTPRequest:mockedHTTPRequest apiRequest:apiRequest];
        
        expect(response.success).toBeTruthy();
        expect([response.error localizedDescription]).toEqual(@"Error 1");
        expect(response.status).toEqual(@"ok");
        expect(response.data).toEqual([NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]);
        
        [headers release];
        
    });
    
});

context(@"- (void)setResponseDictionary:(NSDictionary *);", ^{
        
    __block DKAPIResponse * response;
    
    __block NSDictionary * successResponseDictionary;
    __block NSDictionary * failedResponseDictionary;
    
    beforeEach(^{
       
        response = [DKAPIResponse new];
        
        successResponseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"ok", @"status",
                                     [NSArray arrayWithObject:@"some error"], @"errors",
                                     @"the response", @"response",
                                     nil];
        
        failedResponseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"nok", @"status",
                                    [NSArray arrayWithObject:@"some error"], @"errors",
                                    @"the response", @"response",
                                    nil];
        
    });
    
    it(@"should set the data property", ^{
       
        [response setResponseDictionary:successResponseDictionary];
        
        expect(response.data).toEqual(@"the response");
        
    });
    
    it(@"should set the errors property", ^{
        
        [response setResponseDictionary:successResponseDictionary];
        
        expect([response.errors lastObject]).toEqual(@"some error");
        
    });
    
    it(@"should set the status property", ^{
       
        [response setResponseDictionary:successResponseDictionary];
        
        expect(response.status).toEqual(@"ok");
        
    });
    
    it(@"should set the success property to true if the status is 'ok'", ^{
        
        [response setResponseDictionary:successResponseDictionary];
        
        expect(response.success).toBeTruthy();
        
    });
    
    it(@"should set the success property to false if the status is 'nok'", ^{
        
        [response setResponseDictionary:failedResponseDictionary];
        
        expect(response.success).toBeFalsy();
        
    });
    
});

context(@"- (NSError *)error", ^{
    
    __block DKAPIResponse * response;
    
    beforeEach(^{
        
        response = [DKAPIResponse new];
        response.success = YES;
        
    });
    
    it(@"should make a sentence out of the errors array", ^{
        
        response.errors = [NSArray arrayWithObjects:@"Error 1", @"Error 2", @"Error 3", nil];
        
        expect([response.error localizedDescription]).toEqual(@"Error 1, Error 2 and Error 3");
        
    });
    
    it(@"handle 404 errors", ^{
        
        response.statusCode = 404;
        
        expect([response.error localizedDescription]).toEqual(@"Server could not be found (404)");
        
    });
    
    it(@"should handle 500 errors", ^{
        
        response.statusCode = 500;
        
        expect([response.error localizedDescription]).toEqual(@"Server error (500)");
        
    });
    
    it(@"should handle other HTTP errors", ^{
        
        response.statusCode = 666;
        
        expect([response.error localizedDescription]).toEqual(@"An unknown error occured (666)");
        
    });
    
    it(@"should return nil if the status code is (200 OK)", ^{
        
        response.statusCode = 200;
        
        expect(response.error).toBeNil();
        
    });
    
    it(@"should return an error if the status code is (304 not modified)", ^{
       
        response.statusCode = 304;
        
        expect([response.error localizedDescription]).toEqual(@"An unknown error occured (304)");
        
    });
    
});

SPEC_END