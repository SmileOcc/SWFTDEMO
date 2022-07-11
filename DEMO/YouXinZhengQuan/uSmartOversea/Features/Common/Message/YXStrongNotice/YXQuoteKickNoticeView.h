//
//  YXQuoteKickNoticeView.h
//  uSmartOversea
//
//  Created by youxin on 2021/1/21.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXStrongNoticeView.h"

NS_ASSUME_NONNULL_BEGIN

@class YXNoticeModel;
@interface YXQuoteKickNoticeView : UIView

@property (nonatomic, strong) NSArray<YXNoticeModel *> *dataSource;
@property (nonatomic, assign) YXStrongNoticeType noticeType;

@property (nonatomic, nullable, copy) void(^didClosed)(void);
@property (nonatomic, copy) void (^quoteLevelChangeBlock)(void);
@property (nonatomic, nullable, copy) void(^selectedBlock)(void);
@end

NS_ASSUME_NONNULL_END
