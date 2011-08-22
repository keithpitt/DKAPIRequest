//
//  DKAPIInterceptor.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DKAPIInterceptor.h"

@implementation DKAPIInterceptor

static NSMutableArray * interceptors;

+ (NSMutableArray *)interceptors {
    
    if (!interceptors) interceptors = [NSMutableArray new];
    
    return interceptors;
    
}

+ (void)addInterceptor:(id <DKAPIInterceptorProtocol>)interceptor {
    
    [[self interceptors] addObject:interceptor];
    
}

+ (void)removeInterceptor:(id <DKAPIInterceptorProtocol>)interceptor {
    
    [[self interceptors] removeObject:interceptor];
    
}

+ (BOOL)performDelegation:(SEL)selector withObject:(id)firstObject withObject:(id)secondObject {
    
    BOOL success = YES;
    
    for (id<DKAPIInterceptorProtocol> inteceptor in [self interceptors]) {
        
        if ([inteceptor respondsToSelector:selector]) {
            
            if ([inteceptor performSelector:selector withObject:firstObject withObject:secondObject] == NO) {
                
                success = NO;
                
            }
            
        }
        
    }
    
    return success;
    
}

@end