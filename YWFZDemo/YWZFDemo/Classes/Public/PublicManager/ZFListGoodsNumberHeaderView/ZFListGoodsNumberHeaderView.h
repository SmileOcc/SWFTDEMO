//
//  ZFNativeGoodsItemView.h
//  ZZZZZ
//
//  Created by YW on 13/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __IPHONE_11_0
@interface ZFCustomLayer : CALayer

@end
#endif

@interface ZFListGoodsNumberHeaderView : UICollectionReusableView

@property (nonatomic, copy) NSString   *item;
@property (nonatomic, copy) NSString   *imageUrl;

+ (ZFListGoodsNumberHeaderView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath;

@end
