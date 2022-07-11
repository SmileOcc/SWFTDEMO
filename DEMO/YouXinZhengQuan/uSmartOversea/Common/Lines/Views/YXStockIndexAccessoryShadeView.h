//
//  YXStockIndexAccessoryShadeView.h
//  YouXinZhengQuan
//
//  Created by lennon on 2021/8/31.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, AccessoryButtonType) {
    KICKBUTTON, //互提
    OPENACCOUNTBUTTON, //立即开户
    OPENACCOUNTVSBUTTON, //k先对比 立即开户
    QUOTESTATEMENTBUTTON, //行情声明
};

@interface YXStockIndexAccessoryShadeView : UIView
//-(void)setTitle:(NSString*)title isLandscape:(BOOL)isLandscape;
//
//-(void)setIsKick:(BOOL)isKick;

//设置毛玻璃背景，默认不设置
-(void)setLandscape:(BOOL)isLandscape;
-(void)setButtonType:(AccessoryButtonType)type;
@end

NS_ASSUME_NONNULL_END
