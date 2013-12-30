//
//  ViewController.h
//  getPixel
//
//  Created by Felipe Ortega on 12-09-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    UIImageView* fondo;
    UIImageView* foto1;
    UIImageView* foto2;
    
    NSMutableArray* fotos;
}

@property(nonatomic,retain) IBOutlet UIImageView* fondo;
@property(nonatomic,retain) IBOutlet UIImageView* foto1;
@property(nonatomic,retain) IBOutlet UIImageView* foto2;

@property(nonatomic,retain) NSMutableArray* fotos;

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage;
- (UIColor*) getPixelColorAtLocation:(CGPoint)point withIMG:(UIImageView*)fotoi;
- (UIImage*) generateImgFromData:(unsigned char*)data with:(size_t)w and:(size_t)h;

@end
