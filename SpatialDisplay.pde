static float displayScale = 100.0;

class DisplayScene {
  float zoomSpeed = 1.1;
  
  ArrayList<DisplayObject> objects = new ArrayList<>();
  PVector panPosition = new PVector();
  PVector zoomScale = new PVector(250.0/displayScale, 250.0/displayScale);
  PVector inverseZoomScale = new PVector();
  float aspectRatio = -1.0;
  PVector screenUpperLeft = new PVector();
  PVector screenLowerRight = new PVector();
  
  boolean dragging = false;
  PVector dragAnchor = new PVector();
  
  DisplayScene() {
    setScreenBounds();
    updateScale();
  }
  
  void setScreenBounds() {
    screenUpperLeft.x = -panPosition.x + (-width*0.5)*inverseZoomScale.x;
    screenUpperLeft.y = -panPosition.y + (-height*0.5)*inverseZoomScale.y;
    
    screenLowerRight.x = -panPosition.x + (width*0.5)*inverseZoomScale.x;
    screenLowerRight.y = -panPosition.y + (height*0.5)*inverseZoomScale.y;
  }
  
  void dragStart() {
    dragging = true;
    dragAnchor.x = mouseX*inverseZoomScale.x - panPosition.x;
    dragAnchor.y = mouseY*inverseZoomScale.y - panPosition.y;
  }
  
  void dragStop() {
    dragging = false;
  }
  
  void drag() {
    if(dragging) {
      panPosition.x = mouseX*inverseZoomScale.x - dragAnchor.x;
      panPosition.y = mouseY*inverseZoomScale.y - dragAnchor.y;
      setScreenBounds();
    }
  }
  
  void updateScale() {
    inverseZoomScale.x = 1.0/zoomScale.x;
    inverseZoomScale.y = 1.0/zoomScale.y;
    aspectRatio = zoomScale.x/zoomScale.y;
    setScreenBounds();
  }
  
  void zoomIn() {
    if(zoomScale.y*zoomSpeed > 60000)
      return;
    //zoomScale.x *= zoomSpeed;
    zoomScale.y *= zoomSpeed;
      
    updateScale();
  }
  
  void zoomOut() {
    //zoomScale.x /= zoomSpeed;
    zoomScale.y /= zoomSpeed;
    updateScale();
  }
  
  DisplayObject add(DisplayObject object) {
    objects.add(object);
    object.added(this);
    return object;
  }
  
  boolean objectOnScreen(DisplayObject object) {
    if(object.minimumScale < inverseZoomScale.y)
      return false;
    
    if(object.position.x + object.lowerRightBound.x < screenUpperLeft.x)
      return false;

    if(object.position.y + object.lowerRightBound.y < screenUpperLeft.y)
      return false;
    
    if(object.position.x + object.upperLeftBound.x > screenLowerRight.x)
      return false;
    
    if(object.position.y + object.upperLeftBound.y > screenLowerRight.y)
      return false;
    
    return true;
  }
  
  void draw() {
    pushMatrix();
    translate(width*0.5, height*0.5);
    scale(zoomScale.x, zoomScale.y);
    translate(panPosition.x, panPosition.y);

    for(DisplayObject object : objects) {
      if(!objectOnScreen(object))
        continue;
      object.drawAtPosition();
      if(!object.mouseCheck)
        continue;
      if(object.pointOverlap(screenToWorldX(mouseX), screenToWorldY(mouseY)))
        object.mouseOver();
      
    }
    popMatrix();
  }
  
  float screenToWorldX(float screenX) {
    return -panPosition.x + (screenX - width*0.5)*inverseZoomScale.x;
  }
  
  float screenToWorldY(float screenY) {
    return -panPosition.y + (screenY - height*0.5)*inverseZoomScale.y;
  }
  
  void debugMouseDisplay() {
    noFill();
    stroke(255, 0, 0);
    float mX = screenToWorldX(mouseX);
    float mY = screenToWorldY(mouseY);
    circle(mX, mY, 20*inverseZoomScale.x);
    fill(0);
    textSize(15*inverseZoomScale.x);
    text("   " + mX + ", " + mY, mX, mY);
  }
}

class DisplayObject {
  PVector position = new PVector(0, 0);
  PVector upperLeftBound = new PVector(0, 0);
  PVector lowerRightBound = new PVector(0, 0);
  float minimumScale = 9999.0;
  boolean mouseCheck = false;
  DisplayScene scene;
  
  DisplayObject() {
  }
  
  void added(DisplayScene scene) {
    this.scene = scene;
  }
  
  void setPosition(float x, float y) {
    position.x = x;
    position.y = y;
  }
  
  void drawAtPosition() {
    translate(position.x, position.y);
    this.draw();
    translate(-position.x, -position.y);
  }
  
  boolean pointOverlap(float x, float y) {
    return false;
  }
  
  void mouseOver() {
  }
  
  void draw() {
  }
}

class BezierObject extends DisplayObject {
  void draw() {
    strokeWeight(80);
    bezier(200, 200, 200, 100, -200, -100, -200, -200);
  }
}

class CircleObject extends DisplayObject {
  float size;
  color outlineColor;
  
  CircleObject() {
    this(50, color(0, 0, 0));
  }
  
  CircleObject(float size, color outlineColor) {
    this.size = size;
    this.outlineColor = outlineColor;
    upperLeftBound = new PVector(-size*0.5, -size*0.5);
    lowerRightBound = new PVector(size*0.5, size*0.5);
  }
  
  void draw() {
    noFill();
    stroke(outlineColor);
    strokeWeight(5);
    circle(0, 0, size);
  }
}
