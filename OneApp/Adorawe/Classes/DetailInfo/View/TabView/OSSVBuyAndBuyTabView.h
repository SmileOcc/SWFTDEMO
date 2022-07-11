//
//  OSSVBuyAndBuyTabView.h
// XStarlinkProject
//
//  Created by fan wang on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVBuyAndBuyButton.h"


#define STLBuyAndBuySwitchNotifiName @"STLBuyAndBuySwitchNotifiName"
#define STLBuyAndBuyShowRedDotNotifiName @"STLBuyAndBuyShowRedDotNotifiName"

#define kNeedShowRedDot @"needShowRedDot"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVBuyAndBuyTabView : UIView
-(void)setCurrentIndex:(NSInteger)index;
-(void)didtapButton:(OSSVBuyAndBuyButton *)button;

@property (weak,nonatomic) OSSVBuyAndBuyButton *youMayAlsoLike;
@property (weak,nonatomic) OSSVBuyAndBuyButton *oftenBoughtWith;
@end

NS_ASSUME_NONNULL_END
