#ifndef SHAPE_BASE_TD
#define SHAPE_BASE_TD

include "mlir/IR/OpBase.td"

// TODO(jpienaar): Move to base.
def AnyShaped: ShapedContainerType<[AnyType], IsShapedTypePred, "shaped">;

//===----------------------------------------------------------------------===//
// Shape Inference dialect definitions
//===----------------------------------------------------------------------===//

def ShapeDialect : Dialect {
  let name = "shape";

  let summary = "Types and operations for shape dialect";
  let description = [{
    This dialect contains operations for shape inference.

    Note: Unless explicitly stated, all functions that return a shape and take
    shapes as input, return the invalid shape if one of its operands is an
    invalid shape. This avoids flagging multiple errors for one verification
    failure. The dialect itself does not specify how errors should be combined
    (there are multiple different options, from always choosing first operand,
    concatting etc. on how to combine them).
  }];

  let cppNamespace = "shape";

  let hasConstantMaterializer = 1;
}

def Shape_ComponentType : DialectType<ShapeDialect,
    CPred<"$_self.isa<::mlir::shape::ComponentType>()">, "component type">,
    BuildableType<"$_builder.getType<::mlir::shape::ComponentType>()"> {
  let typeDescription = [{
    `shape.element_type` represents the element type of the ShapedType. It may
    be unknown, error or regular element type supported by ShapedType.
  }];
}

def Shape_ElementType : DialectType<ShapeDialect,
    CPred<"$_self.isa<::mlir::shape::ElementType>()">, "element type">,
    BuildableType<"$_builder.getType<::mlir::shape::ElementType>()"> {
  let typeDescription = [{
    `shape.element_type` represents the element type of the ShapedType. It may
    be unknown, error or regular element type supported by ShapedType.
  }];
}

def Shape_ShapeType : DialectType<ShapeDialect,
    CPred<"$_self.isa<::mlir::shape::ShapeType>()">, "shape">,
    BuildableType<"$_builder.getType<::mlir::shape::ShapeType>()"> {
  let typeDescription = [{
    `shape.type` represents either an unranked shape, a ranked shape with
    possibly unknown dimensions or an invalid shape. The rank is of type
    `shape.size` and, if rank is known, the extent is a 1D tensor of type
    `shape.size`.

    Shape is printed:
    * `[*]` if it is an unranked shape
    * `[?, 2]` if a rank 2 tensor with one unknown dimension
    * `[3, 4]` is a rank 2 static tensor
    * `[]` is a scalar
    * `[1]` is a rank 1 tensor with 1 element
    * `[invalid]` for an invalid shape
  }];
}

def Shape_SizeType : DialectType<ShapeDialect,
    CPred<"$_self.isa<::mlir::shape::SizeType>()">, "size">,
    BuildableType<"$_builder.getType<::mlir::shape::SizeType>()"> {
  let typeDescription = [{
    `shape.size` represents a non-negative integer with support for being
    unknown and invalid.

    Operations on `shape.size` types are specialized to handle unknown/dynamic
    value. So, for example, `<unknown> + x == <unknown>` for all non-error `x :
    !shape.size` (e.g., an unknown value does not become known due to addition).
  }];
}

def Shape_ValueShapeType : DialectType<ShapeDialect,
    CPred<"$_self.isa<::mlir::shape::ValueShapeType>()">, "value shape">,
    BuildableType<"::mlir::shape::ValueShapeType::get($_builder.getContext())">
{
  let typeDescription = [{
    `shape.value_shape` represents the value produced by an operation (this
    corresponds to `Value` in the compiler) and a shape. Conceptually this is a
    tuple of a value (potentially unknown) and `shape.type`. The value and shape
    can either or both be unknown. If both the `value` and `shape` are known,
    then the shape of `value` is conformant with `shape`.
  }];
}

def Shape_ShapeOrSizeType: AnyTypeOf<[Shape_SizeType, Shape_ShapeType],
  "shape or size">;

#endif // SHAPE_BASE_TD
