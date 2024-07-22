//
//  ZFOutfitSelectedRefineView.h
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ZFOutfitRefineSectionModel.h"
#import "CategoryRefineSectionModel.h"
#import "CategoryRefineDetailModel.h"
#import "CategoryRefineCellModel.h"

typedef void(^OutfitSelectedApplyBlock)(NSDictionary *parms);

typedef void(^OutfitSelectedRefineSelectBlock)(BOOL select);

typedef void(^OutfitSelectedCloseBlock)(BOOL close);

@interface ZFOutfitSelectedRefineView : UIView

//@property (nonatomic, strong) ZFOutfitRefineSectionModel          *model;

@property (nonatomic, strong) CategoryRefineSectionModel          *categroyRefineModel;

@property (nonatomic, copy) OutfitSelectedApplyBlock              applyBlock;

@property (nonatomic, copy) OutfitSelectedRefineSelectBlock       selectBlock;

@property (nonatomic, copy) OutfitSelectedCloseBlock              closeBlock;


- (void)clearRequestParmaters;

@end

