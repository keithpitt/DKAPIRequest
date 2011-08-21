//
//  DKAPIInterceptorProtocol.h
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

@class DKAPIResponse;
@class DKAPIRequest;

@protocol DKAPIInterceptorProtocol <NSObject>

@optional

- (void)interceptedAPIRequest:(DKAPIRequest *)apiRequest preparePostData:(NSMutableDictionary *)postData;
- (BOOL)interceptedAPIRequest:(DKAPIRequest *)apiRequest handleAPIResponse:(DKAPIResponse *)apiResponse;

@end