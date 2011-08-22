//
//  DKAPIInterceptor.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DKAPIInterceptorProtocol.h"

@interface DKAPIInterceptor : NSObject

+ (void)addInterceptor:(id <DKAPIInterceptorProtocol>)interceptor;
+ (void)removeInterceptor:(id <DKAPIInterceptorProtocol>)interceptor;

+ (BOOL)performDelegation:(SEL)selector withObject:(id)firstObject withObject:(id)secondObject;

@end