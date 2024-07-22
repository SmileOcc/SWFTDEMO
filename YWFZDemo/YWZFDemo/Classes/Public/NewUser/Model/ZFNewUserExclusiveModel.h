//
//  ZFNewUserExclusiveModel.h
//  ZZZZZ
//
//  Created by mac on 2019/1/8.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFNewUserExclusiveModel : NSObject

@property (nonatomic, strong) NSString  *specialMemo;
@property (nonatomic, strong) NSArray   *list;
@property (nonatomic, strong) NSString  *specialName;
@property (nonatomic, strong) NSString  *specialKeyword;
@property (nonatomic, strong) NSString  *specialUrl;

@end


@interface ZFNewUserExclusiveListModel : NSObject

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSArray   *goodsList;

@end


@interface ZFNewUserExclusiveGoodsListModel : NSObject

@property (nonatomic, strong) NSString *nsSaleStartTime;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *marketPrice;
@property (nonatomic, strong) NSString *nsSaleEndTime;
@property (nonatomic, strong) NSString *goodsGrid;
@property (nonatomic, assign) double   discount;
@property (nonatomic, strong) NSString *catId;
@property (nonatomic, strong) NSString *positionName;
@property (nonatomic, strong) NSString *shopPrice;
@property (nonatomic, strong) NSString *positionId;
@property (nonatomic, strong) NSString *attrSize;
@property (nonatomic, strong) NSString *userPrice;
@property (nonatomic, strong) NSString *goodsImg;
@property (nonatomic, strong) NSString *activityIcon;
@property (nonatomic, strong) NSString *goodsTitle;
@property (nonatomic, strong) NSString *urlTitle;
@property (nonatomic, strong) NSString *goodsId;
@property (nonatomic, strong) NSString *attrColor;
@property (nonatomic, strong) NSString *goodsSn;
@property (nonatomic, strong) NSString *goodsThumb;

@end

NS_ASSUME_NONNULL_END
