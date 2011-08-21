//
//  DKAPIResponse.h
//  DiscoKit
//
//  Created by Keith Pitt on 24/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DKAPIResponseStatusKey @"DKAPIResponseStatusKey"

@interface DKAPIResponse : NSObject

@property (nonatomic, assign) id data;
@property (nonatomic, assign) NSError * error;
@property (nonatomic) bool success;

+ (id)responseWithJSON:(NSDictionary*)json success:(bool)successfull;
+ (id)responseWithError:(NSError*)error success:(bool)successfull;

@end