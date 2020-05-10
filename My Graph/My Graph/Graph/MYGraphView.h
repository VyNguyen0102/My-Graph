//
//  MYGraphView.h
//  My Graph
//
//  Created by VyNV on 10/1/15.
//  Copyright (c) 2015 VyNV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MYGraphView : UIView
@property (nonatomic,strong) id delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *mainScrollContent;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *leftRuler;

@property (strong, nonatomic) NSMutableArray *graphValues;

-(void)fillData;
@end

@interface GraphItemPoint: NSObject
@property int itemID;
@property float value;
@end

@interface GraphItem: NSObject
@property NSString *stringLabel;
@property NSMutableArray *valueArray;
@end

// Protocol definition starts here
@protocol MYGraphViewDelegate <NSObject>
@required

-(UIColor *)colorForItem:(int)itemID;

@end
