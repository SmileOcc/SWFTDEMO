//
//  ZFBottomToolView.h
//  Zaful
//
//  Created by liuxi on 2017/8/29.
//  Copyright © 2017年 Y001. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddAddressCompletionHandler)(void);

@interface ZFBottomToolView : UIView
@property (nonatomic, strong) NSString                  *bottomTitle;
@property (nonatomic, copy) AddAddressCompletionHandler bottomButtonBlock;
@end
