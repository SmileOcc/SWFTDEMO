//
//  YXStockReminderTypeCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockReminderTypeCell.h"
#import "YXReminderModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>


@interface YXStockReminderTypeCell ()



@end

@implementation YXStockReminderTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.backgroundColor = QMUITheme.foregroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    self.iconImageView = [[UIImageView alloc] init];
    self.nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16]];
    self.selectImageView = [[UIImageView alloc] init];
    self.selectImageView.image = [UIImage imageNamed:@"settings_select"];
    
    
//    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.selectImageView];
//
//    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(12);
//        make.centerY.equalTo(self.contentView);
//        make.width.height.mas_equalTo(20);
//    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-12);
        make.centerY.equalTo(self.contentView);
        make.width.height.mas_equalTo(24);
    }];
    
}

- (void)setIsDisable:(BOOL)isDisable {
    _isDisable = isDisable;
    
    if (isDisable) {
        self.nameLabel.textColor = QMUITheme.textColorLevel3;
    } else {
        self.nameLabel.textColor = QMUITheme.textColorLevel1;
    }
}

@end
