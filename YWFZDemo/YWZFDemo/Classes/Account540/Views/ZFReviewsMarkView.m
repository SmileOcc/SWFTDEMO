//
//  ZFReviewsMarkView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFReviewsMarkView.h"
#import "ZFInitViewProtocol.h"
#import "ZFSubmitReviewAddImageCell.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"
#import "ZFOrderReviewModel.h"
#import "YWCFunctionTool.h"

static const CGFloat kReviewPhotoImageHeight = 28.0;
static NSString *const kZFReviewsMarkCellIdentifier = @"kZFReviewsMarkCellIdentifier";

@interface ZFReviewsMarkCell : UICollectionViewCell
@property (nonatomic, strong) UIButton *markButton;
@property (nonatomic, copy) NSString *reviewsMarkKey;
@end

@implementation ZFReviewsMarkCell

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.markButton];
}

- (void)zfAutoLayoutView {
    [self.markButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - getter
- (UIButton *)markButton {
    if (!_markButton) {
        _markButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _markButton.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 6, 12);
        _markButton.backgroundColor = ZFC0xF7F7F7();
        [_markButton setTitleColor:ZFCOLOR(102, 102, 102, 1) forState:UIControlStateDisabled];
        _markButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _markButton.layer.cornerRadius = 2;
        _markButton.layer.masksToBounds = YES;
        _markButton.layer.borderWidth = 1;
        _markButton.layer.borderColor = ZFC0xF7F7F7().CGColor;
        _markButton.enabled = NO;
    }
    return _markButton;
}

- (void)setReviewsMarkKey:(NSString *)reviewsMarkKey {
    _reviewsMarkKey = reviewsMarkKey;
    [self.markButton setTitle:ZFToString(reviewsMarkKey) forState:UIControlStateDisabled];
}

- (void)selecteMark:(BOOL)selecte {
    if (selecte) {
        [self.markButton setTitleColor:ZFC0xFE5269() forState:UIControlStateDisabled];
        self.markButton.layer.borderColor = ZFC0xFE5269().CGColor;
    } else {
        [self.markButton setTitleColor:ZFCOLOR(102, 102, 102, 1) forState:UIControlStateDisabled];
        self.markButton.layer.borderColor = ZFC0xF7F7F7().CGColor;
    }
}

@end


@interface ZFReviewsMarkView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) ZFOrderReviewModel                    *reviewModel;
@property (nonatomic, strong) UICollectionViewLeftAlignedLayout     *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;
@property (nonatomic, strong) NSMutableArray                        *seletedIndexPathArr;
@end

@implementation ZFReviewsMarkView


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
    return self.reviewModel.goods_info.review_tags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFReviewsMarkCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFReviewsMarkCellIdentifier forIndexPath:indexPath];
    if (self.reviewModel.goods_info.review_tags.count > indexPath.item) {
        cell.reviewsMarkKey = self.reviewModel.goods_info.review_tags[indexPath.item];
    }
    BOOL selecte = [self.seletedIndexPathArr containsObject:indexPath];
    [cell selecteMark:selecte];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    BOOL selecte = [self.seletedIndexPathArr containsObject:indexPath];
    if (selecte) {
        [self.seletedIndexPathArr removeObject:indexPath];
    } else {
        [self.seletedIndexPathArr addObject:indexPath];
    }
    
    ZFReviewsMarkCell *cell = (ZFReviewsMarkCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        [collectionView reloadData];
    }
    if (self.reviewModel.goods_info.review_tags.count > indexPath.item) {
        if (self.selectedMarkHandler) {
            NSString *reviewsMarkKey = self.reviewModel.goods_info.review_tags[indexPath.item];
            self.selectedMarkHandler(reviewsMarkKey, !selecte);
        }
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.height.mas_equalTo(kReviewPhotoImageHeight);
    }];
}

#pragma mark - setter

- (void)refreshReviewsMark:(ZFOrderReviewModel *)reviewModel
             handlerHeight:(void(^)(CGFloat))handlerHeight
{
    _reviewModel = reviewModel;
    [self.collectionView reloadData];
    
    if (handlerHeight) {
        [self layoutIfNeeded];
        CGFloat h = self.collectionView.contentSize.height;
        if (h == 0) { //防止自动计算高度出错
            NSInteger count = self.reviewModel.goods_info.review_tags.count-1;
            NSIndexPath *inexPath = [NSIndexPath indexPathForRow:count inSection:0];
            UICollectionViewCell *lastCell = [self collectionView:self.collectionView cellForItemAtIndexPath:inexPath];
            h = CGRectGetMaxY(lastCell.frame);
        }
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(h);
        }];
        handlerHeight(h);
    }
}

#pragma mark - getter
- (UICollectionViewLeftAlignedLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
        _flowLayout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeLeft;
        _flowLayout.minimumLineSpacing = 12;
        _flowLayout.minimumInteritemSpacing = 12;
        _flowLayout.estimatedItemSize = CGSizeMake(kReviewPhotoImageHeight, kReviewPhotoImageHeight);
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor =  ZFCOLOR_WHITE;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.directionalLockEnabled = YES;
        _collectionView.scrollEnabled = NO;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
        [_collectionView registerClass:[ZFReviewsMarkCell class] forCellWithReuseIdentifier:kZFReviewsMarkCellIdentifier];
        
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    }
    return _collectionView;
}

- (NSMutableArray *)seletedIndexPathArr {
    if (!_seletedIndexPathArr) {
        _seletedIndexPathArr = [NSMutableArray array];
    }
    return _seletedIndexPathArr;
}

@end
