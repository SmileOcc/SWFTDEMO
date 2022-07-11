//
//  OSSVCheckOutGoodsAlterView.h
// XStarlinkProject
//
//  Created by odd on 2021/1/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAccounteMyOrderseDetailModel.h"

#import "OSSVCartWareHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CheckOutEvent) {
    CheckOutEventHome = 0,
    CheckOutEventPay,
    CheckOutEventProducts,
    CheckOutEventAddress,
};

@interface OSSVCheckOutGoodsAlterView : UIView

@property (nonatomic, strong) UIView     *contentView;
@property (nonatomic, strong) UIButton   *closeButton;
@property (nonatomic, strong) UILabel    *titleLabel;
@property (nonatomic, strong) UILabel    *messageLabel;

@property (nonatomic, strong) UITableView *goodsTableView;
@property (nonatomic, strong) UIView      *bottomView;
@property (nonatomic, strong) UIButton    *backOrPayButton;
@property (nonatomic, strong) UIButton    *addressButton;

@property (nonatomic, strong) NSMutableArray<OSSVCartGoodsModel *> *cartGoddsArray;
@property (nonatomic, strong) AddressGoodsShieldInfoModel *shielInfoModel;

@property (nonatomic, strong) RateModel             *rateModel;
@property (nonatomic, assign) BOOL                  hasCanShip;
@property (nonatomic, copy) NSAttributedString *attributeMessage;
@property (nonatomic, copy) NSString *message;
///仅展示列表
@property (nonatomic, assign) BOOL                  justList;

@property (nonatomic, assign) CGFloat    contentHeight;

@property (nonatomic, copy) void (^cancelViewBlock)();

@property (nonatomic, copy) void (^checkTipEventBlock)(CheckOutEvent event);

@property (nonatomic, copy) void (^completion)(NSAttributedString *stringAttributed, CGSize calculateSize);
@property (nonatomic, strong) UIButton                        *tipButton;
@property (nonatomic,copy) NSAttributedString *tipMessage;

+ (void)fetchSizeShieldTipHeight:(NSMutableArray<OSSVCartGoodsModel *> *)cartGoodsArray message:(NSString *)string completion:(void (^)(NSAttributedString *stringAttributed, CGSize calculateSize))completion;


-(void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
