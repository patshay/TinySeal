//
//  Terrain.m
//  TinySeal
//
//  Created by Ray Wenderlich on 6/15/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "Terrain.h"
#import "HelloWorldLayer.h"

@implementation Terrain
@synthesize stripes = _stripes;

//without the hill code
//- (void) resetBox2DBody {
//    
//    if(_body) return;
//    
//    CGPoint p0 = _hillKeyPoints[0];
//    CGPoint p1 = _hillKeyPoints[kMaxHillKeyPoints-1];
//    
//    b2BodyDef bd;
//    bd.position.Set(0, 0);
//    _body = _world->CreateBody(&bd);
//    
//    b2PolygonShape shape;
//    b2Vec2 ep1 = b2Vec2(p0.x/PTM_RATIO, 0);
//    b2Vec2 ep2 = b2Vec2(p1.x/PTM_RATIO, 0);
//    shape.SetAsEdge(ep1, ep2);
//    _body->CreateFixture(&shape, 0);
//}


- (void) resetBox2DBody {
    
    if(_body) {
        _world->DestroyBody(_body);
    }
    
    b2BodyDef bd;
    bd.position.Set(0, 0);
    
    _body = _world->CreateBody(&bd);
    
    b2PolygonShape shape;
    
    b2Vec2 p1, p2;
    for (int i=0; i<_nBorderVertices-1; i++) {
        p1 = b2Vec2(_borderVertices[i].x/PTM_RATIO,_borderVertices[i].y/PTM_RATIO);
        p2 = b2Vec2(_borderVertices[i+1].x/PTM_RATIO,_borderVertices[i+1].y/PTM_RATIO);
        shape.SetAsEdge(p1, p2);
        _body->CreateFixture(&shape, 0);
    }
}

- (void) generateHills {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float minDY = 160;
    float minDX = 60;
    int rangeDY = 80;
    int rangeDX = 40;
    
    float y = -minDY;
    float x = winSize.width/2-minDX; //flipped width
    
    float dx, nx;
    float sign = 1; // +1 - going up, -1 - going  down
    float paddingTop = 120;
    float paddingBottom = 20;
    
    for (int i=0; i<kMaxHillKeyPoints; i++) {
        _hillKeyPoints[i] = CGPointMake(x, y);
        if (i == 0) {
            y = 0;
            x = winSize.width/2; //flipped height
        } else {
            y += rand()%rangeDY+minDY;
            while(true) {
                dx = rand()%rangeDX+minDX;
                nx = x + dx*sign;
                if(nx < winSize.width-paddingTop && nx > paddingBottom) {
                    //flipped height
                    break;   
                }
            }
            x = nx;
        }
        sign *= -1;
    }
}

- (void)resetHillVertices {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    static int prevFromKeyPointI = -1;
    static int prevToKeyPointI = -1;
    
    // key points interval for drawing        *******
    while (_hillKeyPoints[_fromKeyPointI+1].y < _offsetY-winSize.height/8/self.scale) {
        _fromKeyPointI++;
    }
    while (_hillKeyPoints[_toKeyPointI].y < _offsetY+winSize.height*9/8/self.scale) {
        _toKeyPointI++;
    }
    
    if (prevFromKeyPointI != _fromKeyPointI || prevToKeyPointI != _toKeyPointI) {
        
        // vertices for visible area
        _nHillVertices = 0;
        _nBorderVertices = 0;
        CGPoint p0, p1, pt0, pt1;
        p0 = _hillKeyPoints[_fromKeyPointI];
        for (int i=_fromKeyPointI+1; i<_toKeyPointI+1; i++) {
            p1 = _hillKeyPoints[i];
            
            // triangle strip between p0 and p1
            int hSegments = floorf((p1.y-p0.y)/kHillSegmentWidth);
            float dy = (p1.y - p0.y) / hSegments;
            float da = M_PI / hSegments;
            float xmid = (p0.x + p1.x) / 2;
            float ampl = (p0.x - p1.x) / 2;
            pt0 = p0;
            _borderVertices[_nBorderVertices++] = pt0;
            for (int j=1; j<hSegments+1; j++) {
                pt1.y = p0.y + j*dy;
                pt1.x = xmid + ampl * cosf(da*j);
                _borderVertices[_nBorderVertices++] = pt1;
                
//                _hillVertices[_nHillVertices] = CGPointMake(0, pt0.y);
//                _hillTexCoords[_nHillVertices++] = CGPointMake(1.0f, pt0.y/512);//flipped
//                _hillVertices[_nHillVertices] = CGPointMake(0, pt1.y);
//                _hillTexCoords[_nHillVertices++] = CGPointMake(1.0f, pt1.y/512);//flipped
//                
//                _hillVertices[_nHillVertices] = CGPointMake(pt0.x, pt0.y);
//                _hillTexCoords[_nHillVertices++] = CGPointMake(0, pt0.y/512);
//                _hillVertices[_nHillVertices] = CGPointMake(pt1.x, pt1.y);
//                _hillTexCoords[_nHillVertices++] = CGPointMake(0,pt1.y/512);
                _hillVertices[_nHillVertices] = CGPointMake(0, pt0.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(1.0f, pt0.y/512);//flipped
                _hillVertices[_nHillVertices] = CGPointMake(0, pt1.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(1.0f, pt1.y/512);//flipped
                
                _hillVertices[_nHillVertices] = CGPointMake(pt0.x, pt0.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(0, pt0.y/512);
                _hillVertices[_nHillVertices] = CGPointMake(pt1.x, pt1.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(0,pt1.y/512);


                
                pt0 = pt1;
            }
            
            p0 = p1;
        }
        
        prevFromKeyPointI = _fromKeyPointI;
        prevToKeyPointI = _toKeyPointI;
        
        [self resetBox2DBody];
    }
    
}

//box 2d circles
- (void)setupDebugDraw {
    _debugDraw = new GLESDebugDraw(PTM_RATIO*[[CCDirector sharedDirector] contentScaleFactor]);
    _world->SetDebugDraw(_debugDraw);
    _debugDraw->SetFlags(b2DebugDraw::e_shapeBit | b2DebugDraw::e_jointBit);
}

- (id)initWithWorld:(b2World *)world {
    if ((self = [super init])) {
        _world = world;
        [self setupDebugDraw];
        [self generateHills];
        [self resetHillVertices];
    }
    return self;
}


- (void) draw {
    
    glBindTexture(GL_TEXTURE_2D, _stripes.texture.name);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glColor4f(1, 1, 1, 1);
    glVertexPointer(2, GL_FLOAT, 0, _hillVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, _hillTexCoords);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nHillVertices);
    
    /*
     //red debug line
     for(int i = MAX(_fromKeyPointI, 1); i <= _toKeyPointI; ++i) {
        glColor4f(1.0, 0, 0, 1.0); 
        ccDrawLine(_hillKeyPoints[i-1], _hillKeyPoints[i]);     
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
        
        CGPoint p0 = _hillKeyPoints[i-1];
        CGPoint p1 = _hillKeyPoints[i];
        int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
        float dx = (p1.x - p0.x) / hSegments;
        float da = M_PI / hSegments;
        float ymid = (p0.y + p1.y) / 2;
        float ampl = (p0.y - p1.y) / 2;
        
        CGPoint pt0, pt1;
        pt0 = p0;
        for (int j = 0; j < hSegments+1; ++j) {
            
            pt1.x = p0.x + j*dx;
            pt1.y = ymid + ampl * cosf(da*j);
            
            ccDrawLine(pt0, pt1);
            
            pt0 = pt1;
            
        }
    }*/
    
    
    //box2d
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    _world->DrawDebugData();
    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void) setOffsetY:(float)newOffsetY {
    _offsetY = newOffsetY;
    self.position = CGPointMake(0,-_offsetY*self.scale);
    [self resetHillVertices];
}

//right now used to offset the right wall.  Can change later If I want the walls to shake?
- (void) setOffsetX:(float)newOffsetX {
    _offsetX = newOffsetX;
}

- (void)dealloc {
    [_stripes release];
    _stripes = NULL;
    [super dealloc];
}

@end