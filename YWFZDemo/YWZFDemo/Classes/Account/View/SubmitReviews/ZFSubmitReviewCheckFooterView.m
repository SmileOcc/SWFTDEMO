

//
//  ZFSubmitReviewCheckFooterView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewCheckFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFOrderReviewInfoModel.h"
#import "ZFReviewImageCollectionViewCell.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"

static NSString *const kZFReviewImageCollectionViewCellIdentifier = @"kZFReviewImageCollectionViewCellIdentifier";

@interface ZFSubmitReviewCheckFooterView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionViewFlowLayout                *flowLayout;
@property (nonatomic, strong) UICollectionView                          *collectionView;
@end

@implementation ZFSubmitReviewCheckFooterView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ZFOrderReviewInfoModel *reviewModel = self.model.reviewList.firstObject;
    return reviewModel.reviewPic.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFOrderReviewInfoModel *reviewModel = self.model.reviewList.firstObject;
    ZFReviewImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFReviewImageCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.url = [NSString stringWithFormat:@"%@%@", self.model.review_img_domain, reviewModel.reviewPic[indexPath.item].big_pic];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.submitReviewCheckImageCompletionHandler) {
        
        self.submitReviewCheckImageCompletionHandler(indexPath.item);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFOrderReviewModel *)model {
    _model = model;
    [self.collectionView reloadData];
}

#pragma mark - getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 12;
        _flowLayout.minimumInteritemSpacing = 12;
        _flowLayout.sectionInset = UIEdgeInsetsMake(12, 16, 12, 16);
        _flowLayout.itemSize = CGSizeMake(80, 80);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
        [_collectionView registerClass:[ZFReviewImageCollectionViewCell class] forCellWithReuseIdentifier:kZFReviewImageCollectionViewCellIdentifier];
    }
    return _collectionView;
}

@end
