//
//  ZFWriteReviewScrollView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFReviewPropertyView.h"

@class ZFOrderReviewModel, ZFWaitCommentModel;

typedef enum : NSUInteger {
    ZFWriteReviewAction_TrueSizeType = 2019,
    ZFWriteReviewAction_SmallType,
    ZFWriteReviewAction_LargeType,
    ZFWriteReviewAction_AddImageType,
    ZFWriteReviewAction_UploadZmeType,
    ZFWriteReviewAction_ShowInfoType,
    ZFWriteReviewAction_SubmitType,
    ZFWriteReviewAction_InputReviewType,
    ZFWriteReviewAction_ChooseRatingType
} ZFWriteReviewActionType;

@interface ZFWriteReviewScrollView : UIScrollView

@property (nonatomic, copy) void(^reviewBtnActionBlock)(ZFWriteReviewActionType, id );

@property (nonatomic, copy) void(^selectedPropertyHandler)(ZFReviewPropertyView *headerView, ZFReviewPropertyType type);

@property (nonatomic, copy) void(^deleteImageActionBlock)(NSInteger index);

@property (nonatomic, copy) void(^showAddImageActionBlock)(NSInteger index, NSArray *rectArray);

@property (nonatomic, strong) NSArray *photosArray;

@property (nonatomic, strong) ZFOrderReviewModel *reviewModel;

@property (nonatomic, strong) ZFWaitCommentModel *commentModel;

- (void)setDefaultSizeModeValue:(NSArray *)defaultSizeModelArray;

- (NSDictionary *)selectedBodySize;

@end
