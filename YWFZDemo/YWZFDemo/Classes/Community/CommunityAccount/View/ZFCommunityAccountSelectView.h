//
//  ZFCommunityAccountSelectView.h
//  ZZZZZ
//
//  Created by YW on 2017/8/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectViewHeight    (44.0)

typedef NS_ENUM(NSInteger, ZFCommunityAccountSelectType) {
    ZFCommunityAccountSelectTypeShow = 0,
    ZFCommunityAccountSelectTypeFaves,
    /**当前枚举有效值的总个数*/
    ZFCommunityAccountSelectTypeAllCount
};
typedef void(^CommunityAccountSelectCompletionHandler)(ZFCommunityAccountSelectType type);

@interface ZFCommunityAccountSelectView : UICollectionReusableView

@property (nonatomic, assign) ZFCommunityAccountSelectType currentType;
@property (nonatomic, copy) CommunityAccountSelectCompletionHandler communityAccountSelectCompletionHandler;

/**阿语适配*/
+ (NSInteger)arCurrentType:(ZFCommunityAccountSelectType)type;
@end
