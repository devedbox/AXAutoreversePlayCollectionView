//
//  AXPreviewingCollectionViewFlowLayout.m
//  AXPreviewingCollectionViewFlowLayout
//
//  Created by devedbox on 2016/11/30.
//  Copyright © 2016年 jiangyou. All rights reserved.
//

#import "AXPreviewingCollectionViewFlowLayout.h"

@implementation AXPreviewingCollectionViewFlowLayout
- (instancetype)init {
    if (self = [super init]) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializer];
    }
    return self;
}

- (void)initializer {
    _sizeScale = 0.08;
}

#pragma mark - Override
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    NSMutableArray *modifiedArray = [@[] mutableCopy];
    
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        UICollectionViewLayoutAttributes* modifiedAttributes = [attributes copy];
        if (CGRectIntersectsRect(modifiedAttributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - modifiedAttributes.center.x;
            CGFloat normalizedDistance = distance / modifiedAttributes.size.width;
            
            CGSize itemSize = [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]?[((id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self sizeForItemAtIndexPath:modifiedAttributes.indexPath]:self.itemSize;
            
            if (ABS(distance) < modifiedAttributes.size.width) {
                CGFloat zoom = 1 - _sizeScale * ABS(normalizedDistance);
                modifiedAttributes.size = CGSizeMake(itemSize.width*zoom, itemSize.height);
            }
        }
        [modifiedArray addObject:modifiedAttributes];
    }
    return modifiedArray;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}
@end
