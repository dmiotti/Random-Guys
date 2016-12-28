//
//  RandomUserDetailViewController.h
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Models.h"

/// Shows a user detail interface
@interface RandomUserDetailVC : UIViewController

/// You need to pass this value
@property (nonatomic, strong) RandomUser *randomUser;

@end
