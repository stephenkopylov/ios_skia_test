//
//  GPUDrawingViewController.m
//  Skia_test
//
//  Created by Stepan Kopylov on 08/07/2019.
//  Copyright © 2019 Test. All rights reserved.
//

#import "GPUDrawingViewController.h"
#import <GLKit/GLKit.h>
#import "GrContext.h"
#import "GrGLInterface.h"
#import "SkSurface.h"
#import "Skottie.h"
#import "SkTextBlob.h"
#import "SkGradientShader.h"



@interface GPUDrawingViewController ()<GLKViewDelegate>

@property (nonatomic) GLKView *glView;

@end

@implementation GPUDrawingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; // 1
    _glView = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; // 2
    _glView.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    _glView.context = context; // 3
    _glView.delegate = self; // 4
    [self.view addSubview:_glView];
    
    _glView.enableSetNeedsDisplay = NO;
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_STENCIL_BUFFER_BIT);
    
    sk_sp<const GrGLInterface> interface(GrGLCreateNativeInterface());
    
    sk_sp<GrContext> grContext(GrContext::MakeGL(interface));
    
    SkImageInfo info = SkImageInfo:: MakeN32Premul(rect.size.width, rect.size.height);
    sk_sp<SkSurface> gpuSurface(SkSurface::MakeRenderTarget(grContext.get(), SkBudgeted::kNo, info));
    
    SkCanvas* canvas = gpuSurface->getCanvas();
    
    canvas->clear(SK_ColorRED);
    
    SkPaint paint;
    paint.setStyle(SkPaint::kFill_Style);
    paint.setAntiAlias(true);
    paint.setStrokeWidth(4);
    paint.setColor(0xffFE938C);
    
    SkRect rect_sk = SkRect::MakeXYWH(10, 30, 100, 160);
    canvas->drawRect(rect_sk, paint);
    
    SkRRect oval;
    oval.setOval(rect_sk);
    oval.offset(40, 80);
    paint.setColor(0xffE6B89C);
    canvas->drawRRect(oval, paint);
    
    paint.setColor(0xff9CAFB7);
    canvas->drawCircle(180, 50, 25, paint);
    
    rect_sk.offset(80, 50);
    paint.setColor(0xff4281A4);
    paint.setStyle(SkPaint::kStroke_Style);
    canvas->drawRoundRect(rect_sk, 10, 10, paint);
    
    canvas->flush();
    grContext->flush();
    
    //    SkRRect oval;
    //    oval.setRect(SkRect::MakeWH(1000, 100));
    //    oval.offset(0, 0);
    //    paint.setColor(SK_ColorYELLOW);
    //    gpuCanvas->drawRRect(oval, paint);
    
    
}

- (void)render:(CADisplayLink*)displayLink {
    [_glView display];
}
@end
