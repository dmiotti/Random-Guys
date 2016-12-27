//
//  RandomUser.h
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomUser : NSObject

/// The email of the random user
@property (nonatomic, strong, readonly) NSString *email;

/// Instanciate a RandomUser from a JSON response
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
