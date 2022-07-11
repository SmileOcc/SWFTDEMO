//
//  OSSVThemeZeorsActivyCCell.m
// OSSVThemeZeorsActivyCCell
//
//  Created by odd on 2020/9/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVThemeZeorsActivyCCell.h"
#import "UIColor+Extend.h"
#import "UIButton+STLCategory.h"

@interface OSSVThemeZeorsActivyCCell ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property (nonatomic, strong) UICollectionView                        *collectionView;
@property (nonatomic, strong) NSArray <OSSVThemeZeroPrGoodsModel*>     *dataSourceModels;

@end

@implementation OSSVThemeZeorsActivyCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

+ (CGSize)itemSize:(NSInteger)count {
    CGFloat h = [STLThemeZeorGoodsItemCell itemSize].height + 24;
    if (count == 0) {
        h = 0;
    }
    return CGSizeMake(SCREEN_WIDTH, floor(h));
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
    }
    return self;
}

#pragma mark - datasource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataSourceModels.count >= 6) {
        return 6;
    }
    return self.dataSourceModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STLThemeZeorGoodsItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(STLThemeZeorGoodsItemCell.class) forIndexPath:indexPath];
    
    if (self.dataSourceModels.count > 3 && (self.dataSourceModels.count == indexPath.row + 1 || indexPath.row == 5)) {
        OSSVThemeZeroPrGoodsModel *model = self.dataSourceModels[indexPath.row];
        [cell updateModel:model isMore:YES];
        
    } else if (self.dataSourceModels.count > indexPath.row) {
        OSSVThemeZeroPrGoodsModel *model = self.dataSourceModels[indexPath.row];
        [cell updateModel:model isMore:NO];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STLThemeZeorGoodsItemCell *cell = (STLThemeZeorGoodsItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeZeorActivityCCell:selectItemCell:isMore:)]) {
        BOOL isMore = NO;
        if (self.dataSourceModels.count > 3 && (self.dataSourceModels.count == indexPath.row + 1 || indexPath.row == 5)) {
            isMore = YES;
        }
        [self.delegate stl_themeZeorActivityCCell:self selectItemCell:cell isMore:isMore];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [STLThemeZeorGoodsItemCell itemSize];
}


#pragma mark - setter and getter

-(void)setModel:(id<CollectionCellModelProtocol>)model
{
    _model = model;
//    if (!STLIsEmptyString(_model.bg_color)) {
//        self.backgroundColor = [UIColor colorWithHexColorString:_model.bg_color];
//    } else {
//        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
//    }
    if ([_model.dataSource isKindOfClass:[NSArray class]]) {
        self.dataSourceModels = (NSArray<OSSVThemeZeroPrGoodsModel *> *)model.dataSource;
        [self.collectionView reloadData];
    }
}


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = ({
            CGFloat padding = 12;
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.minimumLineSpacing = 8;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.sectionInset = UIEdgeInsetsMake(padding, padding, padding, padding);

            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.showsHorizontalScrollIndicator = NO;
            
            [collectionView registerClass:[STLThemeZeorGoodsItemCell class] forCellWithReuseIdentifier:NSStringFromClass(STLThemeZeorGoodsItemCell.class)];
            
            collectionView;
        });
    }
    return _collectionView;
}

@end






@interface STLThemeZeorGoodsItemCell ()

@property (nonatomic, strong) UIView              *bgView;
@property (nonatomic, strong) UIView              *bottomView;
@property (nonatomic, strong) YYAnimatedImageView *productImageView;
@property (nonatomic, strong) UILabel             *priceLabel;
@property (nonatomic, strong) UILabel             *marketPriceLabel;
@property (nonatomic, strong) UILabel             *moreLabel;

@end

@implementation STLThemeZeorGoodsItemCell


+ (CGSize)itemSize {
    CGFloat w = kThemeZeorGoodsItemWidth;
    CGFloat h = kThemeZeorGoodsItemHeight;
    return CGSizeMake(w, h);
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.productImageView];
        [self.bgView addSubview:self.bottomView];
        
        [self.bottomView addSubview:self.priceLabel];
        [self.bottomView addSubview:self.marketPriceLabel];
        [self.bottomView addSubview:self.moreLabel];
        

        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
        [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.bgView);
            make.height.mas_equalTo(self.productImageView.mas_width).multipliedBy(kThemeZeorGoodsImageHeightScale);
            make.top.mas_equalTo(self.bgView);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.bgView);
            make.top.mas_equalTo(self.productImageView.mas_bottom);
            make.bottom.mas_equalTo(self.bgView.mas_bottom);
        }];
        
        
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bottomView.mas_centerY).offset(2);
            make.trailing.mas_equalTo(self.bottomView);
            make.leading.mas_equalTo(self.bottomView.mas_leading).offset(4);
        }];
        
        [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomView.mas_centerY).offset(1);
            make.trailing.mas_equalTo(self.bottomView);
            make.leading.mas_equalTo(self.bottomView.mas_leading).offset(4);
        }];
        
        [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.bottomView.mas_centerY);
            make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        }];
        


    }
    return self;
}

- (void)updateModel:(OSSVThemeZeroPrGoodsModel *)model isMore:(BOOL)isMore {
    self.isMore = isMore;
    self.model = model;
}

#pragma mark - setter and getter

-(void)setModel:(OSSVThemeZeroPrGoodsModel *)model
{
    _model = model;

    if (self.isMore) {
        [self.productImageView yy_setImageWithURL:[NSURL URLWithString:model.goods_img]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        self.moreLabel.hidden = NO;
        self.marketPriceLabel.hidden = YES;
        self.priceLabel.hidden = YES;
    } else {
        
        [self.productImageView yy_setImageWithURL:[NSURL URLWithString:model.goods_img]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        
//        self.priceLabel.text = [ExchangeManager transforPrice:model.exchange_price];
        self.priceLabel.text = STLToString(model.exchange_price_converted);

//        //加一个删除线
//        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[ExchangeManager transforPrice:model.shop_price]
//                                                                                    attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
//        self.marketPriceLabel.attributedText = attrStr;
        if (STLIsEmptyString(model.lineMarketPrice.string)) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(model.shop_price_converted)
                                                                                        attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
            model.lineMarketPrice = attrStr;
        }
        self.marketPriceLabel.attributedText = model.lineMarketPrice;
        self.marketPriceLabel.hidden = NO;
        self.priceLabel.hidden = NO;
        self.moreLabel.hidden = YES;
    }
}

- (void)actionCart:(UIButton *)sender {
    if (self.cartBlock) {
        self.cartBlock();
    }
}
#pragma mark - LazyLoad

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _bgView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _bottomView;
}

-(YYAnimatedImageView *)productImageView
{
    if (!_productImageView) {
        _productImageView = ({
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView;
        });
    }
    return _productImageView;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = OSSVThemesColors.col_B62B21;
            label.font = [UIFont boldSystemFontOfSize:11];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentRight;
            } else {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _priceLabel;
}

-(UILabel *)marketPriceLabel
{
    if (!_marketPriceLabel) {
        _marketPriceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = OSSVThemesColors.col_999999;
            label.font = [UIFont systemFontOfSize:9];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentRight;
            } else {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _marketPriceLabel;
}


-(UILabel *)moreLabel
{
    if (!_moreLabel) {
        _moreLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [OSSVThemesColors stlWhiteColor];
            label.textColor = [OSSVThemesColors col_666666];
            label.font = [UIFont systemFontOfSize:11];
            label.textAlignment = NSTextAlignmentCenter;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.text = [NSString stringWithFormat:@"%@>",STLLocalizedString_(@"zero_View_All", nil)];
            } else {
                label.text = [NSString stringWithFormat:@"%@>",STLLocalizedString_(@"zero_View_All", nil)];
            }

            label;
        });
    }
    return _moreLabel;
}
@end
