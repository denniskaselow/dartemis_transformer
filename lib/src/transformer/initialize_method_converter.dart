part of dartemis_transformer;

class InitializeMethodConverter {
  final Map<String, ClassHierarchyNode> _nodes;

  InitializeMethodConverter(this._nodes);

  bool convert(ClassDeclaration unit) {
    var fieldCollector = new FieldCollectingAstVisitor(_nodes);
    unit.visitChildren(fieldCollector);
    if (fieldCollector.managers.isEmpty && fieldCollector.systems.isEmpty && fieldCollector.mappers.isEmpty) {
      return false;
    }
    bool callSuperInitialize = false;
    var initializeMethod = unit.getMethod('initialize');
    if (null == initializeMethod) {
      initializeMethod = _createInitializeMethodDeclaration();
      unit.members.add(initializeMethod);
      callSuperInitialize = true;
    }
    var initializeStatements = (initializeMethod.body as BlockFunctionBody).block.statements;

    var initField = (FieldDeclaration node, ExpressionStatement createAssignment(String name, String type)) {
      var managerName = node.fields.variables[0].name.name;
      var managerType = (node.fields.type as TypeName).name.name;
      initializeStatements.insert(0, createAssignment(managerName, managerType));
    };
    fieldCollector.managers.forEach((manager) => initField(manager, (String name, String type) => _createManagerAssignment(name, type)));
    fieldCollector.systems.forEach((system) => initField(system, (String name, String type) => _createSystemAssignment(name, type)));
    fieldCollector.mappers.forEach((FieldDeclaration mapper) {
      var mapperName = mapper.fields.variables[0].name.name;
      var mapperType = ((mapper.fields.type as TypeName).typeArguments.arguments[0] as TypeName).name.name;
      initializeStatements.insert(0, _createMapperAssignment(mapperName, mapperType));
    });

    if (callSuperInitialize) {
      initializeStatements.insert(0, _createSuperInitialize());
    }
    return true;
  }

  MethodDeclaration _createInitializeMethodDeclaration() {
    var comment = null;
    var metadata = [AstTestFactory.annotation(AstTestFactory.identifier3('override'))];
    var externalKeyword = null;
    var modifierKeyword = null;
    var returnType = AstTestFactory.typeName4('void');
    var propertyKeyword = null;
    var operatorKeyword = null;
    var name = AstTestFactory.identifier3('initialize');
    var typeParameters = null;
    var parameters = AstTestFactory.formalParameterList();
    var block = AstTestFactory.block();
    var body = AstTestFactory.blockFunctionBody(block);
    return new MethodDeclarationImpl(comment, metadata, externalKeyword, modifierKeyword, returnType, propertyKeyword, operatorKeyword, name, typeParameters, parameters, body);
  }

  ExpressionStatement _createSuperInitialize() {
    var expression = AstTestFactory.methodInvocation(AstTestFactory.identifier3('super'), 'initialize');
    return AstTestFactory.expressionStatement(expression);
  }

  ExpressionStatement _createMapperAssignment(String mapperName, String mapperType) {
    var leftHandSide = AstTestFactory.identifier3(mapperName);
    var rightHandSide = AstTestFactory.instanceCreationExpression2(Keyword.NEW, AstTestFactory.typeName3(AstTestFactory.identifier3('Mapper'), [AstTestFactory.typeName4(mapperType)]), [AstTestFactory.identifier3(mapperType), AstTestFactory.identifier3('world')]);
    var assigmentStatement = AstTestFactory.assignmentExpression(leftHandSide, TokenType.EQ, rightHandSide);
    return AstTestFactory.expressionStatement(assigmentStatement);
  }

  ExpressionStatement _createManagerAssignment(String managerName, String managerType) =>
    _createAssignmentFromWorldMethod(managerName, managerType, 'getManager');

  ExpressionStatement _createSystemAssignment(String systemName, String systemType) =>
    _createAssignmentFromWorldMethod(systemName, systemType, 'getSystem');

  ExpressionStatement _createAssignmentFromWorldMethod(String fieldName, String fieldType, String worldMethod) {
    var leftHandSide = AstTestFactory.identifier3(fieldName);
    var rightHandSide = AstTestFactory.methodInvocation(AstTestFactory.identifier3('world'), worldMethod, [AstTestFactory.identifier3(fieldType)]);
    var assigmentStatement = AstTestFactory.assignmentExpression(leftHandSide, TokenType.EQ, rightHandSide);
    return AstTestFactory.expressionStatement(assigmentStatement);
  }
}