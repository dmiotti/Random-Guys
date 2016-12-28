//
//  ClearOperation.m
//  RandomGuys
//
//  Created by David Miotti on 28/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import "ClearOperation.h"
#import "CoreDataStack.h"
#import "Models.h"

@implementation ClearOperation {
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
    [_importContext performBlockAndWait:^{
        NSFetchRequest *req = [RandomUser fetchRequest];
        NSError *fetchError = nil;
        NSArray<RandomUser *> *users = [_importContext executeFetchRequest:req error:&fetchError];
        if (fetchError != nil) {
            _error = fetchError;
            return;
        }
        
        [users enumerateObjectsUsingBlock:^(RandomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_importContext deleteObject:obj];
        }];
        
        NSError *saveError = nil;
        [_importContext save:&saveError];
        if (saveError != nil) {
            _error = saveError;
        }
    }];
    [self finish];
}

@end
