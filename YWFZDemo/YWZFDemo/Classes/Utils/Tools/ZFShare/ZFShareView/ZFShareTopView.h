//
//  ZFShareTopView.h
//  HyPopMenuView
//
//  Created by YW on 7/8/17.
//  Copyright © 2017年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

//默认图类型
typedef NS_ENUM(NSInteger,ZFShareDefaultTipType) {
    /**普通分享*/
    ZFShareDefaultTipTypeCommon,
    /**社区个人中心分享标识*/
    ZFShareDefaultTipTypeCommunityAccount,
    /**社区分享标识*/
    ZFShareDefaultTipTypeCommunity,
};

@interface ZFShareTopView : UIView


- (void)updateImage:(NSString *)imageName
              title:(NSString *)title
            tipType:(ZFShareDefaultTipType)tipType;


@property (nonatomic, assign, readonly) ZFShareDefaultTipType  defaultType;
@property (nonatomic, copy, readonly) NSString                 *imageName;
@property (nonatomic, copy, readonly) NSString                 *title;

@end
