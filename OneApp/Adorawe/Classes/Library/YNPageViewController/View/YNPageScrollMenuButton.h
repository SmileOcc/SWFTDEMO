//
//  YNPageScrollMenuButton.h
// XStarlinkProject
//
//  Created by mac on 2019/1/7.
//  Copyright © 2019年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    /** 默认 */
    YNPageScrollMenuButtonTypeNor = 0,
    /** 双标题 */
    YNPageScrollMenuButtonTypeSubTitle = 1,
} YNPageScrollMenuButtonType;

@interface YNPageScrollMenuButton : UIButton

/** 副标题 */
@property (nonatomic, strong) UILabel *subTitle;
/** 图片和文字比例 */
@property(nonatomic, assign) float size;
/** 按键样式 */
@property (nonatomic, assign) YNPageScrollMenuButtonType btnType;

@end

NS_ASSUME_NONNULL_END
