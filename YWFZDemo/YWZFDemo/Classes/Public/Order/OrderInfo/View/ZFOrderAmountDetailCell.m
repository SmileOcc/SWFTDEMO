//
//  ZFOrderAmountDetailCell.m
//  ZZZZZ
//
//  Created by YW on 21/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderAmountDetailCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFOrderAmountDetailModel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFOrderAmountDetailCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel   *amountNameLabel;
@property (nonatomic, strong) UILabel   *amountValueLabel;
@property (nonatomic, strong) UIImageView *tipImageView;
@end

@implementation ZFOrderAmountDetailCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.amountNameLabel.text = nil;
    self.amountValueLabel.text = nil;
    self.amountValueLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    self.amountValueLabel.font = [UIFont systemFontOfSize:14];
}

#pragma mark - Public method
+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Setter
-(void)setModel:(ZFOrderAmountDetailModel *)model {
    _model = model;

    self.amountNameLabel.text  = model.name;
    self.amountValueLabel.text = model.value;
    self.amountValueLabel.textColor = ZFCOLOR(51, 51, 51, 1);;
    self.amountValueLabel.font = [UIFont systemFontOfSize:14];

    if (model.attriValue) {
        self.amountValueLabel.attributedText = model.attriValue;
    }
    
    if (model.attriName) {
        self.amountNameLabel.attributedText = model.attriName;
    }
    
    if (model.isShowTipsButton) {
        self.tipImageView.hidden = NO;
    } else {
        self.tipImageView.hidden = YES;
    }
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.amountNameLabel];
    [self.contentView addSubview:self.amountValueLabel];
    [self.contentView addSubview:self.tipImageView];
}

- (void)zfAutoLayoutView {
    [self.amountNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(6);
        make.bottom.mas_equalTo(self.contentView).offset(-6);
        make.leading.mas_equalTo(self.contentView).offset(12);
    }];
    
    [self.amountValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.amountNameLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.amountNameLabel.mas_trailing).mas_offset(4);
        make.centerY.mas_equalTo(self.amountNameLabel);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
}

#pragma mark - Getter
- (UILabel *)amountNameLabel {
    if (!_amountNameLabel) {
        _amountNameLabel = [[UILabel alloc] init];
        _amountNameLabel.font = [UIFont systemFontOfSize:14];
        _amountNameLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    }
    return _amountNameLabel;
}

- (UILabel *)amountValueLabel {
    if (!_amountValueLabel) {
        _amountValueLabel = [[UILabel alloc] init];
        _amountValueLabel.font = [UIFont systemFontOfSize:14];
        _amountValueLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    }
    return _amountValueLabel;
}

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [[UIImageView alloc] init];
        _tipImageView.image = [UIImage imageNamed:@"nationalID"];
        _tipImageView.hidden = YES;
    }
    return _tipImageView;
}

@end
