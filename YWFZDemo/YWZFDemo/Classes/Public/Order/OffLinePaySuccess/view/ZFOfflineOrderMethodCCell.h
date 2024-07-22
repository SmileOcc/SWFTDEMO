//
//  ZFOfflineOrderMethodCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  线下支付订单操作cell

#import <UIKit/UIKit.h>
#import "ZFCollectionViewCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

//继承虚基类，实现
@protocol ZFOfflineOrderMethodCCellDelegate <ZFCollectionViewCellDelegate>

- (void)ZFOfflineOrderMethodCCellDidClickCheckOrderButton;

///点击了查看线下支付凭证的按钮
- (void)ZFOfflineOrderMethodCCellDidClickCheckCode;

@end

@interface ZFOfflineOrderMethodCCell : UICollectionViewCell
<
    ZFCollectionViewCellProtocol
>

//重载
@property (nonatomic, weak) id<ZFOfflineOrderMethodCCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
