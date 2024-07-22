//
//  AccountFooterView.h
//  Dezzal
//
//  Created by 7FD75 on 16/7/28.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SignOutBlock) (void);

@interface AccountFooterView : UIView

@property (nonatomic, copy) SignOutBlock signOutBlock;

@end
