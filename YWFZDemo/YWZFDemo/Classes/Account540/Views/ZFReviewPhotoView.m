//
//  ZFReviewPhotoView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFReviewPhotoView.h"
#import "ZFInitViewProtocol.h"
#import "ZFSubmitReviewAddImageCell.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"

static const CGFloat kReviewPhotoImageHeight = 80.0;
static NSString *const kZFSubmitReviewAddImageCellIdentifier = @"kZFSubmitReviewAddImageCellIdentifier";
static NSString *const kZFReviewPhotoAddImageViewIdentifier = @"kZFReviewPhotoAddImageViewIdentifier";

@interface ZFReviewPhotoAddImageView : UICollectionReusableView
@property (nonatomic, strong) UIButton *addImageButton;
@property (nonatomic, copy) void(^addImageBlock)(void);
@end

@implementation ZFReviewPhotoAddImageView
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
    [self addSubview:self.addImageButton];
}

- (void)zfAutoLayoutView {
    [self.addImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 16, 0, 0));
    }];
}

#pragma mark - getter
- (UIButton *)addImageButton {
    if (!_addImageButton) {
        _addImageButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_addImageButton setImage:[UIImage imageNamed:@"camera_review"] forState:0];
        [_addImageButton addTarget:self action:@selector(addImageAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _addImageButton;
}

- (void)addImageAction {
    if (self.addImageBlock) {
        self.addImageBlock();
    }
}
@end


@interface ZFReviewPhotoView() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionViewFlowLayout            *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;
@end

@implementation ZFReviewPhotoView


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
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSubmitReviewAddImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFSubmitReviewAddImageCellIdentifier forIndexPath:indexPath];
    if (self.photosArray.count < 3) {
        if (indexPath.item == self.photosArray.count) {
            cell.type = SubmitReviewAddImageTypeAdd;
        } else {
            cell.image = self.photosArray[indexPath.item];
            cell.type = SubmitReviewAddImageTypeNormal;
        }
    } else {
        cell.image = self.photosArray[indexPath.item];
        cell.type = SubmitReviewAddImageTypeNormal;
    }
    @weakify(self);
    cell.submitReviewDeleteImageCompletionHandler = ^{
        @strongify(self);
        if (self.deleteImageActionBlock) {
            self.deleteImageActionBlock(indexPath.item);
        }
        [self.collectionView reloadData];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.showAddImageActionBlock) {
        ///获取所有的图片放大位置
        NSMutableArray *rectArray = [NSMutableArray array];
        for (NSInteger i=0; i<self.photosArray.count; i++) {
            CGRect tmpRect = CGRectMake((kReviewPhotoImageHeight + 16) * i + 16, 0, kReviewPhotoImageHeight, kReviewPhotoImageHeight);
            CGRect rect = [collectionView convertRect:tmpRect toView:self.window];
            [rectArray addObject:[NSValue valueWithCGRect:rect]];
        }
        self.showAddImageActionBlock(indexPath.item, rectArray);
    }
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString: UICollectionElementKindSectionHeader] || self.photosArray.count >= 3) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];;
    }
    ZFReviewPhotoAddImageView *addImageView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFReviewPhotoAddImageViewIdentifier forIndexPath:indexPath];
    addImageView.addImageBlock = self.addImageActionBlock;
    return addImageView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (self.photosArray.count < 3) {
        return CGSizeMake(kReviewPhotoImageHeight+16, kReviewPhotoImageHeight);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat leftSpace = 0;
    if (self.photosArray.count > 0 && self.photosArray.count <= 3) {
        leftSpace = 16;
    }
    return UIEdgeInsetsMake(0, leftSpace, 0, 0);
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
- (void)setPhotosArray:(NSArray *)photosArray {
    _photosArray = photosArray;
    [self.collectionView reloadData];
}

#pragma mark - getter
- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.itemSize = CGSizeMake(kReviewPhotoImageHeight, kReviewPhotoImageHeight);
        _flowLayout.minimumLineSpacing = 16;
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
        [_collectionView registerClass:[ZFSubmitReviewAddImageCell class] forCellWithReuseIdentifier:kZFSubmitReviewAddImageCellIdentifier];
        
        [_collectionView registerClass:[ZFReviewPhotoAddImageView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFReviewPhotoAddImageViewIdentifier];
        ZFThemeManager.
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    }
    return _collectionView;
}

@end
