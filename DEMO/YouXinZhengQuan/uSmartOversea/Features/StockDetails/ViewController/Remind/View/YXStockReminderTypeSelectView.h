//
//  YXStockReminderTypeSelectView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXReminderModel.h"
@class YXTextField;


NS_ASSUME_NONNULL_BEGIN

@interface YXStockReminderInputView : UIView

@property (nonatomic, strong) YXTextField *textField;

@property (nonatomic, assign) YXReminderType type;

@end


@interface YXStockReminderTypeSelectView : UIView

//@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIButton *clickBtn;

@end

NS_ASSUME_NONNULL_END
