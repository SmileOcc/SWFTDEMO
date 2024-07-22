//
//  ZFAddressTopMessageTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/8/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFAddressTopMessageTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFAddressTopMessageTableViewCell () <ZFInitViewProtocol>

@property (nonatomic, strong) UILabel      *msgLabel;

@end

@implementation ZFAddressTopMessageTableViewCell

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
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.msgLabel];
}

- (void)zfAutoLayoutView {
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-16);
    }];
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.textColor = ColorHex_Alpha(0x999999, 1.0);
        _msgLabel.font = [UIFont systemFontOfSize:14];
        _msgLabel.text = ZFLocalizedString(@"ModifyAddress_enter_address_english", nil);
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

@end
