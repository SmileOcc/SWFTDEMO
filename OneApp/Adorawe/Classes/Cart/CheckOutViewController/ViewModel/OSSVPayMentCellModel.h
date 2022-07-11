//
//  OSSVPayMentCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartPaymentModel.h"
#import "OSSVBaseCellModelProtocol.h"
#import "OSSVArrowCellModel.h"
#import "OSSVSwitchCellModel.h"
#import "OSSVCouponCellModel.h"
#import "OSSVProductListCellModel.h"
#import "OSSVCoinCellModel.h"
#import "OSSVCartCheckModel.h"

@interface OSSVPayMentCellModel : NSObject<OSSVBaseCellModelProtocol>
@property (nonatomic, assign) BOOL                      isCODPaySelected;
///控制视图属性
@property (nonatomic, assign) BOOL                      isSelect;
///是否显示提示栏
@property (nonatomic, assign) BOOL                      showDetail;
@property (nonatomic, strong) NSMutableArray            *depenDentModelList;

@property (nonatomic, strong) OSSVSwitchCellModel         *insuranceCellModel;
@property (nonatomic, strong) OSSVSwitchCellModel         *pointCellModel;
@property (nonatomic, strong) STLCouponSaveCellModel     *saveCellModel;
@property (nonatomic, strong) OSSVProductListCellModel    *productCellModel;
@property (nonatomic, strong) OSSVCoinCellModel           *coinCellModel;

///<视图显示属性
@property (nonatomic, copy) NSAttributedString          *paymentTitle;
///当showDetail为yes时，不能为空
@property (nonatomic, copy) NSString                    *paymentDetail;
@property (nonatomic, strong) UIImage                   *paymentIcon;

@property (nonatomic, strong) OSSVCartPaymentModel          *payMentModel;
@property (nonatomic, strong) OSSVCartCheckModel            *checkModel;

@property (nonatomic,assign) BOOL islast;

@end
