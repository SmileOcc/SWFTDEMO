//
//  ZFDetailStyleValueTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2019/10/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFDetailStyleValueTableViewCell : UITableViewCell

@property (nonatomic, copy) NSAttributedString *titleAttribute;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailTitle;

@end

NS_ASSUME_NONNULL_END
