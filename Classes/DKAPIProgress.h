//
//  DKAPIProgress.h
//  DKAPIRequest
//
//  Created by Keith Pitt on 23/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "DKAPIProgressProtocol.h"

typedef enum {
    
    DKAPIProgressDownload,
    
    DKAPIProgressUpload
    
} DKAPIProgressMethod;

@interface DKAPIProgress : NSObject

@property (nonatomic, retain) id <DKAPIProgressProtocol> delegate;

@property (nonatomic, retain) DKAPIRequest * apiRequest;

@property (nonatomic) DKAPIProgressMethod progressMethod;

- (id)initWithDelegate:(id <DKAPIProgressProtocol>)progressDelegate progressMethod:(DKAPIProgressMethod)method apiRequest:(DKAPIRequest *)request;

- (void)setProgress:(float)progress;

@end