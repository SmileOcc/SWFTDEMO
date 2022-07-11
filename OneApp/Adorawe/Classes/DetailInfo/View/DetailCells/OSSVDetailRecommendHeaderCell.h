//
//  OSSVDetailRecommendHeaderCell.h
// XStarlinkProject
//
//  Created by odd on 2021/4/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVBuyAndBuyTabView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailRecommendHeaderCell : OSSVDetailBaseCell

+ (CGFloat)heightGoodsRecommendView:(BOOL)hasData;

@property (weak,nonatomic) OSSVBuyAndBuyTabView *tabView;
@end

NS_ASSUME_NONNULL_END
