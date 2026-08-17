# Geometry and IR-physics proof contract

This Lean 4 project models the replacement proof contract for Immersive
Railroading 1.11.0. It is not a PID proof. Its connected layers are:

```text
trace samples -> cubic centreline splines -> derived route graph
              -> detector profile -> front coupler -> combined IR command
              -> discrete particle transition -> guarded arrival/holding
```

`IRRevision.lean` is the normative source-connected model for this revision.
It contains the trace-fit producer, cubic spline orientations, the compiled
`validated_spline_to_directed_routing_edge` theorem, topology/graph/marker
producers, detector/static/configuration profile adapters, exact root-bytecode
force branches, per-particle/linkage transition, raw command/API adapter,
front-coupler localization, timing split, arrival/no-crossing/holding
contracts, and route-local fail-closed decisions. `IRRevisionTestVectors.lean`
contains exact-rational positive and mutation vectors for those boundaries.
`IRProof.lean`, `IRCertifiedModel.lean`, and `IRTestVectors.lean` remain
legacy migration artifacts; any claim they make that is not reproduced by
`IRRevision.lean` is withdrawn.
`Axioms.lean` prints transitive theorem axiom dependencies for both the
legacy inventory and the normative revision inventory.

The fresh revision baseline is `NOT_READY`; the prior readiness claim is
withdrawn until the source-connected rewrite and independent audit complete.
It does not claim that the unchanged production Lua refines the full Java
particle/linkage/collision implementation or is approved for deployment.
Those are explicitly classified as future implementation obligations or
unsupported claims in the surrounding reports.

Build and audit:

```text
lake build
lake env lean Axioms.lean
lake env lean IRTestVectors.lean
lake env lean IRRevisionTestVectors.lean
```
