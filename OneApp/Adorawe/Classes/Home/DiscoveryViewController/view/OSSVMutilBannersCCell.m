//
//  OSSVMutilBannersCCell.m
// OSSVMutilBannersCCell
//
//  Created by Kevin--Xue on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVMutilBannersCCell.h"

@interface OSSVMutilBannersCCell ()
@end

@implementation OSSVMutilBannersCCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[STLProductImagePlaceholder alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:_imageView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(self.contentView);
        }];
    }
    return self;
}
@end
