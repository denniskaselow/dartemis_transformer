part of dartemis_transformer;

class ComponentToPooledComponentConverter {
  bool convert(ClassDeclaration unit) {
    var className = unit.name.name;
    unit.extendsClause.superclass.name = AstTestFactory.identifier3('PooledComponent');

    var constructorVisitor = new _ComponentConstructorToFactoryConstructorConvertingAstVisitor();
    unit.visitChildren(constructorVisitor);

    if (constructorVisitor._count == 0) {
      unit.members.add(_createFactoryConstructor(className));
    }
    unit.members.add(_createStaticConstructorMethod(className));
    unit.members.add(_createHiddenConstructor(className));
    return true;
  }

  MethodDeclaration _createStaticConstructorMethod(String className) {
    TypeName returnType = AstTestFactory.typeName4(className);
    SimpleIdentifier name = AstTestFactory.identifier3('_ctor');
    FormalParameterList parameters = _createFormalParameterList();
    FunctionBody body = _createExpressionFunctionBody(className);
    return AstTestFactory.methodDeclaration2(Keyword.STATIC, returnType, null, null, name, parameters, body);
  }

  ExpressionFunctionBody _createExpressionFunctionBody(String className) {
    Expression expression = _createInstanceCreationExpression(className, '_');
    return AstTestFactory.expressionFunctionBody(expression);
  }

  ConstructorDeclaration _createFactoryConstructor(String className) {
    var returnType = AstTestFactory.identifier3(className);
    var name = null;
    var parameters = _createFormalParameterList();
    var initializers = null;
    var body = new BlockFunctionBodyImpl(null, null, _createPooledComponentCreationBlock(className));
    return AstTestFactory.constructorDeclaration2(null, Keyword.FACTORY, returnType, name, parameters, initializers, body);
  }

  ConstructorDeclaration _createHiddenConstructor(String className) {
    var returnType = AstTestFactory.identifier3(className);
    var parameters = _createFormalParameterList();
    var body = AstTestFactory.emptyFunctionBody();
    return AstTestFactory.constructorDeclaration2(null, null, returnType, '_', parameters, null, body);
  }
}

FormalParameterList _createFormalParameterList([List<FormalParameter> parameters = const <FormalParameter>[]]) {
  return AstTestFactory.formalParameterList(parameters);
}

Block _createPooledComponentCreationBlock(String className, [List<Statement> fieldAssignments = const <Statement>[]]) {
  List<Statement> statements = <Statement>[];
  List<VariableDeclaration> variables = <VariableDeclaration>[];
  variables.add(_createVariableDeclaration(className));
  var variableDeclarationStatement =
      AstTestFactory.variableDeclarationStatement(null, AstTestFactory.typeName3(AstTestFactory.identifier3(className)), variables);
  Expression expression = AstTestFactory.identifier3('pooledComponent');
  var returnStatement = AstTestFactory.returnStatement2(expression);
  statements.add(variableDeclarationStatement);
  fieldAssignments.forEach((statement) => statements.add(statement));
  statements.add(returnStatement);
  return AstTestFactory.block(statements);
}

VariableDeclaration _createVariableDeclaration(String className) {
  List<Expression> arguments = <Expression>[];
  arguments.add(AstTestFactory.identifier3(className));
  arguments.add(AstTestFactory.identifier3('_ctor'));
  Expression initializer = _createInstanceCreationExpression('Pooled', 'of', arguments);
  return AstTestFactory.variableDeclaration2('pooledComponent', initializer);
}

InstanceCreationExpression _createInstanceCreationExpression(String className, String constructorName,
    [List<Expression> arguments = null]) {
  return AstTestFactory.instanceCreationExpression3(
      Keyword.NEW, AstTestFactory.typeName4(className), constructorName, arguments);
}

class _ComponentConstructorToFactoryConstructorConvertingAstVisitor extends SimpleAstVisitor {
  int _count = 0;
  _ComponentConstructorToFactoryConstructorConvertingAstVisitor();

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    node.factoryKeyword = TokenFactory.tokenFromKeyword(Keyword.FACTORY);
    var formalParameters = <FormalParameter>[];
    var assignmentStatements = <Statement>[];
    node.parameters.parameters.forEach((parameter) {
      bool addStatement = true;
      var modifiedParameter = AstTestFactory.simpleFormalParameter3(parameter.identifier.name);
      if (parameter is FieldFormalParameter) {
        formalParameters.add(modifiedParameter);
      } else if (parameter is DefaultFormalParameter) {
        if (parameter.parameter is FieldFormalParameter) {
          parameter.parameter = modifiedParameter;
        }
        formalParameters.add(parameter);
      } else if (parameter is SimpleFormalParameter) {
        formalParameters.add(parameter);
        addStatement = false;
      } else {
        throw '${parameter.runtimeType} is not yet supported as a parameter for a Component, please open an issue at https://github.com/denniskaselow/dartemis/issues';
      }
      if (addStatement) {
        Expression leftHandSide = AstTestFactory.identifier5('pooledComponent', parameter.identifier.name);
        Expression rightHandSide = AstTestFactory.identifier3(parameter.identifier.name);
        assignmentStatements.add(
            AstTestFactory.expressionStatement(AstTestFactory.assignmentExpression(leftHandSide, TokenType.EQ, rightHandSide)));
      }
    });
    node.initializers.forEach((ConstructorFieldInitializer initializer) {
      Expression leftHandSide = AstTestFactory.identifier5('pooledComponent', initializer.fieldName.name);
      assignmentStatements.add(AstTestFactory
          .expressionStatement(AstTestFactory.assignmentExpression(leftHandSide, TokenType.EQ, initializer.expression)));
    });
    if (node.body is BlockFunctionBody) {
      node.body.visitChildren(new PooledComponentConstructorStatementsVisitor());
      (node.body as BlockFunctionBody).block.statements.forEach((statement) {
        assignmentStatements.add(statement);
      });
    }
    node.parameters = _createFormalParameterList(formalParameters);
    node.body =
        AstTestFactory.blockFunctionBody(_createPooledComponentCreationBlock(node.returnType.name, assignmentStatements));
    node.initializers.clear();
    _count++;
  }
}

class PooledComponentConstructorStatementsVisitor extends RecursiveAstVisitor {
  @override
  visitPropertyAccess(PropertyAccess node) {
    super.visitPropertyAccess(node);
    if (node.target is ThisExpression) {
      node.target = AstTestFactory.identifier3('pooledComponent');
    }
    return null;
  }
}
