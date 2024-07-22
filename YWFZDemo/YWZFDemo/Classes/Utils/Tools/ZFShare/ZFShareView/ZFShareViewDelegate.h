//
//  ZFShareViewDelegate.h
//  HyPopMenuView
//
//  Created by YW on 6/8/17.
//  Copyright © 2017年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFShareView, ZFShareButton;

@protocol ZFShareViewDelegate <NSObject>

- (void)zfShsreView:(ZFShareView*)shareView didSelectItemAtIndex:(NSUInteger)index;

@optional
- (void)zfDidTapBgDismissShareView;

@end
