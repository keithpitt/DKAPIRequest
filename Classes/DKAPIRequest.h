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

#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"

#import "DKAPICacheStrategy.h"

@class DKAPIResponse;

typedef void (^DKAPIRequestFinishBlock)(DKAPIResponse *, NSError *);

@interface DKAPIRequest : NSObject <ASIHTTPRequestDelegate> {
    
    ASIFormDataRequest * formDataRequest;
    
}

@property (nonatomic, retain) NSDictionary * parameters;

@property (nonatomic, assign) DKAPICacheStrategy cacheStrategy;

@property (nonatomic, retain) id delegate;

@property (nonatomic, retain) NSURL * url;

@property (nonatomic, retain) NSString * requestMethod;

@property (readonly) NSDate * requestStartTime;

@property (readonly) ASIFormDataRequest * formDataRequest;

@property (nonatomic, copy) DKAPIRequestFinishBlock finishBlock;

- (id)initWithURL:(NSURL *)requestURL requestMethod:(NSString *)method parameters:(NSDictionary *)parameters;

- (void)setCacheStrategy:(DKAPICacheStrategy)strategy;

- (void)setDownloadCache:(ASIDownloadCache *)downloadCache;

- (void)startAsynchronous;
 
@end