//
//  ZFGoodsDetailShowExploreCell.m
//  ZZZZZ
//
//  Created by YW on 2018/6/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailShowExploreCell.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsDetailShowListCell.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "ZFPostDetailSimilarGoodsCell.h"
#import "ZFLocalizationString.h"

static NSString *const kZFZFGoodsDetailShowExploreCellIdentifier = @"kZFZFGoodsDetailShowExploreCellIdentifier";

@interface ZFGoodsDetailShowExploreCell() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionViewFlowLayout        *flowLayout;
@property (nonatomic, strong) UICollectionView                  *collectionView;

/**统计来源页面名*/
@property (nonatomic, copy) NSString                            *pageName;

@end

@implementation ZFGoodsDetailShowExploreCell

#pragma mark - init methods

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.showExploreModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodsShowExploreModel *showExploreModel = self.showExploreModelArray[indexPath.row];
    ZFGoodsDetailShowListCell *showsCell = [ZFGoodsDetailShowListCell ShowListCellWith:collectionView forIndexPath:indexPath];
    showExploreModel.isShowLikeNumber = self.isShowLikeNumber;
    showsCell.model = showExploreModel;
    return showsCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = 90;
    CGFloat height = 120;
    CGFloat showHeight = self.isShowLikeNumber ? (height + 40 ) : (height + 16);
    return CGSizeMake(width, showHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodsShowExploreModel *model = self.showExploreModelArray[indexPath.row];
    if (self.selectedShowExploreBlock) {
        self.selectedShowExploreBlock(model);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setShowExploreModelArray:(NSArray<GoodsShowExploreModel *> *)showExploreModelArray {
    if (![_showExploreModelArray isEqualToArray:showExploreModelArray]) {
        _showExploreModelArray = showExploreModelArray;
        [self.collectionView reloadData];
    }
}

#pragma mark - getter

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 8;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = YES;
        _collectionView.alwaysBounceHorizontal = NO;
    }
    return _collectionView;
}

- (ZFGoodsDetailShowExploreAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFGoodsDetailShowExploreAOP alloc] init];
    }
    return _analyticsAOP;
}
@end

