//
//  ZFSubmitReviewWriteFooterView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderReviewModel.h"

typedef void(^ZFSubmitReviewSubmitCompletionHandler)(void);
typedef void(^ZFSubmitReviewChoosePhotosCompletionHandler)(void);
typedef void(^ZFSubmitReviewDeletePhotoCompletionHandler)(NSInteger index);
typedef void(^ZFSubmitReviewSyncCommunityCompletionHandler)(BOOL isSync);


@interface ZFSubmitReviewWriteFooterView : UITableViewHeaderFooterView

@property (nonatomic, assign) BOOL                      syncCommunity;
@property (nonatomic, strong) NSMutableArray            *photosArray;

@property (nonatomic, copy) ZFSubmitReviewSubmitCompletionHandler           submitReviewSubmitCompletionHandler;
@property (nonatomic, copy) ZFSubmitReviewChoosePhotosCompletionHandler     submitReviewChoosePhotosCompletionHandler;
@property (nonatomic, copy) ZFSubmitReviewDeletePhotoCompletionHandler      submitReviewDeletePhotoCompletionHandler;
@property (nonatomic, copy) ZFSubmitReviewSyncCommunityCompletionHandler    submitReviewSyncCommunityCompletionHandler;
@end
