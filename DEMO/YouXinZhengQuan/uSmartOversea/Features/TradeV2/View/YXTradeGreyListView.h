//
//  YXTradeGreyListView.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXV2Quote;

NS_ASSUME_NONNULL_BEGIN

@interface YXTradeGreyShapeView: UIView




@end


@interface YXTradeGreyListHeaderView : UIView

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, copy) void (^clickCallBack)(void);

@end


@interface YXTradeGreyListView : UIView

@property (nonatomic, strong) NSArray *arr;

@property (nonatomic, copy) void (^selectStockCallBack)(YXV2Quote *quote);

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
