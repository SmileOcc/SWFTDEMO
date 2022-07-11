//
//  OSSVDetailBaseCell.h
// XStarlinkProject
//
//  Created by odd on 2020/10/28.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVDetailBaseCell;

typedef NS_ENUM(NSInteger, HeaderGoodsSelectEvent) {
    /** 满减活动*/
    HeaderGoodsSelectEventActivity = 0,
    /** 满减活动*/
    HeaderGoodsSelectEventActivityTip,
    /** 商品尺寸*/
    HeaderGoodsSelectEventChart,
    /** 商品描述*/
    HeaderGoodsSelectEventDescription,
};

NS_ASSUME_NONNULL_BEGIN

@protocol OSSVDetailBaseCellDelegate <NSObject>

@optional

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell reiveMore:(BOOL)flag;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell activityFlash:(NSString *)flashChannelId;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell activityBuyFree:(OSSVBundleActivityModel *)activityModel;

- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell titleShowAll:(BOOL )showAll;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell coinsTip:(BOOL)flag;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell shipTip:(BOOL)flag;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell serviceTip:(BOOL)flag;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell sizeChat:(OSSVSpecsModel *)sizeModel;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell description:(NSString *)url;
- (void)OSSVDetialCell:(OSSVDetailBaseCell *)cell adv:(OSSVAdvsEventsModel *)advModel;


@end

@interface OSSVDetailBaseCell : UICollectionViewCell

@property (nonatomic, weak) id<OSSVDetailBaseCellDelegate> stlDelegate;

@property (nonatomic, strong) UIView    *bgView;

@property (nonatomic,strong) UILabel *isNewLbl;
@end

NS_ASSUME_NONNULL_END
