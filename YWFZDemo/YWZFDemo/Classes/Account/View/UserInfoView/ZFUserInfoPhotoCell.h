//
//  ZFUserInfoPhotoCell.h
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFUserInfoTypeModel.h"
#import <YYWebImage/YYWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFUserInfoPhotoCell : UITableViewCell

@property (nonatomic, strong) ZFUserInfoTypeModel    *typeModel;

@property (nonatomic, strong) UILabel                *typeLabel;
@property (nonatomic, strong) YYAnimatedImageView    *userImageView;

@property (nonatomic, strong) UIImageView            *arrowImageView;

@property (nonatomic, copy) NSString                 *userImageUrl;


@end

NS_ASSUME_NONNULL_END
