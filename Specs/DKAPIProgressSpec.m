//
//  DKAPIProgressSpec.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKAPIProgress.h"
#import "DKAPIRequest.h"

#import "MockProgressDelegate.h"

SPEC_BEGIN(DKAPIProgressSpec)

__block DKAPIRequest * request;
__block DKAPIProgress * progresss;
__block id progressDelegate;

beforeEach(^{
    
    request = [DKAPIRequest new];
    progressDelegate = [OCMockObject niceMockForClass:[MockProgressDelegate class]];
    progresss = [[DKAPIProgress alloc] initWithDelegate:progressDelegate progressMethod:DKAPIProgressUpload apiRequest:request];
    
});

describe(@"- (id)initWithDelegate:progressMethod:apiRequest:", ^{
    
    it(@"should set the appropriate properties", ^{
        
        expect(progresss.delegate).toEqual(progressDelegate);
        expect(progresss.apiRequest).toEqual(request);
        expect(progresss.progressMethod).toEqual(DKAPIProgressUpload);
        
    });
    
});

describe(@"- (void)setProgress:(float)progress;", ^{
    
    it(@"should forward to the upload method correctly", ^{
        
        progresss.progressMethod = DKAPIProgressUpload;
        
        [[progressDelegate expect] apiRequest:request uploadProgress:0.75];
        
        [progresss setProgress:0.75];
        
    });
    
    it(@"should forward to the download method correctly", ^{
        
        progresss.progressMethod = DKAPIProgressDownload;
        
        [[progressDelegate expect] apiRequest:request downloadProgress:0.75];
        
        [progresss setProgress:0.75];
        
    });
    
});

SPEC_END