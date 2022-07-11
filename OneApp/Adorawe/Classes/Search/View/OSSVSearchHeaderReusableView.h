//
//  OSSVSearchHeaderReusableView.h
// XStarlinkProject
//
//  Created by occ on 10/11/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVSearchHeaderReusableView : UICollectionReusableView

@property (nonatomic, strong) UILabel                *contentLabel;


+ (OSSVSearchHeaderReusableView *)actionCollectionFooterView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
