//
//  CoreDataStack.m
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import "CoreDataStack.h"

@implementation CoreDataStack

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static CoreDataStack *shared;
    dispatch_once(&onceToken, ^{
        shared = [[CoreDataStack alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mainContextChanged:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(mainContextChanged(notification:)),
//                                               name: .NSManagedObjectContextDidSave,
//                                               object: self.managedObjectContext)
//        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(bgContextChanged(notification:)),
//                                               name: .NSManagedObjectContextDidSave,
//                                               object: self.backgroundManagedObjectContext)
    }
    return self;
}

- (void)dealloc {
    
}

- (void)mainContextChanged:(NSNotification *)notification {
    
}

- (void)bgContextChanged:(NSNotification *)notification {
    
}

////#7
//@objc func mainContextChanged(notification: NSNotification) {
//    backgroundManagedObjectContext.perform { [unowned self] in
//        self.backgroundManagedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
//    }
//}
//@objc func bgContextChanged(notification: NSNotification) {
//    managedObjectContext.perform{ [unowned self] in
//        self.managedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
//    }
//}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"RandomGuys"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

- (NSManagedObjectContext *)viewContext {
    return [[self persistentContainer] viewContext];
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
