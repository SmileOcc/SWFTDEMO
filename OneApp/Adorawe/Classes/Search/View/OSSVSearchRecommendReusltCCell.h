//
//  OSSVSearchRecommendReusltCCell.h
// XStarlinkProject
//
//  Created by occ on 10/11/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVSearchRecommendReusltCCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

+ (OSSVSearchRecommendReusltCCell *)attributeCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

+ (CGSize)sizeAttributeContent:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
