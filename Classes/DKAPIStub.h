//
//  DKAPIRequestStub.h
//  DiscoKit
//
//  Created by Keith Pitt on 12/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "DKAPIResponse.h"

typedef id (^DKAPIStubBlock)(ASIFormDataRequest * formRequest);

@interface DKAPIStub : NSObject

@property (nonatomic, copy) DKAPIStubBlock stubBlock;

+ (DKAPIStub *)stubWithBlock:(DKAPIStubBlock)block;

+ (DKAPIResponse *)performWithFormDataRequest:(ASIFormDataRequest *)formDataRequest;

- (id)initWithBlock:(DKAPIStubBlock)block;

- (DKAPIResponse *)responseWithFormDataRequest:(ASIFormDataRequest *)formRequest;

@end