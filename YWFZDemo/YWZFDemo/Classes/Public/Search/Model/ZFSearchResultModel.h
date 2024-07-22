//
//  ZFSearchResultModel.h
//  ZZZZZ
//
//  Created by YW on 2017/12/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import "GoodsDetailModel.h"

@class ZFGoodsModel;
@interface ZFSearchResultModel : NSObject <YYModel>

@property (nonatomic, strong) NSMutableArray * goodsArray;
@property (nonatomic, strong) NSArray *guideWords;
@property (nonatomic, strong) NSArray *spellKeywords;
@property (nonatomic, assign) NSInteger result_num;
@property (nonatomic, assign) NSInteger total_page;
@property (nonatomic, assign) NSInteger cur_page;
@property (nonatomic, strong) AFparams  *af_params_color;
@property (nonatomic, strong) AFparams  *af_params_search;

@end
