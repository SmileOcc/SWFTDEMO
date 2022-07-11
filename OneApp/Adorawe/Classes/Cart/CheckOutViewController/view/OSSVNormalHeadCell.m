//
//  OSSVNormalHeadCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVNormalHeadCell.h"

@interface OSSVNormalHeadCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation OSSVNormalHeadCell
@synthesize delegate = _delegate;
@synthesize model = _model;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(contentView).mas_offset(CheckOutCellLeftPadding);
            make.top.bottom.mas_equalTo(contentView);
            make.height.mas_equalTo(CheckOutCellNormalHeight).priorityHigh();
        }];
        
//        [self addBottomLine:CellSeparatorStyle_LeftRightInset];
    }
    return self;
}

#pragma mark - setter and getter

-(void)setModel:(STLNormalHeadCellModel *)model
{
    _model = model;
    
    self.titleLabel.text = model.titleContent;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"test", nil);
            label.textColor = OSSVThemesColors.col_0D0D0D;
            label.font = [UIFont boldSystemFontOfSize:14];
            label;
        });
    }
    return _titleLabel;
}

@end

@implementation STLNormalHeadCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleContent = [STLLocalizedString_(@"Payment Method", nil) uppercaseString];
    }
    return self;
}

+(instancetype)initWithTitile:(NSString *)title
{
    STLNormalHeadCellModel *model = [[STLNormalHeadCellModel alloc] init];
    model.titleContent = title;
    return model;
}

@end
