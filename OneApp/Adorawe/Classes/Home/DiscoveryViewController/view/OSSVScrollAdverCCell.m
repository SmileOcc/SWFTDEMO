//
//  OSSVScrollAdverCCell.m
// OSSVScrollAdverCCell
//
//  Created by Kevin--Xue on 2020/10/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVScrollAdverCCell.h"
@interface OSSVScrollAdverCCell ()

@end

@implementation OSSVScrollAdverCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imgView.backgroundColor = [UIColor clearColor];
//        _imgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:_imgView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView.mas_top).offset(-1); //iPhone12ProMax 会存在一个1像素的间隙，所以离top 为-1
        }];
    }
    return self;
}

@end
