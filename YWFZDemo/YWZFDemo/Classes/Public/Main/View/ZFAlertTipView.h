//
//  ZFAlertTipView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZFAlertTipCallBlock)(NSInteger buttonIndex, NSString *title);

@interface ZFAlertTipView : UIView

+ (instancetype)alertWithTopImage:(UIImage *)topImage
                    closeBtnImage:(UIImage *)closeBtnImage
                         alerTitle:(NSString *)alerTitle
                       alerMessage:(NSString *)alerMessage
                    otherBtnTitles:(NSArray *)otherBtnTitles
                otherBtnAttributes:(NSArray <NSDictionary<NSAttributedStringKey, id> *> *)otherBtnAttributes
                    alertCallBlock:(ZFAlertTipCallBlock)alertCallBlock;

@end
