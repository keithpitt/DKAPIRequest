//
//  DKAPIFormDataSpec.m
//  DKAPIRequest
//
//  Created by Keith Pitt on 22/08/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

#import "SpecHelper.h"

#import "DKAPIFormData.h"
#import "MockFileUpload.h"
#import "DKFile.h"

SPEC_BEGIN(DKAPIFormDataSpec)

context(@"- (id)initWithDictionary:", ^{
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"The Best Post", @"name", 
                                  [NSDictionary dictionaryWithObjectsAndKeys:@"Keith Pitt", @"name", @"me@keithpitt.com", @"email", nil], @"author",
                                  [NSNumber numberWithInt:12], @"commentCount", 
                                  [NSArray arrayWithObjects:@"First", @"Second", @"Third", nil], @"comments",
                                  [MockFileUpload fileUploadWithPath:@"Something1.txt"], @"some_file",
                                  [DKFile fileFromDocuments:@"Something2.txt"], @"some_other_file",
                                  nil], @"post",
                                 nil];
    
    __block DKAPIFormData * formData = [[DKAPIFormData alloc] initWithDictionary:dictionary];
   
    it(@"should convert an NSDictionary into a Rails-safe postable structure", ^{
        
        NSDictionary * result1 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[name]", @"key",
                                  @"The Best Post", @"value",
                                  nil];
        expect([formData.post objectAtIndex:0]).toEqual(result1);
        
        NSDictionary * result2 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[author][name]", @"key",
                                  @"Keith Pitt", @"value",
                                  nil];
        expect([formData.post objectAtIndex:1]).toEqual(result2);
        
        NSDictionary * result3 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[author][email]", @"key",
                                  @"me@keithpitt.com", @"value",
                                  nil];
        expect([formData.post objectAtIndex:2]).toEqual(result3);
        
        NSDictionary * result4 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[comments][]", @"key",
                                  @"First", @"value",
                                  nil];
        expect([formData.post objectAtIndex:3]).toEqual(result4);
        
        NSDictionary * result5 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[comments][]", @"key",
                                  @"Second", @"value",
                                  nil];
        expect([formData.post objectAtIndex:4]).toEqual(result5);
        
        NSDictionary * result6 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[comments][]", @"key",
                                  @"Third", @"value",
                                  nil];
        expect([formData.post objectAtIndex:5]).toEqual(result6);
        
        NSDictionary * result7 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[commentCount]", @"key", 
                                  [NSNumber numberWithInt:12], @"value",
                                  nil];
        expect([formData.post objectAtIndex:6]).toEqual(result7);
        
    });
    
    it(@"should filter out files into a seperate array", ^{
        
        NSDictionary * result1 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[some_file]", @"key",
                                  [[MockFileUpload fileUploadWithPath:@"Something1.txt"] path], @"value",
                                  nil];
        expect([formData.files objectAtIndex:0]).toEqual(result1);
        
        NSDictionary * result2 = [NSDictionary dictionaryWithObjectsAndKeys:@"post[some_other_file]", @"key",
                                  [[DKFile fileFromDocuments:@"Something2.txt"] path], @"value",
                                  nil];
        expect([formData.files objectAtIndex:1]).toEqual(result2);
        
    });
    
});

context(@"- (NSURL *)urlWithPostData:", ^{
    
    __block NSDictionary * dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"foo", @"bar",
                                 [NSDictionary dictionaryWithObject:@"hang" forKey:@"bang"], @"bar2",
                                 [NSArray arrayWithObjects:@"bing", @"bang", nil], @"bar3",
                                 nil];
    
    __block DKAPIFormData * formData = [[DKAPIFormData alloc] initWithDictionary:dictionary];
    
    it(@"should return a URL with the parameters appended", ^{
                
        NSURL * newURL = [formData urlWithPostData:[NSURL URLWithString:@"http://www.google.com"]];
        
        expect([newURL absoluteString]).toEqual(@"http://www.google.com?bar=foo&bar2%5Bbang%5D=hang&bar3%5B%5D=bing&bar3%5B%5D=bang");

    });
    
    it(@"should not append a '?' if there already is one", ^{
        
        NSURL * newURL = [formData urlWithPostData:[NSURL URLWithString:@"http://www.google.com?keith=awesome"]];
        
        expect([newURL absoluteString]).toEqual(@"http://www.google.com?keith=awesome&bar=foo&bar2%5Bbang%5D=hang&bar3%5B%5D=bing&bar3%5B%5D=bang");
        
    });
    
});

SPEC_END