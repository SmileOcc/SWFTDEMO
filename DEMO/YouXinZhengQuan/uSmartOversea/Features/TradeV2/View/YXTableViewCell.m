//
//  YXTableViewCell.m
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXTableViewCell.h"

@implementation YXTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initialUI];
    }
    return self;
}

- (void)setModel:(YXModel *)model {
    _model = model;
    
    [self refreshUI];
}

- (void)initialUI {
    
}

- (void)refreshUI {
    
}



@end
