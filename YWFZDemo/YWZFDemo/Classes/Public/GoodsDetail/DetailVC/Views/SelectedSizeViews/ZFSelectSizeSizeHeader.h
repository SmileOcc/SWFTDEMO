//
//  ZFSelectSizeSizeHeader.h
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SizeSelectGuideJumpCompletionHandler)(NSString *);

@interface ZFSelectSizeSizeHeader : UICollectionReusableView

@property (nonatomic, copy) NSString    *title;

@property (nonatomic, copy) NSString    *size_url;

@property (nonatomic, copy) SizeSelectGuideJumpCompletionHandler        sizeSelectGuideJumpCompletionHandler;

- (void)updateTopSpace:(CGFloat)space;

- (void)showSizeGuide:(BOOL)show;

@end
