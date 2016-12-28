//
//  FetchRemoteRandomUsers.m
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import "FetchRemoteRandomUsers.h"
#import "CoreDataStack.h"

static NSString *RandomUserEndPoint = @"https://api.randomuser.me";

@implementation FetchRemoteRandomUsers {
    NSManagedObjectContext *_importContext;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _importContext.parentContext = [[CoreDataStack sharedInstance] viewContext];
    }
    return self;
}

- (void)execute {
    /// Fetch the JSON
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
    
    /// Parse the received JSON
    NSArray<NSDictionary *> *results = json[@"results"];
    [_importContext performBlockAndWait:^{
        [results enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self createOrUpdateRandomUserFromDictionary:obj];
        }];
        
        NSError *saveError = nil;
        [_importContext save:&saveError];
        if (saveError != nil) {
            _error = saveError;
        }
    }];
    
    /// Tells the queue we finished this operation
    [self finish];
}

/// Validates unicity with email
- (RandomUser * _Nullable)createOrUpdateRandomUserFromDictionary:(NSDictionary * _Nonnull)dict {
    // Since we validate unicity with email, it must be present
    NSString *email = dict[@"email"];
    if (!email) {
        return nil;
    }

    // Check for a matching one in coredata
    NSFetchRequest *fetchRequest = [RandomUser fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    NSError *fetchError = nil;
    NSArray *randomUsers = [_importContext executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchError != nil) {
        return nil;
    }
    
    RandomUser *randomUser = [randomUsers firstObject];
    if (!randomUser) {
        /// Otherwise create a new entity in coredata
        randomUser = [NSEntityDescription insertNewObjectForEntityForName:@"RandomUser"
                                                   inManagedObjectContext:_importContext];
        randomUser.importedDate = [NSDate date];
    }
    
    // You certainly want to check all those fields avoiding crashes on api changes
    randomUser.email        = email;
    randomUser.title        = dict[@"name"][@"title"];
    randomUser.firstname    = dict[@"name"][@"first"];
    randomUser.lastname     = dict[@"name"][@"last"];
    randomUser.city         = dict[@"location"][@"street"];
    randomUser.street       = dict[@"location"][@"city"];
    randomUser.state        = dict[@"location"][@"state"];
    randomUser.postcode     = [dict[@"location"][@"postcode"] integerValue];
    randomUser.picture      = dict[@"picture"][@"large"];
    randomUser.thumbnail    = dict[@"picture"][@"thumbnail"];
    randomUser.phone        = dict[@"phone"];
    
    return randomUser;
}

/// Because it's a lot easier to code this kind of problem sequencially
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
