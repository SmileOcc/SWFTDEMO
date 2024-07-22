
//
//  ZFPaymentGoodsInfoView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPaymentGoodsInfoView.h"
#import "ZFInitViewProtocol.h"
#import "ZFOrderGoodsInfoCollectionViewCell.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

static NSString *const kZFOrderGoodsInfoCollectionViewCellIdentifier = @"kZFOrderGoodsInfoCollectionViewCellIdentifier";

@interface ZFPaymentGoodsInfoView() <ZFInitViewProtocol, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionViewFlowLayout        *flowLayout;
@property (nonatomic, strong) UICollectionView                  *collectionView;
@end

@implementation ZFPaymentGoodsInfoView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFOrderGoodsInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFOrderGoodsInfoCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 12, 0, 12));
    }];
}

#pragma mark - setter
- (void)setDataArray:(NSArray<CheckOutGoodListModel *> *)dataArray {
    _dataArray = dataArray;
    [self.collectionView reloadData];
}

#pragma mark - getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize = CGSizeMake(60, 80);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
//        _collectionView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
        [_collectionView registerClass:[ZFOrderGoodsInfoCollectionViewCell class] forCellWithReuseIdentifier:kZFOrderGoodsInfoCollectionViewCellIdentifier];
    }
    return _collectionView;
}

@end
