//
//  RandomUserCell.h
//  RandomGuys
//
//  Created by David Miotti on 28/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RandomUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *userSubtitleLbl;
@end
