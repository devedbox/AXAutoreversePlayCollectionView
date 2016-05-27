//
//  AXAutoreversePlayCollectionView.m
//  AXAutoreversePlayCollectionView
//
//  Created by ai on 16/3/15.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXAutoreversePlayCollectionView.h"
#import <objc/runtime.h>
#define kAXAutoreversePlayCollectionViewReverseCount 1000

@interface AXAutoreversePlayCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    UIPageControl *_pageControl;
    AXCollectionView *_collectionView;
    AXCollectionViewFlowLayout *_collectionViewLayout;
    NSTimer *_timer;
    NSInteger _originalSection;
    NSInteger _originalNumberOfSection;
}
/// Center layout constraint.
@property(strong, nonatomic) NSLayoutConstraint *horizontalConstraint;
/// Bottom lauout constraint.
@property(strong, nonatomic) NSLayoutConstraint *verticalConstraint;
@end

static NSString *AXCollectionViewContentOffsetKey = @"collectionView.contentOffset";

@implementation AXAutoreversePlayCollectionView
#pragma mark - Life cycle

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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializer];
}

- (void)initializer {
    if (CGPointEqualToPoint(_pageControlOffset, CGPointZero)) {
        _pageControlOffset = CGPointMake(-10, 0);
    }
    if (_autoReverseTimeinternal == 0.0) {
        _autoReverseTimeinternal = 5.0f;
    }
    if (_reverseLimits == 0) {
        _reverseLimits = 10;
    }
    self.position = AXAutoreversePlayPageControlPositionRight;
    [self addSubview:self.collectionView];
    [self addConstraintsOfCollectionView];
    [self addSubview:self.pageControl];
    [self addOrUpdateConstraintOfPageControl];
}

- (void)dealloc {
}

#pragma mark - Override

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self fireReverseTimer];
}

#pragma mark - Getters
- (UIPageControl *)pageControl {
    if (_pageControl) return _pageControl;
    _pageControl = [UIPageControl new];
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    _pageControl.currentPage = 0;
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
    [_pageControl addConstraint:[NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:15]];
    return _pageControl;
}

- (AXCollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    _collectionViewLayout = [[AXCollectionViewFlowLayout alloc] init];
    _collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[AXCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.refreshFooterEnabled = NO;
    _collectionView.refreshHeaderEnabled = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.alwaysBounceVertical = NO;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    return _collectionView;
}

- (NSLayoutConstraint *)horizontalConstraint {
    if (_horizontalConstraint) return _horizontalConstraint;
    _horizontalConstraint = [NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:_pageControlOffset.x];
    return _horizontalConstraint;
}

- (NSLayoutConstraint *)verticalConstraint {
    if (_verticalConstraint) return _verticalConstraint;
    _verticalConstraint = [NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:_pageControlOffset.y];
    return _verticalConstraint;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    return _collectionViewLayout;
}

#pragma mark - Setters

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setPageControlOffset:(CGPoint)pageControlOffset {
    _pageControlOffset = pageControlOffset;
    _horizontalConstraint.constant = pageControlOffset.x;
    _verticalConstraint.constant = pageControlOffset.y;
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)setPosition:(AXAutoreversePlayPageControlPosition)position {
    _position = position;
    switch (position) {
        case AXAutoreversePlayPageControlPositionLeft:
            _horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:_pageControlOffset.x];
            break;
        case AXAutoreversePlayPageControlPositionRight:
            _horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:_pageControlOffset.x];
            break;
        default:
            _horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:_pageControlOffset.x];
            break;
    }
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

#pragma mark - Public
- (void)reloadData {
    [_collectionView reloadData];
    [self updateNumberOfPageControl];
}

- (void)pauseReverse {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startReverse) object:nil];
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)startReverse {
    [_timer setFireDate:[NSDate distantPast]];
}

- (void)locateDataSourceToCenter {
    NSInteger section = 0;
    NSInteger item = 0;
    if (_originalSection == 1) {
        item = ceil(_reverseLimits*kAXAutoreversePlayCollectionViewReverseCount/2);
    } else {
        section = ceil(_reverseLimits*kAXAutoreversePlayCollectionViewReverseCount/2);
    }
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

#pragma mark - Private
- (void)addOrUpdateConstraintOfPageControl {
    if (![self.constraints containsObject:self.horizontalConstraint]) {
        [self.superview addConstraint:_horizontalConstraint];
    }
    if (![self.constraints containsObject:self.verticalConstraint]) {
        [self addConstraint:_verticalConstraint];
    }
}

- (void)addConstraintsOfCollectionView {
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_collectionView)]];
}

- (void)updateNumberOfPageControl {
    if (_collectionView.numberOfSections == 1) {
        _pageControl.numberOfPages = _originalNumberOfSection;
    } else {
        _pageControl.numberOfPages = _originalSection;
    }
    [self refreshPageControl];
}

- (void)refreshPageControl {
    CGPoint offsets = _collectionView.contentOffset;
    CGFloat flag = CGRectGetWidth(_collectionView.bounds);
    if ([_collectionView numberOfSections] == 1) {
        if (offsets.x != 0) {
            if (((NSInteger)offsets.x%(NSInteger)flag) <= 1.0) {
                _pageControl.currentPage = ((NSInteger)(offsets.x/flag))%_originalNumberOfSection;
            }
        } else {
            _pageControl.currentPage = ((NSInteger)(offsets.x/flag))%_originalNumberOfSection;
        }
    } else {
        NSUInteger section = [_collectionView indexPathForItemAtPoint:CGPointMake(offsets.x+CGRectGetWidth(_collectionView.bounds)/2, offsets.y+CGRectGetHeight(_collectionView.bounds)/2)].section;
        _pageControl.currentPage = section%_originalSection;
    }
}

- (void)fireReverseTimer {
    __weak typeof(self) wself = self;
    _timer = [NSTimer timerWithTimeInterval:_autoReverseTimeinternal target:wself selector:@selector(updateCurrentPosition) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)updateCurrentPosition {
    if (_collectionView.contentOffset.x >= _collectionView.contentSize.width - CGRectGetWidth(_collectionView.bounds)) {// 最右边
        [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [_collectionView setContentOffset:CGPointMake(CGRectGetWidth(_collectionView.bounds)*(ceil(_collectionView.contentOffset.x/CGRectGetWidth(_collectionView.bounds))+1), 0) animated:YES];
    }
}

- (NSIndexPath *)indexPathWithCurrentIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.item;
    NSIndexPath *_indexPath = indexPath;
    if ([_collectionView numberOfSections] > 1) {
        if (section >= _originalSection) {
            section %= _originalSection;
        }
        _indexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:section];
    } else {
        if (item >= _originalNumberOfSection) {
            item %= _originalNumberOfSection;
        }
        _indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    }
    return _indexPath;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_dataSource) {
        _originalNumberOfSection = [_dataSource collectionView:collectionView numberOfItemsInSection:section];
        if ([_dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
            _originalSection = [_dataSource numberOfSectionsInCollectionView:collectionView];
            if (_originalSection > 1) {
                return _originalNumberOfSection;
            }
        }
        return _originalNumberOfSection*_reverseLimits*kAXAutoreversePlayCollectionViewReverseCount;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource) {
        return [_dataSource collectionView:collectionView cellForItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return nil;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        _originalSection = [_dataSource numberOfSectionsInCollectionView:collectionView];
        if (_originalSection <= 1) {
            return _originalSection;
        } else {
            return _originalSection*_reverseLimits*kAXAutoreversePlayCollectionViewReverseCount;
        }
    }
    return 1;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource && [_dataSource respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        return [_dataSource collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return nil;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataSource && [_dataSource respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
        return [_dataSource collectionView:collectionView canMoveItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    if (_dataSource && [_dataSource respondsToSelector:@selector(collectionView:moveItemAtIndexPath:toIndexPath:)]) {
        [_dataSource collectionView:collectionView canMoveItemAtIndexPath:[self indexPathWithCurrentIndexPath:destinationIndexPath]];
    }
}
#pragma mark - UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:shouldHighlightItemAtIndexPath:)]) {
        return [_delegate collectionView:collectionView shouldHighlightItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:didHighlightItemAtIndexPath:)]) {
        [_delegate collectionView:collectionView didHighlightItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:didUnhighlightItemAtIndexPath:)]) {
        [_delegate collectionView:collectionView didUnhighlightItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:shouldSelectItemAtIndexPath:)]) {
        return [_delegate collectionView:collectionView shouldSelectItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:shouldDeselectItemAtIndexPath:)]) {
        return [_delegate collectionView:collectionView shouldDeselectItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
        [_delegate collectionView:collectionView didSelectItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:didDeselectItemAtIndexPath:)]) {
        [_delegate collectionView:collectionView didDeselectItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [_delegate collectionView: collectionView willDisplayCell:cell forItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)]) {
        [_delegate collectionView:collectionView willDisplaySupplementaryView:view forElementKind:elementKind atIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [_delegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)]) {
        [_delegate collectionView:collectionView didEndDisplayingSupplementaryView:view forElementOfKind:elementKind atIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
}

// These methods provide support for copy/paste actions on cells.
// All three should be implemented if any are.
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:shouldShowMenuForItemAtIndexPath:)]) {
        return [_delegate collectionView:collectionView shouldShowMenuForItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:canPerformAction:forItemAtIndexPath:withSender:)]) {
        return [_delegate collectionView:collectionView canPerformAction:action forItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath] withSender:sender];
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:performAction:forItemAtIndexPath:withSender:)]) {
        [_delegate collectionView:collectionView performAction:action forItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath] withSender:sender];
    }
}

// support for custom transition layout
- (nonnull UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:transitionLayoutForOldLayout:newLayout:)]) {
        return [_delegate collectionView:collectionView transitionLayoutForOldLayout:fromLayout newLayout:toLayout];
    }
    return [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
}

// Focus
- (BOOL)collectionView:(UICollectionView *)collectionView canFocusItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:canFocusItemAtIndexPath:)]) {
        return [_delegate collectionView:collectionView canFocusItemAtIndexPath:[self indexPathWithCurrentIndexPath:indexPath]];
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:shouldUpdateFocusInContext:)]) {
        return [_delegate collectionView:collectionView shouldUpdateFocusInContext:context];
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:didUpdateFocusInContext:withAnimationCoordinator:)]) {
        [_delegate collectionView:collectionView didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    }
}
- (nullable NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView
{
    if (_delegate && [_delegate respondsToSelector:@selector(indexPathForPreferredFocusedViewInCollectionView:)]) {
        return [_delegate indexPathForPreferredFocusedViewInCollectionView:collectionView];
    }
    return nil;
}

- (NSIndexPath *)collectionView:(UICollectionView *)collectionView targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)originalIndexPath toProposedIndexPath:(NSIndexPath *)proposedIndexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:targetIndexPathForMoveFromItemAtIndexPath:toProposedIndexPath:)]) {
        return [_delegate collectionView:collectionView targetIndexPathForMoveFromItemAtIndexPath:[self indexPathWithCurrentIndexPath:originalIndexPath] toProposedIndexPath:[self indexPathWithCurrentIndexPath:proposedIndexPath]];
    }
    return proposedIndexPath;
}

- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    if (_delegate && [_delegate respondsToSelector:@selector(collectionView:targetContentOffsetForProposedContentOffset:)]) {
        return [_delegate collectionView:collectionView targetContentOffsetForProposedContentOffset:proposedContentOffset];
    }
    return proposedContentOffset;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateNumberOfPageControl];
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_delegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [_delegate scrollViewDidZoom:scrollView];
    }
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pauseReverse];
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [_delegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self performSelector:@selector(startReverse) withObject:nil afterDelay:_autoReverseTimeinternal];
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)]) {
        [_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [_delegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [_delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [_delegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [_delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [_delegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [_delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [_delegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (_delegate && [_delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [_delegate scrollViewDidScrollToTop:scrollView];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.bounds.size;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
@end