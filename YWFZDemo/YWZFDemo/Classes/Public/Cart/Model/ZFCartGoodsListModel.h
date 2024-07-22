//
//  ZFCartGoodsListModel.h
//  ZZZZZ
//
//  Created by YW on 2017/9/16.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZFCartGoodsModel;

@interface ZFCartGoodsListModel : NSObject
@property (nonatomic, copy) NSString                        *url;
@property (nonatomic, copy) NSString                        *msg;
@property (nonatomic, copy) NSString                        *goodsModuleType;
@property (nonatomic, strong) NSMutableArray<ZFCartGoodsModel *>   *cartList;
@property (nonatomic, copy) NSString                        *reduc_id; //活动ID
@property (nonatomic, copy) NSString                        *activity_type; //活动类型
@property (nonatomic, copy) NSString                        *activity_title; //活动标题

@property (nonatomic, copy) NSString                        *diff_msg;   //赠品提示文案(非赠品为空)
@property (nonatomic, copy) NSString                        *diff_amount;//赠品还差金额(非赠品为空)

@property (nonatomic, strong) NSAttributedString             *freeGiftHeaderAttrText;

@property (nonatomic, copy) NSString                         *currency;            //判断需要替换价格的货币符号

@property (nonatomic, assign) NSInteger             is_up_round; //1表示向上取整，不返回或者为0就保持原来的取整逻辑
/** ⚠️警告: 以下两个字典因为key名不固定,因此不做模型对象 */
@property (nonatomic, strong) NSDictionary                   *org_price_list;      //特定价格
@property (nonatomic, strong) NSDictionary                   *price_list;          //美元价格

@property (nonatomic, strong) NSAttributedString             *headerHtmlAttr;

- (NSAttributedString *)configHeaderHtmlAttr:(NSString *)fontName
                                    fontSize:(CGFloat)fontSize;

@end
