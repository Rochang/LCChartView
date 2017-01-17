//
//  LCChartView.m
//  LCProject
//
//  Created by liangrongchang on 2017/1/6.
//  Copyright © 2017年 Rochang. All rights reserved.
//

#import "LCChartView.h"
#import "UIView+LayoutMethods.h"

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]
#define LCBrown119                      RGB(119, 107, 95)
#define LCRed245                        RGB(245, 94, 78)
#define LCGreen77                       RGB(77, 186, 122)
#define LCClear                         [UIColor clearColor]
#define Image(nameStr)                  [UIImage imageNamed:nameStr]

static NSTimeInterval duration = 0.5;
static CGFloat yAxisMaxY = 0;
static CGFloat yTextCenterMargin = 0;
/** 显示数据的区域高度 */
static CGFloat dataChartHeight = 0;
static CGFloat axisLabelHieght = 0;
static CGFloat xAxisMaxX = 0;

@interface LCChartView ()<UIScrollViewDelegate>
// UI
@property (strong, nonatomic) NSMutableArray <UILabel *>*yAxisLabels;
@property (strong, nonatomic) NSMutableArray <UILabel *>*xAxisLabels;
@property (strong, nonatomic) NSMutableArray <UIView *>*allSubView;

@property (strong, nonatomic) UIScrollView *scrollView;

// 数据
/** 捏合时记录原先X轴点距离 */
@property (assign, nonatomic) CGFloat orginXAxisMargin;
/** 捏合时记录原先动画flag */
@property (assign, nonatomic) BOOL orginAnimation;
/** X轴箭头离XAxisLabel距离 */
@property (assign, nonatomic) CGFloat xArrowsToText;
@property (assign, nonatomic) CGPoint originPoint;
@property (strong, nonatomic) NSMutableArray <CAShapeLayer *>*shapeLayers;
@property (strong, nonatomic) CAShapeLayer *lineShapeLayer;
@property (strong, nonatomic) CAShapeLayer *barShapeLayer;

// response
@property (strong, nonatomic) UITapGestureRecognizer *twoTap;
@property (strong, nonatomic) UIPinchGestureRecognizer *pinch;

@end

@implementation LCChartView

#pragma mark - API
+ (instancetype)getAxisViewLineWithYAxisMaxValue:(CGFloat)yAxisMaxValue {
    LCChartView *axisView = [[self alloc] init];
    axisView.chartViewType = LCChartViewTypeLine;
    axisView.yAxisMaxValue = yAxisMaxValue;
    return axisView;
}

+ (instancetype)getAxisViewBarWithYAxisMaxValue:(CGFloat)yAxisMaxValue {
    LCChartView *axisView = [[self alloc] init];
    axisView.chartViewType = LCChartViewTypeBar;
    axisView.yAxisMaxValue = yAxisMaxValue;
    return axisView;
}

+ (instancetype)getAxisViewLineAndBarWithYAxisMaxValue:(CGFloat)yAxisMaxValue {
    LCChartView *axisView = [[self alloc] init];
    axisView.chartViewType = LCChartViewTypeLineAndBar;
    axisView.yAxisMaxValue = yAxisMaxValue;
    return axisView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _axisColor = [UIColor whiteColor];
        _backColor = LCBrown119;
        _plotsLabelSelectedColor = _plotsButtonSelectedColor = _plotsLabelColor = LCRed245;
        _yTextColor = _xTextColor = _plotsButtonColor = _lineChartFillViewColor = LCGreen77;
        _barWidth = 20;
        _yAxisMaxValue = 1000;
        _chartViewType = LCChartViewTypeLine;
        _axisFontSize = _plotsLabelFontSize = 12;
        _yAxisToLeft = _chartViewRightMargin = _topMargin = 50;
        _displayPlotToLabel = _lineChartWidth = 3;
        _axisWidth = 2;
        _xAxisTextMargin = _orginXAxisMargin = _xArrowsToText = 30;
        _xTextToAxis = _yTextToAxis = _yAxisCount = _plotsButtonWH = 5 ;
        _yAxisTitle = @"y";
        _xAxisTitle = @"x";
        _title = @"LCChartView";
        _xAxisTitleArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8" , @"9", @"10", @"11", @"12"];
        _showPlotsLabelPersent = _lineChartFillView = NO;
        _showAnimation = _orginAnimation = _showPlotsLabel = _PlotsLabelCanClick = _showGridding = YES;
    }
    return self;
}

#pragma mark - private method
- (void)drawChartView {
    if (self.dataSource.count == 0) {
        NSLog(@"请设置展示的点数据");
        return;
    };
    if (self.chartViewType == LCChartViewTypeBar && self.dataSource.count > 2) {
        NSLog(@"目前LCChartViewTypeBar样式只支持2组数据");
        return;
    }
    if ((self.chartViewType == LCChartViewTypeBar || self.chartViewType == LCChartViewTypeLineAndBar) && self.dataSource.count == 2 && (self.xAxisTextMargin < self.barWidth * 2 + 5)) {
        NSLog(@"根据当前设置值可能会造成柱状图显示重叠,默认会设置xAxisTextMargin");
        self.xAxisTextMargin = self.orginXAxisMargin = self.barWidth * 2 + 5;
    }
    
    // 截取数据
    for (LCChartViewDataModel *model in self.dataSource) {
        if (model.plots.count > self.xAxisTitleArray.count) {
            NSLog(@"由于展示的点数据比X轴的点多,需要展示的数据被截取");
            model.plots = [model.plots subarrayWithRange:NSMakeRange(0, self.xAxisTitleArray.count)];
        }
    }
    [self resetDataSource];
    [self drawYAxis];
    [self drawXAxis];
    [self drawYSeparators];
    switch (self.chartViewType) {
            // 折线图
        case LCChartViewTypeLine:{
            [self drawXSeparators];
            [self drawLineChartViewPots];
            [self drawLineChartViewLines];
        }
            break;
            // 柱状图
        case LCChartViewTypeBar:{
            [self drawBarChartViewBars];
        }
            break;
            // 折线图,柱状图叠加
        case LCChartViewTypeLineAndBar:{
            [self drawBarChartViewBars];
            [self drawLineChartViewPots];
            [self drawLineChartViewLines];
        }
            break;
            
        default:
            break;
    }
    if (self.showPlotsLabel) {
        [self drawDisplayLabels];
    }
    if (self.showAnimation) {
        [self addAnimation];
    }
}

#pragma mark - 重置数据
- (void)resetDataSource {
    for (LCChartViewDataModel *model in self.dataSource) {
        if (model.plotButtons) {
            [model.plotButtons removeAllObjects];
            [model.plotButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
    }
    // 移除所有的Label,CAShapeLayer
    if (self.allSubView) {
        [self.allSubView makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.allSubView removeAllObjects];
    }
    if (self.shapeLayers.count) {
        [self.shapeLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.shapeLayers removeAllObjects];
    }
    if (self.xAxisLabels.count) {
        [self.xAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.xAxisLabels removeAllObjects];
    }
    if (self.yAxisLabels.count) {
        [self.yAxisLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.yAxisLabels removeAllObjects];
    }
}

#pragma mark - 描绘Y轴
- (void)drawYAxis {
    self.backgroundColor = self.backColor;
    axisLabelHieght = [self sizeWithText:@"x" fontSize:self.axisFontSize].height;
    // Ylabel的高度
    dataChartHeight = self.LC_height - self.topMargin - self.xTextToAxis - axisLabelHieght;
    
    // ylabel之间的间隙
    CGFloat labelMargin = (dataChartHeight + axisLabelHieght - (self.yAxisCount + 1) * axisLabelHieght) / self.yAxisCount;
    yTextCenterMargin = dataChartHeight / self.yAxisCount;
    yAxisMaxY = self.topMargin - yTextCenterMargin;
    UIBezierPath *yAxisPath = [UIBezierPath bezierPath];
    self.originPoint = CGPointMake(self.yAxisToLeft, self.LC_height - axisLabelHieght - self.xTextToAxis);
    [yAxisPath moveToPoint:self.originPoint];
    [yAxisPath addLineToPoint:CGPointMake(self.yAxisToLeft, yAxisMaxY)];
    [yAxisPath addLineToPoint:CGPointMake(self.yAxisToLeft - 5, yAxisMaxY + 5)];
    [yAxisPath moveToPoint:CGPointMake(self.yAxisToLeft, yAxisMaxY)];
    [yAxisPath addLineToPoint:CGPointMake(self.yAxisToLeft + 5, yAxisMaxY + 5)];
    
    CAShapeLayer *shapeLayer = [self shapeLayerWithPath:yAxisPath lineWidth:self.axisWidth fillColor:LCClear strokeColor:self.axisColor];
    [self.layer addSublayer:shapeLayer];
    [self.shapeLayers addObject:shapeLayer];
    
    // 添加Y轴Label
    for (int i = 0; i < self.yAxisCount + 1; i++) {
        CGFloat avgValue = self.yAxisMaxValue / (self.yAxisCount);
        NSString *title = nil;
        if (self.yShowPercent) {
            title = [NSString stringWithFormat:@"%.0f%%", avgValue * i];
        }else{
            title = [NSString stringWithFormat:@"%.0f", avgValue * i];
        }
        UILabel *label = [self labelWithFrame:CGRectZero textColor:self.yTextColor backColor:LCClear textAlignment:NSTextAlignmentRight lineNumber:1 tiltle:title fontSize:self.axisFontSize];
        if (_comfigurateYAxisLabel) {
            _comfigurateYAxisLabel(label);
        }
        label.LC_x = 0;
        label.LC_height = axisLabelHieght;
        label.LC_y = self.LC_height - axisLabelHieght - self.xTextToAxis - (label.LC_height + labelMargin) * i - label.LC_height/2;
        label.LC_width = self.yAxisToLeft - self.yTextToAxis;
        [self addSubview:label];
        [self.yAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.yAxisLabels];
    
    // yTitleLabel
    UILabel *yTitleLabel = [self labelWithFrame:CGRectZero textColor:self.axisColor backColor:LCClear textAlignment:NSTextAlignmentLeft lineNumber:1 tiltle:self.yAxisTitle fontSize:0];
    if (_comfigurateYAxisTitleLabel) {
        _comfigurateYAxisTitleLabel(yTitleLabel);
    }
    [yTitleLabel sizeToFit];
    yTitleLabel.LC_y = 0;
    yTitleLabel.LC_x = self.originPoint.x + _yTextToAxis;
    [self addSubview:yTitleLabel];
    [self.allSubView addObject:yTitleLabel];
    
    // titleLabel
    UILabel *titleLabel = [self labelWithFrame:CGRectZero textColor:self.axisColor backColor:LCClear textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:self.title fontSize:self.axisFontSize];
    if (_comfigurateTitleLabel) {
        _comfigurateTitleLabel(titleLabel);
    }
    [titleLabel sizeToFit];
    titleLabel.LC_centerX = self.LC_width / 2;
    titleLabel.LC_y = 5;
    [self addSubview:titleLabel];
    [self.allSubView addObject:titleLabel];
    
    // 添加scrollview
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(self.yAxisToLeft, 0, self.LC_width - self.yAxisToLeft, self.LC_height);
}

#pragma mark - 描绘X轴
- (void)drawXAxis {
    // 添加X轴Label
    for (int i = 0; i < self.xAxisTitleArray.count; i++) {
        NSString *title = self.xAxisTitleArray[i];
        
        UILabel *label = [self labelWithFrame:CGRectZero textColor:self.xTextColor backColor:LCClear textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:title fontSize:self.axisFontSize];
        if (_comfiguratexAxisLabel) {
            _comfiguratexAxisLabel(label);
        }
        CGSize labelSize = [self sizeWithText:title fontSize:self.axisFontSize];
        label.LC_x = (i + 1) * self.xAxisTextMargin - labelSize.width / 2;
        label.LC_y = self.LC_height - labelSize.height;
        label.LC_width = labelSize.width;
        label.LC_height = labelSize.height;
        [self.scrollView addSubview:label];
        [self.xAxisLabels addObject:label];
    }
    [self.allSubView addObjectsFromArray:self.xAxisLabels];
    // 处理重叠label
    [self handleOverlapViewWithViews:self.xAxisLabels];
    // 画轴
    UIBezierPath *xAxisPath = [UIBezierPath bezierPath];
    [xAxisPath moveToPoint:CGPointMake(0, self.originPoint.y)];
    xAxisMaxX = self.xAxisTitleArray.count * self.xAxisTextMargin + self.xArrowsToText;
    
    // scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(xAxisMaxX + self.chartViewRightMargin, 0);
    
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX, self.originPoint.y)];
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - 5, self.originPoint.y - 5)];
    [xAxisPath moveToPoint:CGPointMake(xAxisMaxX, self.originPoint.y)];
    [xAxisPath addLineToPoint:CGPointMake(xAxisMaxX - 5 , self.originPoint.y + 5)];
    CAShapeLayer *shapeLayer = [self shapeLayerWithPath:xAxisPath lineWidth:self.axisWidth fillColor:LCClear strokeColor:self.axisColor];
    [self.scrollView.layer addSublayer:shapeLayer];
    [self.shapeLayers addObject:shapeLayer];
    
    // xTitleLabel
    UILabel *xTitleLabel = [self labelWithFrame:CGRectZero textColor:self.axisColor backColor:LCClear textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:self.xAxisTitle fontSize:0];
    if (_comfigurateXAxisTitleLabel) {
        _comfigurateXAxisTitleLabel(xTitleLabel);
    }
    [xTitleLabel sizeToFit];
    xTitleLabel.LC_left = xAxisMaxX;
    xTitleLabel.LC_bottom = self.originPoint.y;
    [self.scrollView addSubview:xTitleLabel];
    [self.allSubView addObject:xTitleLabel];
}

#pragma mark - Y轴分割线
- (void)drawYSeparators {
    // 添加Y轴分割线
    for (int i = 0; i < self.yAxisLabels.count; i++) {
        CAShapeLayer *yshapeLayer = nil;
        UIBezierPath *ySeparatorPath = [UIBezierPath bezierPath];
        if (self.showGridding) {
            [ySeparatorPath moveToPoint:CGPointMake(0, self.yAxisLabels[i].LC_centerY)];
            [ySeparatorPath addLineToPoint:CGPointMake(xAxisMaxX, self.yAxisLabels[i].LC_centerY)];
            yshapeLayer = [self shapeLayerWithPath:ySeparatorPath lineWidth:0.5 fillColor:LCClear strokeColor:self.axisColor];
            yshapeLayer.lineDashPattern = @[@(3), @(3)];
            [self.scrollView.layer addSublayer:yshapeLayer];
        } else {
            [ySeparatorPath moveToPoint:CGPointMake(self.yAxisToLeft, self.yAxisLabels[i].LC_centerY)];
            [ySeparatorPath addLineToPoint:CGPointMake(self.yAxisToLeft + 5, self.yAxisLabels[i].LC_centerY)];
            yshapeLayer = [self shapeLayerWithPath:ySeparatorPath lineWidth:self.axisWidth fillColor:LCClear strokeColor:self.axisColor];
            [self.layer addSublayer:yshapeLayer];
        }
        [self.shapeLayers addObject:yshapeLayer];
    }
}

#pragma mark - X轴分割线
- (void)drawXSeparators {
    // 添加X轴分割线
    for (int i = 0; i < self.xAxisLabels.count; i++) {
        CAShapeLayer *xshapeLayer = nil;
        UIBezierPath *xSeparatorPath = [UIBezierPath bezierPath];
        [xSeparatorPath moveToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, self.originPoint.y)];
        if (self.showGridding) {
            [xSeparatorPath addLineToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, self.yAxisLabels.lastObject.LC_centerY)];
            xshapeLayer = [self shapeLayerWithPath:xSeparatorPath lineWidth:0.5 fillColor:LCClear strokeColor:self.axisColor];
            xshapeLayer.lineDashPattern = @[@(3), @(3)];
        } else {
            [xSeparatorPath addLineToPoint:CGPointMake(self.xAxisLabels[i].LC_centerX, self.originPoint.y - 5)];
            xshapeLayer = [self shapeLayerWithPath:xSeparatorPath lineWidth:self.axisWidth fillColor:LCClear strokeColor:self.axisColor];
        }
        [self.scrollView.layer addSublayer:xshapeLayer];
        [self.shapeLayers addObject:xshapeLayer];
    }
}

#pragma mark - 创建,显示数据label
- (void)drawDisplayLabels {
    for (int i = 0 ; i < self.dataSource.count; i++) {
        LCChartViewDataModel *model = self.dataSource[i];
        NSMutableArray *plotLabels = [NSMutableArray array];
        for (int j = 0; j < model.plots.count; j++) {
            NSString *value = model.plots[j];
            NSString *title = [self decimalwithFormat:@"0.00" floatV:value.floatValue];
            if (![self isPureFloat:title]) {
                title = [NSString stringWithFormat:@"%.0f", title.floatValue];
            }
            if (value.floatValue < 0) {
                value = @"0";
            }
            // 添加point处显示的Label
            NSString *reTitle = self.showPlotsLabelPersent ? [NSString stringWithFormat:@"%@%%", title] : title;
            UILabel *label = [self labelWithFrame:CGRectZero textColor:self.plotsLabelColor backColor:LCClear textAlignment:NSTextAlignmentCenter lineNumber:1 tiltle:reTitle fontSize:self.plotsLabelFontSize];
            label.tag = j;
            if (self.PlotsLabelCanClick) {
                label.userInteractionEnabled = YES;
                [label addGestureRecognizer:[self tapWithTarget:self action:@selector(plotsLabelDidClick:)]];
            }
            [label sizeToFit];
            if (self.chartViewType == LCChartViewTypeLine) {
                label.LC_centerX = self.xAxisLabels[j].LC_centerX;
            }
            else if (self.chartViewType == LCChartViewTypeBar || self.chartViewType == LCChartViewTypeLineAndBar) {
                if (self.dataSource.count == 1) {
                    label.LC_centerX = self.xAxisLabels[j].LC_centerX;
                } else if (self.dataSource.count == 2) {
                    if (i == 0) {
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX - self.barWidth / 2;
                    } else if (i == 1) {
                        label.LC_centerX = self.xAxisLabels[j].LC_centerX + self.barWidth / 2;
                    }
                }
            }
            label.LC_bottom = [self getValueHeightWith:value] - self.displayPlotToLabel;
            [self.scrollView addSubview:label];
            [plotLabels addObject:label];
            [self.allSubView addObjectsFromArray:plotLabels];
            // 处理重叠label
            [self handleOverlapViewWithViews:plotLabels];
        }
    }
}

#pragma mark - 描绘ChartViewLine折线图
/** 描述折线图数据点 */
- (void)drawLineChartViewPots {
    for (int i = 0; i < self.dataSource.count; i++) {
        LCChartViewDataModel *model = self.dataSource[i];
        if (model.plotButtons.count) {
            [model.plotButtons removeAllObjects];
            [model.plotButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        // 画点
        for (int j = 0; j < model.plots.count; j++) {
            // 添加数据点button
            UIButton *button = [self buttonWithFrame:CGRectZero normalImage:nil bgImage:nil target:self action:@selector(plotsButtonDidClick:) normalColor:nil selectcColor:nil backColor:LCClear title:nil fontSize:0];
            if (self.plotsButtonImage.length && self.plotsButtonSelectedImage.length) {
                [button setBackgroundImage:Image(self.plotsButtonImage) forState:UIControlStateNormal];
                [button setBackgroundImage:Image(self.plotsButtonSelectedImage) forState:UIControlStateSelected];
            } else {
                [button setBackgroundImage:[self imageFromColor:self.plotsButtonColor rect:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)] forState:UIControlStateNormal];
                [button setBackgroundImage:[self imageFromColor:self.plotsButtonSelectedColor rect:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)] forState:UIControlStateSelected];
            }
            button.tag = j;
            button.userInteractionEnabled = self.PlotsLabelCanClick;
            button.LC_size = CGSizeMake(self.plotsButtonWH, self.plotsButtonWH);
            // LCChartViewTypeLine
            if (self.chartViewType == LCChartViewTypeLine || self.dataSource.count == 1) {
                button.center = CGPointMake(self.xAxisLabels[j].LC_centerX, [self getValueHeightWith:model.plots[j]]);
                // LCChartViewTypeLineAndBar
            } else if (self.chartViewType == LCChartViewTypeLineAndBar) {
                if (i == 0) {
                    button.center = CGPointMake(self.xAxisLabels[j].LC_centerX - self.barWidth / 2, [self getValueHeightWith:model.plots[j]]);
                } else if (i == 1) {
                    button.center = CGPointMake(self.xAxisLabels[j].LC_centerX + self.barWidth / 2, [self getValueHeightWith:model.plots[j]]);
                }
            }
            button.layer.cornerRadius = self.plotsButtonWH / 2;
            button.layer.masksToBounds = YES;
            [self.allSubView addObject:button];
            [model.plotButtons addObject:button];
            if (button.userInteractionEnabled) {
                if (j == 0) {
                    [self plotsButtonDidClick:button];
                }
            }
            [self.scrollView addSubview:button];
            // 处理重叠点
            [self handleOverlapViewWithViews:model.plotButtons];
        }
    }
}

/** 根据数据点画线 */
- (void)drawLineChartViewLines {
    for (LCChartViewDataModel *model in self.dataSource) {
        UIBezierPath *lineChartPath = [UIBezierPath bezierPath];
        // 填充
        if (self.lineChartFillView) {
            [lineChartPath moveToPoint:CGPointMake(model.plotButtons.firstObject.center.x, self.originPoint.y)];
            for (int i = 0; i < model.plotButtons.count; i++) {
                [lineChartPath addLineToPoint:model.plotButtons[i].center];
            }
            [lineChartPath addLineToPoint:CGPointMake(model.plotButtons.lastObject.center.x, self.originPoint.y)];
            self.lineShapeLayer = [self shapeLayerWithPath:lineChartPath lineWidth:self.lineChartWidth fillColor:self.lineChartFillViewColor strokeColor:model.lineColor];
        } else {
            // 不填充
            [lineChartPath moveToPoint:model.plotButtons.firstObject.center];
            for (int i = 1; i < model.plotButtons.count; i++) {
                [lineChartPath addLineToPoint:model.plotButtons[i].center];
            }
            self.lineShapeLayer = [self shapeLayerWithPath:lineChartPath lineWidth:self.lineChartWidth fillColor:LCClear strokeColor:model.lineColor];
        }
        [self.shapeLayers addObject:self.lineShapeLayer];
        [self.scrollView.layer addSublayer:self.lineShapeLayer];
    }
}

#pragma mark - ChartViewBar柱状图
/** 根据显示点描绘柱状图 */
- (void)drawBarChartViewBars {
    for (int i = 0; i < self.dataSource.count; i++) {
        LCChartViewDataModel *model = self.dataSource[i];
        for (int j = 0; j < model.plots.count; j++) {
            UIBezierPath *barPath = [UIBezierPath bezierPath];
            CGFloat startPointX = 0;
            switch (self.dataSource.count) {
                case 1:{
                    startPointX = self.xAxisLabels[j].LC_centerX;
                }
                    break;
                case 2:{
                    if (i == 0) {
                        startPointX = self.xAxisLabels[j].LC_centerX - self.barWidth / 2;
                    } else if (i == 1) {
                        startPointX = self.xAxisLabels[j].LC_centerX + self.barWidth / 2;
                    }
                }
                    break;
                default:
                    break;
            }
            [barPath moveToPoint:CGPointMake(startPointX, self.originPoint.y)];
            [barPath addLineToPoint:CGPointMake(startPointX, [self getValueHeightWith:model.plots[j]])];
            self.barShapeLayer = [self shapeLayerWithPath:barPath lineWidth:self.barWidth fillColor:model.barColor strokeColor:model.barColor];
            [self.shapeLayers addObject:self.barShapeLayer];
            [self.scrollView.layer insertSublayer:self.barShapeLayer below:self.lineShapeLayer];
        }
    }
}

#pragma mark - private method
/** 处理label重叠显示的情况 */
- (void)handleOverlapViewWithViews:(NSArray <UIView *>*)views {
    // 如果Label的文字有重叠，那么隐藏
    UIView *firstView = views.firstObject;
    for (int i = 1; i < views.count; i++) {
        UIView *view = views[i];
        CGFloat maxX = CGRectGetMaxX(firstView.frame);
        if ((maxX + 3) > view.LC_x) {
            view.hidden = YES;
        }else{
            view.hidden = NO;
            firstView = view;
        }
    }
}

- (NSString *)decimalwithFormat:(NSString *)format  floatV:(float)floatV {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:format];
    return [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

- (CGFloat)getValueHeightWith:(NSString *)value {
    return dataChartHeight - value.floatValue / self.yAxisMaxValue * dataChartHeight + self.topMargin;
}

/** 判断numStr是整数或者小数 */
- (BOOL)isPureFloat:(NSString *)numStr {
    CGFloat num = [numStr floatValue];
    int i = num;
    CGFloat result = num - i;
    // 当不等于0时，是小数
    return result != 0;
}

/** 获取指定文本的size */
- (CGSize)sizeWithText:(NSString *)text fontSize:(CGFloat)fontSize {
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]};
    return [text sizeWithAttributes:attr];
}

/** 给path添加动画 */
- (CAShapeLayer *)shapeLayerWithPath:(UIBezierPath *)path lineWidth:(CGFloat)lineWidth fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.fillColor = fillColor.CGColor;
    shapeLayer.strokeColor = strokeColor.CGColor;
    shapeLayer.lineCap = kCALineCapButt;
    shapeLayer.lineJoin = kCALineJoinBevel;
    shapeLayer.path = path.CGPath;
    return shapeLayer;
}

- (void)addAnimation:(NSArray <CAShapeLayer *>*)shapeLayers KeyPath:(NSString *)KeyPath delegate:(id<CAAnimationDelegate>)delegate duration:(NSTimeInterval)duration animationKey:(NSString *)animationKey {
    if (!shapeLayers.count) {
        return;
    }
    for (CAShapeLayer *shapeLayer in shapeLayers) {
        CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:KeyPath];
        stroke.delegate = delegate;
        stroke.duration = duration;
        stroke.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        stroke.fromValue = [NSNumber numberWithFloat:0.0f];
        stroke.toValue = [NSNumber numberWithFloat:1.0f];
        [shapeLayer addAnimation:stroke forKey:animationKey];
    }
}

/** 创建label */
- (UILabel *)labelWithFrame:(CGRect)frame textColor:(UIColor *)textColor backColor:(UIColor *)backColor textAlignment:(NSTextAlignment)textAlignment lineNumber:(NSInteger)number tiltle:(NSString *)title fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.textColor = textColor;
    label.backgroundColor = backColor;
    label.textAlignment = textAlignment;
    label.numberOfLines = number;
    if (fontSize != 0) {
        label.font = [UIFont systemFontOfSize:fontSize];
    }
    return label;
}

/** 创建tap手势 */
- (UITapGestureRecognizer *)tapWithTarget:(id)target action:(SEL)action {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    return tap;
}

/** 创建button */
- (UIButton *)buttonWithFrame:(CGRect)frame normalImage:(NSString *)image bgImage:(NSString *)bgImage target:(id)target action:(SEL)action normalColor:(UIColor *)color selectcColor:(UIColor *)selectedColor backColor:(UIColor *)backColor title:(NSString *)title fontSize:(CGFloat)fontSize {
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    if (image.length) {
        [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    }
    if (bgImage.length) {
        [button setBackgroundImage:[UIImage imageNamed:bgImage] forState:UIControlStateNormal];
    }
    if (title.length) {
        if (color) {
            [button setTitleColor:color forState:UIControlStateNormal];
        }
        if (selectedColor) {
            [button setTitleColor:selectedColor forState:UIControlStateSelected];
        }
        [button setTitle:title forState:UIControlStateNormal];
        if (fontSize != 0) {
            button.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        }
    }
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (backColor) {
        button.backgroundColor = backColor;
    }
    return button;
}

/** 根据颜色生成图片 */
- (UIImage *)imageFromColor:(UIColor *)color rect:(CGRect)rect{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/** 创建scrollview */
- (UIScrollView *)scrollViewWithFrame:(CGRect)frame delegate:(id<UIScrollViewDelegate>)delegete showsHorizontal:(BOOL)horizontal showVertical:(BOOL)vertical pagingEnable:(BOOL)page bounces:(BOOL)bounces backColor:(UIColor *)backColor {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.delegate = delegete;
    scrollView.showsHorizontalScrollIndicator = horizontal;
    scrollView.showsVerticalScrollIndicator = vertical;
    scrollView.pagingEnabled = page;
    scrollView.bounces = bounces;
    scrollView.backgroundColor = backColor;
    return scrollView;
}

#pragma mark - response

- (void)plotsButtonDidClick:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(chartView:didClickpPotsLabel:)]) {
        [_delegate chartView:self didClickpPotsLabel:button.tag];
    }
}

- (void)plotsLabelDidClick:(UITapGestureRecognizer *)tap {
    if ([_delegate respondsToSelector:@selector(chartView:didClickpPotsLabel:)]) {
        [_delegate chartView:self didClickpPotsLabel:tap.view.tag];
    }
}

#pragma mark - scrollview的手势支持
/** 双击 */
- (void)tapGesture:(UITapGestureRecognizer *)tap {
    self.xAxisTextMargin *= 1.5;
    self.orginXAxisMargin = self.xAxisTextMargin;
    [self drawChartView];
}

/** 捏合 */
- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer {
    self.xAxisTextMargin = recognizer.scale * self.orginXAxisMargin;
    if (self.xAxisTextMargin < 5) {
        self.xAxisTextMargin = 5;
    }
    if (self.chartViewType == LCChartViewTypeBar) {
        if (self.xAxisTextMargin < self.barWidth + 2) {
            self.xAxisTextMargin = self.barWidth + 2;
        }
    }
    self.showAnimation = NO;
    [self drawChartView];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.orginXAxisMargin = self.xAxisTextMargin;
        self.showAnimation = self.orginAnimation;
    }
}

/** addAnimation */
- (void)addAnimation {
    [self addAnimation:self.shapeLayers KeyPath:@"strokeEnd" delegate:nil duration:duration animationKey:@"yAxisPathAnimation"];
    
    [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.alpha = 0.0;
    }];
    
    [self.allSubView enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView animateWithDuration:duration animations:^{
            obj.alpha = 1.0;
        }];
    }];
}

#pragma mark - setter

- (void)setXAxisTextMargin:(CGFloat)xAxisTextMargin {
    _xAxisTextMargin = xAxisTextMargin;
    _xArrowsToText = xAxisTextMargin;
}

- (void)setChartViewXAxisTextMargin:(CGFloat)xAxisTextMargin {
    _xAxisTextMargin = xAxisTextMargin;
    _orginXAxisMargin = xAxisTextMargin;
}

#pragma mark - getter

- (NSMutableArray<UILabel *> *)yAxisLabels {
    if (!_yAxisLabels) {
        _yAxisLabels = [[NSMutableArray alloc] init];
    }
    return _yAxisLabels;
}

- (NSMutableArray<UILabel *> *)xAxisLabels {
    if (!_xAxisLabels) {
        _xAxisLabels = [[NSMutableArray alloc] init];
    }
    return _xAxisLabels;
}

- (NSMutableArray<CAShapeLayer *> *)shapeLayers {
    if (!_shapeLayers) {
        _shapeLayers = [[NSMutableArray alloc] init];
    }
    return _shapeLayers;
}

- (NSMutableArray<UIView *> *)allSubView {
    if (!_allSubView) {
        _allSubView = [[NSMutableArray alloc] init];
    }
    return _allSubView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [self scrollViewWithFrame:CGRectZero delegate:self showsHorizontal:NO showVertical:NO pagingEnable:NO bounces:NO backColor:LCClear];
        // 双击事件
        [_scrollView addGestureRecognizer:self.twoTap];
        // 捏合手势
        [_scrollView addGestureRecognizer:self.pinch];
    }
    return _scrollView;
}

- (UITapGestureRecognizer *)twoTap {
    if (!_twoTap) {
        _twoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        _twoTap.numberOfTapsRequired = 2;
    }
    return _twoTap;
}

- (UIPinchGestureRecognizer *)pinch {
    if (!_pinch) {
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    }
    return _pinch   ;
}

- (CGFloat)xArrowsToText {
    if (_xArrowsToText < 8) {
        return 8;
    }
    return _xArrowsToText;
}

@end

@implementation LCChartViewDataModel

- (instancetype)init {
    if (self = [super init]) {
        _plotButtons = [NSMutableArray array];
    }
    return self;
}

+ (LCChartViewDataModel *)getModelWithLineColor:(UIColor *)lineColor BarColor:(UIColor *)barColor plots:(NSArray<NSString *> *)plots {
    LCChartViewDataModel *model = [[LCChartViewDataModel alloc] init];
    if (lineColor) {
        model.lineColor = lineColor;
    }
    if (barColor) {
        model.barColor = barColor;
    }
    model.plots = plots;
    return model;
}

@end
