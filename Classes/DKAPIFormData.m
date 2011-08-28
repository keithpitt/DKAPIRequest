//
//  DKAPIFormData.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIFormData.h"

@implementation DKAPIFormData

@synthesize post, files;

- (void)traverse:(id)part parentKey:(NSString *)parentKey {
    
    NSString * newKey;
    
    if ([part isKindOfClass:NSDictionary.class]) {
        
        for (id key in [part allKeys]) {
            
            // Create a key for the value. If there is a parentKey, "post" for example, prepend
            // the key from this dictionary onto it, so "post" and "key", becomes "post[key]. However,
            // if there is no parentKey (first round of recursion) then just use the
            // currentKey.
            newKey = parentKey != nil ? [NSString stringWithFormat:@"%@[%@]", parentKey, key] : key;
            
            // Recursion...
            [self traverse:[part objectForKey:key] parentKey:newKey];
            
        }
        
        return;
        
    }
    
    if ([part isKindOfClass:NSArray.class]) {
        
        for (id value in part) {
            
            // Append [] to the parentKey
            newKey = [NSString stringWithFormat:@"%@[]", parentKey];
            
            // Recursion...
            [self traverse:value parentKey:newKey];
            
        }
        
        return;
        
    }
    
    // If we have gotten this far, that means the part is not an NSArray or NSDictionary.
    
    // Default data type
    DKAPIFormDataType dataType = DKAPIFormDataTypeNormal;
    
    // Default value
    id value = part;
    
    // If part conforms to the DKAPIFormDataProtocol, it means its something funky. It could
    // be a file, or the data should be represented differently. For example, if you have an NSObject
    // which comforms to the protocol. When sending this object through the parameters, you may want
    // to use a property (such as an ID) for the post data.
    
    // We don't actually check to see if the part responds to the DKAPIFormDataProtocol because if we do,
    // that means what ever we're checking must have included DKAPIFormDataProtocol. In the case of DKFile,
    // it doesn't require the DKAPIRequest lib.

    if ([part respondsToSelector:@selector(formData:dataTypeForKey:)])
        dataType = [part formData:self dataTypeForKey:parentKey];

    if ([part respondsToSelector:@selector(formData:valueForKey:)])
        value = [part formData:self valueForKey:parentKey];
    
    // The data object
    NSDictionary * object = [NSDictionary dictionaryWithObjectsAndKeys:parentKey, @"key", value, @"value", nil];
    
    // Add the data to the params depending on the type
    if (dataType == DKAPIFormDataTypeFile)
        [self.files addObject:object];
    else
        [self.post addObject:object];
    
    return;
    
}

- (id)initWithDictionary:(NSDictionary *)dictionary {

    if ((self = [super init])) {
        
        post = [[NSMutableArray alloc] init];
        files = [[NSMutableArray alloc] init];
        
        [self traverse:dictionary parentKey:nil];
        
    }

    return self;

}

- (NSURL *)urlWithPostData:(NSURL *)url {
    
    // Grab the string version of the url
    
    NSString * absoluteString = [url absoluteString];
    
    // Collect all the params into an array
    
    NSMutableArray * parts = [[NSMutableArray alloc] init];
    
    for (NSDictionary * param in self.post) {
        
        [parts addObject:[NSString stringWithFormat:@"%@=%@",
                          [param objectForKey:@"key"],
                          [param objectForKey:@"value"]]];
        
    }
    
    // Join them
    
    NSString * joined = [parts componentsJoinedByString:@"&"];
    
    [parts release];
    
    // Do start with a "?" or an "&"
    NSString * finalized = [NSString stringWithFormat:
                            ([absoluteString rangeOfString:@"?"].location == NSNotFound) ? @"%@?%@" : @"%@&%@", 
                            absoluteString,
                            joined];
    
    // Escape and create a URL
    
    return [NSURL URLWithString:[finalized stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
}

- (void)dealloc {
    
    self.files = nil;
    self.post = nil;
    
    [super dealloc];
    
}

@end