//
//  ZFOrderReviewResultViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/10/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderReviewResultViewController.h"
#import "Constants.h"
#import "ZFProgressHUD.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "ZFThemeManager.h"

#import "ZFOrderReviewResultOrderCCell.h"
#import "ZFCMSRecommendGoodsCCell.h"
#import "ZFEmptyCCell.h"

@interface ZFOrderReviewResultViewController ()
<
    ZFInitViewProtocol,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource,
    UICollectionViewDelegate
>
@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) NSMutableArray    *dataSource;

@property (nonatomic, strong) UIView            *firstHeaderView;


@end

@implementation ZFOrderReviewResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    
    [self.collectionView reloadData];
}

- (void)zfInitView {
    self.view.backgroundColor = ZFC0xF2F2F2();
    self.collectionView.backgroundColor = ZFRandomColor();
    [self.view addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading);
        make.top.mas_equalTo(self.view.mas_top).offset(15);
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 6;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        ZFOrderReviewResultOrderCCell *orderCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFOrderReviewResultOrderCCell.class) forIndexPath:indexPath];
        orderCell.backgroundColor = ZFRandomColor();
        return orderCell;
    }
    
    ZFCMSRecommendGoodsCCell *recommendCell = [ZFCMSRecommendGoodsCCell reusableRecommendGoodsCell:collectionView forIndexPath:indexPath];
    recommendCell.backgroundColor = ZFRandomColor();
    
    return recommendCell;
}

// 设置区头尺寸高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    CGSize size = CGSizeZero;
    if (section == 0) {
        size = self.firstHeaderView.frame.size;
    }
    return size;
}



- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableView = nil;
    if (indexPath.section == 0) {
        if (self.firstHeaderView.superview) {
            [self.firstHeaderView removeFromSuperview];
        }
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZFOrderReviewHeaderReusableView" forIndexPath:indexPath];
        self.firstHeaderView.hidden = NO;
        [headerView addSubview:self.firstHeaderView];
        reusableView = headerView;

    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return CGSizeMake(KScreenWidth, 120);
    }
    CGFloat width = (KScreenWidth - 4*12) / 3.0;
    CGFloat height = (width / KImage_SCALE) + 58;
    return CGSizeMake(width, height);
}

// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

#pragma mark - Property Method

- (UICollectionView *)collectionView {
    if (!_collectionView) {

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZFOrderReviewHeaderReusableView"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ZFOrderReviewFooterReusableView"];
        
        [_collectionView registerClass:[ZFOrderReviewResultOrderCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFOrderReviewResultOrderCCell.class)];
        [_collectionView registerClass:[ZFCMSRecommendGoodsCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCMSRecommendGoodsCCell.class)];
        [_collectionView registerClass:[ZFEmptyCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFEmptyCCell.class)];

    }
    return _collectionView;
}


- (UIView *)firstHeaderView {
    if (!_firstHeaderView) {
        _firstHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 120)];
        _firstHeaderView.backgroundColor = ZFRandomColor();
    }
    return _firstHeaderView;
}

@end
