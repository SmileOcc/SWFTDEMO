//
//  ZFOutfitRefineHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ZFOutfitRefineSectionModel.h"
#import "CategoryRefineDetailModel.h"


typedef void(^OutfitRefineHeaderSelectBlock)(CategoryRefineDetailModel *model);

@interface ZFOutfitRefineHeaderView : UITableViewHeaderFooterView

@property (nonatomic, copy) OutfitRefineHeaderSelectBlock  selectBlock;

@property (nonatomic, strong) CategoryRefineDetailModel   *categoryRefineModel;

@end

