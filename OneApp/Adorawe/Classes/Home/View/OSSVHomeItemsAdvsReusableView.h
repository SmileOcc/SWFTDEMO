//
//  HomeItemBannerReusableView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BannerItem;

typedef void (^HomeItemBannerBlcok)(OSSVAdvsEventsModel *model);

@interface OSSVHomeItemsAdvsReusableView : UICollectionReusableView

+ (OSSVHomeItemsAdvsReusableView*)homeItemHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) HomeItemBannerBlcok    bannerBlock;
@property (nonatomic, strong) NSArray              *bannersArray;
@end




@interface BannerItem: UIControl

@property (nonatomic, strong)  YYAnimatedImageView        *imgView;

@end
