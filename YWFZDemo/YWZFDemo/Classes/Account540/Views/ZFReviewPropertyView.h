//
//  ZFReviewPropertyView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger) {
    ZFReviewPropertyType_Height,
    ZFReviewPropertyType_Waist,
    ZFReviewPropertyType_Hips,
    ZFReviewPropertyType_BustSize
}ZFReviewPropertyType;

@class ZFOrderSizeModel;
@class ZFReviewPropertyView;

@interface ZFReviewPropertyView : UIView

@property (nonatomic, copy) void(^selectedPropertyHandler)(ZFReviewPropertyView *headerView, ZFReviewPropertyType type);

///设置默认值
- (BOOL)setDefaultValue:(NSArray<NSArray <ZFOrderSizeModel *> *> *)defaultValue;

///获取title
- (NSString *)gainTitleWithType:(ZFReviewPropertyType)type;

- (NSDictionary *)selectBodySize;

- (void)setContent:(NSString *)content sizeId:(NSString *)sizeId withType:(ZFReviewPropertyType)type;

- (void)reloadSelectItemStatus:(ZFReviewPropertyType)type;

- (void)configurateExtrePoint:(NSAttributedString *)attr;

@end
