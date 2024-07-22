//
//  ZFOrderDetailBannerCell.h
//  ZZZZZ
//
//  Created by YW on 2019/4/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFOrderDetailBannerCell : UITableViewCell

@property (nonatomic, copy) NSString *imageUrl;

- (void)configurate:(NSString *)imageUrl scale:(CGFloat)scale;
@end

NS_ASSUME_NONNULL_END
