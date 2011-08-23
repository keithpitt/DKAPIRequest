//
//  DKAPIProgressProtocol.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 23/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class DKAPIRequest;

@protocol DKAPIProgressProtocol <NSObject>

@optional

- (void)apiRequest:(DKAPIRequest *)apiRequest downloadProgress:(float)progress;
- (void)apiRequest:(DKAPIRequest *)apiRequest uploadProgress:(float)progress;

@end