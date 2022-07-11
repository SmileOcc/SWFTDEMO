//
//  OSSVMultiPGoodsSPecialCCell.h
// OSSVMultiPGoodsSPecialCCell
//
//  Created by odd on 2021/1/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "OSSVProGoodsCCellModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVMultiPGoodsSPecialCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>

////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;
-(void)setHomeCGoodsModel:(STLHomeCGoodsModel *)goodsModel;
@end

NS_ASSUME_NONNULL_END
