//
//  CollectionViewController.m
//  ARSticker
//
//  Created by Jinwoo Kim on 5/15/24.
//

#import "CollectionViewController.h"
#import "ARViewController.h"
#import <PhotosUI/PhotosUI.h>

@interface CollectionViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate>
@property (retain, readonly, nonatomic, direct) UICollectionViewCellRegistration *cellRegistration;
@property (retain, nonatomic, nullable, direct) UIImage *anchorImage;
@property (retain, nonatomic ,nullable, direct) UIImage *stickerImage;
@end

@implementation CollectionViewController

@synthesize cellRegistration = _cellRegistration;

- (instancetype)init {
    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:listConfiguration];
    [listConfiguration release];
    
    if (self = [super initWithCollectionViewLayout:collectionViewLayout]) {
        UINavigationItem *navigationItem = self.navigationItem;
        
        __weak auto weakSelf = self;
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithPrimaryAction:[UIAction actionWithTitle:@"ARView" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            auto uw = weakSelf;
            if (uw == nil) return;
            
            ARViewController *arViewController = [[ARViewController alloc] initWithAnchorImage:uw.anchorImage stickerImage:uw.stickerImage];
            
            [uw presentViewController:arViewController animated:YES completion:nil];
            [arViewController release];
        }]];
        
        navigationItem.rightBarButtonItem = rightBarButtonItem;
        [rightBarButtonItem release];
    }
    
    return self;
}

- (void)dealloc {
    [_cellRegistration release];
    [_anchorImage release];
    [_stickerImage release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cellRegistration];
}

- (UICollectionViewCellRegistration *)cellRegistration {
    if (auto cellRegistration = _cellRegistration) return cellRegistration;
    
    __weak auto weakSelf = self;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewListCell class] configurationHandler:^(__kindof UICollectionViewListCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, id  _Nonnull item) {
        UIListContentConfiguration *contentConfiguration = [cell defaultContentConfiguration];
        
        if (indexPath.item == 0) {
            contentConfiguration.text = @"Anchor Image";
            contentConfiguration.image = weakSelf.anchorImage;
        } else if (indexPath.item == 1) {
            contentConfiguration.text = @"Sticker Image";
            contentConfiguration.image = weakSelf.stickerImage;
        }
        
        contentConfiguration.imageProperties.maximumSize = CGSizeMake(200., 200.);
        
        cell.contentConfiguration = contentConfiguration;
    }];
    
    _cellRegistration = [cellRegistration retain];
    return cellRegistration;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueConfiguredReusableCellWithRegistration:self.cellRegistration forIndexPath:indexPath item:[NSNull null]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    
    if (item == 0) {
        UIImagePickerController *imagePickerController = [UIImagePickerController new];
        imagePickerController.delegate = self;
        imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [imagePickerController takePicture];
        
        [self presentViewController:imagePickerController animated:YES completion:nil];
        [imagePickerController release];
    } else if (item == 1) {
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:PHPhotoLibrary.sharedPhotoLibrary];
        configuration.filter = [PHPickerFilter imagesFilter];
        
        PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        [configuration release];
        
        pickerViewController.delegate = self;
        
        [self presentViewController:pickerViewController animated:YES completion:nil];
        [pickerViewController release];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    self.anchorImage = info[UIImagePickerControllerEditedImage];
    
    UICollectionView *collectionView = self.collectionView;
    [collectionView performBatchUpdates:^{
        [collectionView reconfigureItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
    } completion:nil];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results {
    if (PHPickerResult *result = results.firstObject) {
        __weak auto weakSelf = self;
        [result.itemProvider loadObjectOfClass:UIImage.class completionHandler:^(UIImage * image, NSError * _Nullable error) {
            assert(error == nil);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                auto uw = weakSelf;
                if (uw == nil) return;
                
                uw.stickerImage = image;
                UICollectionView *collectionView = self.collectionView;
                
                [collectionView performBatchUpdates:^{
                    [collectionView reconfigureItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]]];
                } completion:nil];
            });
        }];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
