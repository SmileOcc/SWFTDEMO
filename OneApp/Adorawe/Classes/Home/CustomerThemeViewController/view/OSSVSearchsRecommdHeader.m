//
//  OSSVSearchsRecommdHeader.m
// OSSVSearchsRecommdHeader
//
//  Created by Starlinke on 2021/5/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVSearchsRecommdHeader.h"

@implementation OSSVSearchsRecommdHeader

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self makeCustomView];
    }
    return self;
}

+ (CGFloat)contentH {
    return 260;
}

- (void)makeCustomView{
    self.backgroundColor = [OSSVThemesColors col_F5F5F5];
    UIImageView *mainImgV = [UIImageView new];
    mainImgV.image = STLImageWithName(@"search_bank");
    
    UILabel *lab = [UILabel new];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = STLLocalizedString_(@"search_result_recommend", nil);
    lab.numberOfLines = 0;
    lab.textColor = [OSSVThemesColors col_6C6C6C];
    lab.font = [UIFont systemFontOfSize:14];
    
    UIView *recommendV = [[UIView alloc] init];
    recommendV.backgroundColor = [OSSVThemesColors col_F5F5F5];
    
    UILabel *recLab = [UILabel new];
    recLab.text = STLLocalizedString_(@"Recommendations", nil);
    recLab.font = [UIFont boldSystemFontOfSize:14];
    recLab.textColor = [OSSVThemesColors col_0D0D0D];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [OSSVThemesColors col_0D0D0D];
    
    [self addSubview:mainImgV];
    [self addSubview:lab];
    [self addSubview:recommendV];
    [recommendV addSubview: recLab];
    [recommendV addSubview:lineView];
    
    [mainImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(40);
    }];
    
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(mainImgV.mas_bottom).offset(8);
        make.centerX.mas_equalTo(self);
        make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width - 80);

    }];
    
    [recommendV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(43);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
        
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(recommendV.mas_bottom);
        make.centerX.mas_equalTo(recommendV.mas_centerX);
        make.leading.mas_equalTo(recLab.mas_leading);
        make.trailing.mas_equalTo(recLab.mas_trailing);
        make.height.mas_equalTo(2);
    }];
    [recLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(recommendV.centerX);
        make.bottom.mas_equalTo(lineView.mas_top);
    }];

}
@end
