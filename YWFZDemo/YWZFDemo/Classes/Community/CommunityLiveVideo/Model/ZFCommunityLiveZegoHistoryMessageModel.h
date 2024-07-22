//
//  ZFCommunityLiveZegoHistoryMessageModel.h
//  ZZZZZ
//
//  Created by YW on 2019/8/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "SYBaseRequest.h"
#import "ZFZegoMessageInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveZegoHistoryMessageModel : SYBaseRequest

@property (nonatomic, copy) NSString *like_num;
@property (nonatomic, copy) NSString *total;
@property (nonatomic, strong) NSArray<ZFZegoMessageInfo *> *list;


@end

NS_ASSUME_NONNULL_END
