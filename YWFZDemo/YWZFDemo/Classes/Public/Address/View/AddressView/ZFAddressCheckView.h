//
//  ZFAddressCheckView.h
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCheckShippingAddressModel.h"

@interface ZFAddressCheckView : UIView

@property (nonatomic, copy) void (^saveBlock)(ZFCheckShippingAddressModel *checkModel);
@property (nonatomic, copy) void (^editBlock)(ZFCheckShippingAddressModel *checkModel);
- (void)showView:(ZFCheckShippingAddressModel *)addressCheckModel;
- (void)hideView;
@end



typedef NS_ENUM(NSInteger, ZFAddressCheckEvent) {
    ZFAddressCheckEventSelected,
    ZFAddressCheckEventEdit
};

@interface ZFAddressCheckCell : UITableViewCell

@property (nonatomic, strong) UIButton        *markButton;
@property (nonatomic, strong) UILabel         *titleLabel;
@property (nonatomic, strong) UILabel         *contentLabel;
@property (nonatomic, strong) UIButton        *editButton;
@property (nonatomic, strong) UIView          *bottomLineView;

@property (nonatomic, copy) void (^operateBlock)(ZFAddressCheckEvent event);

- (void)isMark:(BOOL)mark;
- (void)isEdit:(BOOL)edit;
@end

