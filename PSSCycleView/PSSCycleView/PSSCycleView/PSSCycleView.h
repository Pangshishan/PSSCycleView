//
//  PSSCycleView.h
//  PSSCycleView
//
//  Created by 山不在高 on 17/7/9.
//  Copyright © 2017年 山不在高. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSSCycleView;
@protocol PSSCycleViewDelegate <NSObject>

- (UIView *)cycleView:(PSSCycleView *)cycleView  cell:(UICollectionViewCell *)cell forItemAtIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInCycleView:(PSSCycleView *)cycleView;
- (void)cycleView:(PSSCycleView *)cycleView didSelectItemAtIndex:(NSInteger)index;

@end

@interface PSSCycleView : UIView

@property (nonatomic, weak) id<PSSCycleViewDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval duration; //

- (void)refreshCycle;

@end
