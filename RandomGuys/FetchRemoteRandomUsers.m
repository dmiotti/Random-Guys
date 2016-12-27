//
//  FetchRemoteRandomUsers.m
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import "FetchRemoteRandomUsers.h"

static NSString *RandomUserEndPoint = @"https://api.randomuser.me";

@implementation FetchRemoteRandomUsers

- (void)execute {
    NSURL *URL = [NSURL URLWithString:RandomUserEndPoint];
    NSURLRequest *req = [NSURLRequest requestWithURL:URL];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [FetchRemoteRandomUsers sendSynchronousRequest:req returningResponse:&response error:&error];
    if (error != nil) {
        _error = error;
        [self finish];
        return;
    }
    
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError != nil) {
        _error = jsonError;
        [self finish];
        return;
    }
    
    NSArray<NSDictionary *> *results = json[@"results"];
    NSMutableArray<RandomUser *> *parsedUsers = [NSMutableArray arrayWithCapacity:[results count]];
    [results enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RandomUser *ru = [[RandomUser alloc] initWithDictionary:obj];
        [parsedUsers addObject:ru];
    }];
    _randomUsers = parsedUsers;
    
    [self finish];
}

+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }  
                                         if (error == nil) {  
                                             result = data;  
                                         }  
                                         dispatch_semaphore_signal(sem);  
                                     }] resume];  
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);  
    
    return result;  
}

@end
