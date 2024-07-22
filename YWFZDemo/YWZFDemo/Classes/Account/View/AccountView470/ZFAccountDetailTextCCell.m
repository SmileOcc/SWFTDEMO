//
//  ZFAccountDetailTextCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountDetailTextCCell.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "ZFAccountCategorySectionModel.h"
#import <Masonry/Masonry.h>

@interface ZFAccountDetailTextCCell ()

@property (nonatomic, strong) UIImageView       *iconImageView;
@property (nonatomic, strong) UILabel           *titleLabel;
@property (nonatomic, strong) UILabel           *tipsLabel;
@property (nonatomic, strong) UIImageView       *arrowImageView;
@property (nonatomic, strong) UIView            *lineView;

@end

@implementation ZFAccountDetailTextCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.tipsLabel];
    [self addSubview:self.arrowImageView];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_offset(KScreenWidth);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self.mas_leading).offset(17);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(17);
        make.height.mas_offset(44.0f);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-8);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-1.f);
        make.height.mas_equalTo(1.f);
    }];
}

+ (CGSize)itemSize:(NSInteger)sectionRows protocol:(id<ZFCollectionCellDatasourceProtocol>)protocol
{
    return CGSizeMake(KScreenWidth, 44);
}

#pragma mark - Property Method

- (void)setModel:(id<ZFCollectionCellDatasourceProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[ZFAccountDetailTextModel class]]) {
        ZFAccountDetailTextModel *textModel = _model;
        self.iconImageView.image = [UIImage imageNamed:textModel.imageName];
        self.titleLabel.text = textModel.title;
        self.lineView.hidden = textModel.hiddenLine;
    }
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"address"];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _titleLabel.text = @"Shipping Address";
        _titleLabel.textAlignment = ![SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
    }
    return _titleLabel;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
    }
    return _tipsLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"account_arrow"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _lineView;
}

@end
