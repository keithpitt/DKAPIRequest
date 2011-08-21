//
//  DKAPIResponse.m
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIResponse.h"

@implementation DKAPIResponse

@synthesize data, error, success;

+ (id)responseWithJSON:(NSDictionary *)json success:(bool)successfull {
    
    DKAPIResponse * response = [DKAPIResponse new];
    response.data = [json objectForKey:@"response"];
    response.success = successfull;
    
    // Create a custom NSError object
    if (!response.success) {
        
        // Default error message
        NSString * errorMessage;
        
        // Do we have an error from the errors array?
        NSArray * errors = [json objectForKey:@"errors"];
        if ([errors count] > 0) {
            int count = [errors count];
            errorMessage = [errors objectAtIndex:0];
            
            for (int i = 1; i < count; i++) {
                NSString * format = (i == (count-1)) ? @" and %@" : @", %@";
                errorMessage = [errorMessage stringByAppendingFormat:format, [errors objectAtIndex:i]];
            }
        } else {
            errorMessage = NSLocalizedString(@"Unknown Error", nil);
        }
        
        // Create the User Info dictionary for the error
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   errorMessage, NSLocalizedDescriptionKey, 
                                   [json objectForKey:@"status"], DKAPIResponseStatusKey,
                                   nil];
        
        // Create an instance of NSError
        response.error = [NSError errorWithDomain:@"DKAPIHandler"
                                             code:0
                                         userInfo:userInfo];
        
    }
    
    return [response autorelease];
    
}

+ (id)responseWithError:(NSError *)error success:(bool)successfull {
    
    DKAPIResponse *response = [DKAPIResponse new];
    response.error = error;
    response.success = successfull;
    
    return [response autorelease];
    
}

@end
