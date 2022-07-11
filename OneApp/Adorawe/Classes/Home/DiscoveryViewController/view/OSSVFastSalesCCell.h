//
//  OSSVFastSalesCCell.h
// OSSVFastSalesCCell
//
//  Created by Kevin--Xue on 2020/11/1.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol STLFastSaleCollectionViewCellDelegate <CollectionCellDelegate>
@optional
- (void)jumpFlashSaleViewController;
@end

//功能注释：闪购模块（头部广告+闪购商品）点击任何进入闪购
@interface OSSVFastSalesCCell : UICollectionViewCell<OSSVCollectCCellProtocol>
@property (nonatomic, weak) id<STLFastSaleCollectionViewCellDelegate>delegate;
@end


NS_ASSUME_NONNULL_END
