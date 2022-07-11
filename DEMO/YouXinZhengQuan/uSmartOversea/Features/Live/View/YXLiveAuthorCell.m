//
//  YXLiveAuthorCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveAuthorCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLiveAuthorCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *desLabel;

@property (nonatomic, strong) CAGradientLayer *gl;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) QMUIButton *followBtn;

@end

@implementation YXLiveAuthorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.bgView = [[UIView alloc] init];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.clipsToBounds = YES;
    // gradient
    CAGradientLayer *gl = [CAGradientLayer layer];
    self.gl = gl;
    gl.startPoint = CGPointMake(0, 0.55);
    gl.endPoint = CGPointMake(1, 0.5);
    gl.colors = @[(__bridge id)[UIColor colorWithRed:245/255.0 green:233/255.0 blue:223/255.0 alpha:1.0].CGColor, (__bridge id)[UIColor colorWithRed:245/255.0 green:215/255.0 blue:186/255.0 alpha:1.0].CGColor];
    gl.locations = @[@(0), @(1.0f)];
    
    [self.bgView.layer insertSublayer:gl atIndex:0];
    
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.iconView];
    [self.bgView addSubview:self.nameLabel];
    [self.bgView addSubview:self.desLabel];
    [self.bgView addSubview:self.followBtn];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(12);
        make.right.equalTo(self.contentView).offset(-12);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(20);
        make.top.equalTo(self.bgView).offset(12);
        make.width.height.mas_equalTo(36);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconView);
        make.left.equalTo(self.iconView.mas_right).offset(10);
        make.right.equalTo(self.bgView).offset(-10);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView);
        make.right.equalTo(self.bgView).offset(-20);
        make.top.equalTo(self.iconView.mas_bottom).offset(10);
    }];
    
    [self.followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView).offset(-20);
        make.top.equalTo(self.bgView).offset(14);
        make.width.height.mas_equalTo(90);
        make.height.height.mas_equalTo(32);
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.gl.frame = self.bgView.bounds;
}

- (void)setAnchorModel:(YXLiveAnchorModel *)anchorModel {
    _anchorModel = anchorModel;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:anchorModel.image_url] placeholderImage:[UIImage imageNamed:@"nav_user"]];
    self.nameLabel.text = anchorModel.nick_name;
//    self.desLabel.text = anchorModel.introduce;
    NSAttributedString *att = [YXToolUtility attributedStringWithText:anchorModel.introduce font:[UIFont systemFontOfSize:14] textColor:QMUITheme.textColorLevel2 lineSpacing:5];
    self.desLabel.attributedText = att;
}

- (void)setIsFollow:(BOOL)isFollow {
    _isFollow = isFollow;
    self.followBtn.selected = isFollow;
}

- (void)followBtnClick: (UIButton *)sender {
    
    if (self.clickFollowCallBack) {
        self.clickFollowCallBack(!sender.selected);
    }
}

#pragma mark - lazy load

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 18;
        _iconView.layer.borderColor = [UIColor qmui_colorWithHexString:@"#D4A980"].CGColor;
        _iconView.layer.borderWidth = 2;
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    }
    return _nameLabel;
}

- (UILabel *)desLabel {
    if (_desLabel == nil) {
        _desLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14]];
        _desLabel.numberOfLines = 0;
    }
    return _desLabel;
}

- (QMUIButton *)followBtn {
    if (_followBtn == nil) {
        _followBtn = [QMUIButton buttonWithType:UIButtonTypeCustom title:[YXLanguageUtility kLangWithKey:@"live_follow"] font:[UIFont systemFontOfSize:14 weight:UIFontWeightMedium] titleColor:[UIColor qmui_colorWithHexString:@"#D4A980"] target:self action:@selector(followBtnClick:)];
        [_followBtn setTitle:[YXLanguageUtility kLangWithKey:@"live_has_follow"] forState:UIControlStateSelected];
        
        [_followBtn setTitleColor:[[UIColor qmui_colorWithHexString:@"#191919"] colorWithAlphaComponent:0.2] forState: UIControlStateSelected];
        [_followBtn setImage:[UIImage imageNamed:@"live_follow"] forState:UIControlStateNormal];
        [_followBtn setImage:[UIImage imageNamed:@"live_follow_selected"] forState:UIControlStateSelected];
        [_followBtn setImagePosition: QMUIButtonImagePositionLeft];
        _followBtn.spacingBetweenImageAndTitle = 2;
        _followBtn.backgroundColor = UIColor.whiteColor;
        _followBtn.layer.cornerRadius = 4;
        _followBtn.clipsToBounds = YES;
    }
    return _followBtn;
}

@end
