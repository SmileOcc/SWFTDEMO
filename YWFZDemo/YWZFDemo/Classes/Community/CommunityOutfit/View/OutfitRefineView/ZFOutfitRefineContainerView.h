//
//  ZFOutfitRefineContainerView.h
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOutfitSelectedRefineView.h"


typedef void(^ZFOutfitRefineHideBlock)(void);

typedef void(^ZFOutfitRefineApplyBlock)(NSDictionary *parms);

typedef void(^ZFOutfitRefineSelectBlock)(BOOL selelct);

typedef void(^ZFOutfitRefineCloseBlock)(BOOL close);


@interface ZFOutfitRefineContainerView : UIView

@property (nonatomic, copy) ZFOutfitRefineHideBlock                     hideBlock;
@property (nonatomic, copy) ZFOutfitRefineSelectBlock                   selectBlock;
@property (nonatomic, copy) ZFOutfitRefineApplyBlock                    applyBlock;
@property (nonatomic, copy) ZFOutfitRefineCloseBlock                    closeBlock;
@property (nonatomic, strong) CategoryRefineSectionModel                *model;


- (void)showViewAnimation:(BOOL)animation;

- (void)hideViewAnimation:(BOOL)animation;

- (void)clearData;

@end
