//
//  ZFCommunityOutfitsListCell.m
//  ZZZZZ
//
//  Created by YW on 2017/7/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityOutfitsListCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityOutfitsModel.h"
#import "UICollectionViewCell+ZFExtension.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityOutfitsListCell () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView               *outfitsImageView;
@property (nonatomic, strong) UILabel                   *titleLabel;
@property (nonatomic, strong) UIImageView               *waterFlowUserImageView;
@property (nonatomic, strong) UIImageView               *waterFlowRankImageView;
@property (nonatomic, strong) UILabel                   *waterFlowUserLab;
@property (nonatomic, strong) UIButton                  *likeButton;
@property (nonatomic, strong) UIButton                  *topMarkButton;
@end

@implementation ZFCommunityOutfitsListCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.outfitsImageView.image = nil;
    self.titleLabel.text = nil;
    self.likeButton.selected = NO;
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = ZFCOLOR_WHITE;
        [self zfInitView];
        [self zfAutoLayoutView];
        //设置cell投影圆角效果
        [self setShadowAndCornerCell];
    }
    return self;
}

#pragma mark - action methods
- (void)addLikeButtonAction:(UIButton *)sender {
    if (self.communityOutfitsLikeCompletionHandler) {
        [sender.imageView.layer addAnimation:[sender.imageView zfAnimationFavouriteScale] forKey:@"likeAnimation"];
        self.communityOutfitsLikeCompletionHandler(self.model);
    }
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self.contentView addSubview:self.outfitsImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.waterFlowUserImageView];
    [self.contentView addSubview:self.waterFlowRankImageView];
    [self.contentView addSubview:self.waterFlowUserLab];
    [self.contentView addSubview:self.likeButton];
    [self.contentView addSubview:self.topMarkButton];

}

- (void)zfAutoLayoutView {
    [self.outfitsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.equalTo(self.outfitsImageView.mas_width);
    }];
    
    [self.topMarkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(4);
        make.trailing.offset(0);
        make.height.mas_equalTo(16);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outfitsImageView.mas_bottom).offset(6);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.waterFlowUserImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(7);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.waterFlowRankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.waterFlowUserImageView.mas_trailing);
        make.bottom.mas_equalTo(self.waterFlowUserImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    
    [self.likeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-11);
        make.centerY.mas_equalTo(self.waterFlowUserImageView.mas_centerY).offset(1);
        make.height.mas_equalTo(44);
    }];
    
    [self.waterFlowUserLab mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.waterFlowUserImageView.mas_trailing).offset(7);
        make.centerY.mas_equalTo(self.waterFlowUserImageView.mas_centerY);
        make.trailing.mas_equalTo(self.likeButton.mas_leading).offset(-8);
    }];
    
    [self.likeButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.likeButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    [self.waterFlowUserLab setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

}

#pragma mark - setter
- (void)setModel:(ZFCommunityOutfitsModel *)model {
    _model = model;
    
    if (!_model.randomColor) {
        _model.randomColor = [UIColor colorWithHexString:[ZFThemeManager randomColorString:nil]] ;
    }
    self.outfitsImageView.backgroundColor = _model.randomColor;

    //图片
    NSString *smallPic = ZFToString(_model.picInfo[@"small_pic"]);
    if ([smallPic length] > 0) {
        NSURL *url = [NSURL URLWithString:smallPic];
        [self.outfitsImageView yy_setImageWithURL:url
                                       placeholder:nil];
    } else {
        self.outfitsImageView.image = model.img != nil ? model.img : nil;
    }
    
    [self.waterFlowUserImageView yy_setImageWithURL:[NSURL URLWithString:_model.avatar]
                                         placeholder:[UIImage imageNamed:@"public_user"]
                                            options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                           progress:nil
                                          transform:nil
                                         completion:nil];
    
    self.waterFlowRankImageView.hidden = YES;
    if ([model.identify_type integerValue] > 0) {
        [self.waterFlowRankImageView yy_setImageWithURL:[NSURL URLWithString:model.identify_icon] options:kNilOptions];
        self.waterFlowRankImageView.hidden = NO;
    }
    
    self.titleLabel.text = ZFToString(_model.reviewTitle);
    self.waterFlowUserLab.text = ZFToString(_model.nikename);
    self.likeButton.selected = [_model.liked boolValue];
    
    NSInteger likeNum = (long)[model.likeCount integerValue];
    if (likeNum > 0) {
        UIControlState state = self.likeButton.selected ? UIControlStateSelected : UIControlStateNormal;
        
        NSString *likeStr = [NSString stringWithFormat:@"%zd",likeNum];
        if (likeNum >= 10000) {
            likeStr = @"9.9k+";
        }
        [self.likeButton setTitle:likeStr forState:state];        
        self.likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    } else {
        self.likeButton.selected = NO;
        [self.likeButton setTitle:@"" forState:UIControlStateNormal];
        self.likeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    /** 设置置顶图片 */
    if (model.is_top) {
        self.topMarkButton.hidden = NO;
    }else{
        self.topMarkButton.hidden = YES;
    }
}

#pragma mark - getter
- (UIImageView *)outfitsImageView {
    if (!_outfitsImageView) {
        _outfitsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _outfitsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _outfitsImageView.clipsToBounds = YES;
    }
    return _outfitsImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = ZFCOLOR(102, 102, 102, 1.0);
        _titleLabel.preferredMaxLayoutWidth = (KScreenWidth-35)/2-15;
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UIImageView *)waterFlowUserImageView {
    if (!_waterFlowUserImageView) {
        _waterFlowUserImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waterFlowUserImageView.contentMode = UIViewContentModeScaleAspectFill;
        _waterFlowUserImageView.userInteractionEnabled = YES;
        
        UIImageView *maskView = [[UIImageView alloc] init];
        maskView.contentMode = UIViewContentModeScaleAspectFill;
        maskView.frame = CGRectMake(0, 0, 20, 20);
        maskView.image = ZFImageWithName(@"public_user");
        _waterFlowUserImageView.maskView = maskView;
    }
    return _waterFlowUserImageView;
}

- (UIImageView *)waterFlowRankImageView {
    if (!_waterFlowRankImageView) {
        _waterFlowRankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _waterFlowRankImageView.backgroundColor = [UIColor clearColor];
        _waterFlowRankImageView.userInteractionEnabled = YES;
        _waterFlowRankImageView.hidden = YES;
    }
    return _waterFlowRankImageView;
}

- (UILabel *)waterFlowUserLab {
    if (!_waterFlowUserLab) {
        _waterFlowUserLab = [[UILabel alloc] init];
        _waterFlowUserLab.font = ZFFontSystemSize(12.0);
        _waterFlowUserLab.textColor = ZFCOLOR(153, 153, 153, 1.0);
    }
    return _waterFlowUserLab;
}

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.titleLabel.font = ZFFontSystemSize(12.0);
        [_likeButton setTitleColor:ZFCOLOR(102, 102, 102, 1.0) forState:UIControlStateNormal];
        [_likeButton setTitleColor:ZFC0xFE5269() forState:UIControlStateSelected];
        [_likeButton setImage:[UIImage imageNamed:@"Community_like_gray"] forState:UIControlStateNormal];
        [_likeButton setImage:[[UIImage imageNamed:@"Community_like_red"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        [_likeButton addTarget:self action:@selector(addLikeButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];

        [_likeButton zfLayoutStyle:ZFButtonEdgeInsetsStyleLeft imageTitleSpace:3];
        [_likeButton convertUIWithARLanguage];
    }
    return _likeButton;
}

- (UIButton *)topMarkButton{
    if (!_topMarkButton) {
        _topMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topMarkButton setTitle:ZFLocalizedString(@"Community_shows_top", nil) forState:UIControlStateNormal];
        _topMarkButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_topMarkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _topMarkButton.backgroundColor = ZFC0xFE5269();
        _topMarkButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        _topMarkButton.layer.cornerRadius = 2;
        _topMarkButton.layer.masksToBounds = YES;
        _topMarkButton.hidden = YES;
    }
    return _topMarkButton;
}

@end
