//
//  ZFNewUserSecckillModel.h
//  ZZZZZ
//
//  Created by mac on 2019/1/10.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFNewUserSecckillModel : NSObject

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) NSString *specialName;

@end


@interface ZFNewUserSecckillListModel : NSObject

@property (nonatomic, assign) double status;
@property (nonatomic, assign) double endTime;
@property (nonatomic, strong) NSString *sekillStartDesc;
@property (nonatomic, assign) double startTime;
@property (nonatomic, assign) double serviceTime;
@property (nonatomic, strong) NSString *sekillStartTime;
@property (nonatomic, strong) NSArray *goodsList;

@end


@interface ZFNewUserSecckillGoodsListModel : NSObject

@property (nonatomic, strong) NSString *lang;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *marketPrice;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *isShow;
@property (nonatomic, strong) NSString *goodsGrid;
@property (nonatomic, strong) NSString *positionId;
@property (nonatomic, strong) NSString *goodsImg;
@property (nonatomic, strong) NSString *buynumber;
@property (nonatomic, strong) NSString *goodsListIdentifier;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, assign) double leftPercent;
@property (nonatomic, strong) NSString *goodsTitle;
@property (nonatomic, strong) NSString *addTime;
@property (nonatomic, assign) double left;
@property (nonatomic, strong) NSString *urlTitle;
@property (nonatomic, strong) NSString *goodsNumber;
@property (nonatomic, strong) NSString *goodsId;
@property (nonatomic, assign) double seckillStatus;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *goodsLeftDesc;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, assign) double zhekou;
@property (nonatomic, strong) NSString *activityIcon;
@property (nonatomic, strong) NSString *goodsSn;
@property (nonatomic, strong) NSString *goodsThumb;

@end

NS_ASSUME_NONNULL_END
