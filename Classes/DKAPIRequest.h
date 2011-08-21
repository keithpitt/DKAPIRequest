//
//  DKAPIRequest.h
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HTTP_GET_VERB @"GET"
#define HTTP_PUT_VERB @"PUT"
#define HTTP_POST_VERB @"POST"
#define HTTP_DELETE_VERB @"DELETE"

#import "DKAPIResponse.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "DKAPIInterceptorProtocol.h"

@class DKAPIRequest;
@class DKAPIRequestStub;

typedef void (^DKAPIRequestSuccessCallback)(DKAPIResponse *);
typedef void (^DKAPIRequestErrorCallback)(DKAPIResponse *);

@interface DKAPIRequest : NSObject <ASIHTTPRequestDelegate> {
    
    NSDate * requestStartTime;
    
}

@property (nonatomic, copy) DKAPIRequestSuccessCallback successCallback;
@property (nonatomic, copy) DKAPIRequestErrorCallback errorCallback;

@property (nonatomic, retain) NSString * requestURL;
@property (nonatomic, retain) NSString * httpMethod;
@property (nonatomic, retain) NSDictionary * data;
@property (nonatomic, retain) NSDictionary * files;

@property (nonatomic, assign) ASICachePolicy cachePolicy;
@property (nonatomic, assign) ASICacheStoragePolicy cacheStoragePolicy;
@property (nonatomic, retain) ASIDownloadCache * downloadCache;

@property (nonatomic, retain) id uploadProgressDelegate;
@property (nonatomic, retain) id downloadProgressDelegate;

+ (NSArray *)interceptors;
+ (void)addInterceptor:(id <DKAPIInterceptorProtocol>)interceptor;
+ (void)removeInterceptor:(id <DKAPIInterceptorProtocol>)interceptor;

+ (void)stubNextRequest:(DKAPIRequestStub *)requestStub;

- (void)get:(NSString *)url;
- (void)post:(NSString *)url;
- (void)put:(NSString *)url;
- (void)delete:(NSString *)url;

- (ASIFormDataRequest *)request;
- (void)send;

- (NSDictionary *)serialize:(NSDictionary *)dataToSerialize;
 
@end