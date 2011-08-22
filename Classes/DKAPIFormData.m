//
//  DKAPIFormData.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIFormData.h"

#import "DKFile.h"

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
    
    // If we have gotten this far, that means the part is not an NSArray or NSDictionary,
    // so lets just add it as raw data.
    
    if ([part isKindOfClass:[DKFile class]]) {
        
        DKFile * fileUpload = (DKFile *)part;
        
        [self.files addObject:[NSDictionary dictionaryWithObjectsAndKeys:parentKey, @"key", fileUpload.path, @"value", nil]];
        
    } else {
        
        [self.post addObject:[NSDictionary dictionaryWithObjectsAndKeys:parentKey, @"key", part, @"value", nil]];
        
    }
    
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