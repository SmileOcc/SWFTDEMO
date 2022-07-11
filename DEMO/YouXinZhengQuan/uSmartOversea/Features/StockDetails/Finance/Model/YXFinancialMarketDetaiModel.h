//
//  YXFinancialMarketDetaiModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/12.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXFinancialMarketDetaiModel : YXModel
//"report_period": 20181231, // 报告期
//"year": 2018,              // 年份
//"crncy_code": 0,         // 货币单位
//"roa_annual": 0.0,       // 总资产收益率(ROA)
//"roe_annual": 0.0,   // 净资产收益率(ROE)
//"pe_annual": 0.0,    // 市盈率(PE)
//"pb_annual": 0.0,    // 市净率(PB)
//"eps_annual": 0.0,   // 每股收益(EPS)
//"bps_annual": 0.0,   // 每股净资产(BPS)
//"ocfps_annual": 0.0, // 每股经营现金流(OCFPS)
//"grps_annual": 0.0,  // 每股营收(GRPS)
//"roa_annual_yoy": 0.0,   // 同比-总资产收益率(ROA)
//"roe_annual_yoy": 0.0,   // 同比-净资产收益率(ROE)
//"pe_annual_yoy": 0.0,    // 同比-市盈率(PE)
//"pb_annual_yoy": 0.0,    // 同比-市净率(PB)
//"eps_annual_yoy": 0.0,   // 同比-每股收益(EPS)
//"bps_annual_yoy": 0.0,   // 同比-每股净资产(BPS)
//"ocfps_annual_yoy": 0.0, // 同比-每股经营现金流(OCFPS)
//"grps_annual_yoy": 0.0   // 同比-每股营收(GRPS)

@property (nonatomic, strong) NSString *report_period;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger crncy_code;
@property (nonatomic, assign) double roa_annual;
@property (nonatomic, assign) double roe_annual;
@property (nonatomic, assign) double pe_annual;
@property (nonatomic, assign) double pb_annual;
@property (nonatomic, assign) double eps_annual;
@property (nonatomic, assign) double bps_annual;
@property (nonatomic, assign) double ocfps_annual;
@property (nonatomic, assign) double grps_annual;
@property (nonatomic, assign) double roa_annual_yoy;
@property (nonatomic, assign) double roe_annual_yoy;
@property (nonatomic, assign) double pe_annual_yoy;
@property (nonatomic, assign) double pb_annual_yoy;
@property (nonatomic, assign) double eps_annual_yoy;
@property (nonatomic, assign) double bps_annual_yoy;
@property (nonatomic, assign) double ocfps_annual_yoy;
@property (nonatomic, assign) double grps_annual_yoy;


@end

NS_ASSUME_NONNULL_END
