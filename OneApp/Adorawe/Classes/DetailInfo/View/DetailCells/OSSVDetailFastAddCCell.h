//
//  OSSVDetailFastAddCCell.h
// XStarlinkProject
//
//  Created by fan wang on 2021/6/21.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVDetailRecommendCell.h"
@class OSSVDetailFastAddCCell;

NS_ASSUME_NONNULL_BEGIN

@protocol STLDetailsFastAddItemDelegate <NSObject>

/// item {goodsId:goodisid, wid:wid}
@required
-(void)fastAddItemCell:(OSSVDetailFastAddCCell *)cell addToCart:(NSDictionary *)item;

@end

@interface OSSVDetailFastAddCCell : OSSVDetailRecommendCell
@property (weak,nonatomic) id <STLDetailsFastAddItemDelegate> addToCartDelegate;
@end

NS_ASSUME_NONNULL_END
