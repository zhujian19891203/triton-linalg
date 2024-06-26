//===- LinalgExtStructedOps.td - Linalg ext ops ------------*- tablegen -*-===//
//
// Copyright (C) [2022-2025] by Cambricon.
//
//===----------------------------------------------------------------------===//
//
// This is the additional operation definition file for structured operations
// on buffers.
//
//===----------------------------------------------------------------------===//

#ifndef TRITON_LINALG_DIALECT_LINALGEXT_IR_LINALGEXTSTRUCTEDOPS_TD
#define TRITON_LINALG_DIALECT_LINALGEXT_IR_LINALGEXTSTRUCTEDOPS_TD

include "triton-linalg/Dialect/LinalgExt/IR/LinalgExtBase.td"

//===----------------------------------------------------------------------===//
// Op definition for BatchConv2DNhwcFhwcOp
//===----------------------------------------------------------------------===//

def BatchConv2DNhwcFhwcOp : LinalgExtStructuredBase_Op<"batch_conv_2d_nhwc_fhwc",
    [AttrSizedOperandSegments]> {
  let summary = [{ Performs a batched 2-D convolution. }];
  let description = [{
    Layout:
      * Input: BNHWC.
      * Kernel: BFHWC.

    Numeric casting is performed on the operands to the inner multiply, promoting
    them to the same data type as the accumulator/output.
  }];

  let arguments = (ins
    Variadic<AnyType>:$inputs,
    Variadic<AnyShaped>:$outputs,
    DefaultValuedAttr<RankedI64ElementsAttr<[2]>, "{ static_cast<int64_t>(1), static_cast<int64_t>(1) }">:$strides,
    DefaultValuedAttr<RankedI64ElementsAttr<[2]>, "{ static_cast<int64_t>(1), static_cast<int64_t>(1) }">:$dilations
  );
  let results = (outs Variadic<AnyRankedTensor>:$result_tensors);
  let regions = (region AnyRegion:$region);

  let skipDefaultBuilders = 1;
  let builders = [
    OpBuilder<
    (ins "ValueRange":$inputs, "ValueRange":$outputs,
        CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
    [{
      buildStructuredOp($_builder, $_state, std::nullopt, inputs, outputs,
          attributes, BatchConv2DNhwcFhwcOp::getRegionBuilder());
    }]>,
    OpBuilder<
    (ins "TypeRange":$resultTensorTypes, "ValueRange":$inputs, "ValueRange":$outputs,
        CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
    [{
      buildStructuredOp($_builder, $_state, resultTensorTypes, inputs, outputs,
          attributes, BatchConv2DNhwcFhwcOp::getRegionBuilder());
    }]>,
    OpBuilder<
    (ins "TypeRange":$resultTensorTypes, "ValueRange":$inputs, "ValueRange":$outputs,
        "Attribute":$strides, "Attribute":$dilations,
        CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
    [{
      $_state.addAttribute("strides", strides);
      $_state.addAttribute("dilations", dilations);
      buildStructuredOp($_builder, $_state, resultTensorTypes, inputs, outputs,
          attributes, BatchConv2DNhwcFhwcOp::getRegionBuilder());
    }]>
  ];

  let hasCustomAssemblyFormat = 1;
  let hasFolder = 1;

  let extraClassDeclaration = structuredOpsBaseDecls # [{
    SmallVector<mlir::utils::IteratorType> getIteratorTypesArray();
    ArrayAttr getIndexingMaps();
    static void regionBuilder(ImplicitLocOpBuilder &b,
                              Block &block, ArrayRef<NamedAttribute> attrs);
    static std::function<void(ImplicitLocOpBuilder &, Block &, ArrayRef<NamedAttribute>)>
      getRegionBuilder() {
      return regionBuilder;
    }
    static unsigned getNumRegionArgs();
    std::string getLibraryCallName() {
      return "op_has_no_registered_library_name";
    }
    bool hasDynamicIndexingMaps();
    LogicalResult verifyIndexingMapRequiredAttributes();
    MutableOperandRange getDpsInitsMutable() { return getOutputsMutable(); }
  }];
}

//===----------------------------------------------------------------------===//
// Op definition for MakeRangeOp
//===----------------------------------------------------------------------===//

def MakeRangeOp : LinalgExtStructuredBase_Op<"make_range",
    [AttrSizedOperandSegments]> {
  let summary = [{ MakeRange operator. }];
  let description = [{
    Operation to define a 1D tensor of static given shape, the given shape is
    computed from the inputs. The value stored for each element in the tensor
    is its index value.
  }];

  let arguments = (ins
    Variadic<I32>:$inputs,
    Variadic<AnyShaped>:$outputs
  );
  let results = (outs Variadic<AnyRankedTensor>:$result_tensors);
  let regions = (region AnyRegion:$region);

  let skipDefaultBuilders = 1;
  let builders = [
    OpBuilder<
    (ins "ValueRange":$inputs, "ValueRange":$outputs,
          CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
    [{
      buildStructuredOp($_builder, $_state, std::nullopt, inputs, outputs,
        attributes, MakeRangeOp::getRegionBuilder());
    }]>,
    OpBuilder<
    (ins "TypeRange":$resultTensorTypes, "ValueRange":$inputs,
          "ValueRange":$outputs,
          CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
    [{
      buildStructuredOp($_builder, $_state, resultTensorTypes,
        inputs, outputs, attributes, MakeRangeOp::getRegionBuilder());
    }]>,
    OpBuilder<
    (ins "TypeRange":$resultTensorTypes, "ValueRange":$operands,
          CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
    [{
      $_state.addOperands(operands);
      $_state.addAttributes(attributes);
      $_state.addTypes(resultTensorTypes);
      (void)$_state.addRegion();
    }]>
  ];
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
  let hasFolder = 1;


  let extraClassDeclaration = structuredOpsBaseDecls # [{
    // Auto-generated.
    SmallVector<mlir::utils::IteratorType> getIteratorTypesArray();
    ArrayAttr getIndexingMaps();
    static void regionBuilder(ImplicitLocOpBuilder &b,
                              Block &block, ArrayRef<NamedAttribute> attrs);
    static std::function<void(ImplicitLocOpBuilder &,
                              Block &, ArrayRef<NamedAttribute>)>
    getRegionBuilder() {
      return regionBuilder;
    }

    Value getStart() {
      return getOperation()->getOperand(0);
    }
    Value getEnd() {
      return getOperation()->getOperand(1);
    }
    // Generic methods.
    static unsigned getNumRegionArgs();
    std::string getLibraryCallName() {
      return "op_has_no_registered_library_name";
    }
    MutableOperandRange getDpsInitsMutable() { return getOutputsMutable(); }
    ShapedType getOutputOperandType() {
      return getOutputs().front().getType().cast<ShapedType>();
    }
  }];
}

//===----------------------------------------------------------------------===//
// Op definition for Im2ColOp
//===----------------------------------------------------------------------===//

def Im2ColOp : LinalgExtStructuredBase_Op<"im2col", [AttrSizedOperandSegments]> {
  let summary = "Image to Column operation.";
  let description = [{
    Consider 2D input X with single channel input and output and 2x2 filter W:
    ```
    [x(0, 0)  , x(0, 1)  , ...,   x(0, n)  ]
    [x(1, 0)  , x(1, 1)  , ...,   x(1, n)  ]
    [.        ,  .       ,.   ,      .     ]            [w(0, 0), w(0, 1)]
    [.        ,  .       , .  ,      .     ]    (conv)  [w(1, 0), w(1, 1)]
    [.        ,  .       ,   .,      .     ]
    [x(n-1, 0), x(n-1, 1), ..., x(n-1, n-1)]
    ```

    The packed input data (im2col) is a matrix with |rows| = output spatial
    size, |columns| = filter spatial size. To compute the output Y(i, j) we need
    to calculate the dot product between filter window at input X(x, y)) and the
    filter which will look like the following where r.h.s is the im2col matrix
    and l.h.s is the flattned filter:
    ```
    [x(0,0), x(0,1), x(1,0), x(1,1)]
    [x(0,1), x(1,1), x(0,2), x(1,2)] (matmul) [w(0,0), w(0,1), w(1,0), w(1,1)]
    [x(0,1), x(1,1), x(0,2), x(1,2)]
    [   .  ,    .  ,    .  ,    .  ]
    ```

    In general for 2D case with (N, H, W, C) input and (D, Kh, Kw, C) filter
    and output (N, Ho, Wo, D) the convolution is the following matrix-matrix
    multiplication (Ho x Wo, Kh x Kw x C) * (D, Kh x Kw x C) for each input in
    the N input. For the case where N > 1 its a batched matrxi-matrix
    multplication.

    // TODO: add support for conv3d.
  }];

    let arguments = (ins
      Variadic<AnyType>:$inputs,
      Variadic<AnyShaped>:$outputs,
      DefaultValuedAttr<RankedI64ElementsAttr<[2]>, "{ static_cast<int64_t>(1), static_cast<int64_t>(1) }">:$strides
    );
    let results = (outs Variadic<AnyRankedTensor>:$result_tensors);
    let regions = (region AnyRegion:$region);

    let skipDefaultBuilders = 1;
    let builders = [
      OpBuilder<
      (ins "ValueRange":$inputs, "ValueRange":$outputs,
            CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
      [{
        buildStructuredOp($_builder, $_state, std::nullopt, inputs, outputs,
          attributes, Im2ColOp::getRegionBuilder());
      }]>,
      OpBuilder<
      (ins "TypeRange":$resultTensorTypes, "ValueRange":$inputs,
            "ValueRange":$outputs,
            CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
      [{
        buildStructuredOp($_builder, $_state, resultTensorTypes,
          inputs, outputs, attributes, Im2ColOp::getRegionBuilder());
      }]>,
      OpBuilder<
      (ins "TypeRange":$resultTensorTypes, "ValueRange":$operands,
            CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
      [{
        $_state.addOperands(operands);
        $_state.addAttributes(attributes);
        $_state.addTypes(resultTensorTypes);
        (void)$_state.addRegion();
      }]>,
      OpBuilder<
      (ins "TypeRange":$resultTensorTypes, "ValueRange":$inputs,
           "ValueRange":$outputs, "Attribute":$strides,
           CArg<"ArrayRef<NamedAttribute>", "{}">:$attributes),
      [{
        $_state.addAttribute("strides", strides);
        buildStructuredOp($_builder, $_state, resultTensorTypes, inputs, outputs,
          attributes, Im2ColOp::getRegionBuilder());
      }]>
    ];

    let hasCustomAssemblyFormat = 1;
    let hasFolder = 1;

    let extraClassDeclaration = structuredOpsBaseDecls # [{
      // Auto-generated.
      SmallVector<mlir::utils::IteratorType> getIteratorTypesArray();
      ArrayAttr getIndexingMaps();
      static void regionBuilder(ImplicitLocOpBuilder &b,
                                Block &block, ArrayRef<NamedAttribute> attrs);
      static std::function<void(ImplicitLocOpBuilder &,
                                Block &, ArrayRef<NamedAttribute>)>
      getRegionBuilder() {
        return regionBuilder;
      }

      // Generic methods.
      static unsigned getNumRegionArgs();
      std::string getLibraryCallName();
      bool hasDynamicIndexingMaps();
      LogicalResult verifyIndexingMapRequiredAttributes();
      MutableOperandRange getDpsInitsMutable() { return getOutputsMutable(); }
    }];
}
#endif // TRITON_LINALG_DIALECT_LINALGEXT_IR_LINALGEXTSTRUCTEDOPS_TD
