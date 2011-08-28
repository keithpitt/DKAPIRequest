//
//  MockFileUpload.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 28/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIFormDataProtocol.h"

@interface MockFileUpload : NSObject <DKAPIFormDataProtocol>

@property (nonatomic, copy) NSString * path;

+ (MockFileUpload *)fileUploadWithPath:(NSString *)path;

@end