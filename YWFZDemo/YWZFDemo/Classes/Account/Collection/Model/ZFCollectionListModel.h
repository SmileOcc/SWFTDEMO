//
//  ZFCollectionListModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFGoodsModel;

@interface ZFCollectionListModel : NSObject
@property (nonatomic, copy) NSString   *total;         // 商品总数
@property (nonatomic, assign) NSInteger   total_page;    // 总页数
@property (nonatomic, assign) NSInteger   page;          // 当前页
@property (nonatomic, copy) NSString   *page_size;     // 增量个数
@property (nonatomic, assign) BOOL     is_show_popup;  // 是否弹框引导用户评论
@property (nonatomic, copy) NSString   *contact_us;    // 客服联系
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *>  *data;          //列表数据
@end
