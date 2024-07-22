//
//  ZFAccountCategorySectionModel.h
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCollectionSectionProtocol.h"
#import "ZFCCellNormalViewModel.h"

@interface ZFAccountCategorySectionModel : NSObject
<
    ZFCollectionSectionProtocol
>

///是否开启从右到左布局 defaul is YES 开启
@property (nonatomic, assign) BOOL isEnableRightToLeft;

@end

//个人中心订单，优惠券，心愿单，积分
@interface ZFAccountCategoryModel : ZFCCellNormalViewModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *badgeNum;
@property (nonatomic, assign) SEL selector;
///统计name
@property (nonatomic, copy) NSString *analyticsMenuName;

@end

//个人中心选择cell
@interface ZFAccountDetailTextModel : ZFCCellNormalViewModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) BOOL hiddenLine;
///统计name
@property (nonatomic, copy) NSString *analyticsMenuName;

@end

//历史浏览记录
@class ZFCMSItemModel;
@interface ZFAccountRecentlyViewModel : ZFCCellNormalViewModel

@property (nonatomic, strong) NSMutableArray<ZFCMSItemModel *> *dataList;

@end

//推荐商品顶部Title
@interface ZFProductTitleCCellModel : ZFCCellNormalViewModel

@property (nonatomic, copy) NSString *title;

@end
