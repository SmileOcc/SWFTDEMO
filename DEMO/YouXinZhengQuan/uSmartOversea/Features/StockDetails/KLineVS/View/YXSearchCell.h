//
//  YXSearchCell.h
//  YouXinZhengQuan
//
//  Created by rrd on 2018/7/30.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXTableViewCell.h"

@interface YXSearchCell : YXTableViewCell

@property (nonatomic, assign) BOOL added;

@property (nonatomic, copy) NSString *searchWord;

@property (nonatomic, strong) UIButton *addButton;

- (void)updateAddButtonSelected:(BOOL)selected;

@end
