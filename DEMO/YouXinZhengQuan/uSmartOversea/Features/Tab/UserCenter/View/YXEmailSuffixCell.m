//
//  YXEmailSuffixCell.m
//  uSmartOversea
//
//  Created by JC_Mac on 2019/1/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXEmailSuffixCell.h"
#import <Masonry/Masonry.h>

@interface YXEmailSuffixCell ()

@end

@implementation YXEmailSuffixCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initialUI];
    }
    return self;
}

- (void)initialUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = UIColorMakeWithHex(@"#FFFFFF");
    
    [self.contentView addSubview:self.emailSuffixLab];
    [self.emailSuffixLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-5);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    self.lineView = lineView;
    lineView.backgroundColor = UIColorMakeWithHex(@"#F4F4F4");
    [self.contentView addSubview: lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self);
    }];
}

- (UILabel *)emailSuffixLab {
    
    if (!_emailSuffixLab) {
        _emailSuffixLab = [[UILabel alloc] init];
        _emailSuffixLab.textColor = UIColorMakeWithHex(@"#393939");
        _emailSuffixLab.font = [UIFont systemFontOfSize:14];
        _emailSuffixLab.lineBreakMode = NSLineBreakByTruncatingHead;
    }
    
    return _emailSuffixLab;
}

@end
