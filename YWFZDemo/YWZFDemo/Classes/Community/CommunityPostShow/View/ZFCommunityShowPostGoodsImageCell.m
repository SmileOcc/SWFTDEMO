//
//  ZFCommunityShowPostGoodsImageCell.m
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowPostGoodsImageCell.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"

@interface ZFCommunityShowPostGoodsImageCell ()

@property (nonatomic, strong) YYAnimatedImageView          *goodsImageView;

@property (nonatomic, strong) UIView                       *addView;

@property (nonatomic, strong) UIImageView                  *addImageView;

@property (nonatomic, strong) UILabel                      *addTipLabel;


@property (nonatomic, strong) UIButton *deleteGoodsButton;

@end

@implementation ZFCommunityShowPostGoodsImageCell

+ (ZFCommunityShowPostGoodsImageCell *)goodsImageCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFCommunityShowPostGoodsImageCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityShowPostGoodsImageCell class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityShowPostGoodsImageCell class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];

        _goodsImageView = [[YYAnimatedImageView alloc] init];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.userInteractionEnabled = YES;
        _goodsImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_goodsImageView];
        
        
        [_goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self);
            make.height.mas_equalTo(self.goodsImageView.mas_width).multipliedBy(1.0);
        }];
        
        _deleteGoodsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteGoodsButton.backgroundColor = [UIColor clearColor];
        [_deleteGoodsButton setBackgroundImage:[UIImage imageNamed:@"album_delete"] forState:UIControlStateNormal];
        [_deleteGoodsButton addTarget:self action:@selector(deleteGoods:) forControlEvents:UIControlEventTouchUpInside];
        [_goodsImageView addSubview:_deleteGoodsButton];
        
        [_deleteGoodsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.equalTo(self.goodsImageView);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        [self.contentView addSubview:self.addView];
        [self.addView addSubview:self.addImageView];
        [self.addView addSubview:self.addTipLabel];

        [self.addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.addView.mas_centerX);
            make.top.mas_equalTo(self.addView.mas_top).offset(16);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
        
        [self.addTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.addView.mas_leading).offset(6);
            make.trailing.mas_equalTo(self.addView.mas_trailing).offset(-6);
            make.top.mas_equalTo(self.addImageView.mas_bottom).offset(4);
        }];
        
    }
    return self;
}


- (void)setAddImage:(UIImage *)image {
    if (self.isNeedHiddenAddView) {
        self.addView.hidden = YES;
    } else {
        self.addView.hidden = NO;
    }
    self.goodsImageView.hidden = YES;
    self.deleteGoodsButton.hidden = YES;
}
-(void)setModel:(ZFCommunityPostShowSelectGoodsModel *)model {
    _model = model;
    self.deleteGoodsButton.hidden = NO;
    self.goodsImageView.hidden = NO;
    self.addView.hidden = YES;
    if (self.isNeedHiddenAddView) {
        self.goodsImageView.hidden = YES;
    }
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:model.imageURL]
                                placeholder:ZFImageWithName(@"community_loading_product")
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        // CGFloat width = (KScreenWidth - 5 * KImageMargin) / 4;
        //image = [image yy_imageByResizeToSize:CGSizeMake(width,width * ScreenWidth_SCALE) contentMode:UIViewContentModeScaleAspectFit];
        BOOL isHidden = [image isEqual:[UIImage imageNamed:@"add_photo"]];
    }];
}

- (void)deleteGoods:(UIButton *)sender {
    if (self.deleteGoodBlock) {
        self.deleteGoodBlock(self.model);
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.goodsImageView yy_cancelCurrentImageRequest];
    self.goodsImageView.image = nil;
    self.goodsImageView.hidden = NO;
    self.deleteGoodsButton.hidden = NO;
}

- (UIView *)addView {
    if (!_addView) {
        _addView = [[UIView alloc] initWithFrame:CGRectZero];
        _addView.layer.cornerRadius = 2;
        _addView.layer.borderColor = ZFC0xDDDDDD().CGColor;
        _addView.layer.borderWidth = 1.0;
        _addView.layer.masksToBounds = YES;
    }
    return _addView;
}

- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"album_add"]];
        _addImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _addImageView;
}

- (UILabel *)addTipLabel {
    if (!_addTipLabel) {
        _addTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addTipLabel.text = ZFLocalizedString(@"Community_AddItem", nil);
        _addTipLabel.textColor = ZFC0xCCCCCC();
        _addTipLabel.font = [UIFont systemFontOfSize:12];
        _addTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _addTipLabel;
}
@end
