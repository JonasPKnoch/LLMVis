HashMap<String, SankeyTree> treeMap1 = new HashMap();
HashMap<String, SankeyTree> treeMap2 = new HashMap();

class SankeyRibbon extends DisplayObject {
  float size;
  PVector offset;
  color ribbonColor;
  String text;
  SankeyTree connecting;
  boolean hover = false;
  color hoverColor;
  
  float bezierDepth = 0.3333;
  
  SankeyRibbon(PVector start, PVector end, float size, color ribbonColor, color hoverColor, String text, SankeyTree connecting) {
    this.size = size;
    this.ribbonColor = ribbonColor;
    this.text = text;
    this.connecting = connecting;
    position = start;
    offset = PVector.sub(end, start);
    this.mouseCheck = true;
    this.hoverColor = hoverColor;
    
    upperLeftBound.y = min(-size*0.5, offset.y - size*0.5);
    lowerRightBound.x = offset.x;
    lowerRightBound.y = max(size*0.5, offset.y + size*0.5);
    minimumScale = (abs(offset.y) + size);
  }
  
  void mouseOver() {
    hover = true;
    nodeInfo = true;
    nodeID = connecting.id;
  }
  
  boolean pointOverlap(float x, float y) {
    float xLocal = x - position.x;
    float yLocal = y - position.y;
    return 
      xLocal >= upperLeftBound.x && xLocal <= lowerRightBound.x &&
      yLocal >= upperLeftBound.y && yLocal <= lowerRightBound.y;
  }
  
  void draw() {
    noFill();
    strokeWeight(size);
    strokeCap(SQUARE);
    stroke(ribbonColor);
    if(hover)
      stroke(hoverColor);
    hover = false;
    bezier(0, 0, 
      offset.x*bezierDepth, 0,
      offset.x*(1.0 - bezierDepth), offset.y,
      offset.x, offset.y);

    textSize(1.0);
    float tw = textWidth(text);
    float ts = offset.x/tw;
    
    if(ts > size/scene.aspectRatio)
      textSize(size/scene.aspectRatio);
    else
      textSize(ts);
    
    noStroke();
    fill(1.0);
    textAlign(CENTER, CENTER);
    
    pushMatrix();
    translate(offset.x*0.5, offset.y*0.5);
    scale(1.0, scene.aspectRatio);
    text(text, 0, 0);
    popMatrix();
  }
}

/*  //Old, shape-based ribbon that might be faster but looks not as good.
    noStroke();
    fill(ribbonColor);
    beginShape();
    vertex(
      0, size*0.5);
    bezierVertex(
      offset.x*bezierDepth, size*0.5,
      offset.x*(1.0 - bezierDepth), offset.y + size*0.5,
      offset.x, offset.y + size*0.5);
    
    vertex(
      offset.x, offset.y - size*0.5);
    bezierVertex(
      offset.x*(1.0 - bezierDepth), offset.y - size*0.5,
      offset.x*bezierDepth, -size*0.5,
      0, -size*0.5);
    endShape();
*/

class SankeyRect extends DisplayObject {
  float width;
  float height;
  color rectColor;
  
  SankeyRect(PVector position, float width, float height, color rectColor) {
    this.position = position;
    this.width = width;
    this.height = height;
    this.rectColor = rectColor;
    upperLeftBound.x = 0;
    upperLeftBound.y = -height*0.5;
    lowerRightBound.x = width;
    lowerRightBound.y = height*0.5;
    minimumScale = height;
  }
  
  void draw() {
    rectMode(CENTER);
    noStroke();
    fill(rectColor);
    
    rect(width*0.5, 0, width, height);
  }
}

class SankeyTree extends DisplayObject {
  float width;
  float height;
  float nodeHue;
  String token;
  int depth;
  HashMap<String, SankeyTree> treeMap;
  
  String id;
  String fullText;
  ArrayList<SankeyTree> children = new ArrayList();
  ArrayList<SankeyRibbon> edges = new ArrayList();
  SankeyRect rect;
  SankeyRibbon incomingEdge;
  float portionUsed = 0.0;
  float distance;
  
  float nodeWidth = 0.05;
  float nodeHeight = 0.95;
  float hueChangeBase = 0.1;
  float hueChangeRange = 0.1;
  
  SankeyTree(PVector position, float width, float height, String token, String id, String fullText, int depth, float nodeHue, HashMap<String, SankeyTree> treeMap) {
    this.position = position;
    this.width = width;
    this.height = height;
    this.token = token;
    this.depth = depth;
    this.nodeHue = nodeHue;
    this.id = id;
    this.fullText = fullText;
    this.treeMap = treeMap;
    treeMap.put(id, this);
    
    rect = new SankeyRect(position, width*nodeWidth, height*nodeHeight, color(0, 0.0, 0.5));
    upperLeftBound.x = 0;
    upperLeftBound.y = -height*0.5;
    lowerRightBound.x = width;
    lowerRightBound.y = height*0.5;
    minimumScale = height;
  }
  
  void draw() {
    if(depth < layerDistances.size())
      setDistance(layerDistances.get(depth));
  }
  
  void setDistance(float distance) {
    this.distance = distance;
    float hue = lerp(0.2, 1.0, distance/6000);
    if(incomingEdge != null) {
      incomingEdge.ribbonColor = color(hue, 0.9, 1.0);
      incomingEdge.hoverColor = color(hue, 0.5, 1.0);
    }
    rect.rectColor = color(hue, 1.0, 0.75);
  }
  
  void added(DisplayScene scene) {
    super.added(scene);
    scene.add(rect);
  }
  
  SankeyTree addChild(float portion, String id, String fullText, String token) {
    float childHeight = height*portion;
    //float childHue = nodeHue + hueChangeBase + portionUsed*hueChangeRange;
    //childHue %= 1.0;
    float childHue = min(distance/6000.0, 0.75);
    
    SankeyTree child = new SankeyTree(
      new PVector(position.x + width, position.y + height*(portionUsed - 0.5) + childHeight*0.5),
      width,
      portion*height,
      token,
      id,
      fullText,
      depth + 1,
      childHue,
      treeMap);
    
    SankeyRibbon edge = new SankeyRibbon(
      new PVector(position.x + width*nodeWidth, position.y + height*(portionUsed - 0.5)*nodeHeight + childHeight*nodeHeight*0.5),
      new PVector(position.x + width, position.y + height*(portionUsed - 0.5) + childHeight*0.5),
      portion*height*nodeHeight,
      color(0, 0.0, 0.75), 
      color(0, 0.0, 1.0), 
      token,
      child);
    child.incomingEdge = edge;
    
    portionUsed += portion;
    
    children.add(child);
    edges.add(edge);
    scene.add(child);
    scene.add(edge);
    totalNodes++;
    return child;
  }
}
