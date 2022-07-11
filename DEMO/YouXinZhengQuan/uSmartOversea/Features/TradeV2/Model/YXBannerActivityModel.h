//
//  YXBannerActivityModel.h
//  YouXinZhengQuan
//
//  Created by 井超 on 2019/12/30.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXModel.h"
#import "YXBannerActivityDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXBannerActivityModel : YXModel

@property (nonatomic, strong) NSArray <YXBannerActivityDetailModel *>*bannerList;


@end

NS_ASSUME_NONNULL_END
