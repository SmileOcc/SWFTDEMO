//
//  ZFFullLiveGoodsAttributesListView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFLiveFullGoodsAttributePageScrollView.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveGoodsAttributesListView : UIView

- (instancetype)initWithFrame:(CGRect)frame contentHeight:(CGFloat)contentHeight;

@property (nonatomic, strong) ZFLiveFullGoodsAttributePageScrollView *pageScrollView;

@property (nonatomic, copy) NSString *liveVideoId;

@property (nonatomic, strong) NSArray<ZFGoodsModel*>               *goodsArray;
@property (nonatomic, copy) NSString *recommendGoodsId;



@property (nonatomic, copy) void (^cartBlock)(void);
@property (nonatomic, copy) void (^commentListBlock)(GoodsDetailModel *goodsDetailModel);
@property (nonatomic, copy) void (^attributeGuideSizeBlock)(NSString *sizeUrl);





@end

NS_ASSUME_NONNULL_END
