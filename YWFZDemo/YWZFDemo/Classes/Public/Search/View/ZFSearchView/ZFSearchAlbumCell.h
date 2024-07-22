//
//  ZFSearchAlbumCell.h
//  ZZZZZ
//
//  Created by YW on 2018/9/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFPhotoCellType) {
    ZFPhotoCellTypeCamera = 0,
    ZFPhotoCellTypeImage,
    ZFPhotoCellTypeMore
};

@interface ZFSearchAlbumCell : UICollectionViewCell

+ (ZFSearchAlbumCell *)searchAlbumCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)configWithImage:(UIImage *)image type:(ZFPhotoCellType)type;

@end
