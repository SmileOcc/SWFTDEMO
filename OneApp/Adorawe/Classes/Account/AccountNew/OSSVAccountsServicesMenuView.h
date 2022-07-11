//
//  OSSVAccountsServicesMenuView.h
//  Adorawe
//
//  Created by odd on 2021/10/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAccountsMenuItemsModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVAccountsServicesMenuView : UIView

@property (nonatomic, strong) UIView    *headerView;
@property (nonatomic, strong) UILabel   *titleLabel;
@property (nonatomic, strong) UIView    *lineView;
@property (nonatomic, strong) UIView    *contentView;

@property (nonatomic, strong) NSArray   *datas;

@property (nonatomic, copy) void(^didSelectBlock)(NSInteger index,OSSVAccountsMenuItemsModel *model);

- (void)updateDatas:(NSArray<OSSVAccountsMenuItemsModel*> *)datas;

+ (CGFloat)contentHeight;
@end

NS_ASSUME_NONNULL_END
