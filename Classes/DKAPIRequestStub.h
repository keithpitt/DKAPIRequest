//
//  DKAPIRequestStub.h
//  DiscoKit
//
//  Created by Keith Pitt on 12/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "DKRestQuery.h"
#import "DKAPIResponse.h"

typedef id (^DKAPIRequestStubCallback)(ASIFormDataRequest * formRequest);

@interface DKAPIRequestStub : NSObject

@property (nonatomic, copy) DKAPIRequestStubCallback stubbedCallback;

+ (DKAPIRequestStub *)requestStubWithBlock:(DKAPIRequestStubCallback)callback;

- (DKAPIResponse *)responseWithFormDataRequest:(ASIFormDataRequest *)formRequest;

@end