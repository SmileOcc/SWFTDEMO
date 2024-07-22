//
//  ZFCommunityAlbumGroupCell.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAblumModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityAlbumGroupCell : UITableViewCell

@property (nonatomic, strong) UIImageView    *coverImageView;
@property (nonatomic, strong) UILabel        *ablumName;
@property (nonatomic, strong) UILabel        *ablumNums;

@property (nonatomic, strong) PYAblumModel   *ablumModel;


@end

NS_ASSUME_NONNULL_END
