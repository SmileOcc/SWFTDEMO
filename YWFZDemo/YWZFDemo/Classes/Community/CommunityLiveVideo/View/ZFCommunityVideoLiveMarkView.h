//
//  ZFCommunityVideoLiveMarkView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/3.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ZFCommunityVideoLiveMarkView : UIView

- (instancetype)initWithFrame:(CGRect)frame markImage:(UIImage *)markImage dotColor:(UIColor *)dotColor textColor:(UIColor *)textColor addCorners:(UIRectCorner)corners;

/**
 

 @param markImage 
 @param text : NSString or NSAttributedString
 */
- (void)updateMarkImage:(UIImage *)markImage text:(id)text;

@end

