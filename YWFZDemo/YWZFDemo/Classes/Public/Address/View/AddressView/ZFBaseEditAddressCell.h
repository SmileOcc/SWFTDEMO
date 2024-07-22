//
//  ZFBaseEditAddressCell.h
//  ZZZZZ
//
//  Created by YW on 2018/9/6.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAddressEditTypeModel.h"
#import "ZFAddressInfoModel.h"

@class ZFBaseEditAddressCell;

@protocol ZFBaseEditAddressCellDelegate <NSObject>

///实时输入内容
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell editContent:(NSString *)content;
///输入时错误提示
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell showTips:(BOOL)showTips overMax:(BOOL)overMax content:(NSString *)content;
///输入时最大错误提示临界
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell cancelMaxContent:(NSString *)content;
///是否编辑
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell isEditing:(BOOL)isEditing;
///选择事件
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell selectEvent:(BOOL)flag;
///第一次点击
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell selectFirstTips:(BOOL)flag;
///电话选择
- (void)editAddressCell:(ZFBaseEditAddressCell *)cell showTips:(BOOL)showTips content:(NSString *)content resultTell:(NSString *)resultTel;

- (void)editAddressCell:(ZFBaseEditAddressCell *)cell showBottomPlaceholderTip:(BOOL)show;

@end

@interface ZFBaseEditAddressCell : UITableViewCell

@property (nonatomic, weak) id<ZFBaseEditAddressCellDelegate>    myDelegate;
@property (nonatomic, strong) ZFAddressInfoModel                 *infoModel;
@property (nonatomic, strong) ZFAddressEditTypeModel             *typeModel;
@property (nonatomic, strong) UIView                             *lineView;

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel;
- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel hasUpperLevel:(BOOL)hasUpperLevel;
- (void)updateContentText:(NSString *)text;

#pragma mark Event

- (void)baseEditContent:(NSString *)content;
- (void)baseShowTips:(BOOL)showTips overMax:(BOOL)overMax content:(NSString *)content;
- (void)baseShowTips:(BOOL)showTips content:(NSString *)content resultTell:(NSString *)resultTel;
- (void)baseIsEditEvent:(BOOL)isEdit;
- (void)baseCancelContent:(NSString *)content;
- (void)baseSelectEvent:(BOOL)flag;
- (void)baseSelectFirstTips:(BOOL)flag;
- (void)baseShowPlaceholderTips:(BOOL)showTips;

@end
