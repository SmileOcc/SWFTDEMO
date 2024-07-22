//
//  ZFPostDetailTileCollectionReusableView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPostDetailTileCollectionReusableView.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "UIImage+ZFExtended.h"
#import "NSStringUtils.h"
@interface ZFPostDetailTileCollectionReusableView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *goodsMoreView;
@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) UIImageView *moreImageView;

@end

@implementation ZFPostDetailTileCollectionReusableView

+ (ZFPostDetailTileCollectionReusableView *)titleHeaderViewWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath type:(ZFTopicDetailTitleType)type {
    NSString *identifer = NSStringFromClass([self class]);
    [collectionView registerClass:[self class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifer];
    ZFPostDetailTileCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identifer forIndexPath:indexPath];
    
    switch (type) {
        case ZFTopicDetailTitleTypeSimilar: {
            headerView.goodsMoreView.hidden = NO;
            
            headerView.titleLabel.text = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"community_topicdetail_similartitle", nil)];
            break;
        }
        case ZFTopicDetailTitleTypeNomarlRelated: {
            headerView.goodsMoreView.hidden = YES;
            headerView.titleLabel.text = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"community_topicdetail_relatetitle", nil)];
            break;
        }
        case ZFTopicDetailTitleTypeOutfitRelated: {
            headerView.goodsMoreView.hidden = YES;
            headerView.titleLabel.text = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"community_topicdetail_o_relatetitle", nil)];
            break;
        }
            
        default:
            break;
    }
    return headerView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        [self setupView];
        [self layout];
    }
    return self;
}


- (void)setupView {
    [self addSubview:self.titleLabel];
    [self addSubview:self.goodsMoreView];
    [self.goodsMoreView addSubview:self.moreLabel];
    [self.goodsMoreView addSubview:self.moreImageView];
}

- (void)layout {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self).mas_offset(12.0);
    }];
    
    [self.goodsMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.mas_equalTo(self);
        make.width.mas_equalTo(130.0);
    }];
    
    [self.moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.goodsMoreView).mas_offset(-12.0);
        make.height.with.mas_equalTo(20.0);
        make.centerY.mas_equalTo(self.goodsMoreView.mas_centerY);
    }];
    
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.moreImageView.mas_leading);
        make.top.bottom.mas_equalTo(self.goodsMoreView);
    }];
}

#pragma mark - event
- (void)moreGoodsAction {
    if (self.moreActionHandle) {
        self.moreActionHandle();
    }
}

- (void)hideMoreView {
    self.goodsMoreView.hidden = YES;
    self.moreLabel.hidden = YES;
}

#pragma mark - getter/setter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel           = [[UILabel alloc] init];
        _titleLabel.font      = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = ZFC0x2D2D2D();
        _titleLabel.text      = ZFLocalizedString(@"community_post_simalar_produce", nil);
    }
    return _titleLabel;
}

- (UIView *)goodsMoreView {
    if (!_goodsMoreView) {
        _goodsMoreView = [[UIView alloc] init];
        _goodsMoreView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRg  = [[UITapGestureRecognizer alloc] init];
        [tapGestureRg addTarget:self action:@selector(moreGoodsAction)];
        [_goodsMoreView addGestureRecognizer:tapGestureRg];
    }
    return _goodsMoreView;
}

- (UILabel *)moreLabel {
    if (!_moreLabel) {
        _moreLabel           = [[UILabel alloc] init];
        _moreLabel.font      = [UIFont systemFontOfSize:14.0];
        _moreLabel.textColor = ZFC0xFE5269();
        _moreLabel.text      = ZFLocalizedString(@"Detail_Product_GoodsReviewCell_ViewAll", nil);
    }
    return _moreLabel;
}

- (UIImageView *)moreImageView {
    if (!_moreImageView) {
        _moreImageView = [[UIImageView alloc] init];
        _moreImageView.contentMode = UIViewContentModeScaleAspectFit;
        UIImage *arrowImage = [UIImage imageNamed:@"car_topTip_arrow"];
        _moreImageView.image = [arrowImage imageWithColor:ZFC0xFE5269()];
        [_moreImageView convertUIWithARLanguage];
    }
    return _moreImageView;
}

@end
