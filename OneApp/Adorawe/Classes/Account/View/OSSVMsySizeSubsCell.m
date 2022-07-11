//
//  OSSVMsySizeSubsCell.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMsySizeSubsCell.h"

@interface OSSVMsySizeSubsCell()

@property (nonatomic, strong) UILabel *shapLab;

@end

@implementation OSSVMsySizeSubsCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}


- (void)setUpView{
    [self.contentView addSubview:self.shapLab];
    [self.shapLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
    }];
}


- (void)setTitStr:(NSString *)titStr{
    self.shapLab.text = titStr;
}


- (UILabel *)shapLab{
    if (!_shapLab) {
        _shapLab = [UILabel new];
        _shapLab.font = FontWithSize(12);
    }
    return _shapLab;
}

- (void)setSelected:(BOOL)selected{
    if (selected) {
        _shapLab.textColor = OSSVThemesColors.stlWhiteColor;
        self.backgroundColor = OSSVThemesColors.col_60CD8E;
    }else{
        _shapLab.textColor = OSSVThemesColors.stlBlackColor;
        self.backgroundColor = OSSVThemesColors.col_F5F5F5;
    }
}

@end
