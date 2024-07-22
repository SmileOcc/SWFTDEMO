//
//  ZFCommunityRedDotModel.h
//  ZZZZZ
//
//  Created by YW on 2018/8/14.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityRedDotViewModel : BaseViewModel

- (void)requestCommunityNewMessageCompletion:(void (^)(BOOL isNewMessage))completion;
@end
