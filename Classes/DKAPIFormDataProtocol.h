//
//  DKAPIFormDataProtocol.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 28/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DKAPIFormDataType.h"

@class DKAPIFormData;

@protocol DKAPIFormDataProtocol <NSObject>

@optional

- (DKAPIFormDataType)formData:(DKAPIFormData *)formData dataTypeForParameter:(NSString *)param;

- (NSString *)formData:(DKAPIFormData *)formData parameterForKey:(NSString *)key;
- (id)formData:(DKAPIFormData *)formData valueForParameter:(NSString *)param;

@end