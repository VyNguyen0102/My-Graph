//
//  MYGraphView.m
//  My Graph
//
//  Created by VyNV on 10/1/15.
//  Copyright (c) 2015 VyNV. All rights reserved.
//

#import "MYGraphView.h"


#define kDefaultColor [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0]
#define kPointRadius 3

const BOOL kDisplayValueLabel = YES;
const BOOL kDisplayAllValue = YES;
const BOOL kStartFromZero = YES;

const int kMaxStepCount = 10;
const int kRulerSpliter = 10;
const int kFooterStepCount = 5;

@implementation GraphItemPoint
@end
@implementation GraphItem
@end

@implementation MYGraphView
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
	if (self = [super initWithCoder:aDecoder]) {
		[self load];
	}
	return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
		[self load];
	}
	return self;
}
-(void)load{
	UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"GraphView" owner:self options:nil] firstObject];
	[self addSubview:view];
	view.frame = self.bounds;
}
-(void)layoutSubviews{
	[super layoutSubviews];
	[self fillData];
}

-(void)fillData{
	float minValue = kStartFromZero ? 0 :[self getMinGraphValue];
	float maxValue = [self getMaxGraphValue];
	float step = [self getGetStepWithMinValue:minValue maxValue:maxValue];
	minValue = [self fRoundDown:minValue withStep:step];
	maxValue = [self fRoundUp:maxValue withStep:step];
	// clear old data;
	for (UIView *view in self.leftRuler.subviews){
		[view removeFromSuperview];
	}
	self.leftRuler.layer.sublayers = nil;
	//
	for (UIView *view in self.footerView.subviews){
		[view removeFromSuperview];
	}
	self.footerView.layer.sublayers = nil;
	//
	for (UIView *view in self.mainScrollContent.subviews){
		[view removeFromSuperview];
	}
	self.mainScrollContent.layer.sublayers = nil;
	//
	[self drawLeftRulerWithMinValue:(float)minValue MaxValue:(float)maxValue Step:(float)step];
	[self drawFooter];
	[self drawContent];
	[self drawScrollaberContent:(float)minValue MaxValue:(float)maxValue Step:(float)step];
}
-(void)drawGraph{

}
-(void)drawLeftRulerWithMinValue:(float)minValue MaxValue:(float)maxValue Step:(float)step{
	[self drawText:@"left ruler" onView:self.leftRuler at:CGPointMake(5, 10)];
	// Drawing ruler
	float marginLeft = self.leftRuler.frame.size.width;
	float yBottom = self.frame.size.height - self.footerView.frame.size.height;
	CGPoint frmPoint = CGPointMake(marginLeft, 0);
	CGPoint toPoint = CGPointMake(marginLeft, yBottom);
	[self drawLineAt:self.leftRuler From:frmPoint to:toPoint];
	
	int stepCount = (maxValue - minValue )/step;
	
	float layoutStep = yBottom / stepCount;
	float startValue = maxValue;
	for (float i = 0; i <= stepCount; i += 1) {
		float ySpliter = i * layoutStep;
		CGPoint fPoint = CGPointMake(marginLeft, ySpliter);
		CGPoint tPoint = CGPointMake(marginLeft - kRulerSpliter, ySpliter);
		[self drawLineAt:self.leftRuler From:fPoint to:tPoint];
		CGPoint lblPoint = CGPointMake(kRulerSpliter, ySpliter);
		[self drawText:[self stringValue:startValue] onView:self.leftRuler at:lblPoint];
		startValue -= step;
	}
}

-(NSString *)stringValue:(float)value{
	return [NSString stringWithFormat:@"%f",value];
}
-(void)drawFooter{
	[self drawText:@"this is footer" onView:self.footerView at:CGPointMake(200, 40)];
	// Drawing ruler
	float marginLeft = self.leftRuler.frame.size.width;
	CGPoint frmPoint = CGPointMake(marginLeft, 0);
	CGPoint toPoint = CGPointMake(self.frame.size.width, 0);
	[self drawLineAt:self.footerView From:frmPoint to:toPoint];
}
-(void)drawContent{
	//Drawing some thing not scroll
}
-(void)drawScrollaberContent:(float)minValue MaxValue:(float)maxValue Step:(float)step{
	// draw
	float xPoint = 30;
	float footerStepW = [self getFooterStepWidth];
	float yPoint;
	float yBottom = self.frame.size.height - self.footerView.frame.size.height;
	float layoutValue = yBottom / (maxValue - minValue);
	
	NSMutableDictionary *previousValue = [[NSMutableDictionary alloc]init];
	for (GraphItem *item in self.graphValues) {
		for (GraphItemPoint *itemPoint in item.valueArray) {
			yPoint = ( maxValue - itemPoint.value)* layoutValue;
			CGPoint point = CGPointMake(xPoint, yPoint);
			UIColor *color = self.delegate ? [self.delegate colorForItem:itemPoint.itemID] : kDefaultColor;
			[self drawPoint:self.mainScrollContent at:point color:color];
			if(kDisplayValueLabel){
				[self drawText:[self stringValue:itemPoint.value] onView:self.mainScrollContent at:CGPointMake(xPoint, yPoint - 20)];
			}
			NSString *key = [NSString stringWithFormat:@"%d", itemPoint.itemID];
			if ([previousValue objectForKey:key]) {
				NSValue *value = [previousValue objectForKey:key];
				[self drawDashedLineAt:self.mainScrollContent From:point to:[value CGPointValue] color:color];
			}
			[previousValue setObject:[NSValue valueWithCGPoint:point] forKey:key];
		}
		[self drawLineAt:self.mainScrollContent From:CGPointMake(xPoint, yBottom) to:CGPointMake(xPoint, yBottom + kRulerSpliter)];
		[self drawText:item.stringLabel onView:self.mainScrollContent at:CGPointMake(xPoint, yBottom + 2* kRulerSpliter)];
		xPoint += footerStepW;
	}
	// set content size
	CGRect contentRect = self.mainScrollView.frame;
	float contentWidth = MAX((self.frame.size.width - self.leftRuler.frame.size.width), xPoint);
	self.mainScrollContent.frame = CGRectMake(contentRect.origin.x
											  , contentRect.origin.y, contentWidth , self.frame.size.height);
	[self.mainScrollView setContentSize:self.mainScrollContent.frame.size];
}
-(float)getFooterStepWidth{
	return self.mainScrollContent.frame.size.width / kFooterStepCount;
}
-(UIColor *)colorForLine:(int)lineID{
	return [UIColor redColor];
}
#pragma Calculator

-(float)getMaxGraphValue{
	float maxValue = 0;
	for (GraphItem *item in self.graphValues) {
		for (GraphItemPoint *itemPoint in item.valueArray) {
			if (maxValue < itemPoint.value) {
				maxValue = itemPoint.value;
			}
		}
	}
	return maxValue;
}

-(float)getMinGraphValue{
	float minValue = MAXFLOAT;
	for (GraphItem *item in self.graphValues) {
		for (GraphItemPoint *itemPoint in item.valueArray) {
			if (minValue > itemPoint.value) {
				minValue = itemPoint.value;
			}
		}
	}
	return minValue;
}
-(float)fRoundUp:(float)number withStep:(float)step{
	float count = number/step;
	count = ceilf(count);
	return count * step;
}
-(float)fRoundDown:(float)number withStep:(float)step{
	float count = number/step;
	count = floorf(count);
	return count * step;
}
-(float)getGetStepWithMinValue:(float)minValue maxValue:(float)maxValue{
	float maxRange = maxValue - minValue;
	float step = maxRange / kMaxStepCount;
	if (step <= 0.1) {
		return 0.1;
	} else if(step <= 1){
		return 1;
	} else if(step <= 5){
		return 5;
	} else if(step <= 10){
		return 10;
	} else if(step <= 100){
		return [self fRoundUp:step withStep:10];
	} else {
		NSString *numberString = [NSString stringWithFormat:@"%.0f",step];
		return [self fRoundUp:step withStep:(powf(10,([numberString length]-1)))];
	}
}

#pragma Drawing Util
-(void)drawLineAt:(UIView *)view From:(CGPoint)frmPoint to:(CGPoint)toPoint color:(UIColor *)color{
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:frmPoint];
	[path addLineToPoint:toPoint];
	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = [path CGPath];
	shapeLayer.strokeColor = [color CGColor];
	shapeLayer.lineWidth = 1.0;
	shapeLayer.fillColor = [[UIColor clearColor] CGColor];
	[view.layer addSublayer:shapeLayer];
}
-(void)drawDashedLineAt:(UIView *)view From:(CGPoint)frmPoint to:(CGPoint)toPoint color:(UIColor *)color{
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:frmPoint];
	[path addLineToPoint:toPoint];
	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = [path CGPath];
	shapeLayer.strokeColor = [color CGColor];
	shapeLayer.lineWidth = 1.0;
	[shapeLayer setLineDashPattern:[NSArray arrayWithObjects:
	  [NSNumber numberWithInt:10],
	  [NSNumber numberWithInt:5],
	  nil]];
	shapeLayer.fillColor = [[UIColor clearColor] CGColor];
	[view.layer addSublayer:shapeLayer];
}
-(void)drawLineAt:(UIView *)view From:(CGPoint)frmPoint to:(CGPoint)toPoint{
	[self drawLineAt:view From:frmPoint to:toPoint color:kDefaultColor];
}
-(void)drawPoint:(UIView *)view at:(CGPoint)point color:(UIColor *)color{
	CGRect rect = CGRectMake(point.x - kPointRadius, point.y - kPointRadius, 2 * kPointRadius, 2 * kPointRadius);
	UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
	
	CAShapeLayer *shapeLayer = [CAShapeLayer layer];
	shapeLayer.path = [path CGPath];
	shapeLayer.strokeColor = [color CGColor];
	shapeLayer.lineWidth = 1.0;
	shapeLayer.fillColor = [[UIColor clearColor] CGColor];
	[view.layer addSublayer:shapeLayer];
}
-(void)drawPoint:(UIView *)view at:(CGPoint)point{
	[self drawPoint:view at:point color:kDefaultColor];
}
// Drawing some text on view
-(void)drawText:(NSString *)text onView:(UIView *)view at:(CGPoint)position color:(UIColor *)color{
	CGSize textSize = CGSizeMake(0, 0);
	UILabel *lbl=[[UILabel alloc]initWithFrame:(CGRect){.origin = position, .size=textSize}];
	lbl.text = text;
	lbl.textAlignment = NSTextAlignmentCenter;
	lbl.textColor = kDefaultColor;
	lbl.font = [UIFont fontWithName:@"AlNile" size:10.0];
	CGFloat fixedWidth = lbl.frame.size.width;
	CGSize newSize = [lbl sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
	CGRect newFrame = lbl.frame;
	newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
	lbl.frame = newFrame;
	[view addSubview:lbl];
}
-(void)drawText:(NSString *)text onView:(UIView *)view at:(CGPoint)position{
	[self drawText:text onView:view at:position color:kDefaultColor];
}
@end
