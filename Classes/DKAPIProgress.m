//
//  DKAPIProgress.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 23/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIProgress.h"

@implementation DKAPIProgress

@synthesize delegate, progressMethod, apiRequest;

- (id)initWithDelegate:(id <DKAPIProgressProtocol>)progressDelegate progressMethod:(DKAPIProgressMethod)method apiRequest:(DKAPIRequest *)request {
    
    if ((self = [super init])) {
        self.delegate = progressDelegate;
        self.progressMethod = method;
        self.apiRequest = request;
    }
    
    return self;
    
}

- (void)setProgress:(float)progress {
    
    // Forward the progress float to the correct method on the delegate (if it responds
    // to the selector)
    
    if (progressMethod == DKAPIProgressUpload && [self.delegate respondsToSelector:@selector(apiRequest:uploadProgress:)]) {
        
        [self.delegate apiRequest:self.apiRequest uploadProgress:progress];
        
    } else if (progressMethod == DKAPIProgressDownload && [self.delegate respondsToSelector:@selector(apiRequest:downloadProgress:)]) {
        
        [self.delegate apiRequest:self.apiRequest downloadProgress:progress];
        
    }
    
}

- (void)dealloc {
    
    self.delegate = nil;
    self.apiRequest = nil;
    
    [super dealloc];
    
}

@end