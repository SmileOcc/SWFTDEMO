//
//  ZFRecentlyTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFRecentlyTableViewCell.h"
#import "ZFFrameDefiner.h"
#import "ZFCMSSectionModel.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "ZFLocalizationString.h"
#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>

#define rowsIndex 3

@interface ZFRecentlyProductCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *productImage;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) ZFGoodsModel *goodsModel;

@end

@implementation ZFRecentlyProductCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addSubview:self.productImage];
        [self addSubview:self.priceLabel];
        
        ///屏幕宽度 - padding宽度 - 首行padding
        CGFloat width = (floorf)((KScreenWidth - (8 * (rowsIndex)) - 16) / (rowsIndex + 0.5));
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(width);
        }];
        
        [self.productImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(self.mas_width).multipliedBy(1.35);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.productImage.mas_bottom).mas_offset(8);
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_offset(16);
        }];
    }
    return self;
}

#pragma mark - Property Method

-(void)setGoodsModel:(ZFGoodsModel *)goodsModel
{
    _goodsModel = goodsModel;
    
    [self.productImage yy_setImageWithURL:[NSURL URLWithString:_goodsModel.wp_image]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  }
                                 transform:^UIImage *(UIImage *image, NSURL *url) {
                                     return image;
                                 }
                                completion:nil];
    self.priceLabel.text = [ExchangeManager transforPrice:_goodsModel.shop_price];
}

- (UIImageView *)productImage
{
    if (!_productImage) {
        _productImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img;
        });
    }
    return _productImage;
}

-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _priceLabel;
}

@end

@interface ZFRecentlyTableViewCell ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *clearButton;

@end

@implementation ZFRecentlyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.collectionView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.clearButton];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.leading.mas_equalTo(self.mas_leading).offset(16);
            make.height.mas_offset(44);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self).mas_offset(-16);
        }];
        
        [self.clearButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self).mas_offset(-12);
            make.centerY.mas_equalTo(self.titleLabel);
        }];
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFRecentlyProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFRecentlyProductCell" forIndexPath:indexPath];
    cell.goodsModel = self.dataList[indexPath.row].goodsModel;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didClickProductHandler) {
        ZFCMSItemModel *itemModel = self.dataList[indexPath.row];
        self.didClickProductHandler(itemModel);
    }
}

- (void)clearButtonClick
{
    if (self.clearButtonHandler) {
        self.clearButtonHandler();
    }
}

#pragma mark - Property Method

-(void)setDataList:(NSArray<ZFCMSItemModel *> *)dataList
{
    if (dataList == _dataList) {
        return;
    }
    _dataList = dataList;
    
    [self.collectionView reloadData];
}

-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.minimumLineSpacing = 8;
            layout.minimumInteritemSpacing = 8;
            layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 12);
            layout.estimatedItemSize = CGSizeMake(50, 100);
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.backgroundColor = [UIColor whiteColor];
            collectionView.delegate = self;
            collectionView.dataSource = self;
            collectionView.showsHorizontalScrollIndicator = NO;
            collectionView.showsVerticalScrollIndicator = NO;
            [collectionView registerClass:[ZFRecentlyProductCell class] forCellWithReuseIdentifier:@"ZFRecentlyProductCell"];
            collectionView;
        });
    }
    return _collectionView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"History_View_Title", nil);
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:16];
            label;
        });
    }
    return _titleLabel;
}

- (UIButton *)clearButton {
    if (!_clearButton) {
        _clearButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.borderColor = ZFC0xCCCCCC().CGColor;
            button.layer.borderWidth = 1;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"Home_Channel_Recently_Clear", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clearButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _clearButton;
}

@end
