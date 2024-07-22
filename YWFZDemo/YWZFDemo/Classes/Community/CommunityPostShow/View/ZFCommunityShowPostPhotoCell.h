//
//  PostPhotoCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>

#import "PYAssetModel.h"
#import "PYAblum.h"

typedef void(^DeletePhotoBlock)(PYAssetModel *assetModel);

@interface ZFCommunityShowPostPhotoCell : UICollectionViewCell


@property (nonatomic,copy) DeletePhotoBlock deletePhotoBlock;
@property (nonatomic, copy) void (^longPressBlock)(UILongPressGestureRecognizer *gesture);


@property (nonatomic,strong) YYAnimatedImageView   *photoView;
@property (nonatomic,strong) UIButton              *deleteButton;
@property (nonatomic,strong) PYAssetModel          *assetModel;
@property (nonatomic, assign) CGFloat              imageWidth;
@property (nonatomic,assign) BOOL                  isNeedHiddenAddView;


@property (nonatomic, strong) UIImageView          *addImageView;
@property (nonatomic, strong) UILabel              *addLabel;



- (void)setAddPhotoImage:(UIImage *)image;

+ (ZFCommunityShowPostPhotoCell *)postPhotoCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end
