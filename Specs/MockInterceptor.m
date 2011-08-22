//
//  MockInterceptor.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "MockInterceptor.h"

@implementation MockInterceptor

- (void)interceptedAPIRequest:(DKAPIRequest *)apiRequest preparePostData:(NSMutableDictionary *)postData {
    
    // Wooo!
    
}

- (BOOL)interceptedAPIRequest:(DKAPIRequest *)apiRequest handleAPIResponse:(DKAPIResponse *)apiResponse {
    
    // I'm having fun!
    
    return YES;
    
}

@end