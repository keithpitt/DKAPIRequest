//
//  DKAPIResponse.h
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;
@class DKAPIRequest;

#define DKAPIResponseStatusKey @"DKAPIResponseStatusKey"

@interface DKAPIResponse : NSObject

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) NSString * contentType;
@property (nonatomic, copy) NSDictionary * headers;

@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) id data;
@property (nonatomic, copy) NSArray * errors;
@property (nonatomic) bool success;

@property (nonatomic, assign) NSError * error;

+ (id)responseWithStatus:(NSString *)status data:(id)data errors:(NSArray *)errors;

- (id)initWithHTTPRequest:(ASIHTTPRequest *)httpRequest apiRequest:(DKAPIRequest *)apiRequest;

- (id)initWithResponseDictionary:(NSDictionary *)dictionary;

- (void)setResponseDictionary:(NSDictionary *)dictionary;

@end