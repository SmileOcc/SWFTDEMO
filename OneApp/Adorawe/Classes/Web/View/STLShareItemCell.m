//
//  STLShareItemCell.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLShareItemCell.h"

@interface STLShareItemCell()

@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *titLab;

@end

@implementation STLShareItemCell

+(STLShareItemCell *)stlShareItemCellWithCollection:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath{
    [collectionView registerClass:[STLShareItemCell class] forCellWithReuseIdentifier:NSStringFromClass(STLShareItemCell.class)];
    STLShareItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(STLShareItemCell.class) forIndexPath:indexPath];
    return cell;
}

- (void)setDataDic:(NSDictionary *)dataDic{
    _dataDic = dataDic;
    NSString *titStr = [dataDic objectForKey:@"titStr"];
    NSString *imgStr = [dataDic objectForKey:@"imgStr"];
    
    self.titLab.text = titStr;
    self.imgV.image = [UIImage imageNamed:imgStr];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpVivew];
    }
    return self;
}

- (void)setUpVivew{
    [self.contentView addSubview:self.imgV];
    [self.contentView addSubview:self.titLab];
    
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(-15);
        make.width.height.mas_equalTo(48);
    }];
    
    [self.titLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.top.mas_equalTo(self.imgV.mas_bottom).offset(8);
    }];
}

- (UIImageView *)imgV{
    if (!_imgV) {
        _imgV = [UIImageView new];
        _imgV.contentMode = UIViewContentModeScaleAspectFill;
        _imgV.clipsToBounds = YES;
    }
    return _imgV;
}

- (UILabel *)titLab{
    if (!_titLab) {
        _titLab = [UILabel new];
        _titLab.font  = FontWithSize(12);
        _titLab.textAlignment = NSTextAlignmentCenter;
    }
    return  _titLab;
}


@end
