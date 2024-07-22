//
//  ZFPCCNumInputCell.h
//  ZZZZZ
//
//  Created by YW on 2019/8/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  输入身份证的cell

#import <UIKit/UIKit.h>
#import "ZFOrderCheckInfoDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

#define ZFShowError @"ZFShowError"

@protocol ZFPCCNumInputCellDelegate <NSObject>

- (void)ZFPCCNumInputCellDidEndEditPccNum:(NSString *)value cell:(UITableViewCell *)cell;

@end

@interface ZFPCCNumInputCell : UITableViewCell

@property (nonatomic, weak) id<ZFPCCNumInputCellDelegate>delegate;

- (void)configurate:(ZFTaxVerifyModel *)verifyModel pccNum:(NSString *)pccNum;

@property (nonatomic, copy) void (^refreshBlock)(void);

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, copy) void (^refreshCellTextHeight) (void);

@end

NS_ASSUME_NONNULL_END
