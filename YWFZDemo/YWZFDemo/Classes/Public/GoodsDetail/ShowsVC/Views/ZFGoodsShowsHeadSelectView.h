//
//  ZFGoodsShowsHeadSelectView.h
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectViewHeight    (44.0)

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZFGoodsShowsHeadSelectType) {
    ZFGoodsShowsHeadSelectType_Shows,
    ZFGoodsShowsHeadSelectType_RelatedItems,
};
typedef void(^ShowsHeadSelectCompletionHandler)(ZFGoodsShowsHeadSelectType type);

@interface ZFGoodsShowsHeadSelectView : UICollectionReusableView

@property (nonatomic, copy) ShowsHeadSelectCompletionHandler selectCompletionHandler;

@property (nonatomic, assign) ZFGoodsShowsHeadSelectType currentType;

@end

NS_ASSUME_NONNULL_END
