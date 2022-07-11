//
//  YXVSSearchViewModel.h
//  YouXinZhengQuan
//
//  Created by youxin on 2021/2/5.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXSecu.h"
#import "YXRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXVSSearchViewModel : YXViewModel

@property (nonatomic, strong, nullable) YXRequest *searchRequest;

@property (nonatomic, strong) RACCommand *searchRequestCommand;

//是否是从个股详情页面弹出
@property (nonatomic, assign) BOOL isFromStockDetail;

@end

NS_ASSUME_NONNULL_END
