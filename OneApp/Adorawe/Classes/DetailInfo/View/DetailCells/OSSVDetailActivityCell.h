//
//  OSSVDetailActivityCell.h
// XStarlinkProject
//
//  Created by odd on 2021/6/25.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVDetailArrView.h"
#import "OSSVDetaillHtmlArrView.h"
#import "OSSVDetailsBaseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface OSSVDetailActivityCell : OSSVDetailBaseCell

/** 满减活动*/
@property (nonatomic, strong) OSSVDetaillHtmlArrView            *activityView;
@property (nonatomic, strong) OSSVDetailsBaseInfoModel    *infoModel;

- (void)updateHeaderGoodsSelect:(OSSVDetailsBaseInfoModel *)goodsInforModel;

@end

NS_ASSUME_NONNULL_END
