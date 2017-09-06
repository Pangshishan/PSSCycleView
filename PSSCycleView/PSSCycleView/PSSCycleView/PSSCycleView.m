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
//    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [self.collectionView setContentOffset:CGPointMake(self.bounds.size.width * 1, 0) animated:NO];
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
    collectionView.bounces = NO;
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
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.pageControl.currentPage + 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PSSCycleViewCellID forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    if (self.viewDict[@(indexPath.row)] == nil) {
        NSInteger count = [self.delegate numberOfItemsInCycleView:self];
        if (indexPath.row == 0) {
            UIView *view = [self.delegate cycleView:self cell:cell forItemAtIndex:count - 1];
            self.viewDict[@(indexPath.row)] = view;
        } else if (indexPath.row == count + 1) {
            UIView *view = [self.delegate cycleView:self cell:cell forItemAtIndex:0];
            self.viewDict[@(indexPath.row)] = view;
        } else {
            self.viewDict[@(indexPath.row)] = [self.delegate cycleView:self cell:cell forItemAtIndex:indexPath.row - 1];
        }
    }
    UIView *view = self.viewDict[@(indexPath.row)];
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell.contentView addSubview:view];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInCycleView:)]) {
        NSInteger count = [self.delegate numberOfItemsInCycleView:self];
        if (count == 0) {
            return 0;
        } else if (count == 1) {
            return 1;
        } else {
            return count + 2;
        }
    }
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInCycleView:)]) {
        count = [self.delegate numberOfItemsInCycleView:self];
    }
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectItemAtIndex:)]) {
        [self.delegate cycleView:self didSelectItemAtIndex:count < 2 ? 0 : indexPath.row - 1];
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
    NSInteger count = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInCycleView:)]) {
        count = [self.delegate numberOfItemsInCycleView:self];
    }
    if (duration != 0 && count > 1) {
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

- (void)dealloc
{
    [self.timer invalidate];
}

@end










