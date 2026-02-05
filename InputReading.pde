import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;
import java.util.Collections;
import java.lang.Comparable;

Thread readerThread;
boolean currentlyReadingInput = false;
List<NodeToAdd> nodesToAddBuffer = Collections.synchronizedList(new ArrayList());
boolean addingNodes = false;
ArrayList<Float> layerDistances = new ArrayList();
ArrayList<DistanceContribution> distanceContributions = new ArrayList();

class DistanceContribution implements Comparable<DistanceContribution> {
  String distID;
  float contribution;
  
  DistanceContribution(String distID, float contribution) {
    this.distID = distID;
    this.contribution = contribution;
  }
  
  @Override
  public int compareTo(DistanceContribution other) {
    return Float.compare(other.contribution, this.contribution);
  }
}

class NodeToAdd {
  String parentId;
  String childId;
  String childToken;
  String fullText;
  float portion;
  String root;
  String[] distances;
  int mode;
  
  NodeToAdd(String parentId, String childId, String childToken, String fullText, float portion, String root) {
    this.parentId = parentId;
    this.childId = childId;
    this.childToken = childToken;
    this.fullText = fullText;
    this.portion = portion;
    this.root = root;
    mode = 0;
  }
  
  NodeToAdd(String[] distances) {
    this.distances=distances;
    mode = 1;
  }
  
  NodeToAdd(String[] cont, int mode) {
    this.distances=cont;
    this.mode = mode;
  }
}

String inputPrompt1 = "";
String inputPrompt2 = "";
int inputIterations = 0;

void readInputFile() {
  File file = new File(sketchPath() + "\\input.txt");
  StringBuilder sb = new StringBuilder();
  int mode = 0;
  try(Scanner scanner = new Scanner(file)) {
    while (scanner.hasNextLine()) {
      String line = scanner.nextLine();
      
      if(line.equals("PROMPT 1")) {
        mode = 1;
        continue;
      }
      if(line.equals("PROMPT 2")) {
        mode = 2;
        inputPrompt1 = sb.toString();
        sb.setLength(0);
        continue;
      }
      if(line.equals("ITERATIONS")) {
        inputPrompt2 = sb.toString();
        sb.setLength(0);
        mode = 3;
        continue;
      }
      
      if(mode == 1 || mode==2) {
        sb.append(line);
        continue;
      }
      if(mode == 3) {
        inputIterations = Integer.parseInt(line);
      }
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
  
  println(inputPrompt1);
  println(inputPrompt2);
  println(inputIterations);
}

void startReadingInput() {
  readInputFile();
  currentlyReadingInput = true;
  readerThread = new Thread(() -> {
    println("READING INPUT FROM PYTHON...");
    try {
      Process process = Runtime.getRuntime().exec("python " + sketchPath() + "\\python\\test.py \"" + inputPrompt1 + "\" \"" + inputPrompt2 + "\" " + inputIterations);
      
      BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
      BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream()));
      
      String line = reader.readLine();
      while (line != null) {
          inputLineRead(line);
          line = reader.readLine();
      }
      
      line = errorReader.readLine();
      if(line != null)
        println("READING ERROR:");
      while (line != null) {
          System.out.println(line);
          line = errorReader.readLine();
      }
      
    } catch(Exception exception) {
      exception.printStackTrace();
    }
    currentlyReadingInput = false;
    println("DONE READING INPUT FROM PYTHON");
  });
  readerThread.setDaemon(true);
  readerThread.start();
}

void inputLineRead(String line) {
  String[] arr = line.split("@@@");
  String type = arr[0];
  
  
  if(type.equals("child"))
    bufferAddChild(arr);
  else if(type.equals("dist"))
    bufferAddDistance(arr);
  else if(type.equals("cont"))
    bufferAddContributions(arr);
}

void bufferAddChild(String[] arr) {
  String parent = arr[1];
  String child = arr[2];
  String token = arr[3];
  String fullText = arr[4];
  float portion = Float.parseFloat(arr[5]);
  String root = arr[6];
  
  nodesToAddBuffer.add(new NodeToAdd(parent, child, token, fullText, portion, root));
}

void bufferAddDistance(String[] arr) {  
  nodesToAddBuffer.add(new NodeToAdd(arr));
}

void bufferAddContributions(String[] arr) {  
  nodesToAddBuffer.add(new NodeToAdd(arr, 2));
}

import java.io.FileWriter;

void addNodes() {
  if(nodesToAddBuffer.isEmpty())
    return;

  synchronized(nodesToAddBuffer) {
    for(NodeToAdd el : nodesToAddBuffer) {
      if(el.mode == 0)
        addChildren(el);
      if(el.mode == 1)
        addDistance(el);
      if(el.mode == 2)
        addContributions(el);
    }
    nodesToAddBuffer.clear();
  }
}

void addChildren(NodeToAdd el) {
  SankeyTree node = null;
  if(el.root.equals("tree1"))
    node = treeMap1.get(el.parentId);
  else if(el.root.equals("tree2"))
    node = treeMap2.get(el.parentId);
  node.addChild(el.portion, el.childId, el.fullText, el.childToken);
}

void addDistance(NodeToAdd el) {
  layerDistances.clear();
  float sumDistance = 0.0;
  for(int i = 1; i < el.distances.length; i++) {
    float dist = Float.parseFloat(el.distances[i]);
    layerDistances.add(dist);
    sumDistance += dist;
  }
  averageLayerDistance = sumDistance/layerDistances.size();
}

void addContributions(NodeToAdd el) {
  distanceContributions.clear();
  float sumDistance = 0.0;
  for(int i = 1; i < el.distances.length; i+=2) {
    String id = el.distances[i];
    float cont = Float.parseFloat(el.distances[i + 1]);
    distanceContributions.add(new DistanceContribution(id, cont));
  }
  Collections.sort(distanceContributions);
}
