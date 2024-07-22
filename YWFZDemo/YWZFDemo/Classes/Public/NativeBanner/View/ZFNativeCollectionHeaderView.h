//
//  ZFNativeCollectionHeaderView.h
//  ZZZZZ
//
//  Created by YW on 4/1/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFNativeCollectionHeaderView : UICollectionReusableView

@property (nonatomic, copy) NSString   *title;

+ (ZFNativeCollectionHeaderView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath;

@end
