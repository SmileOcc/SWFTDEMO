//
//  OSSVRelatedeSearcheCell.m
// XStarlinkProject
//
//  Created by Kevin on 2021/9/6.
//  Copyright © 2021 starlink. All rights reserved.
//  -----地址填写 搜索的弹窗视图

#import "OSSVRelatedeSearcheCell.h"

@interface OSSVRelatedeSearcheCell ()
@property (nonatomic, strong) UIImageView *addressImageView;
@end

@implementation OSSVRelatedeSearcheCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.addressImageView];
        [self.contentView addSubview:self.addressLabel];
    }
    return self;
}

- (UIImageView *)addressImageView {
    if (!_addressImageView) {
        _addressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address_map"]];
    }
    return _addressImageView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _addressLabel.font = [UIFont systemFontOfSize:12];
        _addressLabel.numberOfLines = 0;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _addressLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _addressLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _addressLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.addressImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(11);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.size.equalTo(CGSizeMake(12, 12));
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressImageView.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-11);
        make.height.equalTo(36);
    }];
}
@end
