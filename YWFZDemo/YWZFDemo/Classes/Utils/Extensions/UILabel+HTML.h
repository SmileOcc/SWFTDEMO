//
//  UILabel+HTML.h
//  ZZZZZ
//
//  Created by YW on 2017/9/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (HTML)

- (void)zf_setHTMLFromString:(NSString *)string;

- (void)zf_setHTMLFromString:(NSString *)string textColor:(NSString *)textColor;

- (void)zf_setHTMLFromString:(NSString *)string completion: (void (^)(NSAttributedString *stringAttributed))completion;
@end
