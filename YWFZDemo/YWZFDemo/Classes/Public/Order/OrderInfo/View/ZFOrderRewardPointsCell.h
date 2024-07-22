//
//  ZFOrderRewardPointsCell.h
//  ZZZZZ
//
//  Created by 602600 on 2019/10/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFOrderRewardPointsCell : UITableViewCell

+ (NSString *)queryReuseIdentifier;

@property (nonatomic, copy) NSString *pointsTip;

@end

NS_ASSUME_NONNULL_END
