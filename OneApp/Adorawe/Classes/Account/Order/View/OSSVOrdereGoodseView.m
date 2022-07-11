//
//  OSSVOrdereGoodseView.m
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdereGoodseView.h"

@interface OSSVOrdereGoodseView()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation OSSVOrdereGoodseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.goodsInfoView];
        [self addSubview:self.collectionView];
        
        [self.goodsInfoView addSubview:self.iconView];
//        [self.goodsInfoView addSubview:self.priceLabel];
//        [self.goodsInfoView addSubview:self.countLabel];
        [self.goodsInfoView addSubview:self.titleLabel];
        [self.goodsInfoView addSubview:self.attrLabel];
        
        [self.goodsInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self);
            
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top).offset(8);
            make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
        }];
        

        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodsInfoView.mas_leading).offset(14);
            make.top.mas_equalTo(self.goodsInfoView.mas_top).offset(8);
            make.bottom.mas_equalTo(self.goodsInfoView.mas_bottom).offset(-8);
            make.width.mas_equalTo(self.iconView.mas_height).multipliedBy(0.75);
        }];
        
//        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
//            make.top.mas_equalTo(self.iconView.mas_top);
//        }];
//
//        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
//            make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(2);
//        }];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconView.mas_trailing).offset(8);
            make.top.mas_equalTo(self.goodsInfoView.mas_top).offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
        }];
        
        [self.attrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.trailing.mas_equalTo(self.titleLabel.mas_trailing);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        }];
        
//        //设置优先完整显示
//        [self.priceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addGestureRecognizer:self.collectionView.panGestureRecognizer];
    }
    return self;
}

- (void)setOrdersGoodsList:(NSArray<OSSVAccounteMyOrderseGoodseModel *> *)ordersGoodsList {
    _ordersGoodsList = ordersGoodsList;
    if (!STLJudgeNSArray(ordersGoodsList)) {
        _ordersGoodsList = @[];
    }
    
    if (_ordersGoodsList.count > 1) {
        [self.collectionView reloadData];
        self.goodsInfoView.hidden = YES;
        self.collectionView.hidden = NO;
    } else if(_ordersGoodsList.count == 1){
        self.collectionView.hidden = YES;
        self.goodsInfoView.hidden = NO;
        
        OSSVAccounteMyOrderseGoodseModel *goodsModel = [_ordersGoodsList firstObject];
        self.attrLabel.text = STLToString(goodsModel.goods_attr);
        self.titleLabel.text = STLToString(goodsModel.goods_name);
//        self.priceLabel.text = STLToString(self.formated_goods_amount);
//        self.countLabel.text = [NSString stringWithFormat:@"x%@",STLToString(goodsModel.goods_number)];
        [self.iconView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goods_thumb]
                         placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                             options:kNilOptions
                            progress:nil
                           transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
            return image;
        } completion:nil];
    } else {
        self.collectionView.hidden = YES;
        self.goodsInfoView.hidden = YES;
    }
}
#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.ordersGoodsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];

    UIImageView *goodsImgView = [[UIImageView alloc] init];
    goodsImgView.contentMode = UIViewContentModeScaleAspectFill;
    OSSVAccounteMyOrderseGoodseModel *goodsModel = self.ordersGoodsList[indexPath.row];
    [goodsImgView yy_setImageWithURL:[NSURL URLWithString:STLToString(goodsModel.goods_thumb)]
                         placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                             options:kNilOptions
                            progress:nil
                           transform:nil
                          completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];
    imageCell.backgroundView = goodsImgView;
    imageCell.layer.borderWidth = 0.5;
    imageCell.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
    imageCell.layer.masksToBounds = YES;
        return imageCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(72 / 96.0 * CGRectGetHeight(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 8;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 14, 0, 14);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.userInteractionEnabled = NO;
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}

- (UIView *)goodsInfoView {
    if (!_goodsInfoView) {
        _goodsInfoView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _goodsInfoView;
}

- (YYAnimatedImageView *)iconView {
    if (!_iconView) {
        YYAnimatedImageView *iconView = [YYAnimatedImageView new];
        iconView.contentMode = UIViewContentModeScaleAspectFill;
        iconView.clipsToBounds = YES;
        iconView.layer.borderWidth = 0.5;
        iconView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        iconView.layer.masksToBounds = YES;
        _iconView = iconView;
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [UILabel new];
        _titleLabel = titleLabel;
        titleLabel.textColor = [OSSVThemesColors col_6C6C6C];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.numberOfLines = 2;
        titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            titleLabel.textAlignment = NSTextAlignmentRight;
            titleLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
    }
    return _titleLabel;
}

- (UILabel *)attrLabel {
    if (!_attrLabel) {
        UILabel *attrLabel = [UILabel new];
        _attrLabel = attrLabel;
        attrLabel.textColor = [OSSVThemesColors col_6C6C6C];
        attrLabel.font = [UIFont boldSystemFontOfSize:12];
        attrLabel.numberOfLines = 0;
        attrLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            attrLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _attrLabel;
}

///v 1.4.6隐藏
//- (UILabel *)priceLabel {
//    if (!_priceLabel) {
//        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
//        _priceLabel.font = [UIFont systemFontOfSize:11];
//        _priceLabel.textAlignment = NSTextAlignmentRight;
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            _priceLabel.textAlignment = NSTextAlignmentLeft;
//        }
//    }
//    return _priceLabel;
//}
//
//- (UILabel *)countLabel {
//    if (!_countLabel) {
//        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _countLabel.textColor = [OSSVThemesColors col_999999];
//        _countLabel.font = [UIFont systemFontOfSize:11];
//        _countLabel.textAlignment = NSTextAlignmentRight;
//    }
//    return _countLabel;
//}

@end
