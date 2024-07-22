//
//  ZFCommunityHomeCMSViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/6/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityHomeCMSViewModel : ZFCMSBaseViewModel

@property (nonatomic, strong) ZFBTSModel *cmsBtsModel;
@property (nonatomic, copy) NSString     *menu_id;
@property (nonatomic, copy) NSString     *menu_name;

/**
 * 请求社区首页对应的列表广告接口
 */
- (void)requestCMSListDataCompletion:(void (^)(NSArray<ZFCMSSectionModel *> *, BOOL ))completion;

@end

NS_ASSUME_NONNULL_END
