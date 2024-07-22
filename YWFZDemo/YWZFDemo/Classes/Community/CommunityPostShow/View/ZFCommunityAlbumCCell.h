//
//  ZFCommunityAlbumCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAssetModel.h"

@interface ZFCommunityAlbumCCell : UICollectionViewCell

+ (ZFCommunityAlbumCCell *)albumPhotoCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;


@property (nonatomic, copy) void (^selectBlock)(PYAssetModel *assetModel);

@property (nonatomic, assign) CGFloat     imageWidth;

@property (nonatomic, strong) UIImageView *addPhotoImageView;

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIButton    *selectButton;
@property (nonatomic, strong) UIView      *markSelectView;

@property (nonatomic, strong) PYAssetModel *assetModel;

- (void)setCameraImage:(UIImage *)image;
- (void)showSelectMaskView:(BOOL)isShow;


@end
