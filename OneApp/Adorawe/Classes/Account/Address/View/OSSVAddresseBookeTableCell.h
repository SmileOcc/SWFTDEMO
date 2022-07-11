//
//  OSSVAddresseBookeTableCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Adorawe-Swift.h"



@class OSSVAddresseBookeModel;
@class OSSVAddresseBookeTableCell;
@class AddressShowLabel;

typedef NS_ENUM(NSInteger,AddressBookEvent) {
    AddressBookEventDefault,
    AddressBookEventEdit,
    AddressBookEventDelete
};

@protocol AddressBookTableCellDelegate<NSObject>

- (void)yyAddressBookTableCell:(OSSVAddresseBookeTableCell *)addressCell addressEvent:(AddressBookEvent)event;
@end

@interface OSSVAddresseBookeTableCell : UITableViewCell

+ (OSSVAddresseBookeTableCell *)addressBookCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak) id<AddressBookTableCellDelegate> delegate;

@property (nonatomic, strong) OSSVAddresseBookeModel *addressBookModel;
/**从订单过来*/
@property (nonatomic, assign) BOOL             isOrder;
/**是否选中*/
@property (nonatomic, assign) BOOL             isMark;
/**编辑状态*/
@property (nonatomic, assign) BOOL             isEdit;

- (void)handleAddressBookModel:(OSSVAddresseBookeModel *)addresseBookeModel editState:(BOOL)isEdit isMark:(BOOL)isMark isFromOrder:(BOOL)isOrder;

- (void)defaultAction:(UIButton *)sender;

// 此处针对于AddressOfOrder 默认选中 DefalutButton的需求
@property (nonatomic, assign) BOOL isSelectedAddress;


@property (nonatomic, strong) YYAnimatedImageView    *addressIconImageView;
@property (nonatomic, strong) UILabel                *nameLabel;
@property (nonatomic, strong) UILabel                *phoneLabel;
@property (nonatomic, strong) AddressShowLabel       *addressLabel;

@property (nonatomic, strong) UIButton               *editButton;
@property (nonatomic, strong) UIButton               *deleteButton;
@property (nonatomic, strong) UIView                 *addressBgView; //背景
@property (nonatomic, strong) UIView                 *addressIconBgView; //图片背景
@property (nonatomic,weak) UIImageView               *selectCornerImg;
@property (nonatomic,weak) UILabel                   *isDefaultLbl;

@end
