//
//  AXAutoreversePlayCollectionView.m
//  AXAutoreversePlayCollectionView
//
//  Created by ai on 16/3/15.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "AXAutoreversePlayCollectionView.h"
#import <objc/runtime.h>

@interface AXAutoreversePlayCollectionView ()
{
    UIPageControl *_pageControl;
    AXCollectionView *_collectionView;
    AXCollectionViewFlowLayout *_collectionViewLayout;
    NSTimer *_timer;
}
/// Center layout constraint.
@property(strong, nonatomic) NSLayoutConstraint *horizontalConstraint;
/// Bottom lauout constraint.
@property(strong, nonatomic) NSLayoutConstraint *verticalConstraint;
@end

static NSString *AXCollectionViewContentOffsetKey = @"collectionView.contentOffset";
static char *AXAutoreversePlayCollectionViewTimerStatePaused = "AXAutoreversePlayCollectionViewTimerStatePaused";

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
    _pageOffset = CGPointMake(-10, 0);
    _autoReverseTimeinternal = 5.0f;
    self.position = AXAutoreversePlayPageControlPositionRight;
    [self addSubview:self.collectionView];
    [self addConstraintsOfCollectionView];
    [self addSubview:self.pageControl];
    [self addOrUpdateConstraintOfPageControl];
    [self addObserver:self forKeyPath:AXCollectionViewContentOffsetKey options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:AXCollectionViewContentOffsetKey];
}

#pragma mark - Override
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:AXCollectionViewContentOffsetKey]) {
        // collectionView.contentOffset
        [self updateNumberOfPageControl];
        [self refreshPageControl];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [self pauseReverse];
    objc_setAssociatedObject(_timer, AXAutoreversePlayCollectionViewTimerStatePaused, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self performSelector:@selector(detectStateOfTimer) withObject:nil afterDelay:_autoReverseTimeinternal];
    return [super hitTest:point withEvent:event];
}

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
    _collectionView.backgroundColor = [UIColor clearColor];
    return _collectionView;
}

- (NSLayoutConstraint *)horizontalConstraint {
    if (_horizontalConstraint) return _horizontalConstraint;
    _horizontalConstraint = [NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:_pageOffset.x];
    return _horizontalConstraint;
}

- (NSLayoutConstraint *)verticalConstraint {
    if (_verticalConstraint) return _verticalConstraint;
    _verticalConstraint = [NSLayoutConstraint constraintWithItem:_pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:_pageOffset.y];
    return _verticalConstraint;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    return _collectionViewLayout;
}

#pragma mark - Setters
- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    _delegate = delegate;
    _collectionView.delegate = delegate;
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    _dataSource = dataSource;
    _collectionView.dataSource = dataSource;
    [self reloadData];
}

- (void)setPageOffset:(CGPoint)pageOffset {
    _pageOffset = pageOffset;
    _horizontalConstraint.constant = pageOffset.x;
    _verticalConstraint.constant = pageOffset.y;
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)setPosition:(AXAutoreversePlayPageControlPosition)position {
    _position = position;
    switch (position) {
        case AXAutoreversePlayPageControlPositionLeft:
            _horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:_pageOffset.x];
            break;
        case AXAutoreversePlayPageControlPositionRight:
            _horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:_pageOffset.x];
            break;
        default:
            _horizontalConstraint = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:_pageOffset.x];
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
    [_timer setFireDate:[NSDate distantFuture]];
}

- (void)startReverse {
    if (_timer) {
        [self fireReverseTimer];
    } else {
        [_timer setFireDate:[NSDate distantPast]];
    }
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
        _pageControl.numberOfPages = [_collectionView numberOfItemsInSection:0];
    } else {
        _pageControl.numberOfPages = [_collectionView numberOfSections];
    }
    [self refreshPageControl];
}

- (void)refreshPageControl {
    CGPoint offsets = _collectionView.contentOffset;
    CGFloat flag = CGRectGetWidth(_collectionView.bounds);
    if ([_collectionView numberOfSections] == 1) {
        if (offsets.x != 0) {
            if (((NSInteger)offsets.x%(NSInteger)flag) <= 1.0) {
                _pageControl.currentPage = (NSInteger)(offsets.x/flag);
            }
        } else {
            _pageControl.currentPage = (NSInteger)(offsets.x/flag);
        }
    } else {
        NSUInteger section = [_collectionView indexPathForItemAtPoint:CGPointMake(offsets.x+CGRectGetWidth(_collectionView.bounds)/2, offsets.y+CGRectGetHeight(_collectionView.bounds)/2)].section;
        _pageControl.currentPage = section;
    }
    if (offsets.x != 0) {
        if ((((NSInteger)offsets.x%(NSInteger)flag) <= 0.5) && [objc_getAssociatedObject(_timer, AXAutoreversePlayCollectionViewTimerStatePaused) boolValue]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(detectStateOfTimer) object:nil];
            [self startReverse];
        }
    }
}

- (void)fireReverseTimer {
    _timer = [NSTimer timerWithTimeInterval:_autoReverseTimeinternal target:self selector:@selector(updateCurrentPosition) userInfo:nil repeats:YES];
    objc_setAssociatedObject(_timer, AXAutoreversePlayCollectionViewTimerStatePaused, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)updateCurrentPosition {
    if (_collectionView.contentOffset.x >= _collectionView.contentSize.width - CGRectGetWidth(_collectionView.bounds)) {// 最右边
        [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [_collectionView setContentOffset:CGPointMake(CGRectGetWidth(_collectionView.bounds)*(ceil(_collectionView.contentOffset.x/CGRectGetWidth(_collectionView.bounds))+1), 0) animated:YES];
    }
}

- (void)detectStateOfTimer {
    if ([objc_getAssociatedObject(_timer, AXAutoreversePlayCollectionViewTimerStatePaused) boolValue]) {
        [self updateCurrentPosition];
        [self startReverse];
        objc_setAssociatedObject(_timer, AXAutoreversePlayCollectionViewTimerStatePaused, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
@end