//
//  PSSCycleView.m
//  PSSCycleView
//
//  Created by 山不在高 on 17/7/9.
//  Copyright © 2017年 山不在高. All rights reserved.
//

#import "PSSCycleView.h"

#define PSSCycleViewCellID @"PSSCycleViewCellID"


@interface PSSCycleView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableDictionary *viewDict;

@end

@implementation PSSCycleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addCollectionViewInThis];
        [self addPageControl];
    }
    return self;
}

- (void)refreshCycle
{
    [self.viewDict removeAllObjects];
    _pageControl.numberOfPages = [self.delegate respondsToSelector:@selector(numberOfItemsInCycleView:)] ? [self.delegate numberOfItemsInCycleView:self] : 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.collectionView reloadData];
}

// 添加CollectionView
- (void)addCollectionViewInThis
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:collectionView];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView = collectionView;
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:PSSCycleViewCellID];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
}

- (void)addPageControl
{
    CGFloat hei = 20;
    CGRect rect = CGRectMake(0, self.bounds.size.height - hei, self.bounds.size.width, hei);
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:rect];
    [self addSubview:pageControl];
    self.pageControl = pageControl;
}

- (void)timerRunning
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.pageControl.currentPage + 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PSSCycleViewCellID forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    if (!self.viewDict[@(indexPath.row)]) {
        NSInteger count = [self.delegate numberOfItemsInCycleView:self];
        if (indexPath.row == 0) {
            if (self.viewDict[@(count)]) {
                self.viewDict[@(indexPath.row)] = self.viewDict[@(count)];
            } else {
                UIView *view = [self.delegate cycleView:self cell:cell forItemAtIndex:count - 1];
                self.viewDict[@(indexPath.row)] = view;
                self.viewDict[@(count)] = view;
            }
        } else if (indexPath.row == count + 1) {
            if (self.viewDict[@(1)]) {
                self.viewDict[@(indexPath.row)] = self.viewDict[@(1)];
            } else {
                UIView *view = [self.delegate cycleView:self cell:cell forItemAtIndex:0];
                self.viewDict[@(indexPath.row)] = view;
                self.viewDict[@(1)] = view;
            }
        } else {
            self.viewDict[@(indexPath.row)] = [self.delegate cycleView:self cell:cell forItemAtIndex:indexPath.row - 1];
        }
    } else {
        UIView *view = self.viewDict[@(indexPath.row)];
        for (UIView *subView in cell.contentView.subviews) {
            [subView removeFromSuperview];
        }
        [cell.contentView addSubview:view];
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInCycleView:)]) {
        return [self.delegate numberOfItemsInCycleView:self] + 2;
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectItemAtIndex:)]) {
        [self.delegate cycleView:self didSelectItemAtIndex:indexPath.row - 1];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self adjustPageWithScrollView:scrollView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self adjustPageWithScrollView:scrollView];
}

- (void)adjustPageWithScrollView:(UIScrollView *)scrollView
{
    NSInteger totalCount = [self.delegate respondsToSelector:@selector(numberOfItemsInCycleView:)] ? [self.delegate numberOfItemsInCycleView:self] : 0;
    if (totalCount == 0) {
        return;
    }
    CGFloat wid = self.bounds.size.width;
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger i = offsetX / wid;
    self.pageControl.currentPage = i - 1;
    if (i == 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:totalCount inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.pageControl.currentPage = totalCount - 1;
    } else if (i == totalCount + 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        self.pageControl.currentPage = 0;
    }
}


- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    if (duration != 0) {
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(timerRunning) userInfo:nil repeats:true];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

- (NSMutableDictionary *)viewDict
{
    if (_viewDict == nil) {
        _viewDict = [NSMutableDictionary dictionary];
    }
    return _viewDict;
}

@end










