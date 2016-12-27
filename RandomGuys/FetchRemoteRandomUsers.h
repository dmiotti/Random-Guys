//
//  FetchRemoteRandomUsers.h
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Operation.h"
#import "Models.h"

@interface FetchRemoteRandomUsers : Operation

@property (nonatomic, strong, readonly, nonnull) NSError *error;

@end
