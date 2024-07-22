//
//  ZFOrderShippingInfoCell.m
//  ZZZZZ
//
//  Created by YW on 7/7/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderShippingInfoCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFOrderShippingInfoCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel   *titleLabel;
@end

@implementation ZFOrderShippingInfoCell
#pragma mark - Life cycle
+ (instancetype)shipHeaderCellViewWith:(UITableView *)tableView index:(NSIndexPath *)index {
    [tableView registerClass:[ZFOrderShippingInfoCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:index];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    [self.contentView addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(8);
        make.leading.mas_equalTo(12);
        make.bottom.mas_equalTo(-16);
    }];
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = ZFFontSystemSize(12);
        _titleLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.text = ZFLocalizedString(@"shipping_info", nil);
        _titleLabel.numberOfLines = 0;
        _titleLabel.preferredMaxLayoutWidth = KScreenWidth - 24;
    }
    return _titleLabel;
}

@end
