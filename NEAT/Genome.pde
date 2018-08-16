class Genome {
  ArrayList<Integer> network;
  ArrayList<Node> nodes;
  
  Genome(int inputNodes, int outputNodes) {
    network = new ArrayList<Integer>();
    nodes = new ArrayList<Node>();
    
    for (int i = 0; i < inputNodes; i++) {
      nodes.add(new Node(NodeTypes.INPUT));
    }
    
    for (int i = 0; i < outputNodes; i++) {
      nodes.add(new Node(NodeTypes.OUTPUT));
    }
    
    for (int i = 0; i < inputNodes; i++) {
      for (int j = inputNodes; j < nodes.size(); j++) {
        connectionGenes.add(new Connection(i, j));
        network.add(connectionGenes.get(i + j).innovationNumber);
      }
    }
  }
}
