//
//  ZFCommunityLiveDataModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityLiveListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveDataModel : NSObject

@property (nonatomic, strong) NSArray <ZFCommunityLiveListModel *> *live_list;
@property (nonatomic, strong) NSArray <ZFCommunityLiveListModel *> *end_live_list;
@property (nonatomic, copy) NSString *end_live_total;

@end

NS_ASSUME_NONNULL_END
