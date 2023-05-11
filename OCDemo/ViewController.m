//
//  ViewController.m
//  OCDemo
//
//  Created by Weiwen Wan on 2023/5/9.
//

#import "ViewController.h"
#import "MyCollectionViewCell.h"

#define padding 10.f
#define margin 16.f
#define scrollViewWidth (self.view.bounds.size.width - 2 * margin)
#define scrollViewHeight 200.f

@interface ViewController ()<UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSArray *imageWidthArray; // 用户传入，图片宽度数组
@property (nonatomic, assign) NSInteger canSeeViewCount; // 屏幕最多可见几个view

@property (nonatomic, strong) NSMutableArray *imageWidthMuArray;
@property (nonatomic, strong) NSMutableArray *imageContentOffsetXArray;

@property (nonatomic, strong) NSMutableArray *currentPageMuArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self setupViewWithImageWidthArray:@[@(200), @(60), @(120)]];
    [self setupViewWithImageWidthArray:@[@(150), @(80),@(60), @(120)]];
}

-(void)setupViewWithImageWidthArray:(NSArray *)imageWidthArray {
    // 根据机型宽度，计算屏幕可见数量
    self.canSeeViewCount = imageWidthArray.count;
    CGFloat checkWidth = 0;
    for (NSInteger i = 0; i < imageWidthArray.count; i ++) {
        checkWidth += [imageWidthArray[i] floatValue];
        if (checkWidth >= scrollViewWidth) {
            self.canSeeViewCount = i + 1;
        }
    }

    self.imageWidthArray = imageWidthArray;
    self.imageContentOffsetXArray = [NSMutableArray arrayWithCapacity:self.imageWidthArray.count];

    // 插入头尾数据（前后插入可见数-1个）、生成currentPageMuArray
    self.imageWidthMuArray = [NSMutableArray array];
    self.currentPageMuArray = [NSMutableArray array];
    for (NSInteger i = self.imageWidthArray.count - (self.canSeeViewCount - 1); i < self.imageWidthArray.count; i ++) {
        [self.imageWidthMuArray addObject:self.imageWidthArray[i]];
        [self.currentPageMuArray addObject:@(i)];
    }
    [self.imageWidthMuArray addObjectsFromArray:self.imageWidthArray];

    for (NSInteger i = 0; i < self.imageWidthArray.count; i ++) {
        [self.currentPageMuArray addObject:@(i)];
    }

    for (NSInteger i = 0; i < (self.canSeeViewCount - 1); i ++) {
        [self.imageWidthMuArray addObject:self.imageWidthArray[i]];
        [self.currentPageMuArray addObject:@(i)];
    }

    CGFloat collectionViewContentSizeWidth = 0;
    for (NSInteger i = 0; i < self.imageWidthMuArray.count; i ++) {
        CGFloat imageWidth = [self.imageWidthMuArray[i] floatValue];
        if ( i > 0) {
            collectionViewContentSizeWidth += padding;
        }
        [self.imageContentOffsetXArray addObject:@(collectionViewContentSizeWidth)];
        collectionViewContentSizeWidth += imageWidth;
    }

    // collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = padding;
    flowLayout.minimumLineSpacing = padding;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(margin, 100, scrollViewWidth, scrollViewHeight) collectionViewLayout:flowLayout];
    [collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"MyCollectionViewCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.bounces = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:collectionView];
    collectionView.contentSize = CGSizeMake(collectionViewContentSizeWidth, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [collectionView setContentOffset:CGPointMake([self.imageContentOffsetXArray[self.canSeeViewCount - 1] floatValue], 0)];
    });
    self.collectionView = collectionView;

    // topScrollView
    UIScrollView *topScrollView = [[UIScrollView alloc] initWithFrame:collectionView.frame];
    topScrollView.showsHorizontalScrollIndicator = NO;
    [topScrollView setPagingEnabled:YES];
    topScrollView.backgroundColor = [UIColor clearColor];
    topScrollView.delegate = self;
    topScrollView.bounces = NO;
    [self.view addSubview:topScrollView];
    self.topScrollView = topScrollView;
    topScrollView.contentSize = CGSizeMake(self.imageWidthMuArray.count * scrollViewWidth, 0);
    [topScrollView setContentOffset:CGPointMake((self.canSeeViewCount - 1) * scrollViewWidth, 0)];

    // pageControl
    CGFloat pageControlHeight = 50.f;
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(margin, 100 + scrollViewHeight-pageControlHeight, scrollViewWidth, pageControlHeight)];
    pageControl.numberOfPages = self.imageWidthArray.count;
    pageControl.currentPage = 0;
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        return;
    }
    // 页面整数部分
    NSInteger floorPageIndex = floor(scrollView.contentOffset.x / scrollView.frame.size.width);

    // 小数部分
    CGFloat pageRate = scrollView.contentOffset.x / scrollView.frame.size.width - floor(scrollView.contentOffset.x / scrollView.frame.size.width);

    CGFloat imageContentOffsetX = [self.imageContentOffsetXArray[floorPageIndex] floatValue];
    CGFloat imageWidth = [self.imageWidthMuArray[floorPageIndex] floatValue];
    self.collectionView.contentOffset = CGPointMake(imageContentOffsetX + (imageWidth + 10.f) * pageRate, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger rightIndex = (self.canSeeViewCount - 1) + (self.imageWidthArray.count) - 1;
    NSInteger leftIndex = (self.canSeeViewCount - 1) - 1;

    // 右边卡到尾时
    if (self.collectionView.contentOffset.x == [self.imageContentOffsetXArray[rightIndex] floatValue]) {
        [self.collectionView setContentOffset:CGPointMake([self.imageContentOffsetXArray[leftIndex] floatValue], 0)];
    }
    // 左边卡到头时
    else if (self.collectionView.contentOffset.x == 0) {
        [self.collectionView setContentOffset:CGPointMake([self.imageContentOffsetXArray[self.imageWidthArray.count] floatValue], 0)];
    }

    // 右边卡到尾时
    if (self.topScrollView.contentOffset.x == scrollViewWidth * rightIndex) {
        [self.topScrollView setContentOffset:CGPointMake(scrollViewWidth * leftIndex, 0)];
    }
    // 左边卡到头时
    if (self.topScrollView.contentOffset.x == 0) {
        [self.topScrollView setContentOffset:CGPointMake(scrollViewWidth * self.imageWidthArray.count, 0)];
    }

    // 设置currentPage
    NSInteger floorPageIndex = floor(scrollView.contentOffset.x / scrollView.frame.size.width);
    self.pageControl.currentPage = [self.currentPageMuArray[floorPageIndex] intValue];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageWidthMuArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionViewCell" forIndexPath:indexPath];
    cell.labelText = [NSString stringWithFormat:@"%.0f", [self.imageWidthMuArray[indexPath.item] floatValue]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([self.imageWidthMuArray[indexPath.item] floatValue], scrollViewHeight);
}

@end
