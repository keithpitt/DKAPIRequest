//
//  MockDataObject.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 28/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DKAPIFormDataProtocol.h"

@interface MockDataObject : NSObject <DKAPIFormDataProtocol>

@property (nonatomic, copy) NSNumber * identifier;

+ (MockDataObject *)dataObjectWithIdentifier:(NSNumber *)identifier;

@end