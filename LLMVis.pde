import java.io.File;                  // Import the File class
import java.util.Scanner;

DisplayScene scene = new DisplayScene();

float initialHeight = displayScale;

void setup() {
  pixelDensity(2);
  fullScreen();
  
  colorMode(HSB, 1.0, 1.0, 1.0);

  DisplayObject obj = null;
  
  /*
  obj = scene.add(new CircleObject());
  obj.setPosition(500, 500);
  
  obj = scene.add(new CircleObject());
  obj.setPosition(-500, 500);
  
  obj = scene.add(new CircleObject());
  obj.setPosition(-500, -500);
  
  obj = scene.add(new CircleObject());
  obj.setPosition(500, -500);
  */
  
  SankeyTree tree = new SankeyTree(new PVector(0, -displayScale*0.5), 0.5*displayScale, initialHeight, "", "", "", 0, 0, treeMap1);
  scene.add(tree);
  tree = new SankeyTree(new PVector(0, displayScale*0.5), 0.5*displayScale, initialHeight, "", "", "", 0, 0, treeMap2);
  scene.add(tree);
  
  startReadingInput();

}

void addManyChildren(SankeyTree tree, int count, int depth) {
  if(depth == 0)
    return;
  
  float portion = 1.0/count;
  for(int i = 0; i < count; i++) {
    SankeyTree child = tree.addChild(portion, "test king test", "", "");
    addManyChildren(child, count, depth - 1);
  }
}

void addRandomChildren(SankeyTree tree, int count, int depth) {
  if(depth == 0)
    return;
  for(int i = 0; i < count; i++) {
    if(tree.portionUsed > 0.9)
      return;
    float portion = random(1.0 - tree.portionUsed);
    SankeyTree child = tree.addChild(portion, "test", "", "");
    addRandomChildren(child, count, depth - 1);
  }
}

void draw() {
  if(currentlyReadingInput) {
    addNodes();
  }
  
  background(0.1);
  scene.draw();
  
  if(showUI)
    drawUI();
}

void keyPressed() {
  if(key == 'h')
    showUI = !showUI;
}

void mousePressed() {
  scene.dragStart();
}

void mouseReleased() {
  scene.dragStop();
}

void mouseDragged() {
  scene.drag();
}

void mouseWheel(MouseEvent event) {
  float count = event.getCount();
  if(count > 0)
    scene.zoomOut();
  if(count < 0)
    scene.zoomIn();
}
