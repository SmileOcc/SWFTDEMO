//
//  YXLiveReplayCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveReplayCell.h"
#import "YXLiveDetailModel.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLiveReplayCell ()
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) CAGradientLayer *glLayer;
@property (nonatomic, strong) UILabel *playTimeLabel;
@end

@implementation YXLiveReplayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *glView = [[UIView alloc] init];
    self.glLayer = [[CAGradientLayer alloc] init];
    self.glLayer.startPoint = CGPointMake(0.5, 0);
    self.glLayer.endPoint = CGPointMake(0.5, 1);
    self.glLayer.locations = @[@(0), @(1.0f)];
    self.glLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1.0].CGColor];
    [glView.layer addSublayer:self.glLayer];
    
    self.coverImageView.layer.cornerRadius = 2;
    self.coverImageView.clipsToBounds = YES;
    self.iconView.layer.cornerRadius = 9;
    self.iconView.clipsToBounds = YES;
    
    self.backgroundColor = UIColor.whiteColor;
    
    [self.contentView addSubview:self.coverImageView];
    [self.contentView addSubview:glView];
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.desLabel];
    [self.contentView addSubview:self.playTimeLabel];
    
    [self.coverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.bottom.equalTo(self.contentView).offset(-14);
        make.width.mas_equalTo(171);
        make.height.mas_equalTo(96);
    }];
    
    [glView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.coverImageView);
        make.height.mas_equalTo(30);
    }];
    
    [self.desLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(8);
        make.top.equalTo(self.coverImageView);
        make.right.equalTo(self).offset(-12);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView).offset(6);
        make.width.height.mas_equalTo(18);
        make.bottom.equalTo(self.coverImageView).offset(-6);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.iconView);
        make.left.equalTo(self.iconView.mas_right).offset(4);
        make.right.equalTo(self.contentView);
    }];

    [self.playTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.coverImageView);
        make.left.equalTo(self.coverImageView.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-12);
    }];
        
    QMUILabel *tagLabel = (QMUILabel *)[QMUILabel labelWithText:[YXLanguageUtility kLangWithKey:@"live_replay"] textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:10]];
    tagLabel.backgroundColor = [[UIColor qmui_colorWithHexString:@"#666666"] colorWithAlphaComponent:0.5];
    tagLabel.layer.cornerRadius = 1;
    tagLabel.clipsToBounds = YES;
    tagLabel.contentEdgeInsets = UIEdgeInsetsMake(3, 4, 3, 4);
    [self.contentView addSubview:tagLabel];
    [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView).offset(6);
        make.left.equalTo(self.coverImageView).offset(6);
    }];
}

- (void)setLiveModel:(YXLiveDetailModel *)liveModel {
    _liveModel = liveModel;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:liveModel.anchor.image_url?:@""] placeholderImage:[UIImage imageNamed:@"nav_user_WhiteSkin"]];
    self.nameLabel.text = liveModel.anchor.nick_name;
    self.desLabel.text = liveModel.title;
    self.playTimeLabel.text = liveModel.replayTimeStr;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:liveModel.cover_images.image.lastObject] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.glLayer.frame = CGRectMake(0, 0, self.coverImageView.mj_w, 30);
}

#pragma mark - 懒加载

- (UIImageView *)coverImageView {
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] init];
    }
    return _coverImageView;
}

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [UILabel labelWithText:@"--" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:12]];
    }
    return _nameLabel;
}


- (UILabel *)desLabel {
    if (_desLabel == nil) {
        _desLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel1 textFont:[UIFont systemFontOfSize:14]];
        _desLabel.numberOfLines = 2;
    }
    return _desLabel;
}


- (UILabel *)playTimeLabel {
    if (_playTimeLabel == nil) {
        _playTimeLabel = [UILabel labelWithText:@"--" textColor:QMUITheme.textColorLevel3 textFont:[UIFont systemFontOfSize:12]];
    }
    return _playTimeLabel;
}


@end
