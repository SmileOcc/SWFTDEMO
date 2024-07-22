//
//  ZFAccountRecentlyCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountRecentlyCCell.h"
#import "ZFFrameDefiner.h"
#import "ZFCMSSectionModel.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "ZFLocalizationString.h"
#import "ZFAccountCategorySectionModel.h"

#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>

#define rowsIndex 3

@interface ZFRecentlyProductCCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *productImage;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) ZFGoodsModel *goodsModel;

@end

@implementation ZFRecentlyProductCCell

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
            make.height.mas_equalTo(self.mas_width).multipliedBy(1.33);
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

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.goodsModel = nil;
    self.productImage.image = nil;
    self.priceLabel.text = nil;
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
            label.font = [UIFont boldSystemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _priceLabel;
}

@end

@interface ZFAccountRecentlyCCell ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) NSArray <ZFCMSItemModel *> *dataList;
@end

@implementation ZFAccountRecentlyCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
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

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dataList = nil;
}

+ (CGSize)itemSize:(NSInteger)sectionRows protocol:(id<ZFCollectionCellDatasourceProtocol>)protocol
{
    if ([protocol isKindOfClass:[ZFAccountRecentlyViewModel class]]) {
        ZFAccountRecentlyViewModel *viewModel = protocol;
        CGFloat screenWidth = ([[UIScreen mainScreen] bounds].size.width);
        if ([viewModel.dataList count]) {
            return CGSizeMake(screenWidth, 214 * ScreenWidth_SCALE);
        } else {
            return CGSizeMake(screenWidth, 0);
        }
    }
    return CGSizeZero;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFRecentlyProductCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFRecentlyProductCCell" forIndexPath:indexPath];
    cell.goodsModel = self.dataList[indexPath.row].goodsModel;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFAccountRecentlyCellDidClickProductItem:)]) {
        ZFCMSItemModel *itemModel = self.dataList[indexPath.row];
        [self.delegate ZFAccountRecentlyCellDidClickProductItem:itemModel];
    }
}

- (void)clearButtonClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFAccountRecentlyCellDidClickClearButton)]) {
        [self.delegate ZFAccountRecentlyCellDidClickClearButton];
    }
}

#pragma mark - Property Method

-(void)setModel:(id<ZFCollectionCellDatasourceProtocol>)model
{
    _model = model;
    if ([model isKindOfClass:[ZFAccountRecentlyViewModel class]]) {
        ZFAccountRecentlyViewModel *vm = (ZFAccountRecentlyViewModel *)model;
        if ([vm.dataList count]) {
            self.clearButton.hidden = NO;
            self.titleLabel.hidden = NO;
            if (self.dataList == vm.dataList) {
                return;
            }
            self.dataList = vm.dataList;
            [self.collectionView reloadData];
        } else {
            self.clearButton.hidden = YES;
            self.titleLabel.hidden = YES;
        }
    }
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
            [collectionView registerClass:[ZFRecentlyProductCCell class] forCellWithReuseIdentifier:@"ZFRecentlyProductCCell"];
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
