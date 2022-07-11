//
//  OSSVLogistieeTrackeCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVLogistieeTrackeCell.h"
#import "UITableViewCell+STLBottomLine.h"

@interface OSSVLogistieeTrackeCell ()

@property (nonatomic, strong) UIImageView *trackDot;
@property (nonatomic, strong) UILabel *trackContent;
@property (nonatomic, strong) UILabel *trackTime;
@property (nonatomic, strong) UIView *verLine;
@end

@implementation OSSVLogistieeTrackeCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *content = self.contentView;
        
        [content addSubview:self.verLine];
        [content addSubview:self.trackDot];
        [content addSubview:self.trackContent];
        [content addSubview:self.trackTime];
    
        CGFloat padding = 18;
        [self.trackDot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content).mas_offset(padding);
            make.centerX.mas_equalTo(self.verLine.mas_centerX);
        }];
        
        [self.trackContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.verLine.mas_trailing).mas_offset(padding);
            make.trailing.mas_equalTo(content.mas_trailing).mas_offset(-padding);
            make.centerY.mas_equalTo(self.trackDot.mas_centerY);
        }];
        self.trackContent.preferredMaxLayoutWidth = SCREEN_WIDTH - padding*4;
        
        [self.trackTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.trackContent.mas_bottom).mas_offset(8);
            make.leading.mas_equalTo(self.trackContent);
            make.trailing.mas_equalTo(self.trackContent);
            make.bottom.mas_equalTo(content.mas_bottom).mas_offset(-padding);
        }];
        
        [self.verLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(content);
            make.bottom.mas_equalTo(content);
            make.leading.mas_equalTo(content.mas_leading).mas_offset(padding);
            make.width.mas_offset(1);
        }];
        
        [self addBottomLine:CellSeparatorStyle_LeftInset inset:padding*2];
    }
    return self;
}

-(void)setDotLineStatus:(DotLineStatus)status
{
    [self.verLine mas_remakeConstraints:^(MASConstraintMaker *make){}];
    self.verLine.hidden = NO;
    if (status == DotLineStatus_Top) {
        [self.verLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.trackDot.mas_bottom);
            make.bottom.mas_equalTo(self.contentView);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(18);
            make.width.mas_offset(1);
        }];
        self.trackDot.image = [UIImage imageNamed:@"dot_light"];
        self.trackContent.textColor = [UIColor blackColor];
        self.trackTime.textColor = [UIColor blackColor];
    }else if (status == DotLineStatus_Bottom){
        [self.verLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.trackDot);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(18);
            make.width.mas_offset(1);
        }];
        self.trackDot.image = [UIImage imageNamed:@"dot_gray"];
        self.trackContent.textColor = OSSVThemesColors.col_999999;
        self.trackTime.textColor = OSSVThemesColors.col_999999;
    }else if (status == DotLineStatus_OnlyOne){
        [self.verLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.trackDot);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(18);
            make.width.mas_offset(1);
        }];
        self.verLine.hidden = YES;
        self.trackDot.image = [UIImage imageNamed:@"dot_light"];
        self.trackContent.textColor = [UIColor blackColor];
        self.trackTime.textColor = [UIColor blackColor];
    }else{
        [self.verLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(18);
            make.width.mas_offset(1);
        }];
        self.trackDot.image = [UIImage imageNamed:@"dot_gray"];
        self.trackContent.textColor = OSSVThemesColors.col_999999;
        self.trackTime.textColor = OSSVThemesColors.col_999999;
    }
}

#pragma mark - setter and getter

//- (void)setModel:(OSSVTrackingcMessagecModel *)model
//{
//    _model = model;
//    
//    NSString *content = [NSString stringWithFormat:@"%@", model.detail];
////    if (model.address && model.address.length) {
////        content = [NSString stringWithFormat:@"%@ 【%@】", content, model.address];
////    }
//    self.trackContent.text = content;
//    self.trackTime.text = model.origin_time;
//}

-(UIImageView *)trackDot
{
    if (!_trackDot) {
        _trackDot = ({
            UIImageView *view = [[UIImageView alloc] init];
            view;
        });
    }
    return _trackDot;
}

-(UILabel *)trackContent
{
    if (!_trackContent) {
        _trackContent = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"Signed, Thank you for shopping at Adorawe,Welcome to visit again", nil);
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label.numberOfLines = 0;
            label;
        });
    }
    return _trackContent;
}

-(UILabel *)trackTime
{
    if (!_trackTime) {
        _trackTime = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = STLLocalizedString_(@"", nil);
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _trackTime;
}

-(UIView *)verLine
{
    if (!_verLine) {
        _verLine = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = OSSVThemesColors.col_CCCCCC;
            view;
        });
    }
    return _verLine;
}

@end
