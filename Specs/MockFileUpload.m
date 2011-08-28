//
//  MockFileUpload.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 28/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "MockFileUpload.h"

@implementation MockFileUpload

@synthesize path;

+ (MockFileUpload *)fileUploadWithPath:(NSString *)path {
    
    MockFileUpload * fileUpload = [MockFileUpload new];
    fileUpload.path = path;
    
    return [fileUpload autorelease];
    
}

- (id)formData:(DKAPIFormData *)formData valueForKey:(NSString *)key {
    
    return self.path;
    
}

- (DKAPIFormDataType)formData:(DKAPIFormData *)formData dataTypeForKey:(NSString *)key {
    
    return DKAPIFormDataTypeFile;
    
}

@end