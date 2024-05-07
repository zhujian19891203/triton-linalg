#pragma once
#include "triton/Dialect/Triton/IR/Dialect.h"
#include "triton-linalg/Dialect/Auxiliary/IR/AuxiliaryDialect.h"
#include "triton-linalg/Dialect/Auxiliary/Transforms/AuxOpTilingInterface.h"
#include "triton-linalg/Dialect/LinalgExt/IR/LinalgExtOps.h"
#include "triton-linalg/Dialect/LinalgExt/Transforms/TilingInterfaceImpl.h"
#include "triton-linalg/Dialect/Triton/Transforms/InferAxisInfoInterfaceImpl.h"
#include "mlir/InitAllPasses.h"

#include "triton-linalg/Conversion/Passes.h"
#include "triton-linalg/Dialect/Triton/Transforms/Passes.h"
#include "triton-linalg/Dialect/Arith/Transforms/Passes.h"

inline void registerTritonLinalgDialects(mlir::DialectRegistry &registry) {
  // Triton.
  registry.insert<mlir::triton::TritonDialect>();
  // TritonLinalg.
  registry.insert<mlir::triton::aux::AuxiliaryDialect>();
  registry.insert<mlir::triton::linalg_ext::LinalgExtDialect>();

  mlir::triton::aux::registerTilingInterfaceExternalModels(registry);
  mlir::triton::linalg_ext::registerTilingInterfaceExternalModels(registry);
  mlir::triton::linalg_ext::registerExtOpTilingInterfaceExternalModels(registry);
  mlir::triton::registerInferAxisInfoInterfaceExternalModels(registry);
}

inline void registerTritonLinalgPasses() {
  ::mlir::triton::arith_ext::registerArithExtPasses();
  ::mlir::triton::registerTritonLinalgConversionPasses();
  ::mlir::triton::registerTritonTransformsExtendPasses();
}
