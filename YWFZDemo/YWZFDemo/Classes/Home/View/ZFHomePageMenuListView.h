//
//  ZFHomePageMenuListView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZFSkinModel;

@interface ZFHomePageMenuListView : NSObject

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) void(^selectedMenuIndex)(NSInteger index);


- (instancetype)initWithMenuTitles:(NSArray *)menuTitles selectedIndex:(NSInteger)selectedIndex;
- (void)showWithOffsetY:(CGFloat)offsetY;
- (void)hidden;

- (void)refreshMenuColor:(ZFSkinModel *)appHomeSkinModel
              resetColor:(BOOL)needConvertColor;

@end
