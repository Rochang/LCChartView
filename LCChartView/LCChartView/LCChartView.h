//
//  LCChartView.h
//  LCProject
//
//  Created by liangrongchang on 2017/1/6.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 代理
@class LCChartView;
@protocol LCChartViewDelegate <NSObject>

- (void)chartView:(LCChartView *)chartView didClickpPotsLabel:(NSInteger)index;

@end

typedef NS_ENUM(NSInteger, LCChartViewType) {
    LCChartViewTypeLine,
    LCChartViewTypeBar,
    LCChartViewTypeLineAndBar
};

#pragma mark - 数据model
@interface LCChartViewDataModel : NSObject

@property (strong, nonatomic) UIColor *barColor;
@property (strong, nonatomic) UIColor *lineColor;
@property (strong, nonatomic) NSArray <NSString *>*plots;
@property (strong, nonatomic) NSMutableArray <UIButton *>*plotButtons;
+ (LCChartViewDataModel *)getModelWithLineColor:(UIColor *)lineColor BarColor:(UIColor *)barColor plots:(NSArray<NSString *> *)plots;

@end

@interface LCChartView : UIView
@property (weak, nonatomic) id <LCChartViewDelegate> delegate;

// switch
@property (assign, nonatomic) BOOL showGridding;
@property (assign, nonatomic) BOOL showAnimation;
@property (assign, nonatomic) BOOL yShowPercent;
@property (assign, nonatomic) BOOL showPlotsLabel;
@property (assign, nonatomic) BOOL showPlotsLabelPersent;
@property (assign, nonatomic) BOOL PlotsLabelCanClick;
@property (assign, nonatomic) BOOL lineChartFillView;
@property (assign, nonatomic) LCChartViewType chartViewType;

// data
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *xAxisTitle;
@property (copy, nonatomic) NSString *yAxisTitle;
@property (strong, nonatomic) NSArray <NSString *> *xAxisTitleArray;

// size
@property (assign, nonatomic) CGFloat yAxisMaxValue;
@property (assign, nonatomic) CGFloat axisWidth;
@property (assign, nonatomic, readonly) CGFloat xAxisTextMargin;
@property (assign, nonatomic) CGFloat yAxisToLeft;
@property (assign, nonatomic) NSInteger yAxisCount;
@property (assign, nonatomic) CGFloat topMargin;
@property (assign, nonatomic) CGFloat xTextToAxis;
@property (assign, nonatomic) CGFloat yTextToAxis;
@property (assign, nonatomic) CGFloat axisFontSize;
@property (assign, nonatomic) CGFloat plotsLabelFontSize;
@property (assign, nonatomic) CGFloat plotsButtonWH;
@property (assign, nonatomic) CGFloat lineChartWidth;
@property (assign, nonatomic) CGFloat chartViewRightMargin;
@property (assign, nonatomic) CGFloat displayPlotToLabel;
@property (assign, nonatomic) CGFloat barWidth;

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

/** 展示的数据点 */
@property (strong, nonatomic) NSArray <LCChartViewDataModel *>*dataSource;

/** 设置title属性Block */
@property (copy, nonatomic) void(^comfigurateTitleLabel)(UILabel *);

/** 设置yAxisLabel属性Block */
@property (copy, nonatomic) void(^comfigurateYAxisLabel)(UILabel *);

/** 设置xAxisLabel属性Block */
@property (copy, nonatomic) void(^comfiguratexAxisLabel)(UILabel *);

/** 设置yAxisTitleLabel属性Block */
@property (copy, nonatomic) void(^comfigurateYAxisTitleLabel)(UILabel *);

/** 设置xAxisTitleLabel属性Block */
@property (copy, nonatomic) void(^comfigurateXAxisTitleLabel)(UILabel *);

/** 设置xAxisTextMargin */
- (void)setChartViewXAxisTextMargin:(CGFloat)xAxisTextMargin;

/** 初始化 */
+ (instancetype)getAxisViewLineWithYAxisMaxValue:(CGFloat)yAxisMaxValue;
+ (instancetype)getAxisViewBarWithYAxisMaxValue:(CGFloat)yAxisMaxValue;
+ (instancetype)getAxisViewLineAndBarWithYAxisMaxValue:(CGFloat)yAxisMaxValue;

/** 开始描绘LCChartView */
- (void)drawChartView;

@end
