//
//  GenderSelectionView.h
//  YoshopPro
//
//  Created by mac on 2018/10/11.
//  Copyright © 2018年 yoshop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFNewUserHeckReceivingStatusModel;

@interface CouponRulesView : UIView

@property (nonatomic, strong) ZFNewUserHeckReceivingStatusModel *heckReceivingStatusModel;

-(void)show;

-(void)hiddenView;

@end
