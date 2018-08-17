class Node {
  int id;
  int nodeType;
  int layer;
  
  Node(int idInput, int nodeTypeInput) {
    id = idInput;
    nodeType = nodeTypeInput;
    layer = -1;
  }
  
  Node(int idInput, int nodeTypeInput, int layerInput) {
    id = idInput;
    nodeType = nodeTypeInput;
    layer = layerInput;
  }
}
