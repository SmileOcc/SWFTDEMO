//
//  YXEmailSuffixController.m
//  uSmartOversea
//
//  Created by JC_Mac on 2019/1/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXEmailSuffixController.h"
#import "YXEmailSuffixCell.h"
#import <YXKit/YXKit-Swift.h>

#define YX_EmailSuffix_Cell    @"YXEmailSuffixCell"

@interface YXEmailSuffixController ()


@end

@implementation YXEmailSuffixController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = UIColorMakeWithHex(@"#FFFFFF");
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.hidden = YES;
    [self.tableView registerClass:[YXEmailSuffixCell class] forCellReuseIdentifier:@"YXEmailSuffixCell"];
    self.tableView.frame = CGRectMake(0, 0, YXConstant.screenWidth, 80);
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
    return self.matchedSuffixArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YXEmailSuffixCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXEmailSuffixCell"];
    NSString *text = [NSString stringWithFormat:@"%@%@", self.email, self.matchedSuffixArray[indexPath.row]];
    cell.emailSuffixLab.text = text;
    if (indexPath.row == self.matchedSuffixArray.count-1) {
        cell.lineView.hidden = YES;
    }else {
        cell.lineView.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.block) {
        self.block([NSString stringWithFormat:@"%@%@", self.email, self.matchedSuffixArray[indexPath.row]]);
    }
}

- (void)setEmail:(NSString *)email {
    
    _email = [email copy];
    [self.tableView reloadData];
}

@end
