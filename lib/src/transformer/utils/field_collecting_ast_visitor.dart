part of dartemis_transformer;

class FieldCollectingAstVisitor extends SimpleAstVisitor {
  List<FieldDeclaration> mappers = <FieldDeclaration>[];
  List<FieldDeclaration> managers = <FieldDeclaration>[];
  List<FieldDeclaration> systems = <FieldDeclaration>[];
  Map<String, ClassHierarchyNode> nodes;

  FieldCollectingAstVisitor(this.nodes);

  @override
  visitFieldDeclaration(FieldDeclaration node) {
    if (null != node.fields.type) {
      var typeName = node.fields.type.name.name;
      if (typeName == 'Mapper') {
        mappers.add(node);
      } else if (_isOfType(nodes, typeName, 'Manager')) {
        managers.add(node);
      } else if (_isOfType(nodes, typeName, 'EntitySystem')) {
        systems.add(node);
      }
    }
  }
}