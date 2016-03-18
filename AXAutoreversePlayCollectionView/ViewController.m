//
//  ViewController.m
//  AXAutoreversePlayCollectionView
//
//  Created by ai on 16/3/15.
//  Copyright © 2016年 devedbox. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import <AXCollectionViewFlowLayout/AXCollectionViewFlowLayout.h>

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, AXCollectionViewDelegate>

@end

static NSString *AXResusIdentifier = @"AXResusIdentifier";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [_collectionView.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:AXResusIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_collectionView locateDataSourceToCenter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AXCollectionView Definition

#define kAXCollectionViewItemLayoutCount 1
#define kAXCollectionViewItemTopEdge 0
#define kAXCollectionViewItemLeftEdge 0
#define kAXCollectionViewItemBottomEdge 0
#define kAXCollectionViewItemRightEdge 0
#define kAXCollectionViewInset (UIEdgeInsetsMake(kAXCollectionViewItemTopEdge, kAXCollectionViewItemLeftEdge, kAXCollectionViewItemBottomEdge, kAXCollectionViewItemRightEdge))
#define kAXCollectionViewItemMinimumLineSpacing 0
#define kAXCollectionViewItemMinimumInteritemSpacing 0

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AXResusIdentifier" forIndexPath:indexPath];
    cell.imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",@(indexPath.row+1)]];
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ;
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat size = 0.0;
//    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
//    if (layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
//        size = (CGRectGetWidth(collectionView.bounds) - (kAXCollectionViewItemMinimumInteritemSpacing*(kAXCollectionViewItemLayoutCount-1)+kAXCollectionViewItemLeftEdge+kAXCollectionViewItemRightEdge))/kAXCollectionViewItemLayoutCount;
//    } else {
//        size = (CGRectGetHeight(collectionView.bounds) - (kAXCollectionViewItemMinimumInteritemSpacing*(kAXCollectionViewItemLayoutCount-1)+kAXCollectionViewItemTopEdge+kAXCollectionViewItemBottomEdge))/kAXCollectionViewItemLayoutCount;
//    }
//    return CGSizeMake(size, size);
    return collectionView.bounds.size;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return kAXCollectionViewInset;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kAXCollectionViewItemMinimumLineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kAXCollectionViewItemMinimumInteritemSpacing;
}
#pragma mark - AXCollectionViewDelegate
- (void)collectionViewRefreshData:(AXCollectionView *)collectionView
{
    
}
- (void)collectionViewMoreData:(AXCollectionView *)collectionView
{
    
}
@end