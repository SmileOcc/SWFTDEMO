//
//  OSSVCouponApplyView.h
// XStarlinkProject
//
//  Created by 10010 on 20/10/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OSSVCouponCellModel;
@class OSSVCouponModel;
@class OSSVMyCouponsListsModel;

@protocol STLCouponViewDelegate <NSObject>

-(void)STL_CouponCellDidClickApply:(OSSVCouponCellModel *)model;

@end

@interface OSSVCouponApplyView : UIView

@property (nonatomic, strong) UITextField *couponInputTF;
@property (nonatomic, strong) UIButton *applyButton;

@property (nonatomic, strong) OSSVCouponCellModel        *model;
@property (nonatomic, strong) OSSVCouponModel                *couponModel;
@property (nonatomic,strong)  OSSVMyCouponsListsModel    *selectedModel;
@property (nonatomic, weak) id<STLCouponViewDelegate>    delegate;
@property (nonatomic,copy) void (^textFieldBlock)(NSString *text);
@end

