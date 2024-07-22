//
//  AlertWebView.h
//  ZZZZZ
//
//  Created by DBP on 17/3/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertWebView : UIView
- (instancetype)initWithUrlStr:(NSString *)urlStr;
- (void)show;
- (void)dismiss;
@end
