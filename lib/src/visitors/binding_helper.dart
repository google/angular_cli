// Copyright 2017 Google Inc.
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:analyzer/analyzer.dart';

import '../app_logger.dart';
import '../exceptions.dart';
import 'binding_info.dart';
import 'utils.dart';

/// Extracts binding information from list literal.
///
/// Given a list of bindings in [bindingList], extracts all information to
/// [module].
void extractBindingInfo(ListLiteral bindingList, ModuleInfo module) {
  for (var node in bindingList.elements) {
    try {
      processBindingElement(node, module);
    } on UnsupportedError catch (e) {
      AppLogger.log.fine(e.message);
    }
  }
}

/// Parses a single binding creation expression.
///
/// For one binding expression [node], saves the information to [module].
/// For code block below:
///
///   const testBindings = Const [
///       X,
///       otherBindings,
///       const Binding(A, toAlias: B)
///   ]
///
/// Simple identifier "X" and "otherBindings" will be stored in
/// directChildren of [module] as a String, and binding creation expression
/// "const Binding(A, toAlias: B)" will be parsed into a BindingInstance
/// and be stored in directChildren of [module].
void processBindingElement(Expression node, ModuleInfo module) {
  Object binding;
  if (node is SimpleIdentifier) {
    // Ignores PrefixedIdentifier here. node here can be
    // a module (binding list)  or
    // an OpaqueToken or
    // a class name.
    binding = extractName(node);
  } else if (node is InstanceCreationExpression) {
    binding = _getBindingFromCreationExpression(node);
  } else if (node is MethodInvocation) {
    binding = _getBindingFromMethodInvocation(node);
  } else {
    throw new UnsupportedError('Unable to handle $node.');
  }

  if (binding != null) module.directChildren.add(binding);
}

/// Extracts binding information from instance creation expression [node].
/// [node] can be something like below.
///
///   const/new Provider(Expression, ...)
BindingInstance _getBindingFromCreationExpression(
    InstanceCreationExpression node) {
  if (extractName(node.constructorName.type.name) != 'Provider') {
    throw new UnsupportedError(
        'Unable to handle ${node.constructorName.type.name} in $node');
  }

  return _buildBindingInstance(node.argumentList.arguments, node.toString());
}

/// Extracts binding information from method invocation [node].
/// [node] can be something like below.
///
///   provide(ClassABC, ...).
BindingInstance _getBindingFromMethodInvocation(MethodInvocation node) {
  if (node.target != null) {
    throw new UnsupportedError('Unable to handle ${node.target} in $node');
  }

  if (node.methodName.name != 'provide') {
    throw new UnsupportedError(
        'Unable to handle ${node.methodName.name} in $node');
  }

  return _buildBindingInstance(node.argumentList.arguments, node.toString());
}

BindingInstance _buildBindingInstance(
    NodeList<Expression> args, String creationExpression) {
  if (args.isEmpty) throw new InvalidExpressionError(creationExpression);

  BindingInstance binding;
  var token = args[0];
  if (token is SimpleIdentifier || token is PrefixedIdentifier) {
    // Expression is an OpaqueToken or a class name.
    binding = new BindingInstance(extractName(token), creationExpression);
  } else if (token is InstanceCreationExpression) {
    // Expression is to create a class instance.
    binding = new BindingInstance(
        extractName(token.constructorName.type.name), creationExpression);
  } else if (token is SimpleStringLiteral) {
    binding = new BindingInstance(token.value, creationExpression);
  }

  if (binding != null) {
    _handleBindingArgs(args, binding);
    return binding;
  }

  throw new UnsupportedError('Unable to handle $token '
      '(${token.runtimeType}) in $creationExpression');
}

/// Extracts name of the class from [expression] used in toClass / toAlias.
String _extractClassName(Expression expression) {
  if (expression is SimpleIdentifier || expression is PrefixedIdentifier) {
    return extractName(expression);
  }

  throw new UnsupportedError(
      'Unable to handle $expression for toClass / toAlias');
}

/// Collects all referenced classes in binding creation [expression]
/// to [bindingInstance] recursively.
void _addReferencedClasses(
    Expression expression, BindingInstance bindingInstance) {
  if (expression is Identifier) {
    bindingInstance.referencedClasses.add(extractName(expression));
  } else if (expression is InstanceCreationExpression) {
    // Annotation, skip.
    AppLogger.log.fine('Ignore expression "$expression" in deps');
  } else if (expression is ListLiteral) {
    for (var dependency in expression.elements) {
      _addReferencedClasses(dependency, bindingInstance);
    }
  } else {
    throw new InvalidExpressionError(expression.toString());
  }
}

/// Extracts binding information from arguments in calling
///
/// const/new Provider(token, ...)
/// provider(token, ...)
void _handleBindingArgs(
    NodeList<Expression> args, BindingInstance bindingInstance) {
  // Element 0 is already processed by caller.
  for (var i = 1; i < args.length; ++i) {
    if (args[i] is! NamedExpression) {
      throw new InvalidExpressionError('Invalid parameter ${args[i]} at $i');
    }

    var namedExpression = args[i] as NamedExpression;
    var expression = namedExpression.expression;
    switch (namedExpression.name.label.name) {
      case 'useClass': // Fallthrough, they share the same format.
      case 'useExisting':
        bindingInstance.referencedClasses.add(_extractClassName(expression));
        break;
      case 'useValue':
        if (expression is InstanceCreationExpression) {
          bindingInstance.referencedClasses
              .add(extractName(expression.constructorName.type.name));
        }
        break;
      case 'useFactory':
        break;
      case 'multi': // Do nothing.
        break;
      case 'deps':
        _addReferencedClasses(expression, bindingInstance);
        break;
      default:
        throw new UnsupportedError('Unimplemented named expression:'
            ' ${namedExpression.name.label.name}');
    }
  }
}
