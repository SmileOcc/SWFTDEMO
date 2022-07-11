//
//  OSSVZeroActivyDoulesLineCCell.m
// OSSVZeroActivyDoulesLineCCell
//
//  Created by Starlinke on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVZeroActivyDoulesLineCCell.h"
#import "UIButton+STLCategory.h"
#import "OSSVHomeCThemeModel.h"
#import "OSSVThemeZeroActivyTwoCCellModel.h"


#define KITEM_NUMBER_LIMITE 50
@interface OSSVZeroActivyDoulesLineCCell ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>


@property (nonatomic, strong) NSArray <OSSVThemeZeroPrGoodsModel*>     *dataSourceModels;
@property (nonatomic, assign) NSInteger                               cart_exit;

@end


@implementation OSSVZeroActivyDoulesLineCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

+ (CGSize)itemSize:(NSInteger)count {
    CGFloat h = [STLThemeZeorDoubleGoodsItemCell itemSize].height * 2 + 13;
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
    if (self.dataSourceModels.count >= KITEM_NUMBER_LIMITE) {
        return KITEM_NUMBER_LIMITE;
    }
    return self.dataSourceModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STLThemeZeorDoubleGoodsItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(STLThemeZeorDoubleGoodsItemCell.class) forIndexPath:indexPath];
    
    OSSVThemeZeroPrGoodsModel *model = self.dataSourceModels[indexPath.row];
    model.cart_exists = self.cart_exit;
    if (self.dataSourceModels.count > 3 && (self.dataSourceModels.count == indexPath.row + 1 || indexPath.row == 5)) {
        [cell updateModel:model isMore:YES];
    } else if (self.dataSourceModels.count > indexPath.row) {
        [cell updateModel:model isMore:NO];
    }
    if (self.dataSourceModels.count > KITEM_NUMBER_LIMITE && indexPath.item == KITEM_NUMBER_LIMITE - 1) {
        [cell updateLastCellWithHidden:NO];
    }else{
        [cell updateLastCellWithHidden:YES];
    }
    
    __weak typeof (cell) weakCell  = cell;
    cell.cartBlock = ^{
        if (model.sold_out == 1) {
            return;
        }
//        if (model.cart_exists) {
//            NSString *msg = @"Free item is available in your shopping cart, want to switch ?";
//            [STLALertTitleMessageView alertWithAlerTitle:@"" alerMessage:STLToString(msg) otherBtnTitles:@[STLLocalizedString_(@"no",nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString] otherBtnAttributes:nil alertCallBlock:^(NSInteger buttonIndex, NSString *title) {
//                if (buttonIndex == 1) {
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeZeorActivityDoubleCCell:selectItemCell:addCart:)]) {
//                        [self.delegate stl_themeZeorActivityDoubleCCell:self selectItemCell:weakCell addCart:model];
//                    }
//                }
//            }];
//            return;
//        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeZeorActivityDoubleCCell:selectItemCell:addCart:)]) {
                [self.delegate stl_themeZeorActivityDoubleCCell:self selectItemCell:weakCell addCart:model];
            }
//        }
        
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OSSVThemeZeroPrGoodsModel *model = self.dataSourceModels[indexPath.row];
    if (model.sold_out == 1) {
        return;
    }
    
    STLThemeZeorDoubleGoodsItemCell *cell = (STLThemeZeorDoubleGoodsItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_themeZeorActivityDoubleCCell:selectItemCell:isMore:)]) {
        BOOL isMore = NO;
        if (self.dataSourceModels.count > KITEM_NUMBER_LIMITE && (self.dataSourceModels.count == indexPath.item + 1 || indexPath.item == KITEM_NUMBER_LIMITE - 1)) {
            isMore = YES;
        }
        [self.delegate stl_themeZeorActivityDoubleCCell:self selectItemCell:cell isMore:isMore];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [STLThemeZeorDoubleGoodsItemCell itemSize];
}


#pragma mark - setter and getter

-(void)setModel:(id<CollectionCellModelProtocol>)model
{
    _model = model;
    if ([_model.dataSource isKindOfClass:[NSArray class]]) {
        
        if ([model isKindOfClass:[OSSVThemeZeroActivyTwoCCellModel class]]) {
            OSSVThemeZeroActivyTwoCCellModel *themeModel = (OSSVThemeZeroActivyTwoCCellModel *)model;
            self.cart_exit = themeModel.cart_exits;
            
            for (OSSVThemeZeroPrGoodsModel *pModel in (NSArray<OSSVThemeZeroPrGoodsModel *> *)model.dataSource) {
                pModel.type = themeModel.type;
            }
        }
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
            layout.minimumInteritemSpacing = 12;
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.sectionInset = UIEdgeInsetsMake(0, padding, 0, padding);

            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            collectionView.showsVerticalScrollIndicator = NO;
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.backgroundColor = [UIColor clearColor];
            collectionView.showsHorizontalScrollIndicator = NO;
            
            [collectionView registerClass:[STLThemeZeorDoubleGoodsItemCell class] forCellWithReuseIdentifier:NSStringFromClass(STLThemeZeorDoubleGoodsItemCell.class)];
            
            collectionView;
        });
    }
    return _collectionView;
}

@end


@interface STLThemeZeorDoubleGoodsItemCell ()

@property (nonatomic, strong) UIView              *bgView;
@property (nonatomic, strong) UIView              *bottomView;
@property (nonatomic, strong) YYAnimatedImageView *productImageView;
@property (nonatomic, strong) UILabel             *priceLabel;
@property (nonatomic, strong) UILabel             *marketPriceLabel;
@property (nonatomic, strong) UILabel             *moreLabel;
@property (nonatomic, strong) UIButton            *freeBtn;

@property (nonatomic, strong) UIView              *soldView;
@property (nonatomic, strong) UIView              *viewAll;

@end

@implementation STLThemeZeorDoubleGoodsItemCell


+ (CGSize)itemSize {
    CGFloat w = kThemeZeorGoodsDoubleLinesItemWidth;
    CGFloat h = kThemeZeorGoodsDoubleLinesItemHeight;
    return CGSizeMake(w, h);
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.bgView];
        [self.bgView addSubview:self.productImageView];
        [self.productImageView addSubview:self.bottomView];
        [self.bgView addSubview:self.freeBtn];
        
        [self.bottomView addSubview:self.priceLabel];
        [self.bottomView addSubview:self.marketPriceLabel];
        [self.bgView addSubview:self.soldView];
        [self.bgView addSubview:self.viewAll];
        

        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.mas_top);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
        [self.freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(4);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-4);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-4);
            make.height.mas_equalTo(20);
        }];
        
        [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.bottomView);
            make.bottom.mas_equalTo(self.freeBtn.mas_top).offset(-4);
            make.top.mas_equalTo(self.bgView.mas_top).offset(2);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(2);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-2);
            make.height.mas_equalTo(20);
            make.bottom.mas_equalTo(self.productImageView.mas_bottom);
        }];
        
        [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bottomView.mas_centerX).offset(-2);
            make.trailing.mas_equalTo(self.bottomView.mas_trailing);
            make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.marketPriceLabel.mas_centerY);
            make.trailing.mas_equalTo(self.marketPriceLabel.mas_leading).offset(-2);
            make.leading.mas_equalTo(self.bottomView.mas_leading);
        }];
        
        [self.soldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self.bgView);
            make.bottom.mas_equalTo(self.bottomView.mas_bottom);
        }];
        
        [self.viewAll mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
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
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:model.goods_img]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                   completion:nil];
    
    self.priceLabel.text = STLToString(model.exchange_price_converted);

    //加一个删除线
    if (STLIsEmptyString(model.lineMarketPrice.string)) {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(model.shop_price_converted)
                                                                                    attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
        model.lineMarketPrice = attrStr;
    }
    self.marketPriceLabel.attributedText = model.lineMarketPrice;
    if (model.sold_out == 1) {
        self.soldView.hidden = NO;
        self.freeBtn.enabled = NO;
    }else{
        self.soldView.hidden = YES;
        self.freeBtn.enabled = YES;
    }
}

- (void)updateLastCellWithHidden:(BOOL)ishidden{
    self.viewAll.hidden = ishidden;
}

- (void)freeBtnDidSelected:(UIButton *)sender{
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
//        _bottomView.backgroundColor = [UIColor redColor];
        _bottomView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
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
            imageView.layer.masksToBounds = YES;
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
            label.font = [UIFont boldSystemFontOfSize:12];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentLeft;
            } else {
                label.textAlignment = NSTextAlignmentRight;
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
            label.textColor = OSSVThemesColors.col_6C6C6C;
            label.font = [UIFont systemFontOfSize:10];
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

- (UIButton *)freeBtn{
    if (!_freeBtn) {
        _freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _freeBtn.titleLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _freeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [_freeBtn setTitle:STLLocalizedString_(@"getFree", nil) forState:UIControlStateNormal];
        [_freeBtn setBackgroundImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_B62B21] forState:UIControlStateNormal];
        [_freeBtn setBackgroundImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_CCCCCC] forState:UIControlStateDisabled];
        [_freeBtn addTarget:self action:@selector(freeBtnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _freeBtn;
}

- (UIView *)soldView{
    if (!_soldView) {
        _soldView = [UIView new];
        _soldView.backgroundColor = [UIColor colorWithRed:0.051 green:0.051 blue:0.051 alpha:0.3];
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"zero_hangers"];
        UILabel *lab = [UILabel new];
        lab.text = STLLocalizedString_(@"soldOut", nil);
        lab.textColor = [UIColor whiteColor];
        lab.font = FontWithSize(12);
        lab.textAlignment = NSTextAlignmentCenter;
        
        [_soldView addSubview:imgV];
        [_soldView addSubview:lab];
        
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_soldView.mas_centerX);
            make.centerY.mas_equalTo(_soldView.mas_centerY).offset(-14);
            make.width.height.mas_equalTo(24);
        }];
        
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(_soldView);
            make.height.mas_equalTo(14);
            make.centerY.mas_equalTo(_soldView.mas_centerY).offset(9);
        }];
        _soldView.hidden = YES;
    }
    return _soldView;
}

- (UIView *)viewAll{
    if (!_viewAll) {
        _viewAll  = [[UIView alloc] init];
        _viewAll.backgroundColor =[UIColor whiteColor];
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.image = [UIImage imageNamed:@"zero_viewAll"];
        UILabel *lab = [UILabel new];
        lab.text = STLLocalizedString_(@"viewAll", nil);
        lab.font = [UIFont boldSystemFontOfSize:10];
        lab.textAlignment = NSTextAlignmentCenter;
        [_viewAll addSubview:imgV];
        [_viewAll addSubview:lab];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_viewAll.mas_centerX);
            make.centerY.mas_equalTo(_viewAll.mas_centerY).offset(-11);
            make.height.width.mas_equalTo(18);
        }];
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_viewAll.mas_centerX);
            make.centerY.mas_equalTo(_viewAll.mas_centerY).offset(8);
            make.leading.trailing.mas_equalTo(_viewAll);
        }];
        _viewAll.userInteractionEnabled = YES;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            imgV.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
    }
    return _viewAll;
}
@end
