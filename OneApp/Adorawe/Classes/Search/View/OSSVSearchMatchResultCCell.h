//
//  OSSVSearchMatchResultCCell.h
// XStarlinkProject
//
//  Created by occ on 10/11/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVSearchMatchResultCCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imgView;

+ (OSSVSearchMatchResultCCell *)attributeCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
