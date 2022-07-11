//
//  YXAuthorityReminderTool.h
//  uSmartOversea
//
//  Created by youxin on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LoginStatusChangeBlock)(void);

typedef NS_ENUM(NSUInteger, YXAuthorityReminderPosition) {
    YXAuthorityReminderPositionViewBottom,
    YXAuthorityReminderPositionTableViewFooter
};

NS_ASSUME_NONNULL_BEGIN

@protocol YXAuthorityReminderToolDelegate <NSObject>

@optional
- (UIView *)reminderLabelSuperView;

@optional
- (UITableView *)needLayoutTableView;


@end

@protocol YXAuthorityReminderToolGroupingDelegate <NSObject>

@required
- (NSString *)getMarketType;
- (NSString *)getSymbol;

@end

@interface YXAuthorityReminderTool : NSObject

@property (nonatomic, weak) id <YXAuthorityReminderToolDelegate> delegate;
@property (nonatomic, strong) NSString *market;
@property (nonatomic, strong) NSString *rankCode;
@property (nonatomic, assign) YXAuthorityReminderPosition position;

//+ (QMUILabel *)reminderLabelWithAuthority:(YXQuoteAuthority)authority;

- (BOOL)isHKDelay;
- (BOOL)isUSDelay;
- (BOOL)isHKBMP;
- (BOOL)isHKLevel1;
- (BOOL)isHKLevel2;
- (BOOL)isUSLevel1;
//- (BOOL)isShowReminderDelayText;
//- (BOOL)isShowReminderBMPText;

- (void)showReminderDelayText;

- (void)showReminderBMPText;

- (void)showReminderText:(NSString *)text;

- (void)removeReminderText;

- (void)addLoginOutObserverWithOperationBlock:(LoginStatusChangeBlock)block;

- (void)removeLoginOutObserver;

- (NSDictionary *)groupingWithArray:(NSArray<YXAuthorityReminderToolGroupingDelegate> *)array;
//- (NSArray *)getBMPsWithArray:(NSArray<YXAuthorityReminderToolGroupingDelegate> *)array;
//- (NSArray *)getDelaysWithArray:(NSArray<YXAuthorityReminderToolGroupingDelegate> *)array;
//- (NSArray *)getLevel1sWithArray:(NSArray<YXAuthorityReminderToolGroupingDelegate> *)array;
//- (NSArray *)getLevel2sWithArray:(NSArray<YXAuthorityReminderToolGroupingDelegate> *)array;

// 设置内容的对齐
@property (nonatomic, assign) NSTextAlignment alignment;

@end

NS_ASSUME_NONNULL_END
