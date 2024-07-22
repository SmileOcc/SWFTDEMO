//
//  ZFOrderDetailPartHintCell.m
//  ZZZZZ
//
//  Created by 602600 on 2019/12/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderDetailPartHintCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

@interface ZFOrderDetailPartHintCell ()

@property (nonatomic, strong) UILabel *partHintLabel;

@end

@implementation ZFOrderDetailPartHintCell

#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)setModel:(OrderDetailOrderModel *)model {
    _model = model;
    self.partHintLabel.text = model.order_part_hint;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.partHintLabel];
}

- (void)zfAutoLayoutView {
    [self.partHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self.contentView).offset(15);
        make.trailing.bottom.mas_equalTo(self.contentView).offset(-15);
    }];
}

- (UILabel *)partHintLabel {
    if (!_partHintLabel) {
        _partHintLabel = [[UILabel alloc] init];
        _partHintLabel.font = [UIFont systemFontOfSize:12];
        _partHintLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _partHintLabel.numberOfLines = 0;
    }
    return _partHintLabel;
}

@end
