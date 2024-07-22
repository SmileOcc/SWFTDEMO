//
//  ZFCarRecommendView.m
//  ZZZZZ
//
//  Created by YW on 2018/12/4.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCarRecommendView.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailSameModel.h"
#import "ZFCarRecommendGoodsCell.h"
#import "ZFGoodsModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
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

@interface ZFCarRecommendView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<ZFGoodsModel *>           *dataArray;
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UILabel                           *itemLabel;
@property (nonatomic, strong) UIView                            *bottomLine;
@property (nonatomic, strong) UICollectionViewFlowLayout        *flowLayout;
@property (nonatomic, strong) UICollectionView                  *collectionView;
@property (nonatomic, weak) UIViewController                    *currentViewController;
@property (nonatomic, strong) ZFCartRecommendAnalyticsAOP       *analyticsAOP;
@end

@implementation ZFCarRecommendView
#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        [self zfInitView];
        [self zfAutoLayoutView];
        //获取当前控制器
        [self currentViewController];
    }
    return self;
}

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
    if (self.carRecommendSelectGoodsBlock) {
        
        NSNumber *from3DTouchFlag = objc_getAssociatedObject(indexPath, k3DTouchRelationCellComeFrom);
        //标记是从3DTouch进来不传动画视图进入商详
        UIImageView *sourceView = nil;
        if (![from3DTouchFlag boolValue]) {
            ZFCarRecommendGoodsCell *cell = (ZFCarRecommendGoodsCell *)[collectionView cellForItemAtIndexPath:indexPath];
            sourceView = cell.iconImageView;
        }
        self.carRecommendSelectGoodsBlock(model.goods_id, sourceView);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.itemLabel];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.bottomLine];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(23);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
    }];
    
    [self.itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(14);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView).offset(-14);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(14);
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

- (void)setIsPaysuccessView:(BOOL)isPaysuccessView {
    _isPaysuccessView = isPaysuccessView;
    self.analyticsAOP.aopTpye = isPaysuccessView ? RecommendPagePaysuccessView : RecommendPageCart;
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFCOLOR(0, 0, 0, 1);
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
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 12, 0, 12);
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
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.alwaysBounceHorizontal = YES;
        [_collectionView registerClass:[ZFCarRecommendGoodsCell class] forCellWithReuseIdentifier:kZFCarRecommendViewCellIdentifier];
        if ([SystemConfigUtils isRightToLeftShow]) {
            _collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }
    return _collectionView;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    }
    return _bottomLine;
}

-(ZFCartRecommendAnalyticsAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCartRecommendAnalyticsAOP alloc] init];
        _analyticsAOP.aopTpye = _isPaysuccessView ? RecommendPagePaysuccessView : RecommendPageCart;
    }
    return _analyticsAOP;
}

@end
