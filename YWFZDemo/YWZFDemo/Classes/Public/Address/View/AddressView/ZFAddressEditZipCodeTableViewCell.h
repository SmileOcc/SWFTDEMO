//
//  ZFAddressEditZipCodeTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseEditAddressCell.h"

@interface ZFAddressEditZipCodeTableViewCell : ZFBaseEditAddressCell

- (void)updateInfo:(ZFAddressInfoModel *)infoModel typeModel:(ZFAddressEditTypeModel *)typeModel zips:(NSArray *)zipArrays;

- (void)fillInZip:(NSString *)zipString;
@end
