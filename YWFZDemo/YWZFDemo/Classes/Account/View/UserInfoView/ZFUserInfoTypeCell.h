//
//  ZFUserInfoTypeCell.h
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFUserInfoTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFUserInfoTypeCell : UITableViewCell

@property (nonatomic, strong) ZFUserInfoTypeModel *typeModel;

@property (nonatomic, strong) UILabel          *typeLabel;
@property (nonatomic, strong) UILabel          *typeInfoLabel;
@property (nonatomic, strong) UIImageView      *arrowImageView;
@property (nonatomic, strong) UIView           *bottomLineView;


@end

NS_ASSUME_NONNULL_END
