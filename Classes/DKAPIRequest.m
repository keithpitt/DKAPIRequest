//
//  DKAPIRequest.m
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIRequest.h"

#import "DKAPIRequestStub.h"
#import "DKAPIResponse.h"
#import "DKFile.h"
#import "DKAPILogger.h"

#import "JSON.h"

@implementation DKAPIRequest

@synthesize successCallback, errorCallback;
@synthesize requestURL, data, files, httpMethod;
@synthesize uploadProgressDelegate, downloadProgressDelegate;
@synthesize cachePolicy, downloadCache, cacheStoragePolicy;

static NSMutableArray * sharedInterceptors;
static NSMutableArray * sharedStubbings;

+ (NSArray *)interceptors {
    
    return sharedInterceptors;
    
}

+ (void)addInterceptor:(id <DKAPIInterceptorProtocol>)interceptor {
    
    // If the shared inteceptor doesn't exist
    if (!sharedInterceptors) {
        sharedInterceptors = [NSMutableArray new];
    }
    
    // Add it
    [sharedInterceptors addObject:interceptor];
    
}

+ (void)removeInterceptor:(id <DKAPIInterceptorProtocol>)interceptor {
    
    [sharedInterceptors removeObject:interceptor];
    
}

+ (void)stubNextRequest:(DKAPIRequestStub *)requestStub {
    
    if (!sharedStubbings) {
        sharedStubbings = [NSMutableArray new];
    }
    
    // Add it
    [sharedStubbings addObject:requestStub];
    
}

- (void)get:(NSString *)url {
    
    // Set the HTTP method to "GET"
    self.httpMethod = HTTP_GET_VERB;
    self.requestURL = url;
    
    // Send the request
    [self send];
    
}
- (void)post:(NSString *)url{
    
    // Set the HTTP method to "POST"
    self.httpMethod = HTTP_POST_VERB;
    self.requestURL = url;
    
    // Send the request
    [self send];
    
}

- (void)put:(NSString *)url{
    
    // Set the HTTP method to "PUT"
    self.httpMethod = HTTP_PUT_VERB;
    self.requestURL = url;
    
    // Send the request
    [self send];
    
}

- (void)delete:(NSString *)url{
    
    // Set the HTTP method to "DELETE"
    self.httpMethod = HTTP_DELETE_VERB;
    self.requestURL = url;
    
    // Send the request
    [self send];
    
}

- (void)send {
    
    ASIFormDataRequest * formDataRequest = [self request];
    
    requestStartTime = [[NSDate alloc] init];
    
    // Should we use a stubbing?
    if (sharedStubbings && [sharedStubbings count] > 0) {
        
        // Grab the stubbed response to use
        DKAPIRequestStub * requestStub = (DKAPIRequestStub *)[sharedStubbings lastObject];
        
        DKAPIResponse * response = [requestStub responseWithFormDataRequest:formDataRequest];
        
        // Remove it from the stubbings array
        [sharedStubbings removeObject:response];
        
        // Toggle between calling the success/error callback
        if (response.success && errorCallback)
            successCallback(response);
        else if (errorCallback)
            errorCallback(response);
        
        [requestStub release];
        
    } else {
        
        // Start the request asynchronously
        [formDataRequest startAsynchronous];
        
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    DKAPIRequestLog(DKAPIRequestLogDEBUG, @"Connection Failed: %@", request.error);
    
    // Error callback
    if (errorCallback) {
        DKAPIResponse * response = [DKAPIResponse responseWithError:request.error success:NO];
        errorCallback(response);
    }
    
    // Release the reference to self we made earlier
    [self release];
    
}

- (NSString *)addParamsToUrl:(NSString *)baseURL params:(NSArray *)params {
    
    NSMutableArray * parts = [[NSMutableArray alloc] init];
    
    for (NSDictionary * param in params) {
        [parts addObject:[NSString stringWithFormat:@"%@=%@",
                          [param objectForKey:@"key"],
                          [param objectForKey:@"value"]]];
    }
    
    NSString * joined = [parts componentsJoinedByString:@"&"];
    
    [parts release];
    
    NSString * format = ([baseURL rangeOfString:@"?"].location == NSNotFound) ? @"%@?%@" : @"%@&%@";
    NSString * finalized = [NSString stringWithFormat:format, baseURL, joined];
    
    return [finalized stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}

- (NSError *)localizedErrorFromStatusCode:(int)statusCode {
    
    NSString * message;
    
    switch (statusCode) {
        case 404:
            message = NSLocalizedString(@"Server could not be found (404)", nil);
            break;
            
        case 500:
            message = NSLocalizedString(@"Server error (500)", nil);
            break;
            
        default:
            message = [NSString stringWithFormat:@"An unknown error occured (%i)", statusCode];
            break;
    }
    
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    
    return [NSError errorWithDomain:@"DKAPIRequest" code:statusCode userInfo:userInfo];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	
	// Find the response body for the request
	NSString * responseBody = [request responseString];
    
    // Find the content type of the request
	NSString * contentType = [[request responseHeaders] objectForKey:@"Content-Type"];
    
    // Convert the response status code to an integer
    int statusCode = [request responseStatusCode];
    
    // How long did the request take?
    NSTimeInterval timePassed = [requestStartTime timeIntervalSinceNow] * -1;
    [requestStartTime release], requestStartTime = nil;
    
    NSString * didUseCache = [request didUseCachedResponse] ? @"YES" : @"NO";
    
    // Some logging
	DKAPIRequestLog(DKAPIRequestLogDEBUG, @"Time:          %f seconds\n  Status Code:   %i\n  Content Type:  %@\n  Cached:        %@\n  Response Body: %@\n\n", timePassed, statusCode, contentType, didUseCache, responseBody);
    
    // Get the inteceptors
    NSArray * interceptors = [DKAPIRequest interceptors];
    
    // Did we get a 200 response?
    if (statusCode == 200) {
        
        // Did we get a json-like response?
        if ([contentType rangeOfString:@"json"].location != NSNotFound) {
            
            // Parse the JSON content
            id json = [responseBody JSONValue];
            
            // Was the request successfull?
            bool success = [[json objectForKey:@"status"] hasPrefix:@"ok"];
            
            DKAPIResponse * response = [DKAPIResponse responseWithJSON:json
                                                               success:success];
            
            // If we have any, loop over them, and the run "preparePostData" method on them.
            if (interceptors) {
                
                BOOL runCallbacks = YES;
                
                for (id<DKAPIInterceptorProtocol> inteceptor in interceptors) {
                    if ([inteceptor respondsToSelector:@selector(interceptedAPIRequest:handleAPIResponse:)]) {
                        if (![inteceptor interceptedAPIRequest:self handleAPIResponse:response])
                            runCallbacks = NO;
                    }
                }
                
                // Are we still able to run the callbacks?
                if (runCallbacks)
                    if (success)
                        successCallback(response);
                    else if (errorCallback)
                        errorCallback(response);
                
            } else {
                
                if (success)
                    successCallback(response);
                else if (errorCallback)
                    errorCallback(response);
                
            }

        }
        
    } else {
        
        DKAPIResponse * response = [DKAPIResponse responseWithError:[self localizedErrorFromStatusCode:statusCode]
                                                            success:NO];
        
        errorCallback(response);
        
    }
    
    // Release the reference to self we made earlier
    [self release];
	
}

- (ASIFormDataRequest *)request {
    
    // If we don't have a successCallback or errorCallback, blow up.
    if (!successCallback && !errorCallback) {
        DKAPIRequestLog(DKAPIRequestLogDEBUG, @"No successCallback or errorCallback defined for this request.");
        abort();
    }
    
    // Increment the retain count of self because we are doing a callback
    [self retain];
    
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:self.requestURL]];
    
    request.requestMethod = self.httpMethod;
    request.delegate = self;
    request.timeOutSeconds = 120;
    request.shouldAttemptPersistentConnection = NO;
    request.showAccurateProgress = YES;
    
    if (cachePolicy)
        request.cachePolicy = cachePolicy;
    
    if (cacheStoragePolicy)
        request.cacheStoragePolicy = cacheStoragePolicy;
    
    if (downloadCache)
        request.downloadCache = downloadCache;
    
    if (uploadProgressDelegate)
        request.uploadProgressDelegate = uploadProgressDelegate;
    
    if (downloadProgressDelegate)
        request.downloadProgressDelegate = downloadProgressDelegate;
        
    NSDictionary * serializedResults = nil;
    NSMutableDictionary * changeablePostData = self.data ? [[self.data mutableCopy] autorelease] : [NSMutableDictionary dictionary];
    
    // Get the inteceptors
    NSArray * interceptors = [DKAPIRequest interceptors];
    
    // If we have any, loop over them, and the run "preparePostData" method on them.
    if (interceptors)
        for (id<DKAPIInterceptorProtocol> inteceptor in interceptors) {
            if ([inteceptor respondsToSelector:@selector(interceptedAPIRequest:preparePostData:)])
                [inteceptor interceptedAPIRequest:self preparePostData:changeablePostData];
        }
    
    // If we now have any data
    if ([[changeablePostData allKeys] count] > 0) {
        
        // Serialize the post data
        serializedResults = [self serialize:changeablePostData];
        
        // Add any files found in the serialized results
        for (NSDictionary * param in [serializedResults objectForKey:@"files"]) {
            [request setFile:[param objectForKey:@"value"]
                      forKey:[param objectForKey:@"key"]];
        }
        
        // Add the post data
        if ([self.httpMethod isEqualToString:HTTP_GET_VERB]) {
            
            request.url = [NSURL URLWithString:[self addParamsToUrl:self.requestURL
                                                             params:[serializedResults objectForKey:@"data"]]];
            
        } else {            
            
            for (NSDictionary * param in [serializedResults objectForKey:@"data"])
                [request setPostValue:[param objectForKey:@"value"]
                               forKey:[param objectForKey:@"key"]];
            
        }
        
    }
    
    // Attach files if its not a GET request
    if (self.files && ![httpMethod isEqualToString:HTTP_GET_VERB]) {
        for (NSString * param in [files allKeys])
            [request setFile:[files objectForKey:param] forKey:param];
    }
    
    // Some debugging information
    if(serializedResults && [serializedResults objectForKey:@"data"] && self.httpMethod != HTTP_GET_VERB)
        DKAPIRequestLog(DKAPIRequestLogDEBUG, @"%@ %@\n%@\n", request.requestMethod, [request.url absoluteURL], self.data);
    else
        DKAPIRequestLog(DKAPIRequestLogDEBUG, @"%@ %@\n", request.requestMethod, [request.url absoluteURL]);
    
    return request;
    
}

- (void)_serializeData:(id)part parentKey:(NSString*)parentKey serialized:(NSMutableArray *)serialized files:(NSMutableArray *)collectedFiles {
    
    NSString * newKey;
    
    if ([part isKindOfClass:NSDictionary.class]) {
        
        NSEnumerator * enumerator = [part keyEnumerator];
        id currentKey;
        
        while ((currentKey = [enumerator nextObject])) {
            
            // Create a key for the value. If there is a parentKey, "post" for example, prepend
            // the key from this dictionary onto it, so "post" and "key", becomes "post[key]. However,
            // if there is no parentKey (first round of recursion) then just use the
            // currentKey.
            newKey = parentKey != nil ? [NSString stringWithFormat:@"%@[%@]", parentKey, currentKey] : currentKey;
            
            // Recursion...
            [self _serializeData:[part objectForKey:currentKey] parentKey:newKey serialized:serialized files:collectedFiles];
            
        }
        
        return;
        
    }
    
    if ([part isKindOfClass:NSArray.class]) {
        
        for (id value in part) {
            
            // Append [] to the parentKey
            newKey = [NSString stringWithFormat:@"%@[]", parentKey];
            
            // Recursion...
            [self _serializeData:value parentKey:newKey serialized:serialized files:collectedFiles];
            
        }
        
        return;
        
    }
    
    // If we have gotten this far, that means the part is not an NSArray or NSDictionary,
    // so lets just add it as raw data.
    
    if ([part isKindOfClass:[DKFile class]]) {
        
        DKFile * fileUpload = (DKFile *)part;
        
        [collectedFiles addObject:[NSDictionary dictionaryWithObjectsAndKeys:parentKey, @"key", fileUpload.path, @"value", nil]];
        
    } else {
    
        [serialized addObject:[NSDictionary dictionaryWithObjectsAndKeys:parentKey, @"key", part, @"value", nil]];
        
    }
    
    return;
    
}

- (NSDictionary *)serialize:(NSDictionary*)dataToSerialize {
    
    NSMutableArray * serialized = [NSMutableArray array];
    NSMutableArray * collectedFiles = [NSMutableArray array];
                      
    [self _serializeData:dataToSerialize parentKey:nil serialized:serialized files:collectedFiles];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:serialized, @"data", collectedFiles, @"files", nil];
    
}

- (void)dealloc {
    
    [requestStartTime release];
    [uploadProgressDelegate release];
    [downloadProgressDelegate release];
    
    [super dealloc];
    
}

@end