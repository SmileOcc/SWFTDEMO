//
//  ZFSubmitReviewTableHeadView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  提交评论的表头

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    UserPropertyType_Height,
    UserPropertyType_Waist,
    UserPropertyType_Hips,
    UserPropertyType_BustSize
}UserPropertyType;

@class ZFOrderSizeModel;
@class ZFSubmitReviewTableHeadView;
typedef void(^didClickPropertyHandler)(ZFSubmitReviewTableHeadView *headerView, UserPropertyType type);

@interface ZFSubmitReviewTableHeadView : UIView

@property (nonatomic, copy) didClickPropertyHandler didClickPropertyHandler;

///设置默认值
- (void)setDefaultValue:(NSArray<NSArray <ZFOrderSizeModel *> *> *)defaultValue;

///获取title
- (NSString *)gainTitleWithType:(UserPropertyType)type;

- (NSDictionary *)selectBodySize;

- (void)setContent:(NSString *)content sizeId:(NSString *)sizeId withType:(UserPropertyType)type;

- (void)reloadSelectItemStatus:(UserPropertyType)type;

@end

NS_ASSUME_NONNULL_END
