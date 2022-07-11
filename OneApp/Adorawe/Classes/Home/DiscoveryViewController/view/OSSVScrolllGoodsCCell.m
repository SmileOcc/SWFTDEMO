//
//  OSSVScrolllGoodsCCell.m
// OSSVScrolllGoodsCCell
//
//  Created by odd on 2021/3/23.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVScrolllGoodsCCell.h"
#import "OSSVThemeZeroPrGoodsModel.h"

@interface OSSVScrolllGoodsCCell ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>

@property (nonatomic, strong) UICollectionView                        *collectionView;

@property (nonatomic, strong) OSSVScrollGoodsItesCCellModel          *cellModel;

@property (nonatomic, assign) CGSize                                  itemSize;
@property (nonatomic, assign) CGSize                                  subItemSize;

@end

@implementation OSSVScrolllGoodsCCell

@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

// (SCREEN_WIDTH - 12 - 3*8) * 4 / 15.0
//默认显示3个+3/4
+ (CGSize)itemSize:(CGFloat)imageScale{
    
    CGSize size = [OSSVScrolllGoodsCCell subItemSize:imageScale];
    
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return CGSizeZero;
    }

    
    //子视图 + 12底部间隙
    return CGSizeMake(SCREEN_WIDTH, size.height + 12);
}

+ (CGSize)subItemSize:(CGFloat)imageScale {
    if (imageScale <= 0) {
        return CGSizeZero;
    }
    CGFloat itemW = (SCREEN_WIDTH - 12 - 3*8) * 4 / 15.0;
    CGFloat itemH = itemW / imageScale;
    
    //图片高 + 内容高
    return CGSizeMake(itemW, itemH + 34);
}

- (NSIndexPath *)indexPathForCell:(STLScrollerGoodsItemCell *)cell {
    NSIndexPath *indexPath;
    if (cell && self.collectionView) {
        indexPath = [self.collectionView indexPathForCell:cell];
    }
    return indexPath;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.itemSize = CGSizeZero;
        self.subItemSize = CGSizeZero;
        
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
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
    if (self.dataSourceModels) {//首页滑动商品
        
        if (self.dataSourceModels.slide_data.count >= 10) {
            return 10;
        }
        return self.dataSourceModels.slide_data.count;
    }
    
    if (self.dataSourceThemeModels) {//原生专题滑动商品
        if (self.dataSourceThemeModels.slideList.count >= 10) {
            return 10;
        }
        return self.dataSourceThemeModels.slideList.count;
    }
    return 0;
}
//首页和专题页滑动商品cell
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STLScrollerGoodsItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(STLScrollerGoodsItemCell.class) forIndexPath:indexPath];
    //首页滑动商品
    if (self.dataSourceModels) {
        if (self.dataSourceModels.slide_data.count > indexPath.row && indexPath.row == 9) {
            STLDiscoveryBlockSlideGoodsModel *model = self.dataSourceModels.slide_data[indexPath.row];

            //配置原生专题，切大于等于10个数据
//            if (!STLIsEmptyString(model.special_id) && [model.special_id integerValue] > 0) {
//                [cell updateModel:model isMore:YES];
//            } else {
//                [cell updateModel:model isMore:NO];
//            }
            [cell updateModel:model isMore:YES];

        } else if (self.dataSourceModels.slide_data.count > indexPath.row) {
            STLDiscoveryBlockSlideGoodsModel *model = self.dataSourceModels.slide_data[indexPath.row];
            [cell updateModel:model isMore:NO];
        }
    }
    //专题页滑动商品
    if (self.dataSourceThemeModels) {
        if (self.dataSourceThemeModels.slideList.count > indexPath.row && indexPath.row == 9) {
            OSSVHomeGoodsListModel *model = self.dataSourceThemeModels.slideList[indexPath.row];
//            if (!STLIsEmptyString(model.specialId) && [model.specialId integerValue] > 0) {
//                [cell updateModel:model isMore:YES];
//            } else {
//                [cell updateModel:model isMore:NO];
//            }
            [cell updateModel:model isMore:YES];

        } else if (self.dataSourceThemeModels.slideList.count > indexPath.row) {
            OSSVHomeGoodsListModel *model = self.dataSourceThemeModels.slideList[indexPath.row];
            [cell updateModel:model isMore:NO];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STLScrollerGoodsItemCell *cell = (STLScrollerGoodsItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_scrollerGoodsCCell:selectItemCell:isMore:)]) {
        BOOL isMore = NO;
        if (indexPath.row + 1 == 10) {
            isMore = YES;
        }
        [self.delegate stl_scrollerGoodsCCell:self selectItemCell:cell isMore:isMore];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.subItemSize;
}


#pragma mark - setter and getter

-(void)setModel:(id<CollectionCellModelProtocol>)model
{
    _model = model;
    
    self.itemSize = CGSizeZero;
    self.subItemSize = CGSizeZero;
    
    //专题，还是透明的
    if (model && [model isKindOfClass:[OSSVScrollGoodsItesCCellModel class]]) {
        OSSVScrollGoodsItesCCellModel *blockModel = (OSSVScrollGoodsItesCCellModel *)model;
        self.itemSize = blockModel.size;
        self.subItemSize = blockModel.subItemSize;

    }
    if ([_model.dataSource isKindOfClass:[OSSVDiscoverBlocksModel class]]) {
        self.cellModel = model;
        self.dataSourceModels = (OSSVDiscoverBlocksModel *)model.dataSource;
        [self.collectionView reloadData];
        
    } else if(_model.dataSource && [_model.dataSource isKindOfClass:[OSSVHomeCThemeModel class]]) {
        self.backgroundColor = UIColor.clearColor;
        self.dataSourceThemeModels = (OSSVHomeCThemeModel *)_model.dataSource;
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
            layout.sectionInset = UIEdgeInsetsMake(0, 12, padding, 12);

            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.showsHorizontalScrollIndicator = NO;
            
            [collectionView registerClass:[STLScrollerGoodsItemCell class] forCellWithReuseIdentifier:NSStringFromClass(STLScrollerGoodsItemCell.class)];
            
            collectionView;
        });
    }
    return _collectionView;
}

@end






@interface STLScrollerGoodsItemCell ()

@property (nonatomic, strong) UIView              *bgView;
@property (nonatomic, strong) UIView              *bottomView;
@property (nonatomic, strong) YYAnimatedImageView *productImageView;
@property (nonatomic, strong) UILabel             *priceLabel;
@property (nonatomic, strong) UILabel             *marketPriceLabel;
@property (nonatomic, strong) UILabel             *moreLabel;
////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;
@end

@implementation STLScrollerGoodsItemCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.productImageView];
        [self.bgView addSubview:self.bottomView];
        [self.productImageView addSubview:self.activityStateView];

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
            make.top.mas_equalTo(self.bgView);
            make.bottom.mas_equalTo(self.bottomView.mas_top);
        }];
        
        
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.productImageView.mas_leading);
            make.top.equalTo(self.productImageView.mas_top);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.bgView);
            make.height.mas_equalTo(@34);
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
        
//        [self setShadowAndCornerCell];


    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
//        
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
//        } else {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//        }
//    }
//}

- (void)updateModel:(id)model isMore:(BOOL)isMore {
    self.isMore = isMore;
    self.model = model;
}

#pragma mark - setter and getter

- (void)setModel:(id)model
{
    _model = model;
    self.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];

    if ([model isKindOfClass:[STLDiscoveryBlockSlideGoodsModel class]]) {
        STLDiscoveryBlockSlideGoodsModel *homeSlideGoodsModel = (STLDiscoveryBlockSlideGoodsModel *)model;
        [self updateHomeModel:homeSlideGoodsModel];
    } else if([model isKindOfClass:[OSSVHomeGoodsListModel class]]) {
        OSSVHomeGoodsListModel *themeSlideGoodsModel = (OSSVHomeGoodsListModel *)model;
        [self updateThemeModel:themeSlideGoodsModel];
    }
    
}

- (void)updateHomeModel:(STLDiscoveryBlockSlideGoodsModel *)model {
    
    self.activityStateView.hidden = YES;
    if (self.isMore) {
        self.activityStateView.hidden = YES;
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
        
        self.priceLabel.text = STLToString(model.shop_price_converted);

//        //加一个删除线
        if (STLIsEmptyString(model.lineMarketPrice)) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(model.market_price_converted)
                                                                                        attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
            model.lineMarketPrice = attrStr;
        }
        self.marketPriceLabel.attributedText = model.lineMarketPrice;
        self.marketPriceLabel.hidden = NO;
        self.priceLabel.hidden = NO;
        self.moreLabel.hidden = YES;
        
        ////折扣标 闪购标
        if ([model.show_discount_icon integerValue] && STLToString(model.discount).intValue > 0) {
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.discount)];
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        if (model.flash_sale && [model.flash_sale isOnlyFlashActivity]) {
            self.activityStateView.hidden = NO;
            self.priceLabel.text = STLToString(model.flash_sale.active_price_converted);
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
        }

        [self setNeedsDisplay];
    }
}

- (void)updateThemeModel:(OSSVHomeGoodsListModel *)model {
    
    self.activityStateView.hidden = YES;
    if (self.isMore) {
        self.activityStateView.hidden = YES;
        [self.productImageView yy_setImageWithURL:[NSURL URLWithString:model.goodsImageUrl]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        self.moreLabel.hidden = NO;
        self.marketPriceLabel.hidden = YES;
        self.priceLabel.hidden = YES;
    } else {
        
        [self.productImageView yy_setImageWithURL:[NSURL URLWithString:model.goodsImageUrl]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        
        self.priceLabel.text = STLToString(model.shop_price_converted);

//        //加一个删除线
        if (STLIsEmptyString(model.lineMarketPrice)) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(model.market_price_converted)
                                                                                        attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
            model.lineMarketPrice = attrStr;
        }
        self.marketPriceLabel.attributedText = model.lineMarketPrice;
        self.marketPriceLabel.hidden = NO;
        self.priceLabel.hidden = NO;
        self.moreLabel.hidden = YES;
        
        ////折扣标 闪购标
        if ([model.show_discount_icon integerValue] && STLToString(model.discount).intValue > 0) {
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.discount)];
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        if (model.flash_sale && [model.flash_sale isOnlyFlashActivity]) {
            self.activityStateView.hidden = NO;
            self.priceLabel.text = STLToString(model.flash_sale.active_price_converted);
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
        }

        [self setNeedsDisplay];
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
            imageView.layer.borderWidth = 0.5;
            imageView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
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
            label.textColor = [OSSVThemesColors col_0D0D0D];
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
            label.font = [UIFont boldSystemFontOfSize:9];
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

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
        _activityStateView.hidden = YES;
        _activityStateView.backgroundColor = [UIColor clearColor];
    }
    return _activityStateView;
}

@end

