
//
//  ZFCartFreeGiftTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/5/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCartFreeGiftTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"

@interface ZFCartFreeGiftTableViewCell() <ZFInitViewProtocol>

@end

@implementation ZFCartFreeGiftTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    
}

- (void)zfAutoLayoutView {
    
}

#pragma mark - setter
- (void)setModel:(ZFCartGoodsModel *)model {
    _model = model;
    
}

#pragma mark - getter



@end
