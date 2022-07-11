//
//  STLCatrActivityModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ActivityInfoModel;

@interface STLCatrActivityModel : NSObject

/**活动商品列表*/
@property (nonatomic, strong) NSArray <CartModel*>             *goodsList;
/**活动信息*/
@property (nonatomic, strong) ActivityInfoModel                *activityInfo;


@end


@interface   ActivityInfoModel : NSObject

/**节省金额*/
@property (nonatomic, copy) NSString      *totalDiscount;
/**活动提示信息*/
@property (nonatomic, copy) NSString      *cartTips;
/**活动跳转*/
@property (nonatomic, copy) NSString      *specialUrl;

/**专题id*/
@property (nonatomic, copy) NSString      *activeId;
@property (nonatomic, copy) NSString      *activeName;
@property (nonatomic, assign) NSInteger   is_full_active;
@property (nonatomic, assign) CGFloat     headerHeight;

- (void)compareHeaderHeight;
+ (CGFloat)saleSizeWidth;
+ (NSMutableAttributedString *)activityTitle:(NSString *)title;


@end
