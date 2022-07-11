//
//  OSSVDetailServicesCell.h
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVDetailsHeaderServiceView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailServicesCell : OSSVDetailBaseCell

/** 商品服务信息*/
@property (nonatomic, strong) OSSVDetailsHeaderServiceView  *goodsServiceView;

@property (nonatomic, strong) OSSVDetailsBaseInfoModel  *infoModel;
@end

NS_ASSUME_NONNULL_END
