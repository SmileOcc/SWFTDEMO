//
//  ZFGoodsDetailCollocationBuyCell.m
//  ZZZZZ
//
//  Created by YW on 2019/8/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCollocationBuyCell.h"
#import "GoodsDetailModel.h"
#import "ZFCollocationBuyModel.h"
#import "ZFGoodsDetailCollocationBuyItemCell.h"
#import "ZFLocalizationString.h"
#import "ZFGoodsDetailCollocationBuyAop.h"

#import "UIView+ZFViewCategorySet.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsDetailEnumDefiner.h"
#import "ExchangeManager.h"
#import "SystemConfigUtils.h"

static NSString *const kZFZFGoodsDetailCollocationBuyCellIdentifier = @"kZFZFGoodsDetailCollocationBuyCellIdentifier";

@interface ZFGoodsDetailCollocationBuyCell() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView                            *topLineView;
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UICollectionView                  *collectionView;
@property (nonatomic, strong) UIButton                          *buyButton;
@property (nonatomic, strong) UILabel                           *shopPriceLabel;
@property (nonatomic, strong) UILabel                           *markPriceLabel;
@property (nonatomic, strong) NSArray<ZFCollocationGoodsModel *>  *collocationGoodsArray;
@property (nonatomic, strong) ZFGoodsDetailCollocationBuyAop    *analyticsAop;
@end

@implementation ZFGoodsDetailCollocationBuyCell

@synthesize cellTypeModel = _cellTypeModel;

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAop];
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - setter

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    NSArray *array = cellTypeModel.detailModel.collocationBuyModel.collocationGoodsArr;
    if ([self.collocationGoodsArray isEqual:array.firstObject]) {
        return;
    } else {
        [self resetCollocationBuyList];
    }
}

// 此方法不能删除,供统计交换方法使用
- (void)resetCollocationBuyList {
    self.shopPriceLabel.text = [ExchangeManager transAppendPrice:self.cellTypeModel.detailModel.collocationBuyModel.shopPrice currency:nil];
    
    NSString *marketPrice = [ExchangeManager transAppendPrice:self.cellTypeModel.detailModel.collocationBuyModel.marketPrice currency:nil];
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:marketPrice attributes:attribtDic];
    self.markPriceLabel.attributedText = attribtStr;
    
    NSArray *array = self.cellTypeModel.detailModel.collocationBuyModel.collocationGoodsArr;
    self.collocationGoodsArray = array.firstObject;
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.collocationGoodsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsDetailCollocationBuyItemCell *showsCell = [ZFGoodsDetailCollocationBuyItemCell ShowListCellWith:collectionView forIndexPath:indexPath];
    
    ZFCollocationGoodsModel *goodsModel = self.collocationGoodsArray[indexPath.row];
    if ([goodsModel isKindOfClass:[ZFCollocationGoodsModel class]]) {
        showsCell.model = goodsModel;
    }
    return showsCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger customIndex = [SystemConfigUtils isRightToLeftShow] ? 0 : (self.collocationGoodsArray.count - 1);
    CGFloat width = (indexPath.row == customIndex) ? 100 : 140;
    return CGSizeMake(width, 120);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self buyButtonAction:nil];
}

#pragma mark - buyButton action

- (void)buyButtonAction:(UIButton *)button {
    if (self.cellTypeModel.detailCellActionBlock) {
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, self.cellTypeModel.detailModel.collocationBuyModel, nil);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.topLineView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.buyButton];
    [self.contentView addSubview:self.shopPriceLabel];
    [self.contentView addSubview:self.markPriceLabel];
}

- (void)zfAutoLayoutView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(8);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLineView.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(44);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(120);
    }];
    
    [self.buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.height.mas_equalTo(32);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.buyButton.mas_top);
        make.leading.mas_equalTo(self.buyButton.mas_trailing).offset(8);
    }];
    
    [self.markPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.buyButton.mas_bottom);
        make.leading.mas_equalTo(self.buyButton.mas_trailing).offset(8);
    }];
}

#pragma mark - getter

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _topLineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.text = ZFLocalizedString(@"Cart_MatchItems", nil);
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *_flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 8;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
    }
    return _collectionView;
}

- (UIButton *)buyButton {
    if (!_buyButton) {
        _buyButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _buyButton.backgroundColor = ZFC0x2D2D2D();
        _buyButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_buyButton setTitleColor:ZFCOLOR_WHITE forState:0];
        [_buyButton setTitle:ZFLocalizedString(@"Cart_BuyTogether", nil) forState:0];
        _buyButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        _buyButton.layer.cornerRadius = 3;
        _buyButton.layer.masksToBounds = YES;
        [_buyButton addTarget:self action:@selector(buyButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _buyButton;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.backgroundColor = [UIColor whiteColor];
        _shopPriceLabel.font = [UIFont boldSystemFontOfSize:14];
        _shopPriceLabel.textColor = ZFC0xFE5269();
    }
    return _shopPriceLabel;
}

- (UILabel *)markPriceLabel {
    if (!_markPriceLabel) {
        _markPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _markPriceLabel.backgroundColor = [UIColor whiteColor];
        _markPriceLabel.font = [UIFont systemFontOfSize:11];
        _markPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _markPriceLabel;
}

- (ZFGoodsDetailCollocationBuyAop *)analyticsAop {
    if (!_analyticsAop) {
        _analyticsAop = [[ZFGoodsDetailCollocationBuyAop alloc] initAopWithSourceType:(ZFAppsflyerInSourceTypeDefault)];
    }
    return _analyticsAop;
}

@end

