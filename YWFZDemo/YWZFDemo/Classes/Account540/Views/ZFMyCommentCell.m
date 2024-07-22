//
//  ZFMyCommentCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFMyCommentCell.h"
#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFColorDefiner.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"
#import "BigClickAreaButton.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "GoodsDetailModel.h"
#import "ZFRRPLabel.h"
#import "ExchangeManager.h"
#import "ZFThemeManager.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>
#import "AccountManager.h"
#import "ZFGoodsReviewStarsView.h"
#import "NSDate+ZFExtension.h"

@interface ZFMyCommentCell ()
@property (nonatomic, strong) UIView                                *contentBgView;
@property (nonatomic, strong) UIImageView                           *userImageView;
@property (nonatomic, strong) UILabel                               *timeLabel;
@property (nonatomic, strong) ZFGoodsReviewStarsView                *starView;
@property (nonatomic, strong) UILabel                               *reviewDescLabel;
@property (nonatomic, strong) UIView                                *imageContentView;
@property (nonatomic, strong) UIImageView                           *goodsImageView;
@property (nonatomic, strong) UILabel                               *goodsTitleLabel;
@property (nonatomic, strong) UILabel                               *goodsSizeLabel;

@property (nonatomic, strong) UIButton                              *goodButton;

@end

@implementation ZFMyCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ZFC0xF2F2F2();
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)setCommentModel:(ZFMyCommentModel *)commentModel {
    _commentModel = commentModel;
    
    NSString *avatar = [AccountManager sharedManager].account.avatar;
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:avatar]
                               placeholder:[UIImage imageNamed:@"public_user_small"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:nil
                                 transform:nil
                                completion:nil];
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:commentModel.goods_grid]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:nil
                                 transform:nil
                                completion:nil];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ZFToString(commentModel.add_time).integerValue];
    [date queryZFDateFormatter].dateFormat = @"MMM,dd,yyyy 'at' hh:mm:ss";
    NSString *add_time = [[date queryZFDateFormatter] stringFromDate:date];
    self.timeLabel.text = ZFToString(add_time);
    
    self.goodsTitleLabel.text = ZFToString(commentModel.goods_title);
    self.reviewDescLabel.text = ZFToString(commentModel.pros);
    self.goodsSizeLabel.text = ZFToString(commentModel.goods_attr_str);
    self.starView.rateAVG = ZFToString(commentModel.rate_overall);
}

- (void)actionGoods:(UIButton *)sender {
    if (self.TapGoodsBlock) {
        self.TapGoodsBlock(self.commentModel.goods_id);
    }
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    [self.contentView addSubview:self.contentBgView];
    [self.contentBgView addSubview:self.userImageView];
    [self.contentBgView addSubview:self.timeLabel];
    [self.contentBgView addSubview:self.starView];
    [self.contentBgView addSubview:self.reviewDescLabel];
    [self.contentBgView addSubview:self.imageContentView];
    [self.imageContentView addSubview:self.goodsImageView];
    [self.imageContentView addSubview:self.goodsTitleLabel];
    [self.imageContentView addSubview:self.goodsSizeLabel];
    [self.imageContentView addSubview:self.goodButton];
}

- (void)zfAutoLayoutView {
    [self.contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(6, 12, 6, 12));
    }];
    
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentBgView).offset(12);
        make.leading.mas_equalTo(self.contentBgView).offset(12);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userImageView.mas_top);
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(6);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-12);
    }];
    
    [self.starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(-1);
        make.leading.mas_equalTo(self.timeLabel);
        make.size.mas_equalTo(CGSizeMake(95, 28));
    }];

    [self.reviewDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userImageView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.userImageView.mas_leading);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-12);
    }];
    
    [self.imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.reviewDescLabel.mas_bottom).offset(16);
        make.leading.mas_equalTo(self.userImageView.mas_leading);
        make.trailing.mas_equalTo(self.reviewDescLabel.mas_trailing);
        make.bottom.mas_equalTo(self.contentBgView.mas_bottom).offset(-12);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageContentView.mas_top).offset(6);
        make.leading.mas_equalTo(self.imageContentView).offset(8);
        make.bottom.mas_equalTo(self.imageContentView.mas_bottom).offset(-6);
        make.size.mas_equalTo(CGSizeMake(42, 56));
    }];
    
    [self.goodsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(4);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-6);
        make.bottom.mas_equalTo(self.goodsImageView.mas_centerY).offset(-1);
    }];
    
    [self.goodsSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsTitleLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentBgView.mas_trailing).offset(-6);
        make.top.mas_equalTo(self.goodsTitleLabel.mas_bottom).offset(4);
    }];
    
    [self.goodButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageContentView);
    }];
}

#pragma mark - Getter

- (UIView *)contentBgView{
    if (!_contentBgView) {
        _contentBgView = [[UIView alloc] init];
        _contentBgView.backgroundColor = ZFCOLOR_WHITE;
        _contentBgView.layer.cornerRadius = 8;
        _contentBgView.layer.masksToBounds = YES;
        _contentBgView.clipsToBounds = YES;
    }
    return _contentBgView;
}

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.layer.cornerRadius = 20;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor whiteColor];
        _timeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (ZFGoodsReviewStarsView *)starView {
    if (!_starView) {
        _starView = [[ZFGoodsReviewStarsView alloc] initWithFrame:CGRectZero];
    }
    return _starView;
}

- (UILabel *)reviewDescLabel {
    if (!_reviewDescLabel) {
        _reviewDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _reviewDescLabel.backgroundColor = [UIColor whiteColor];
        _reviewDescLabel.font = [UIFont systemFontOfSize:14];
        _reviewDescLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _reviewDescLabel.numberOfLines = 0;
        _reviewDescLabel.preferredMaxLayoutWidth = KScreenWidth - 24 * 2;
    }
    return _reviewDescLabel;
}

- (UIView *)imageContentView {
    if (!_imageContentView) {
        _imageContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _imageContentView.backgroundColor = ZFC0xF2F2F2();
        _imageContentView.clipsToBounds = YES;
    }
    return _imageContentView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UILabel *)goodsTitleLabel {
    if (!_goodsTitleLabel) {
        _goodsTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsTitleLabel.font = [UIFont systemFontOfSize:14];
        _goodsTitleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _goodsTitleLabel.preferredMaxLayoutWidth = KScreenWidth - 16 * 2;
    }
    return _goodsTitleLabel;
}

- (UILabel *)goodsSizeLabel {
    if (!_goodsSizeLabel) {
        _goodsSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _goodsSizeLabel.font = [UIFont systemFontOfSize:12];
        _goodsSizeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _goodsSizeLabel;
}

- (UIButton *)goodButton {
    if (!_goodButton) {
        _goodButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_goodButton addTarget:self action:@selector(actionGoods:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goodButton;
}
@end

