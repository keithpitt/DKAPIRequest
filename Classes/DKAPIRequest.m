//
//  DKAPIRequest.m
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIRequest.h"

#import "DKAPIStub.h"
#import "DKAPIInterceptor.h"

#import "DKAPIResponse.h"
#import "DKAPIFormData.h"

#import "DKAPILogger.h"

@implementation DKAPIRequest

@synthesize finishBlock, parameters, formDataRequest;

@synthesize uploadProgressDelegate, downloadProgressDelegate;

@synthesize cacheStrategy;

@synthesize requestStartTime;

- (id)initWithURL:(NSURL *)requestURL requestMethod:(NSString *)method parameters:(NSDictionary *)params {

    if ((self = [super init])) {
        
        formDataRequest = [[ASIFormDataRequest alloc] initWithURL:requestURL];

        formDataRequest.requestMethod = method;
        formDataRequest.delegate = self;
        formDataRequest.timeOutSeconds = 120;
        formDataRequest.shouldAttemptPersistentConnection = NO;
        formDataRequest.showAccurateProgress = YES;
        
        self.parameters = params;

    }

    return self;

}

- (NSURL *)url {
    
    return formDataRequest.url;
    
}

- (NSString *)requestMethod {
    
    return formDataRequest.requestMethod;
    
}

- (void)setDownloadCache:(ASIDownloadCache *)downloadCache {
    
    formDataRequest.downloadCache = downloadCache;
    
}

- (void)setCacheStrategy:(DKAPICacheStrategy)strategy {
    
    cacheStrategy = strategy;
    
    switch (strategy) {
            
        case DKAPICacheStrategySession:
            
            formDataRequest.cacheStoragePolicy = ASICacheForSessionDurationCacheStoragePolicy;
            
            break;
            
        case DKAPICacheStrategyPersisted:
            
            formDataRequest.cacheStoragePolicy = ASICachePermanentlyCacheStoragePolicy;
            
            break;

    }
    
}

- (void)startAsynchronous {
    
    // Start the timer
    requestStartTime = [[NSDate alloc] init];
    
    // Ensure we always have post data
    NSMutableDictionary * postData = self.parameters ? [[self.parameters mutableCopy] autorelease] : [NSMutableDictionary dictionary];
    
    // Pass the post data to the interceptors for changing
    [DKAPIInterceptor performDelegation:@selector(interceptedAPIRequest:preparePostData:) withObject:self withObject:postData];
    
    // If we now have any data
    if ([[postData allKeys] count] > 0) {
        
        // Create the form data
        DKAPIFormData * formData = [[DKAPIFormData alloc] initWithDictionary:postData];
        
        if ([formDataRequest.requestMethod isEqualToString:HTTP_GET_VERB]) {
            
            // If this is a GET request, add the parameters to the current URL
            formDataRequest.url = [formData urlWithPostData:self.url];
            
        } else {
            
            // Add any files found in the serialized results
            for (NSDictionary * param in formData.files)
                [formDataRequest setFile:[param objectForKey:@"value"] forKey:[param objectForKey:@"key"]];
            
            // Add the post data
            for (NSDictionary * param in formData.post)
                [formDataRequest setPostValue:[param objectForKey:@"value"] forKey:[param objectForKey:@"key"]];
            
        }
        
        [formData release];
        
    }
    
    // Some debuggiong information
    #ifdef DEBUG
        
        if(self.parameters && formDataRequest.requestMethod != HTTP_GET_VERB)
            DKAPIRequestLog(DKAPIRequestLogDEBUG, @"%@ %@\n%@\n", formDataRequest.requestMethod, [formDataRequest.url absoluteURL], self.parameters);
        else
            DKAPIRequestLog(DKAPIRequestLogDEBUG, @"%@ %@\n", formDataRequest.requestMethod, [formDataRequest.url absoluteURL]);
        
    #endif
    
    // Try and stub the response
    DKAPIResponse * stubbedResponse = [DKAPIStub performWithFormDataRequest:formDataRequest];
    
    // Should we use a stubbing?
    if (stubbedResponse) {
                
        // Run the finish block right away if we have one
        if (finishBlock) finishBlock(stubbedResponse, stubbedResponse.error);
        
    } else {
        
        // Start the request asynchronously
        [formDataRequest startAsynchronous];
        
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    DKAPIRequestLog(DKAPIRequestLogDEBUG, @"Connection Failed: %@", request.error);
    
    if (finishBlock)
        finishBlock(nil, request.error);
    
    // Release the reference to self we made earlier
    [self release];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    // Grab the global dispatch queue
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // Handle the response in a thread
    dispatch_async(queue, ^{
        
        // Create our response
        DKAPIResponse * response = [[DKAPIResponse alloc] initWithHTTPRequest:request apiRequest:self];
        
        // Perform the delegation on the interceptors
        if ([DKAPIInterceptor performDelegation:@selector(interceptedAPIRequest:handleAPIResponse:) withObject:self withObject:response]) {
            
            // Finish by calling our block
            if (finishBlock) finishBlock(response, response.error);
            
        }
        
        // Release the reference to self we made earlier
        [self release];
        
    });    
	
}

- (void)dealloc {
    
    [formDataRequest release];
    [requestStartTime release];
    
    [uploadProgressDelegate release];
    [downloadProgressDelegate release];
    
    [super dealloc];
    
}

@end