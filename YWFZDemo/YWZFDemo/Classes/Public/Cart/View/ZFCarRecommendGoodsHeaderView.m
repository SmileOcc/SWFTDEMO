//
//  ZFCarRecommendGoodsHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCarRecommendGoodsHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailSameModel.h"
#import "ZFCarRecommendGoodsCell.h"
#import "ZFGoodsModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFCartRecommendAnalyticsAOP.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZF3DTouchHeader.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"

// 推荐商品Cell的宽度
#define kCarRecommendCellWidth    (130 * 1)
// 推荐商品Cell的高度
#define kCarRecommendCellHeight   ((173 + 28) * 1)

static NSString *const kZFCarRecommendViewCellIdentifier = @"kZFCarRecommendViewCellIdentifier";

@interface ZFCarRecommendGoodsHeaderView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<ZFGoodsModel *>           *dataArray;
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UILabel                           *itemLabel;
@property (nonatomic, strong) UICollectionViewFlowLayout        *flowLayout;
@property (nonatomic, strong) UICollectionView                  *collectionView;
@property (nonatomic, weak) UIViewController                    *currentViewController;
@property (nonatomic, strong) UIView                            *whiteContentView;
@property (nonatomic, strong) ZFCartRecommendAnalyticsAOP       *analyticsAOP;
@end

@implementation ZFCarRecommendGoodsHeaderView

#pragma mark - init methods

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        [self zfInitView];
        [self zfAutoLayoutView];
        [self currentViewController];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    [self addTopLeftRightCorners];
//}
//
//- (void)addTopLeftRightCorners {
//    [self.whiteContentView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
//}

//获取当前控制器
- (UIViewController *)currentViewController {
    if (!_currentViewController) {
        _currentViewController = [UIViewController currentTopViewController];
    }
    return _currentViewController;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCarRecommendGoodsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCarRecommendViewCellIdentifier forIndexPath:indexPath];
    ZFGoodsModel *goodsModel = self.dataArray[indexPath.row];
    cell.goodsModel = goodsModel;
    //关联3DTouch数据
    [self.currentViewController register3DTouchAlertWithDelegate:collectionView sourceView:cell goodsModel:goodsModel];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kCarRecommendCellWidth, kCarRecommendCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsModel *model = self.dataArray[indexPath.row];
    if (self.selectGoodsBlock) {
        
        NSNumber *from3DTouchFlag = objc_getAssociatedObject(indexPath, k3DTouchRelationCellComeFrom);
        //标记是从3DTouch进来不传动画视图进入商详
        UIImageView *sourceView = nil;
        if (![from3DTouchFlag boolValue]) {
            ZFCarRecommendGoodsCell *cell = (ZFCarRecommendGoodsCell *)[collectionView cellForItemAtIndexPath:indexPath];
            sourceView = cell.iconImageView;
        }
        self.selectGoodsBlock(model.goods_id, sourceView);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.clipsToBounds = NO;
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.whiteContentView];
    [self.whiteContentView addSubview:self.titleLabel];
    [self.whiteContentView addSubview:self.itemLabel];
    [self.whiteContentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.whiteContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView).offset(12);
        make.trailing.mas_equalTo(self.contentView).offset(-12);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.whiteContentView.mas_top).offset(14);
        make.leading.mas_equalTo(self.whiteContentView.mas_leading).offset(0);
    }];
    
    [self.itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.whiteContentView.mas_trailing).offset(0);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(14);
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.trailing.mas_equalTo(self.itemLabel.mas_trailing);
        make.bottom.mas_equalTo(self.whiteContentView).offset(0);
    }];
}

#pragma mark - setter
/// 警告: 一定要传afParams对象来供AOP实现大数据统计
- (void)setDataArray:(NSArray<ZFGoodsModel *> *)dataArray afParams:(AFparams *)afParams {
    _dataArray = dataArray;
    NSString *count = [NSString stringWithFormat:@"%ld",dataArray.count];
    self.itemLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil),count];
    self.analyticsAOP.sourceType = afParams.sourceType;
    [self.collectionView reloadData];
}

- (void)setIsEmptyCart:(BOOL)isEmptyCart {
    _isEmptyCart = isEmptyCart;
    self.analyticsAOP.aopTpye = !isEmptyCart ? RecommendPageCart : RecommendPageNullCart;
    
    CGFloat offsetX = isEmptyCart ? 12 : 0;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.whiteContentView.mas_leading).offset(offsetX);
    }];
    
    [self.itemLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.whiteContentView.mas_trailing).offset(-offsetX);
    }];
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.whiteContentView).offset(-offsetX);
    }];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ColorHex_Alpha(0x2d2d2d, 1);
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.text = ZFLocalizedString(@"you_may_also_like",nil);
    }
    return _titleLabel;
}

- (UILabel *)itemLabel {
    if (!_itemLabel) {
        _itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _itemLabel.textAlignment = NSTextAlignmentCenter;
        _itemLabel.font = [UIFont systemFontOfSize:12];
        _itemLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _itemLabel.text = @"";
    }
    return _itemLabel;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 12;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = YES;
        _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, -5, 0);
        if ([SystemConfigUtils isRightToLeftShow]) {
            _collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
        [_collectionView registerClass:[ZFCarRecommendGoodsCell class] forCellWithReuseIdentifier:kZFCarRecommendViewCellIdentifier];
    }
    return _collectionView;
}

- (UIView *)whiteContentView {
    if (!_whiteContentView) {
        _whiteContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _whiteContentView.backgroundColor = ZFCOLOR_WHITE;
        _whiteContentView.layer.cornerRadius = 8;
        _whiteContentView.layer.masksToBounds = YES;
    }
    return _whiteContentView;
}

-(ZFCartRecommendAnalyticsAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCartRecommendAnalyticsAOP alloc] init];
    }
    return _analyticsAOP;
}

@end
