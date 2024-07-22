//
//  ZFVATCell.m
//  ZZZZZ
//
//  Created by YW on 6/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFVATCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFOrderAmountDetailModel.h"
#import "FilterManager.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "Masonry.h"
#import "ZFLocalizationString.h"

@interface ZFVATCell ()
@property (nonatomic, strong) UILabel       *tipLabel;
@property (nonatomic, strong) UIImageView   *tipImageView;
@property (nonatomic, strong) UILabel       *priceLabel;
@end

@implementation ZFVATCell
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
    self.priceLabel.text = nil;
}

#pragma mark - Public method
+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Setter
-(void)setModel:(ZFOrderAmountDetailModel *)model {
    _model = model;
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:model.value attributes:attribtDic];
    self.priceLabel.attributedText = attribtStr;
    self.tipLabel.text = model.name;
    self.tipImageView.hidden = NO;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.tipImageView];
    [self.contentView addSubview:self.priceLabel];
}

- (void)zfAutoLayoutView {
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(12);
        make.bottom.mas_equalTo(self.contentView).offset(-12);
        make.leading.mas_equalTo(self.contentView).offset(12);
    }];
    
    [self.tipImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.tipLabel.mas_trailing).offset(4);
        make.centerY.equalTo(self.tipLabel);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
}

#pragma mark - Getter
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    }
    return _tipLabel;
}

- (UIImageView *)tipImageView {
    if (!_tipImageView) {
        _tipImageView = [YYAnimatedImageView new];
        _tipImageView.image = [UIImage imageNamed:@"nationalID"];
    }
    return _tipImageView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont systemFontOfSize:14];
        _priceLabel.textColor = ZFCOLOR(51, 51, 51, 1);
    }
    return _priceLabel;
}




@end
