//
//  OSSVGoodsHistorEmptCollectionReusView.h
// XStarlinkProject
//
//  Created by odd on 2020/8/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVGoodsHistorEmptCollectionReusView : UICollectionReusableView

+ (OSSVGoodsHistorEmptCollectionReusView*)goodsHistoryHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
