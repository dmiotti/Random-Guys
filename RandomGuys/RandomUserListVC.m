//
//  ViewController.m
//  RandomGuys
//
//  Created by David Miotti on 27/12/2016.
//  Copyright © 2016 David Miotti. All rights reserved.
//

#import "RandomUserListVC.h"
#import "RandomUser.h"
#import "RandomUserTableViewCell.h"
#import <Masonry/Masonry.h>

@interface RandomUserListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<RandomUser *> *randomUsers;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RandomUserListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.randomUsers = [NSArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[RandomUserTableViewCell class]
           forCellReuseIdentifier:[RandomUserTableViewCell reuseIdentifier]];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.randomUsers.count;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
