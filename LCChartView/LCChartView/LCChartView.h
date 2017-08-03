//
//  LCChartView.h
//  LCProject
//
//  Created by liangrongchang on 2017/1/6.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCChartViewModel.h"

typedef NS_ENUM(NSInteger, LCChartViewType) {
    LCChartViewTypeLine,
    LCChartViewTypeBar
};

@interface LCChartView : UIView

@property (copy, nonatomic) void (^plotClickBlock)(NSInteger index);

// switch
@property (assign, nonatomic) BOOL showGridding;
@property (assign, nonatomic) BOOL showAnimation;
@property (assign, nonatomic) BOOL showPlotsLabel;
@property (assign, nonatomic) BOOL lineChartFillView;
@property (assign, nonatomic) BOOL showNote;
@property (assign, nonatomic) LCChartViewType chartViewType;

// data
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *xAxisTitle;
@property (copy, nonatomic) NSString *yAxisTitle;
@property (strong, nonatomic) NSArray <NSString *> *xAxisTitleArray;

// size
@property (assign, nonatomic) CGFloat axisTitleSizeFont;
@property (assign, nonatomic) CGFloat axisWidth;
@property (assign, nonatomic) CGFloat xAxisTextMargin;
@property (assign, nonatomic) CGFloat yAxisToLeft;
@property (assign, nonatomic) NSInteger yAxisCount;
@property (assign, nonatomic) CGFloat topMargin;
@property (assign, nonatomic) CGFloat xTextToAxis;
@property (assign, nonatomic) CGFloat yTextToAxis;
@property (assign, nonatomic) CGFloat axisFontSize;
@property (assign, nonatomic) CGFloat titleFontSize;
@property (assign, nonatomic) CGFloat plotsLabelFontSize;
@property (assign, nonatomic) CGFloat plotsButtonWH;
@property (assign, nonatomic) CGFloat lineChartWidth;
@property (assign, nonatomic) CGFloat chartViewRightMargin;
@property (assign, nonatomic) CGFloat displayPlotToLabel;
@property (assign, nonatomic) CGFloat barWidth;
@property (assign, nonatomic) CGFloat barMargin;

// color
@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor *yTextColor;
@property (strong, nonatomic) UIColor *xTextColor;
@property (strong, nonatomic) UIColor *axisColor;
@property (strong, nonatomic) UIColor *plotsLabelColor;
@property (strong, nonatomic) UIColor *plotsLabelSelectedColor;
@property (strong, nonatomic) UIColor *lineChartFillViewColor;

@property (strong, nonatomic) UIColor *plotsButtonColor;
@property (strong, nonatomic) UIColor *plotsButtonSelectedColor;
// 或者图片
@property (strong, nonatomic) NSString *plotsButtonImage;
@property (strong, nonatomic) NSString *plotsButtonSelectedImage;

/** 设置title属性Block */
@property (copy, nonatomic) void(^comfigurateTitleLabel)(UILabel *title);

/** 设置yAxisLabel属性Block */
@property (copy, nonatomic) void(^yAxisLabelUIBlock)(UILabel *yAxisLabel, NSInteger index);

/** 设置xAxisLabel属性Block */
@property (copy, nonatomic) void(^xAxisLabelUIBlock)(UILabel *xAxisLabel, NSInteger index);

/** 设置yAxisTitleLabel属性Block */
@property (copy, nonatomic) void(^yAxisTitleLabelUIBlock)(UILabel *yAxisTitleLabel);

/** 设置xAxisTitleLabel属性Block */
@property (copy, nonatomic) void(^xAxisTitleLabelUIBlock)(UILabel *xAxisTitleLabel);

/** 设置xAxisTextMargin */
- (void)setChartViewXAxisTextMargin:(CGFloat)xAxisTextMargin;

/** 初始化 */
+ (instancetype)chartViewWithType:(LCChartViewType)type;
- (instancetype)initWithFrame:(CGRect)frame chartViewType:(LCChartViewType)type;

/** 开始描绘LCChartView */
- (void)showChartViewWithYAxisMaxValue:(CGFloat)yAxisMaxValue dataSource:(NSArray <LCChartViewModel *>*)dataSource;

@end
