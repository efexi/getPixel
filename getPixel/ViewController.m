//
//  ViewController.m
//  INMOgira
//
//  Created by Felipe Ortega on 27-07-12.
//  Copyright (c) 2012 ELUN. All rights reserved.
//

/*----------------------------------------------------------------------------------------- //-->

<!-- VARIABLES //-->

<!-- -------------------------------------------------------------------------------------- //-*/
#import "ViewController.h"

#define FPS 0.03

@implementation ViewController
@synthesize fondo,foto1,foto2;

@synthesize fotos;

/*----------------------------------------------------------------------------------------- //-->
<!-- ENTER FRAME //-->
<!-- -------------------------------------------------------------------------------------- //-*/
- (void)eFrame{
}
/*----------------------------------------------------------------------------------------- //-->
<!-- TOUCHES BEGAN //-->
<!-- -------------------------------------------------------------------------------------- //-*/
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UIColor *color;
    UITouch *touch = [touches anyObject];
    CGPoint punto = [touch locationInView:self.view];
    
    float alfa;
    
    int i = 0;
    //[self getPixelColorAtLocation:punto withIMG:self.foto1];
    for(UIImageView *img in fotos){
        img.alpha = 0;
        color = [self getPixelColorAtLocation:punto withIMG:img];
        
        //const CGFloat* components = CGColorGetComponents(color.CGColor);
        //NSLog(@"Red: %f", components[0]);
        //NSLog(@"Green: %f", components[1]); 
        //NSLog(@"Blue: %f", components[2]);
        //NSLog(@"Alpha: %f", CGColorGetAlpha(color.CGColor));
        alfa = CGColorGetAlpha(color.CGColor);
        
        //NSLog(@"foto%i: %f",i,alfa);
        if(alfa > 0){
            img.alpha = 1;
        }
        i++;
    }
}
/*----------------------------------------------------------------------------------------- //-->
<!-- TOUCHES MOVED //-->
<!-- -------------------------------------------------------------------------------------- //-*/
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//UITouch *touch = [touches anyObject];
}
/*----------------------------------------------------------------------------------------- //-->
<!-- TOUCHES END //-->
<!-- -------------------------------------------------------------------------------------- //-*/
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
/*----------------------------------------------------------------------------------------- //-->
<!-- AUTO ORIENTADO //-->
<!-- -------------------------------------------------------------------------------------- //-*/
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
/*----------------------------------------------------------------------------------------- //-->
<!-- CONSTRUCTOR //-->
<!-- -------------------------------------------------------------------------------------- //-*/
- (void)viewDidLoad{
    [super viewDidLoad];
    
    foto1.alpha = 0;
    foto2.alpha = 0;
    
    fotos = [[NSMutableArray alloc] init];
    [fotos addObject:foto1];
    [fotos addObject:foto2];
    
    [NSTimer scheduledTimerWithTimeInterval:(FPS) target:self selector:@selector(eFrame) userInfo:nil repeats:YES];
    //[self performSelector:@selector(eFrame) withObject:nil afterDelay:0.5f];    
}
/*----------------------------------------------------------------------------------------- //-->
<!-- CREATE ARGB BITMAP CONTEXT FROM IMAGE //-->
<!-- -------------------------------------------------------------------------------------- //-*/
- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage {
    
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
    
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
    
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
	colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
    
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
    
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
    
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
    
	return context;
}
/*----------------------------------------------------------------------------------------- //-->
<!-- GET COLOR AT LOCATION //-->
<!-- -------------------------------------------------------------------------------------- //-*/
- (UIColor*) getPixelColorAtLocation:(CGPoint)point withIMG:(UIImageView*)fotoi {
    UIColor* color = nil;
    CGImageRef inImage = fotoi.image.CGImage;
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) { return nil; /* error */ }
    
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    float xscale = w / fotoi.frame.size.width;
    float yscale = h / fotoi.frame.size.height;
    point.x = point.x * xscale;
    point.y = point.y * yscale;
    /*
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    */
    CGRect rect = {{0,0},{w,h}}; 
    
    CGContextDrawImage(cgctx, rect, inImage); 
    
    long size = 4*((w*round(fotoi.frame.size.width * xscale))+round(fotoi.frame.size.height * yscale));
    unsigned char* data = malloc(size);
    data = CGBitmapContextGetData (cgctx);
    
    int alfa;
    if (data != NULL) {
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset]; 
        int red = data[offset+1]; 
        int green = data[offset+2]; 
        int blue = data[offset+3]; 
        //NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        alfa = alpha;
    }
    
    if(alfa > 0){
        int i = 0;
        for(i=0;i<size;i+=4){
            //int alpha =  data[i]; 
            //int red = data[i+1]; 
            //int green = data[i+2]; 
            //int blue = data[i+3];
            data[i+1] = data[i];
            data[i+2] = 0;
            data[i+3] = 0;
        }
        
        fotoi.image = [self generateImgFromData:data with:w and:h];
    }
    
    CGContextRelease(cgctx); 
    if (data) { free(data); }
    return color;
}
/*----------------------------------------------------------------------------------------- //-->
<!-- GET COLOR AT LOCATION //-->
<!-- -------------------------------------------------------------------------------------- //-*/
- (UIImage*) generateImgFromData:(unsigned char*)data with:(size_t)w and:(size_t)h{
    int bitmapBytesPerRow   = (w * 4);        
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    CGContextRef context = CGBitmapContextCreate (data,
                                                  w,
                                                  h,
                                                  8,      // bits per component
                                                  bitmapBytesPerRow,
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedFirst);
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage* salida = [UIImage imageWithCGImage:cgImage];
    return salida;
}
/*----------------------------------------------------------------------------------------- //-->
<!-- FIN DE LA CLASE //-->
<!-- -------------------------------------------------------------------------------------- //-*/
@end