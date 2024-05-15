//
//  ARViewController.h
//  ARSticker
//
//  Created by Jinwoo Kim on 5/15/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((objc_direct_members))
@interface ARViewController : UIViewController
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithAnchorImage:(UIImage *)anchorImage stickerImage:(UIImage *)stickerImage;
@end

NS_ASSUME_NONNULL_END
