//
//  YXKLineProtocol.h
//  YXKlineDemo
//
//  Created by rrd on 2018/8/31.
//Copyright © 2018年 RRD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YXKLineProtocol <NSObject>


@required

//- (NSInteger *)numberOfDatasInKLineView:(UIView *)kLineView;
- (NSArray *)datasInKLineView:(UIView *)kLineView;



@end
