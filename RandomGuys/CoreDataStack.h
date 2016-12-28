//
//  CoreDataStack.h
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/// This class is responsible of giving a correct access to CoreData
@interface CoreDataStack : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)sharedInstance;

/// The main context, for interface display you can directly his this context
/// Otherwise you should create a Private context with this one has parent
- (NSManagedObjectContext *)viewContext;

- (void)saveContext;

@end
