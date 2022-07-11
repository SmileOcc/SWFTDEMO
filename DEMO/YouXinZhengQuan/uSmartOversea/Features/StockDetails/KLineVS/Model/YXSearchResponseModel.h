//
//  YXSearchResponseModel.h
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/12/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXResponseModel.h"

NS_ASSUME_NONNULL_BEGIN
@class YXSecu;
@interface YXSearchResponseModel : YXResponseModel
@property (nonatomic, strong) NSArray<YXSecu *> *list;
@end

NS_ASSUME_NONNULL_END
