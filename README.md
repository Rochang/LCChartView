# LCChartView
快速展示折线图, 柱状图, 饼状图, 环形图, 其中折线图、柱状图支持tap缩放, pan缩放. 
![arc.gif](https://github.com/Rochang/LCChartView/blob/master/line.gif)
![arc.gif](https://github.com/Rochang/LCChartView/blob/master/bar.gif)
![arc.gif](https://github.com/Rochang/LCChartView/blob/master/pie.gif)
![arc.gif](https://github.com/Rochang/LCChartView/blob/master/arc.gif)


# 使用说明
```obj
// 数据
    LCChartViewModel *model0 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"1组"];
    LCChartViewModel *model1 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"2组"];
    LCChartViewModel *model2 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"3组"];
    LCChartViewModel *model3 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"4组"];
    LCChartViewModel *model4 = [LCChartViewModel modelWithColor:RandomColor plots:[self randomArrayWithCount:12] project:@"5组"];

// 折线图
  LCChartView *chartViewLine = [LCChartView chartViewWithType:LCChartViewTypeLine];
  chartViewLine.frame = CGRectMake(0, 64, self.view.LC_width, 250);
  [self.chartViewLine showChartViewWithYAxisMaxValue:1000 dataSource:@[model0, model1]];

// 柱状图
  LCChartView *chartViewLine = [LCChartView chartViewWithType:LCChartViewTypeBar];
  chartViewLine.frame = CGRectMake(0, 64, self.view.LC_width, 250);
  [self.chartViewLine showChartViewWithYAxisMaxValue:1000 dataSource:@[model, model1, model2, model3, model4]];
  
// 饼状图
  LCPieViewModel *modelP0 = [LCPieViewModel modelWithValue:arc4random_uniform(100) color:[UIColor redColor] text:@"1组"];
  LCPieViewModel *modelP1 = [LCPieViewModel modelWithValue:arc4random_uniform(100) color:[UIColor grayColor] text:@"2组"];
  LCPieViewModel *modelP2 = [LCPieViewModel modelWithValue:arc4random_uniform(100) color:[UIColor blueColor] text:@"3组"];

  LCPieView *pieView = [LCPieView pieView];
  pieView.frame = CGRectMake(0, 650, self.view.LC_width, 200);
  [pieView showPieViewWithDataSource:@[modelP0, modelP1, modelP2]];
  
// 环形图
LCArcView *arcView = [[LCArcView alloc] initWithFrame:CGRectMake(0, 900, self.view.LC_width, 150)];
[arcView showArcViewWithBgStartAngle:0 endBgAngle:M_PI * 2 bgAnimation:NO StartAngle:0 endAngle:M_PI animaion:YES];

/* 每种图形样式都支持颜色,文字的自定义设置,修复对应的属性即可 */
```
