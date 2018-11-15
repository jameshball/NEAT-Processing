class Genome {
  ArrayList<Connection> network;
  ArrayList<Node> nodes;
  
  int nodeCount;
  int inputNodeCount;
  int outputNodeCount;
  int layerCount;
  int species;
  
  float fitness;
  
  static final float weightMutationRate = 0.8;
  static final float uniformPerturbed = 0.9;
  static final float newNodeRate = 0.03;
  static final float newLinkRate = 0.05;
  
  static final float sigmoidConst = 4.9;
  
  Genome(int inputNodesNo, int outputNodesNo, boolean isChild) {
    inputNodeCount = inputNodesNo;
    outputNodeCount = outputNodesNo;
    network = new ArrayList<Connection>();
    nodes = new ArrayList<Node>();
    nodeCount = 0;
    species = 0;
    
    for (int i = 0; i < inputNodesNo; i++) {
      addNode(NodeTypes.INPUT);
    }
    
    for (int i = 0; i < outputNodesNo; i++) {
      addNode(NodeTypes.OUTPUT);
    }
    
    if (!isChild) {
      for (int i = 0; i < inputNodesNo; i++) {
        for (int j = inputNodesNo; j < inputNodesNo + outputNodesNo; j++) {
          network.add(new Connection(connectionGenes.returnGene(nodes.get(i).id, nodes.get(j).id), random(-1, 1), true));
        }
      }
      formatNodes();
    }
    
    
    
  }
  
  void mutate() {
    if (random(1) < weightMutationRate) {
      mutateConnectionWeights();
    }
    
    if (random(1) < newNodeRate) {
      mutateAddNode();
    }
    
    if (random(1) < newLinkRate) {
      mutateAddConnection();
    }
  }
  
  void mutateAddNode() {
    addNode(NodeTypes.HIDDEN);
    int newNode = nodes.get(nodes.size() - 1).id;
    
    int randIndex = (int)random(network.size());
    
    Connection oldConnection = network.get(randIndex);
    oldConnection.enabled = false;
    if (oldConnection.gene.in > nodes.size() || newNode > nodes.size() || oldConnection.gene.out > nodes.size()) {
      println("ERROR"); //<>//
    }
    network.add(new Connection(connectionGenes.returnGene(oldConnection.gene.in, newNode), 1, true));
    network.add(new Connection(connectionGenes.returnGene(newNode, oldConnection.gene.out), oldConnection.weight, true));
  }
  
  void mutateAddConnection() {
    if (network.size() != inputNodeCount * outputNodeCount) {
      int inNode = (int)random(0, nodes.size() - outputNodeCount - 1);
      int outNode = (int)random(inNode + 1, nodes.size());
      
      while (connectionExists(outNode + 1, inNode + 1) || connectionExists(inNode + 1, outNode + 1)) {
        inNode = (int)random(0, nodes.size() - outputNodeCount - 1);
        outNode = (int)random(inNode + 1, nodes.size());
      }
      
      network.add(new Connection(connectionGenes.returnGene(inNode + 1, outNode + 1), random(-1, 1), true));
      if (inNode + 1 > nodes.size() || outNode + 1 > nodes.size()) {
        println("ERROR"); //<>//
      }
    }
  }
  
  void mutateConnectionWeights() {
    for (int i = 0; i < network.size(); i++) {
      Connection connection = network.get(i);
      
      if (random(1) < uniformPerturbed) {
        uniformPerturbation(connection);
      }
      else {
        connection.weight = random(-1, 1);
      }
    }
  }
  
  void uniformPerturbation(Connection connection) {
    connection.weight += randomGaussian() / 8;
    
    if (connection.weight > 1) {
      connection.weight = 1;
    }
    else if (connection.weight < -1) {
      connection.weight = -1;
    }
  }
  
  boolean connectionExists(int in, int out) {
    for (int i = 0; i < network.size(); i++) {
      Connection c = network.get(i);
      
      if (in == c.gene.in && out == c.gene.out) {
        return true;
      }
    }
    
    return false;
  }
  
  void addNode(int nodeType) {
    nodeCount++;
    if (nodeType == NodeTypes.INPUT) {
      nodes.add(new Node(nodeCount, nodeType, 0));
    }
    else {
      nodes.add(new Node(nodeCount, nodeType));
    }
  }
  
  //Function to place nodes into layers so we can feedforward.
  void formatNodes() {
    ArrayList<Node> processedNodes = new ArrayList<Node>();
    ArrayList<Node> otherNodes = new ArrayList<Node>();
    ArrayList<Connection> networkCopy = new ArrayList<Connection>(network);
    
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).nodeType == NodeTypes.INPUT) {
        processedNodes.add(nodes.get(i));
      }
      else {
        otherNodes.add(new Node(nodes.get(i)));
      }
    }
    
    layerCount = 1;
    
    while (otherNodes.size() > 0) {
      if (layerCount > 50) {
        println("ERROR"); //<>//
      }
      
      ArrayList<Node> layerNodes = new ArrayList<Node>();
      
      for (int i = 0; i < otherNodes.size(); i++) {
        Node outNode = otherNodes.get(i);
        
        if (allInputsWithinList(networkCopy, processedNodes, outNode.id)) {
          outNode.layer = layerCount;
          
          layerNodes.add(outNode);
          otherNodes.remove(i);
          i--;
        }
      }
      
      processedNodes.addAll(layerNodes);
      
      Collections.sort(processedNodes, new Comparator<Node>(){
        public int compare(Node n1, Node n2) {
          return Integer.compare(n1.id, n2.id);
        }
      });
      
      layerCount++;
    }
    
    nodes = processedNodes;
  }
  
  boolean isWithinNodeList (ArrayList<Node> n, int id) {
    for (int i = 0; i < n.size(); i++) {
      if (n.get(i).id == id) {
        return true;
      }
    }
    
    return false;
  }
  
  boolean allInputsWithinList (ArrayList<Connection> cs, ArrayList<Node> n, int out) {
    for (int i = 0; i < cs.size(); i++) {
      Connection c = cs.get(i);
      
      if (c.gene.out == out) {
        if (!isWithinNodeList(n, c.gene.in)) {
          //println(i);
          return false;
        }
      }
    }
    
    return true;
  }
  
  void removeAllInputsInList (ArrayList<Connection> cs, ArrayList<Node> n, int out) {
    for (int i = 0; i < cs.size(); i++) {
      Connection c = cs.get(i);
      
      if (c.gene.out == out) {
        cs.remove(i);
      }
    }
  }
  
  void updateFitness(float score) {
    fitness = score * score;
  }
  
  float[] feedForward(float[] input) {
    float[] nodeValues = new float[nodes.size()];
    
    if (input.length == inputNodeCount) {
      for (int i = 0; i < inputNodeCount; i++) {
        nodeValues[i] = input[i];
      }
      
      int currentLayer = 0;
      
      while (currentLayer < layerCount - 1) {
        for (int i = 0; i < network.size(); i++) {
          Connection c = network.get(i);
          Node n = nodes.get(c.gene.in - 1);
          
          if (n.layer == currentLayer) {
            nodeValues[c.gene.out - 1] += nodeValues[c.gene.in - 1] * c.weight;
          }
        }
        
        for (int i = 0; i < nodes.size(); i++) {
          Node n = nodes.get(i);
          
          if (n.layer == currentLayer + 1) {
            nodeValues[i] = sigmoid(nodeValues[i], sigmoidConst);
          }
        }
        
        currentLayer++;
      }
      
      float[] output = new float[outputNodeCount];
      
      int currentNode = 0;
      
      for (int i = 0; i < nodes.size(); i++) {
        Node n = nodes.get(i);
        
        if (n.layer == layerCount - 1) {
          output[currentNode] = nodeValues[i];
          currentNode++;
        }
      }
      
      return output;
    }
    else {
      return null;
    }
  }
  
  float sigmoid(float f, float mult) {
    return 1.0 / (1.0 + exp(-mult * f));
  }
  
  boolean nodeExists(int id) {
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i).id == id) {
        return true;
      }
    }
    
    return false;
  }
}
