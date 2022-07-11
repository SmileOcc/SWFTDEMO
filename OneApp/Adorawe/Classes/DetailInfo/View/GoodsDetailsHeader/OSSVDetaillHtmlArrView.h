//
//  OSSVDetaillHtmlArrView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVDetaillHtmlArrView : UIButton

@property (nonatomic, copy) void(^activityBlock)(NSInteger index);
@property (nonatomic, copy) void(^activityTipBlock)(NSInteger index);

- (void)setHtmlTitle:(NSArray *)htmlTitles specialUrl:(NSString *)url contentWidth:(CGFloat)contentWidth;

+ (CGFloat)computeContentWidth:(NSArray *)contents;
@end
