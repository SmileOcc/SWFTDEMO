//
//  OSSVMyCurrencysCell.h
// XStarlinkProject
//
//  Created by odd on 2020/8/4.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVMyCurrencysCell : UITableViewCell

@property (nonatomic, strong) UILabel           *contentLabel;
@property (nonatomic, strong) UIImageView       *accesoryImageView;
@property (nonatomic, strong) UIView            *lineView;

- (void)showLinew:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
