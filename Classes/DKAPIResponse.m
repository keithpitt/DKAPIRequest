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
#import "JSON.h"

@implementation DKAPIResponse

@synthesize data, error, success, status, errors;

@synthesize statusCode, contentType, headers;

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
            
                DKAPIRequestLog(DKAPIRequestLogDEBUG, @"Time:          %f seconds\nStatus Code:   %i\nContent Type:  %@\nCached:        %@\nResponse Body:\n%@",
                            timePassed, statusCode, contentType, didUseCache, response);
            
            #endif
            
        };
        
        // Did we get a 200 response?
        if (statusCode == 200) {
            
            // Did we get a json-like response?
            if ([contentType rangeOfString:@"json"].location != NSNotFound) {
                
                // Parse the JSON content
                NSDictionary * json = [responseString JSONValue];
                
                // Set the response object
                [self setResponseDictionary:json];
                
                // Log the response
                log(json);
                
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

- (void)setResponseDictionary:(NSDictionary *)dictionary {
    
    self.data = [dictionary objectForKey:@"response"];
    self.errors = [dictionary objectForKey:@"errors"];
    self.status = [dictionary objectForKey:@"status"];
    
    self.success = [self.status isEqualToString:@"ok"];
    
}

- (NSError *)error {
    
    if (!error && ([errors count] > 0 || statusCode > 0)) {
        
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
            
        } else if (statusCode > 0) {
            
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
        error = [NSError errorWithDomain:@"DKAPIRequest" code:0 userInfo:userInfo];
        
    }
    
    return error;
    
}

@end