//
//  ZFGoodsKeyWordsHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/6/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 商品列表、搜索结果列表关键字头部
 */
@interface ZFGoodsKeyWordsHeaderView : UIView

@property (nonatomic, strong) NSArray *kerwordArray;
@property (nonatomic, copy) void(^selectedKeywordHandle)(NSString *keyword);

- (void)reset;

@end
