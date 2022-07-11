//
//  STLPicListCell.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLPicListCell : UICollectionViewCell

@property (nonatomic, copy)NSString *imgUrlStr;
@property (nonatomic, strong) YYAnimatedImageView *imgV;

- (UIImage *)getImgOfCell;

+ (STLPicListCell *)STLPicListCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
