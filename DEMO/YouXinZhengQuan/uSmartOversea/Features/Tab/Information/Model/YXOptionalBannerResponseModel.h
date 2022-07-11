//
//  YXOptionalBannerResponseModel.h
//  uSmartOversea
//
//  Created by youxin on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXOptionalBannerResponseModel : YXResponseModel
@property (nonatomic, strong) NSArray * bannerList;
@end

@interface Banner : NSObject

@property (nonatomic, assign) NSInteger adType;
@property (nonatomic, assign) NSInteger bannerID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString * adName;
@property (nonatomic, assign) NSInteger adPos;
@property (nonatomic, copy) NSString * jumpUrl;
@property (nonatomic, copy) NSString * newsId;
@property (nonatomic, assign) NSInteger newsJumpType;
@property (nonatomic, copy, nullable) NSString * pictureUrl;
@property (nonatomic, copy) NSString *tag;      //标签
@end

NS_ASSUME_NONNULL_END
