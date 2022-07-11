//
//  OSSVAccountsFastsAddItemsCell.h
// XStarlinkProject
//
//  Created by fan wang on 2021/6/10.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVHomeItemssCell.h"
@class OSSVAccountsFastsAddItemsCell;

NS_ASSUME_NONNULL_BEGIN

@protocol STLAccountFastAddItemDelegate <NSObject>

/// item {goodsId:goodisid, wid:wid}
@required
-(void)fastAddItemCell:(OSSVAccountsFastsAddItemsCell *)cell addToCart:(NSDictionary *)item;

@end


@interface OSSVAccountsFastsAddItemsCell : OSSVHomeItemssCell
@property (weak,nonatomic) id <STLAccountFastAddItemDelegate> addToCartDelegate;

+ (OSSVAccountsFastsAddItemsCell *)fastAddItemCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
