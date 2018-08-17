class Genome {
  ArrayList<Connection> network;
  ArrayList<Node> nodes;
  
  int nodeCount;
  int inputNodeCount;
  int outputNodeCount;
  int layerCount;
  
  float fitness;
  
  static final float weightMutationRate = 0.8;
  static final float uniformPerturbed = 0.9;
  static final float newNodeRate = 0.03;
  static final float newLinkRate = 0.05;
  static final float geneDisabledInChild = 0.75;
  
  static final float sigmoidConst = 4.9;
  
  Genome(int inputNodesNo, int outputNodesNo) {
    inputNodeCount = inputNodesNo;
    outputNodeCount = outputNodesNo;
    network = new ArrayList<Connection>();
    nodes = new ArrayList<Node>();
    nodeCount = 0;
    
    for (int i = 0; i < inputNodesNo; i++) {
      addNode(NodeTypes.INPUT);
    }
    
    for (int i = 0; i < outputNodesNo; i++) {
      addNode(NodeTypes.OUTPUT);
    }
    
    for (int i = 0; i < inputNodesNo; i++) {
      for (int j = inputNodesNo; j < outputNodesNo; j++) {
        network.add(new Connection(connectionGenes.returnGene(nodes.get(i).id, nodes.get(j).id), random(-1, 1), true));
      }
    }
  }
  
  void mutate() {
    if (random(1) < weightMutationRate) {
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
    
    if (random(1) < newNodeRate) {
      addNode(NodeTypes.HIDDEN);
      int newNode = nodes.get(nodes.size() - 1).id;
      
      int randIndex = (int)random(network.size());
      
      Connection oldConnection = network.get(randIndex);
      oldConnection.enabled = false;
      network.add(new Connection(connectionGenes.returnGene(oldConnection.gene.in, newNode), 1, true));
      network.add(new Connection(connectionGenes.returnGene(newNode, oldConnection.gene.out), oldConnection.weight, true));
    }
    
    if (random(1) < newLinkRate) {
      int inNode = (int)random(nodes.size());
      int outNode = (int)random(nodes.size());
      
      while (inNode == outNode || connectionExists(inNode, outNode) || nodes.get(outNode).nodeType == NodeTypes.INPUT) {
        inNode = (int)random(nodes.size());
        outNode = (int)random(nodes.size());
      }
      
      network.add(new Connection(connectionGenes.returnGene(inNode, outNode), random(-1, 1), true));
    }
  }
  
  void uniformPerturbation(Connection connection) {
    connection.weight += randomGaussian() / 5;
    
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
    ArrayList<Connection> networkCopy = new ArrayList<Connection>(network);
    
    for (int i = 0; i < inputNodeCount; i++) {
      processedNodes.add(nodes.get(i));
    }
    
    layerCount = 1;
    
    while (networkCopy.size() > 0) {
      for (int i = 0; i < networkCopy.size(); i++) {
        Connection c = networkCopy.get(i);
        
        if (isWithinNodeList(processedNodes, c.gene.in) && allInputsWithinList(networkCopy, processedNodes, c.gene.out)) {
          Node outNode = nodes.get(c.gene.out);
          outNode.layer = layerCount;
          
          processedNodes.add(outNode);
          networkCopy.remove(i);
        }
      }
      
      layerCount++;
    }
  }
  
  boolean isWithinNodeList (ArrayList<Node> n, int id) {
    for (int i = 0; i < n.size(); i++) {
      if (n.get(i).id == id) {
        return true;
      }
    }
    
    return false;
  }
  
  boolean allInputsWithinList (ArrayList<Connection> c, ArrayList<Node> n, int out) {
    for (int i = 0; i < c.size(); i++) {
      Connection current = c.get(i);
      
      if (current.gene.out == out) {
        if (!isWithinNodeList(n, current.gene.in)) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  void updateFitness(float score) {
    fitness = score * score;
  }
  
  Genome crossover(Genome p2) {
    Genome child = new Genome(inputNodeCount, outputNodeCount);
    ArrayList<Connection> networkCopy1 = new ArrayList<Connection>(network);
    ArrayList<Connection> networkCopy2 = new ArrayList<Connection>(p2.network);
    
    for (int i = 0; i < networkCopy1.size(); i++) {
      Connection c1 = networkCopy1.get(i);
      
      for (int j = 0; j < networkCopy2.size(); j++) {
        Connection c2 = networkCopy2.get(j);
        
        if (c2.gene.innovationNumber == c1.gene.innovationNumber) {
          if (random(1) < geneDisabledInChild && (!c1.enabled || !c2.enabled)) {
            c1.enabled = false;
            c2.enabled = false;
          }
          else {
            c1.enabled = true;
            c2.enabled = true;
          }
          
          if (random(1) < 0.5) {
            child.network.add(c1);
          }
          else {
            child.network.add(c2);
          }
          
          if (!isWithinNodeList(child.nodes, c1.gene.out)) {
            child.addNode(NodeTypes.HIDDEN);
          }
          
          networkCopy1.remove(i);
          networkCopy2.remove(j);
        }
      }
    }
    
    if (fitness >= p2.fitness) {
      child.network.addAll(networkCopy1);
    }
    else {
      child.network.addAll(networkCopy2);
    }
    
    return child;
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
        
        for (int i = 0; i < network.size(); i++) {
          Connection c = network.get(i);
          Node n = nodes.get(c.gene.in - 1);
          
          if (n.layer == currentLayer) {
            nodeValues[c.gene.out - 1] = sigmoid(nodeValues[c.gene.out - 1], sigmoidConst);
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
}
