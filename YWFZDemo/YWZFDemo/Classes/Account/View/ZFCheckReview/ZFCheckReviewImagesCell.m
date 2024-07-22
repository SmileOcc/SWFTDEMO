


//
//  ZFCheckReviewImagesCell.m
//  ZZZZZ
//
//  Created by YW on 2018/2/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCheckReviewImagesCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCheckReviewImageCollectionViewCell.h"
#import "CheckReviewModel.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

static NSString *const kZFCheckReviewImageCollectionViewCellIdentifier = @"kZFCheckReviewImageCollectionViewCellIdentifier";

@interface ZFCheckReviewImagesCell() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionViewFlowLayout        *flowLayout;
@property (nonatomic, strong) UICollectionView                  *collectionView;

@end


@implementation ZFCheckReviewImagesCell

#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    return self.checkModel.review_pic.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCheckReviewImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCheckReviewImageCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.imageUrl = self.checkModel.review_pic[indexPath.item][@"originPic"];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (IPHONE_4X_3_5 || IPHONE_5X_4_0) {
        return CGSizeMake(90, 90);
    }else{
        return CGSizeMake(112, 112);
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
- (void)setCheckModel:(CheckReviewModel *)checkModel {
    _checkModel = checkModel;
    [self.collectionView reloadData];
}


#pragma mark - getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 10;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[ZFCheckReviewImageCollectionViewCell class] forCellWithReuseIdentifier:kZFCheckReviewImageCollectionViewCellIdentifier];
        
    }
    return _collectionView;
}

@end
