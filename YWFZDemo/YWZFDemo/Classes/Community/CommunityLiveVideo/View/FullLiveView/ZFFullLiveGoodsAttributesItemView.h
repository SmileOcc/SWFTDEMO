//
//  ZFFullLiveGoodsAttributesItemView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFLiveGoodsAttributeView.h"
#import "ZFGoodsModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveGoodsAttributesItemView : UIView

@property (nonatomic, strong) ZFLiveGoodsAttributeView *attributeView;

@property (nonatomic, strong) ZFGoodsModel *goodsModel;
@property (nonatomic, copy) NSString       *liveId;
@property (nonatomic, copy) NSString       *currentGuideSizeUrl;
@property (nonatomic, copy) NSString       *currentGoodsId;

@property (nonatomic, copy) NSString       *recommendGoodsId;



@property (nonatomic, copy) void (^selectBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^similarGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^goCartBlock)(void);

@property (nonatomic, copy) void (^guideSizeBlock)(NSString *guideUrl);

@property (nonatomic, copy) void (^commentBlock)(GoodsDetailModel *model);



- (void)zfWillViewAppear;
@end

NS_ASSUME_NONNULL_END
