//
//  ZFSelectSizeColorHeader.h
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFSelectSizeColorHeader : UICollectionReusableView
@property (nonatomic, copy) NSString        *title;

- (void)updateTopSpace:(CGFloat)space;
@end
