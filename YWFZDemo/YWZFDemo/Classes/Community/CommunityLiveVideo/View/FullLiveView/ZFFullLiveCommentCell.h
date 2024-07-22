//
//  ZFFullLiveCommentCell.h
//  ZZZZZ
//
//  Created by YW on 2019/12/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "Masonry.h"
#import "Configuration.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveCommentCell : UITableViewCell

@property (nonatomic, strong) YYAnimatedImageView         *avatar;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end

NS_ASSUME_NONNULL_END
