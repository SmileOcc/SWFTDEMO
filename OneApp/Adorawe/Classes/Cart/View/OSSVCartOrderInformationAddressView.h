//
//  OSSVCartOrderInformationAddressView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVAddresseBookeModel;

@interface OSSVCartOrderInformationAddressView : UIView

/*修改地址Block*/
@property (nonatomic,copy) void (^changeAddressBlock)(OSSVAddresseBookeModel *addressModel);

@property (nonatomic,strong) OSSVAddresseBookeModel *addressModel;

/*由于在订单详情页也会用到 ---> 需要隐藏*/
@property (nonatomic, strong) UIButton *addressShowBtn;

@end
