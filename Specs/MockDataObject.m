//
//  MockDataObject.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 28/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MockDataObject.h"

@implementation MockDataObject

@synthesize identifier;

+ (MockDataObject *)dataObjectWithIdentifier:(NSNumber *)identifier {
    
    MockDataObject * dataObject = [MockDataObject new];
    dataObject.identifier = identifier;
    
    return [dataObject autorelease];
    
}

- (id)formData:(DKAPIFormData *)formData valueForParameter:(NSString *)param {
    
    return self.identifier;
    
}

- (NSString *)formData:(DKAPIFormData *)formData parameterForKey:(NSString *)key {

    if ([key hasSuffix:@"]"]) {
        
        return [key stringByReplacingCharactersInRange:NSMakeRange([key length] - 1, 1) withString:@"_id]"];
        
    } else {
        
        return [key stringByAppendingString:@"_id"];
        
    }

}

@end