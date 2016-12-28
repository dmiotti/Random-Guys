//
//  Operation.h
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A basic wrapper around NSOperation
@interface Operation : NSOperation

- (void)execute;
- (void)finish;

@end
