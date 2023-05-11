# DifferentWidthCarouselDemo



## 背景
项目中需要实现一个不同宽度的图片的无限轮播图效果，而且每次滚动，只滚到下一个图片。由于业界实现的轮播图效果都是等宽图片，所以需要重新根据“以假乱真”的原理，设计一款不同宽度的轮播效果；

## 演示效果

底部是个collectionView，顶部盖了个透明的scrollView，传入的数据源是：
```ObjectiveC
NSArray *imageWidthArray = @[@(200), @(60), @(120)];
```

![Simulator Screen Recording - iPhone 13 Pro - 2023-05-10 at 15.39.44.gif](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f2108d55f25b41fa8b222800cecb0b0c~tplv-k3u1fbpfcp-watermark.image?)

## 实现思路
1. 传入一个存储图片宽度的数组，计算出屏幕可见的个数，比如下图，假如可见数为3个；

2. 左、右两侧各有2个灰块，用于实现以假乱真的数据；（两侧各需生成的灰块数=屏幕可见数-1）
   
- 比如当前看到123，左滑会滚到231，再左滑会滚到312，此时设置contentOffset，切到前面那个312；
- 比如当前看到123，右滑会滚到312，再右滑会滚到231，此时设置contentOffset，切到后面那个231；

3. 为了性能方面的考虑，使用的是collectinoView；
4. 关于每次滚动，只滚到下一个，实现方式则是在collectionView上面盖一个scrollView，设置其isPagingEnabled = YES; scrollView里面的页数和数据源保持一致（方便计算滚到哪个page）；

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/db75924c6416468e80c2dd278e70f759~tplv-k3u1fbpfcp-watermark.image?)


![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b3dc89b73db243a2892efaebc878b1ea~tplv-k3u1fbpfcp-watermark.image?)


![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/93c0f6cbd232446b91a498052e60db05~tplv-k3u1fbpfcp-watermark.image?)