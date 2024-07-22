//
//  ZFGoodsDetailShowListCell.m
//  ZZZZZ
//
//  Created by YW on 20/7/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailShowListCell.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFGoodsDetailShowListCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView     *videoMaskView;
@property (nonatomic, strong) UIImageView     *videoIconImageView;
@property (nonatomic, strong) UIImageView     *goodsImageView;
@property (nonatomic, strong) UILabel         *likeNumberLabel;
@end

@implementation ZFGoodsDetailShowListCell

+ (ZFGoodsDetailShowListCell *)ShowListCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFGoodsDetailShowListCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.goodsImageView addSubview:self.videoMaskView];
    [self.videoMaskView addSubview:self.videoIconImageView];
    [self.contentView addSubview:self.likeNumberLabel];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = 90;
        CGFloat height = 120;
        make.top.leading.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(width,height));
    }];
    
    [self.videoMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self.goodsImageView);
    }];
    
    [self.videoIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.videoMaskView);
        make.size.mas_equalTo(CGSizeMake(24,24));
    }];
    
    [self.likeNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.goodsImageView.mas_bottom).offset(8);
        make.centerX.equalTo(self.goodsImageView);
        make.width.lessThanOrEqualTo(self.goodsImageView.mas_width);
        make.height.mas_equalTo(16);
    }];
}

#pragma mark - Setter
- (void)setModel:(GoodsShowExploreModel *)model {
    _model = model;
    
    // 如果为视频则显示播放图标
    self.videoMaskView.hidden = (model.type != 1);
    
    // type=1: 视频, (视频需要拼接id获取图片)
    NSString *imageUrl = model.bigPic;
    if (model.type == 1) {
        imageUrl = [NSString stringWithFormat:ZFCommunityVideoImageUrl,model.video_url];
    }
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
    
    NSString *likeNumber = @"";
    if ([model.likeNumbers integerValue] > 10000) {
        likeNumber = [NSString stringWithFormat:@"9.9k+ %@",ZFLocalizedString(@"MyStylePage_SubVC_Likes", nil)];
    }else{
        likeNumber = [NSString stringWithFormat:@"%@ %@",model.likeNumbers,ZFLocalizedString(@"MyStylePage_SubVC_Likes", nil)];
    }
    
    self.likeNumberLabel.text = likeNumber;
    self.likeNumberLabel.hidden = !model.isShowLikeNumber;
    [self.likeNumberLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(model.isShowLikeNumber ? 16 : 0);
    }];
}

#pragma mark - Getter
- (UIImageView *)videoMaskView {
    if (!_videoMaskView) {
        _videoMaskView = [[UIImageView alloc] init];
        _videoMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _videoMaskView.clipsToBounds = YES;
        _videoMaskView.hidden = YES;
    }
    return _videoMaskView;
}

- (UIImageView *)videoIconImageView {
    if (!_videoIconImageView) {
        _videoIconImageView = [[UIImageView alloc] initWithImage:ZFImageWithName(@"community_home_play_big")];
        _videoIconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoIconImageView.clipsToBounds = YES;
    }
    return _videoIconImageView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
        _goodsImageView.backgroundColor = ZFCOLOR_WHITE;
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds = YES;
    }
    return _goodsImageView;
}

- (UILabel *)likeNumberLabel {
    if (!_likeNumberLabel) {
        _likeNumberLabel = [[UILabel alloc] init];
        _likeNumberLabel.backgroundColor = ZFCOLOR_WHITE;
        _likeNumberLabel.font = ZFFontSystemSize(14);
        _likeNumberLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _likeNumberLabel.hidden = YES;
    }
    return _likeNumberLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.goodsImageView.image = nil;
    self.likeNumberLabel.text = nil;
}

@end
