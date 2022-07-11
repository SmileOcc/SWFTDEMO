//
//  STLAttributeSelectImageListView.m
// XStarlinkProject
//
//  Created by odd on 2020/12/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLAttributeSelectImageListView.h"
#import "YYPhotoBrowseView.h"

@interface STLAttributeSelectImageListView() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView  *collectionView;
@property (nonatomic, strong) NSArray           *pictUrlArray;
@end

@implementation STLAttributeSelectImageListView

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

#pragma mark - setter

- (void)setGoodsDetailModel:(OSSVDetailsBaseInfoModel *)goodsDetailModel {
    _goodsDetailModel = goodsDetailModel;
    
    NSMutableArray *pictUrlArray = [NSMutableArray arrayWithCapacity:goodsDetailModel.pictureListArray.count];
    
//    for (int i = 0; i < goodsDetailModel.pictureListArray.count; i++) {
//        OSSVDetailPictureArrayModel *pict = goodsDetailModel.pictureListArray[i];
//        if ([pict.goodsBigImg length] > 0) {
//            [pictUrlArray addObject:pict.goodsBigImg];
//        } else {
//            [pictUrlArray addObject:pict.goodsSmallImg];
//        }
//    }
    
    [pictUrlArray addObject:STLToString(goodsDetailModel.goodsBigImg)];
    
    if (pictUrlArray.count >= 3) {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        self.collectionView.scrollEnabled = YES;

    } else if(pictUrlArray.count == 2) {
        
        CGFloat left = (SCREEN_WIDTH - kImageListViewWidth * 2 - kListViewSpace) / 2.0 -  kListViewMargin;
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, left, 0, 0));
        }];
        self.collectionView.scrollEnabled = NO;
        
    } else if(pictUrlArray.count == 1) {
        CGFloat left = (SCREEN_WIDTH - kImageListViewWidth) / 2.0 -  kListViewMargin;
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, left, 0, 0));
        }];
        self.collectionView.scrollEnabled = NO;
    }
   
    
    self.showGoodsImage = [UIImage imageNamed:@"loading_cat_list"];
    
    
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
                         placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                             options:YYWebImageOptionShowNetworkActivity
                            progress:nil
                           transform:nil
                          completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (indexPath.item == 0) {
            self.showGoodsImage = image;
        }
    }];
    imageCell.backgroundView = goodsImgView;
    imageCell.backgroundColor = STLRandomColor();
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
                scrollX = MIN(scrollX, self.collectionView.contentSize.width - SCREEN_WIDTH);
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

#pragma mark - <STLInitViewProtocol>
- (void)stlInitView {
    self.backgroundColor = [UIColor whiteColor];;
    [self addSubview:self.collectionView];
}

- (void)stlAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
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
