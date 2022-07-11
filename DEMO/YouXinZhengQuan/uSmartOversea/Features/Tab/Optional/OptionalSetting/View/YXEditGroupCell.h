//
//  YXManageGroupCell.h
//  uSmartOversea
//
//  Created by ellison on 2018/11/21.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXSecuGroupNameTextField;

NS_ASSUME_NONNULL_BEGIN

@interface YXEditGroupCell : UITableViewCell

@property (nonatomic, copy) dispatch_block_t onClickDelete;
@property (nonatomic, copy) dispatch_block_t onClickEdit;


@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *editButton;
//@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) YXSecuGroupNameTextField *nameTextField;
@property (nonatomic, assign) int secuID;

@end

NS_ASSUME_NONNULL_END
