//
//  AXAutoreversePlayCollectionView.h
//  AXAutoreversePlayCollectionView
//
//  Created by ai on 16/3/15.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AXExtensions/AXCollectionView.h>
#import <AXPreviewingCollectionViewFlowLayout/AXPreviewingCollectionViewFlowLayout.h>

typedef NS_ENUM(NSInteger, AXAutoreversePlayPageControlPosition) {
    AXAutoreversePlayPageControlPositionCenter,
    AXAutoreversePlayPageControlPositionLeft,
    AXAutoreversePlayPageControlPositionRight
};

@interface AXAutoreversePlayCollectionView : UIView
/// Delegate.
@property(weak, nonatomic, nullable) IBOutlet id<UICollectionViewDelegate> delegate;
/// Data source.
@property(weak, nonatomic, nullable) IBOutlet id<UICollectionViewDataSource> dataSource;
/// Page control.
@property(readonly, strong, nonatomic, nonnull) UIPageControl *pageControl;
/// Collection view.
@property(readonly, strong, nonatomic, nonnull) AXCollectionView *collectionView;
/// Collection view layout.
@property(readonly, nonatomic, nonnull) UICollectionViewFlowLayout *collectionViewLayout;
/// Auto reverse time delay. Defatuls is 5.0f.
@property(assign, nonatomic) IBInspectable double autoReverseTimeinternal;
/// Page control offset. Defaults is (-10, 0)
@property(assign, nonatomic) IBInspectable CGPoint pageControlOffset;
/// Position of page control. Defaults is right.
@property(assign, nonatomic) IBInspectable AXAutoreversePlayPageControlPosition position;
/// Count of reverse limits. Defatilts is 10(count*100).
@property(assign, nonatomic) IBInspectable NSInteger reverseLimits;

- (void)reloadData;

- (void)pauseReverse;
- (void)startReverse;

- (void)locateDataSourceToCenter;
@end
