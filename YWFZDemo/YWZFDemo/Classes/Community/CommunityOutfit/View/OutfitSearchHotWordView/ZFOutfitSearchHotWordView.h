//
//  ZFOutfitSearchHotWordView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  社区搭配搜索热词

#import <UIKit/UIKit.h>

@protocol ZFOutfitSearchHotWordViewDelegate <NSObject>

- (void)ZFOutfitSearchHotWordViewDidClickHotWord:(NSString *)word;

@end

@interface ZFOutfitSearchHotWordView : UIView

@property (nonatomic, weak) id<ZFOutfitSearchHotWordViewDelegate>delegate;

- (void)showHotWordView:(UIView *)superView offsetY:(CGFloat)offsetY contentOffsetY:(CGFloat)contentOffsetY;

- (void)hiddenHotWordView;

- (void)reloadHotWord:(NSArray *)wordList key:(NSString *)key;

@end
