//
//  DKAPIResponse.m
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIResponse.h"

#import "DKAPILogger.h"
#import "DKAPIRequest.h"

#import "ASIHTTPRequest.h"
#import "JSONKit.h"

@implementation DKAPIResponse

@synthesize data, error, success, status, errors;

@synthesize statusCode, contentType, headers;

+ (id)responseWithStatus:(NSString *)status data:(id)data errors:(NSArray *)errors {
    
    NSDictionary * responseDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         (status ? status : @"ok"), @"status",
                                         (data ? data : [NSDictionary dictionary]), @"response",
                                         (errors ? errors : [NSArray array]), @"errors",
                                         nil];
    
    return [[[self alloc] initWithResponseDictionary:responseDictionary] autorelease];
    
}

- (id)initWithHTTPRequest:(ASIHTTPRequest *)httpRequest apiRequest:(DKAPIRequest *)apiRequest {
    
    if ((self = [super init])) {
    
        // Find the response body for the request
        NSString * responseString = [httpRequest responseString];
        
        // Copy the headers
        self.headers = [httpRequest responseHeaders];
        
        // Find the content type of the request
        self.contentType = [self.headers objectForKey:@"Content-Type"];
        
        // Convert the response status code to an integer
        self.statusCode = [httpRequest responseStatusCode];
        
        // Some logging
        void (^log)(id) = ^(id response) {

            // Only perform the following checks if we're debugging...
            #ifdef DEBUG
            
                // How long did the request take?
                NSTimeInterval timePassed = [apiRequest.requestStartTime timeIntervalSinceNow] * -1;
            
                // Was the result from the cache?
                NSString * didUseCache = [httpRequest didUseCachedResponse] ? @"YES" : @"NO";
            
                DKAPIRequestLog(DKAPIRequestLogDEBUG, @"Request:       %@ %@\nTime:          %f seconds\nStatus Code:   %i\nContent Type:  %@\nCached:        %@\nResponse Body: %@", apiRequest.requestMethod, [httpRequest.url absoluteString],
                            timePassed, statusCode, contentType, didUseCache, response);
            
            #endif
            
        };
        
        // Did we get a 200 response?
        if (statusCode == 200) {
            
            // Did we get a json-like response?
            if ([contentType rangeOfString:@"json"].location != NSNotFound) {
                
                NSError * jsonParsingError = nil;
                
                // Parse the JSON content
                NSDictionary * json = [responseString objectFromJSONStringWithParseOptions:JKParseOptionNone error:&jsonParsingError];
                
                // If there was an error pasing the JSON
                if (jsonParsingError) {
                    
                    // Copy the error
                    error = [jsonParsingError copy];
                    success = NO;
                    
                    // Log the response
                    log(responseString);
                    
                } else {
                
                    // Set the response object
                    [self setResponseDictionary:json];
                    
                    // Log the response
                    log(json);
                    
                }
                
            } else {
                
                // Log the response
                log(responseString);
                
            }
            
        } else {
            
            success = NO;
            
        }
        
    }
    
    return self;
    
}

- (id)initWithResponseDictionary:(NSDictionary *)dictionary {
    
    if ((self = [super init]))
        [self setResponseDictionary:dictionary];
    
    return self;
    
}

- (void)setResponseDictionary:(NSDictionary *)dictionary {
    
    self.data = [dictionary objectForKey:@"response"];
    self.errors = [dictionary objectForKey:@"errors"];
    self.status = [dictionary objectForKey:@"status"];
    
    self.success = [self.status isEqualToString:@"ok"];
    
}

- (NSError *)error {
    
    if (!error && (([errors count] > 0 || (statusCode >= 300)) || self.success == NO)) {
        
        // Default error message
        NSString * errorMessage;
        
        // Do we have an error from the errors array?
        if ([errors count] > 0) {
            
            int count = [errors count];
            errorMessage = [errors objectAtIndex:0];
            
            // Make a sentence out of the errors
            for (int i = 1; i < count; i++) {
                NSString * format = (i == (count-1)) ? @" and %@" : @", %@";
                errorMessage = [errorMessage stringByAppendingFormat:format, [errors objectAtIndex:i]];
            }
            
        } else {
            
            switch (statusCode) {
                    
                case 404:
                    errorMessage = NSLocalizedString(@"Server could not be found (404)", nil);
                    break;
                    
                case 500:
                    errorMessage = NSLocalizedString(@"Server error (500)", nil);
                    break;
                    
                default:
                    errorMessage = [NSString stringWithFormat:@"An unknown error occured (%i)", statusCode];
                    break;
                    
            }
            
        }
        
        // Create the User Info dictionary for the error
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   errorMessage, NSLocalizedDescriptionKey, 
                                   status, DKAPIResponseStatusKey,
                                   nil];
        
        // Create an instance of NSError
        error = [[NSError alloc] initWithDomain:@"DKAPIRequest" code:0 userInfo:userInfo];
        
    }
    
    return error;
    
}

- (NSString *)description {
    
    if (self.error)    
        return [NSString stringWithFormat:@"<DKAPIResponse: Status: %@ Error: %@>", self.status, [self.error localizedDescription]];
    else
        return [NSString stringWithFormat:@"<DKAPIResponse: Status: %@ Data: %@>", self.status, self.data];
    
}

- (void)dealloc {
    
    [contentType release];
    [headers release];
    
    [status release];
    [data release];
    [errors release];
    
    [super dealloc];
    
}

@end