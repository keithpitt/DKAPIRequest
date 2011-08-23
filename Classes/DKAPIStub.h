//
//  DKAPIRequestStub.h
//  DiscoKit
//
//  Created by Keith Pitt on 12/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIResponse.h"

typedef id (^DKAPIStubBlock)(DKAPIRequest * apiRequest);

@interface DKAPIStub : NSObject

@property (nonatomic, copy) DKAPIStubBlock stubBlock;

+ (DKAPIStub *)stubWithBlock:(DKAPIStubBlock)block;

+ (DKAPIResponse *)performWithAPIRequest:(DKAPIRequest *)apiRequest;

- (id)initWithBlock:(DKAPIStubBlock)block;

- (DKAPIResponse *)responseWithAPIRequest:(DKAPIRequest *)apiRequest;

@end