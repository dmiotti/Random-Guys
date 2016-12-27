//
//  RandomUser.m
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import "RandomUser.h"

@implementation RandomUser

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _email = dict[@"email"];
    }
    return self;
}

@end
