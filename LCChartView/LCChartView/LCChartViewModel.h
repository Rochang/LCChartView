//
//  LCChartViewModel.h
//  LCProject
//
//  Created by liangrongchang on 2017/5/17.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LCChartViewModel : NSObject
@property (strong, nonatomic) UIColor *color;
/** 项目名称 */
@property (nonatomic, copy) NSString *project;
@property (strong, nonatomic) NSArray <NSString *>*plots;
@property (strong, nonatomic) NSMutableArray <UIButton *>*plotButtons;

+ (instancetype)modelWithColor:(UIColor *)color  plots:(NSArray<NSString *> *)plots project:(NSString *)project;

@end
