//
//  ZFAddressCityTableView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/8.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFAddressCityTableView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFAddressCityTableView()<ZFInitViewProtocol,UITableViewDelegate,UITableViewDataSource>

@end

@implementation ZFAddressCityTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (NSMutableArray *)cityDatas {
    if (!_cityDatas) {
        _cityDatas = [[NSMutableArray alloc] init];
    }
    return _cityDatas;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    
}

- (void)zfAutoLayoutView {
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cityDatas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 32)];
    UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLab.text = ZFLocalizedString(@"ModifyAddress_Enter_your_delivery_city", nil);
    headerLab.textColor = ColorHex_Alpha(0x999999, 1.0);
    headerLab.font = ZFFontSystemSize(14);
    [headerView addSubview:headerLab];
    [headerLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(headerView.mas_leading).offset(32);
        make.trailing.mas_equalTo(headerView.mas_trailing).offset(-32);
        make.bottom.mas_equalTo(headerView.mas_bottom);
    }];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CityCellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        UILabel *titLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titLabel.textColor = ColorHex_Alpha(0x2D2D2D, 1.0);
        titLabel.font = ZFFontSystemSize(14);
        titLabel.tag = 2000;
        [cell.contentView addSubview:titLabel];
        
        [titLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(cell.contentView.mas_leading).offset(32);
            make.trailing.mas_equalTo(cell.contentView.mas_trailing).offset(-32);
            make.top.bottom.mas_equalTo(cell.contentView);
        }];
    }
    
    UILabel *titLabel = [cell viewWithTag:2000];
    titLabel.text = @"";
    if (titLabel) {
        if (self.cityDatas.count > indexPath.row) {
            ZFAddressHintCityModel *model = self.cityDatas[indexPath.row];
            titLabel.text = ZFToString(model.city);
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cityDatas.count > indexPath.row) {
        ZFAddressHintCityModel *model = self.cityDatas[indexPath.row];
        if (self.selectCityBlock) {
            self.selectCityBlock(model);
        }
    }
}
@end
