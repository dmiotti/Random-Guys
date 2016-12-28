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

/// This class is used to download a new user from api.randomuser.me
@interface FetchRemoteRandomUsers : Operation

/// If an error occur during the execution
@property (nonatomic, strong, readonly, nullable) NSError *error;

@end
