//
//  YXActivityDetailModel.h
//  YouXinZhengQuan
//
//  Created by 井超 on 2019/12/31.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXBannerActivityDetailModel : YXModel
@property (nonatomic, assign) NSInteger adPos;

@property (nonatomic, copy) NSString *adType;
@property (nonatomic, assign) long long bannerId;

@property (nonatomic, copy) NSString *bannerTitle;
@property (nonatomic, copy) NSString *effectiveTime;
@property (nonatomic, copy) NSString *jumpUrl;
@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, assign) NSInteger newsJumpType;
@property (nonatomic, copy) NSString * pictureUrl;
@property (nonatomic, copy) NSString * tag;

@end

NS_ASSUME_NONNULL_END
