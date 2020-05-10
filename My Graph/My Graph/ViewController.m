//
//  ViewController.m
//  My Graph
//
//  Created by VyNV on 10/1/15.
//  Copyright (c) 2015 VyNV. All rights reserved.
//

#import "ViewController.h"
#import "MYGraphView.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet MYGraphView *mGraphView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSMutableArray *graphData = [[NSMutableArray alloc]init];
	for (int i = 0 ; i <= 9; i++) {
		GraphItem *graphItem = [[GraphItem alloc]init];
		graphItem.stringLabel = [NSString stringWithFormat:@"Label %d", i];
		NSMutableArray *itemValue = [[NSMutableArray alloc]init];
		for (int y = 0 ; y < 3; y++) {
			GraphItemPoint *item = [[GraphItemPoint alloc]init];
			item.itemID = y;
			item.value = (float) [self getRandomNumberBetween:5 to:18];
			[itemValue addObject:item];
		}
		graphItem.valueArray = itemValue;
		[graphData addObject:graphItem];
	}
	
	[self.mGraphView setGraphValues: graphData];
	[self.mGraphView setDelegate:self];
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
	
	return from + arc4random() % (to-from+1);
}

#pragma My graph view delegate
-(UIColor *)colorForItem:(int)itemID{
	switch (itemID) {
		case 0:{
			return [UIColor greenColor];
		}
		case 1:{
			return [UIColor blueColor];
		}
		case 2:{
			return [UIColor redColor];
		}
		default:{
			return [UIColor blackColor];
		}
	}
}

@end
