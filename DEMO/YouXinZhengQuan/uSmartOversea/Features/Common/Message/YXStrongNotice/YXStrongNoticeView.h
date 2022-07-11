//
//  YXStrongNoticeView.h
//  uSmartOversea
//
//  Created by ellison on 2018/12/5.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VoidBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@class YXNoticeModel;
@class YXMessageCenterService;
typedef NS_ENUM(NSUInteger, YXStrongNoticeType){
    YXStrongNoticeTypeNone        =   0,
    YXStrongNoticeTypeNormal      =   1,
    YXStrongNoticeTypeNetWork     =   2,
    YXStrongNoticeTypeNotice      =   3,
    YXStrongNoticeTypeCustom      =   4,
};

@interface YXStrongNoticeView : UIView

- (instancetype)initWithFrame:(CGRect)frame services:(YXMessageCenterService *)services;

@property (nonatomic, strong) NSArray<YXNoticeModel *> *dataSource;
@property (nonatomic, assign) YXStrongNoticeType noticeType;

@property (nonatomic, assign) BOOL needShowNotice;
@property (nonatomic, assign) BOOL isCurrencyExchange;
@property (nonatomic, strong, readonly) YXMessageCenterService *services;

@property (nonatomic, nullable, copy) void(^didClosed)(void);

@property (nonatomic, copy) VoidBlock selectedBlock;

@property (nonatomic, copy) void (^bmpCloseCallBack)(void);

@property (nonatomic, copy) void (^tempCodeCloseCallBack)(void);
@property (nonatomic, copy) void (^tempCodeJumpCallBack)(void);
@property (nonatomic, copy) void (^quoteLevelChangeBlock)(void);
@end

NS_ASSUME_NONNULL_END
