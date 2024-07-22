//
//  ZFSelectSizeImageListView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFSelectSizeImageListView.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "YYPhotoBrowseView.h"
#import <YYWebImage/YYWebImage.h>
#import "GoodsDetailModel.h"

@interface ZFSelectSizeImageListView() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) NSArray           *pictUrlArray;
@end

@implementation ZFSelectSizeImageListView

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - setter

- (void)setGoodsDetailModel:(GoodsDetailModel *)goodsDetailModel {
    _goodsDetailModel = goodsDetailModel;
    
    self.showGoodsImage = [UIImage imageNamed:@"loading_cat_list"];
    NSMutableArray *pictUrlArray = [NSMutableArray arrayWithCapacity:goodsDetailModel.pictures.count];
    
    for (int i = 0; i < goodsDetailModel.pictures.count; i++) {
        GoodsDetailPictureModel *pict = goodsDetailModel.pictures[i];
        if ([pict.goods_img_app length] > 0) {
            [pictUrlArray addObject:pict.goods_img_app];
        } else {
            [pictUrlArray addObject:pict.wp_image];
        }
    }
    self.pictUrlArray = pictUrlArray;
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pictUrlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];

    UIImageView *goodsImgView = [[UIImageView alloc] init];
    NSString *imageUrl = self.pictUrlArray[indexPath.row];
    [goodsImgView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                         placeholder:[UIImage imageNamed:@"loading_cat_list"]
                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                            progress:nil
                           transform:nil
                          completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (indexPath.item == 0) {
            self.showGoodsImage = image;
        }
    }];
    imageCell.backgroundView = goodsImgView;
    return imageCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kImageListViewWidth, kImageListViewHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self showImageBrowseViewAtIndex:indexPath.item];
}

#pragma mark - <YYPhotoBrowseView>

- (void)showImageBrowseViewAtIndex:(NSInteger)index {
    
    NSMutableArray *showImageViewArray = [NSMutableArray array];
    for (NSInteger i=0; i<self.pictUrlArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
        UIImageView *tmpImageView = (UIImageView *)cell.backgroundView;
        if (![tmpImageView isKindOfClass:[UIImageView class]]) continue;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:tmpImageView.image];
        CGRect tmpRect = CGRectMake((kImageListViewWidth + kListViewSpace) * i + kListViewMargin, 0, kImageListViewWidth, kImageListViewHeight);
        imageView.frame = [self.collectionView convertRect:tmpRect toView:self.window];
        [showImageViewArray addObject:imageView];
    }

    NSMutableArray *tempBrowseImageArr = [NSMutableArray array];

    [self.pictUrlArray enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            YYPhotoGroupItem *showItem = [YYPhotoGroupItem new];
            if (showImageViewArray.count > idx) {
                showItem.thumbView = showImageViewArray[idx];
            }
            NSURL *url = [NSURL URLWithString:imageUrl];
            showItem.largeImageURL = url;
            [tempBrowseImageArr addObject:showItem];
        }
    }];

    if (tempBrowseImageArr.count > index && tempBrowseImageArr.count > 0) {
        YYPhotoBrowseView *groupView = [[YYPhotoBrowseView alloc] initWithGroupItems:tempBrowseImageArr];
        groupView.blurEffectBackground = NO;
        @weakify(self)
        groupView.dismissCompletion = ^(NSInteger currentPage) {
            @strongify(self)
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentPage inSection:0];
            UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
            if (!cell) return ;
            if (![self.collectionView.visibleCells containsObject:cell]) {
                CGFloat scrollX = CGRectGetMinX(cell.frame);
                scrollX = MIN(scrollX, self.collectionView.contentSize.width - KScreenWidth);
                scrollX = MAX(0, scrollX);
                // [self.collectionView setContentOffset:CGPointMake(scrollX, 0) animated:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.collectionView scrollRectToVisible:cell.frame animated:YES];
                });
            }
        };
        
        if (showImageViewArray.count > index) {
            [groupView presentFromImageView:showImageViewArray[index] toContainer:self.window animated:YES completion:nil];
        }
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];;
    [self addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(kListViewSpace, 0, 0, 0));
//        make.height.mas_equalTo(kImageListViewHeight);
    }];
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = kListViewSpace;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, kListViewMargin, 0, kListViewMargin);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _collectionView;
}

@end
