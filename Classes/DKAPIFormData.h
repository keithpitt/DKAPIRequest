//
//  DKAPIFormData.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DKAPIFormDataProtocol.h"

@interface DKAPIFormData : NSObject

@property (nonatomic, retain) NSMutableArray * post;
@property (nonatomic, retain) NSMutableArray * files;

- (id)initWithDictionary:(NSDictionary *)dictionary;

- (NSURL *)urlWithPostData:(NSURL *)url;

@end