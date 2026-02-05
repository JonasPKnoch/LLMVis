import java.text.DecimalFormat;

DecimalFormat floatFormat = new DecimalFormat("0.00");
DecimalFormat probFloatFormat = new DecimalFormat("0.000000");

boolean showUI = false;

float averageLayerDistance = 0.0;
int totalNodes = 0;

boolean nodeInfo = true;
String nodeID = "";

void drawUI() {
  float overviewWidth = width*0.2;
  rectMode(CORNERS);
  textAlign(CENTER, TOP);
  noStroke();
  
  fill(0.75);
  rect(0, 0, overviewWidth, height);
  
  textSize(32);
  fill(0);
  float lineDist = 0;
  text("Final Divergence:", overviewWidth*0.5, lineDist);
  lineDist += 32;
  if(layerDistances.size() > 0)
    text(floatFormat.format(layerDistances.get(layerDistances.size()-1)), overviewWidth*0.5, lineDist);
  lineDist += 32;
  
  text("Average Divergence:", overviewWidth*0.5, lineDist);
  lineDist += 32;
  text(floatFormat.format(averageLayerDistance), overviewWidth*0.5, lineDist);
  lineDist += 32;
  text("Nodes Expanded:", overviewWidth*0.5, lineDist);
  lineDist += 32;
  text(totalNodes, overviewWidth*0.5, lineDist);
  lineDist += 32;
  
  lineDist += 32;
  text("Top Contributions", overviewWidth*0.5, lineDist);
  lineDist += 32;
  for(int i = 0; i < min(distanceContributions.size(), 26); i++) {
    DistanceContribution cont = distanceContributions.get(i);
    textAlign(LEFT, TOP);
    text(cont.distID, 0, lineDist); 
    textAlign(RIGHT, TOP);
    text(floatFormat.format(cont.contribution), overviewWidth, lineDist);
    lineDist += 32;
  }
  
  if(!nodeInfo)
    return;
  
  SankeyTree node1 = treeMap1.get(nodeID);
  SankeyTree node2 = treeMap2.get(nodeID);
  String node1Prob = "N/A";
  String node2Prob = "N/A";
  
  String nodeText = "";
  if(node1 != null) {
    nodeText = node1.fullText;
    node1Prob = probFloatFormat.format(100*node1.height/initialHeight) + "%";
  }
  if(node2 != null) {
    nodeText = node2.fullText;
    node2Prob = probFloatFormat.format(100*node2.height/initialHeight) + "%";
  }
  
  float nodeInfoWidth = width*0.25;
  int charsPerLine = 34;
  fill(0.75);
  rect(width - nodeInfoWidth, 0, width, height);
  
  lineDist = 0;
  textAlign(CENTER, TOP);
  fill(0);
  text("Tree 1 Probability:", width - nodeInfoWidth*0.5, lineDist);
  lineDist += 32;
  text(node1Prob, width - nodeInfoWidth*0.5, lineDist);
  lineDist += 32;
  text("Tree 2 Probability:", width - nodeInfoWidth*0.5, lineDist);
  lineDist += 32;
  text(node2Prob, width - nodeInfoWidth*0.5, lineDist);
  lineDist += 32;
  lineDist += 32;
  
  int lineCount = floor(nodeText.length()/charsPerLine);
  textAlign(LEFT, TOP);
  for(int i = 0; i < lineCount; i++) {
    String lineText = nodeText.substring(charsPerLine*i, charsPerLine*(i + 1));
    text(lineText, width - nodeInfoWidth, lineDist);
    lineDist += 32;
  }
  String lineText = nodeText.substring(lineCount*charsPerLine, nodeText.length());
  text(lineText, width - nodeInfoWidth, lineDist);
  
  
  nodeInfo = false;
}
