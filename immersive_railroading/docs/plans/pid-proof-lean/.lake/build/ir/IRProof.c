// Lean compiler output
// Module: IRProof
// Imports: public import Init public meta import Init public import Lean public import Lean.Elab.Tactic.Grind.Main
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
lean_object* l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(lean_object*);
lean_object* l_Rat_sub(lean_object*, lean_object*);
lean_object* l_Rat_mul(lean_object*, lean_object*);
lean_object* l_Rat_add(lean_object*, lean_object*);
uint8_t l_instDecidableEqRat_decEq(lean_object*, lean_object*);
lean_object* l_Rat_div(lean_object*, lean_object*);
uint8_t l_Rat_instDecidableLe(lean_object*, lean_object*);
lean_object* l_Rat_neg(lean_object*);
uint8_t l_Rat_blt(lean_object*, lean_object*);
lean_object* l_List_reverse___redArg(lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
lean_object* lean_nat_sub(lean_object*, lean_object*);
lean_object* lean_string_append(lean_object*, lean_object*);
uint8_t lean_string_dec_eq(lean_object*, lean_object*);
lean_object* l_List_appendTR___redArg(lean_object*, lean_object*);
lean_object* l_Repr_addAppParen(lean_object*, lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
lean_object* lean_nat_to_int(lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
lean_object* l_instDecidableEqRat___boxed(lean_object*, lean_object*);
uint8_t l_Option_instDecidableEq___redArg(lean_object*, lean_object*, lean_object*);
lean_object* l_List_zipWith___at___00List_zip_spec__0___redArg(lean_object*, lean_object*);
lean_object* l_List_lengthTR___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_square(lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_absQ___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_absQ___closed__0;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_absQ(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_clamp(lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_sat01___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_sat01___closed__0;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_sat01(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqVec3_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqVec3_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqVec3(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqVec3___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Vec3_add(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Vec3_sub(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_distance3Sq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_distance3L1(lean_object*, lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_cubicPosition___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_cubicPosition___closed__0;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_cubicPosition(lean_object*, lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_cubicDerivative___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_cubicDerivative___closed__0;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_cubicDerivative(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_cubicReverse(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_degenerateStraight(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineFromCurve(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineOrientation(lean_object*, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineOrientation___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_tangentAt(lean_object*, uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_tangentAt___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_gradeAt(lean_object*, uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_gradeAt___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAtList(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAtList___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAt(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAt___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arcDistance(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_centreEstimate(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_centrelineResidualBound(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_TopologyClass_ofNat(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ofNat___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqTopologyClass(uint8_t, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqTopologyClass___boxed(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 35, .m_capacity = 35, .m_length = 34, .m_data = "IRProof.TopologyClass.continuation"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__0_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__0_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__1 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__1_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 32, .m_capacity = 32, .m_length = 31, .m_data = "IRProof.TopologyClass.extension"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__2 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__2_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__2_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__3 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__3_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 39, .m_capacity = 39, .m_length = 38, .m_data = "IRProof.TopologyClass.sharedConnection"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__4 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__4_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__4_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__5 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__5_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 39, .m_capacity = 39, .m_length = 38, .m_data = "IRProof.TopologyClass.isolatedCrossing"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__6 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__6_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__7_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__6_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__7 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__7_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__8_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 31, .m_capacity = 31, .m_length = 30, .m_data = "IRProof.TopologyClass.overpass"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__8 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__8_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__9_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__8_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__9 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__9_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__10_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 33, .m_capacity = 33, .m_length = 32, .m_data = "IRProof.TopologyClass.unresolved"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__10 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__10_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__11_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__10_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__11 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__11_value;
static lean_once_cell_t lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12;
static lean_once_cell_t lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_ir_x2dproof_IRProof_instReprTopologyClass___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass___closed__0_value;
LEAN_EXPORT const lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprTopologyClass___closed__0_value;
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_classifyTopology(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_classifyTopology___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_topologyRoutable(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_topologyRoutable___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter___redArg(uint8_t, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter___redArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter(lean_object*, uint8_t, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_containsString(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_containsString___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeChainValid_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeChainValid_spec__0___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeChainValid(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeChainValid___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__2(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__2___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__3(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__3___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__6(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__6___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_any___at___00IRProof_routeEdgeSetValid_spec__4(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_any___at___00IRProof_routeEdgeSetValid_spec__4___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__7(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__7___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__0___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__1(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__1___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__5(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__5___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeEdgeSetValid(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeEdgeSetValid___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeInvalidated(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeInvalidated___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_Approach_ofNat(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ofNat___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqApproach(uint8_t, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqApproach___boxed(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 25, .m_capacity = 25, .m_length = 24, .m_data = "IRProof.Approach.forward"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__0_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__0_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__1 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__1_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 25, .m_capacity = 25, .m_length = 24, .m_data = "IRProof.Approach.reverse"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__2 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__2_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__2_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__3 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__3_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_ir_x2dproof_IRProof_instReprApproach___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_ir_x2dproof_IRProof_instReprApproach_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_ir_x2dproof_IRProof_instReprApproach___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach___closed__0_value;
LEAN_EXPORT const lean_object* lp_ir_x2dproof_IRProof_instReprApproach = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprApproach___closed__0_value;
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarker_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarker_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarker(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarker___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_mapMarker(lean_object*, lean_object*, lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_stockKey___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 2, .m_capacity = 2, .m_length = 1, .m_data = ":"};
static const lean_object* lp_ir_x2dproof_IRProof_stockKey___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_stockKey___closed__0_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stockKey(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profileKeys_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileKeys(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileFingerprint(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profileFingerprints_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileFingerprints(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_beq___at___00IRProof_profileMismatch_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_beq___at___00IRProof_profileMismatch_spec__0___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_profileMismatch(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileMismatch___boxed(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_catalogueOne___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 18, .m_capacity = 18, .m_length = 17, .m_data = "ir_train_overhead"};
static const lean_object* lp_ir_x2dproof_IRProof_catalogueOne___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_catalogueOne___closed__0_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_catalogueOne(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_catalogueOne___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_catalogueSpeedBound(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistMass_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistMass(lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelStatic___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelStatic___closed__0;
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelStatic___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelStatic___closed__1;
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelStatic___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelStatic___closed__2;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_steelStatic;
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelKinetic___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelKinetic___closed__0;
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelKinetic___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelKinetic___closed__1;
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelKinetic___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelKinetic___closed__2;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_steelKinetic;
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__0;
static lean_once_cell_t lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__1;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_steelCastIronKinetic;
static lean_once_cell_t lp_ir_x2dproof_IRProof_gravity___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_gravity___closed__0;
static lean_once_cell_t lp_ir_x2dproof_IRProof_gravity___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_gravity___closed__1;
static lean_once_cell_t lp_ir_x2dproof_IRProof_gravity___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_gravity___closed__2;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_gravity;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_defaultBrakeMultiplier;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_physicalPressure(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeSystemEfficiency(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeSystemEfficiency___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeAdhesionEfficiency(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeAdhesionEfficiency___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_maximumAdhesionN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_maximumAdhesionN___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_designAdhesionN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_designAdhesionN___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeDemandN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_wheelSlipBrakeN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_wheelSlipBrakeN___boxed(lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_brakeBranch___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_brakeBranch___closed__0;
static lean_once_cell_t lp_ir_x2dproof_IRProof_brakeBranch___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_brakeBranch___closed__1;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeBranch(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeForceN(lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_gradeForceN___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_gradeForceN___closed__0;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_gradeForceN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_tractiveForceN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_rollingDirectInterferenceN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_couplerAdverseN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_signedNetForceN(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_forceLedger(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_particleAcceleration(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_irParticleStep(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistMassQ_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistMassQ(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistBrakeQ_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistBrakeQ(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistTractionQ_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistTractionQ(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistAdverseQ_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistAdverseQ(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_consistStep_spec__0(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistStep(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_localizeFrontCoupler(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedTargetFromLocalization(lean_object*, lean_object*, lean_object*, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedTargetFromLocalization___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stoppingError(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedVelocity(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedVelocity___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_totalPositionError(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_stoppingDistance___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_stoppingDistance___closed__0;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stoppingDistance(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_delayDistance(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_delayDistance___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_uniformBrakingAcceleration(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_certifiedBrakeStep(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_certifiedBrakeStep___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeVelocity(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeVelocity___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandForceUpper(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandForceUpper___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandBrakeLower(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stoppingCommand(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_ControllerMode_ofNat(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ofNat___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqControllerMode(uint8_t, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqControllerMode___boxed(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 30, .m_capacity = 30, .m_length = 29, .m_data = "IRProof.ControllerMode.cruise"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__0_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__0_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__1 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__1_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 32, .m_capacity = 32, .m_length = 31, .m_data = "IRProof.ControllerMode.stopping"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__2 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__2_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__2_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__3 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__3_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 31, .m_capacity = 31, .m_length = 30, .m_data = "IRProof.ControllerMode.holding"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__4 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__4_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__4_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__5 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__5_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 34, .m_capacity = 34, .m_length = 33, .m_data = "IRProof.ControllerMode.failClosed"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__6 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__6_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__7_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__6_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__7 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__7_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_ir_x2dproof_IRProof_instReprControllerMode___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_ir_x2dproof_IRProof_instReprControllerMode_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode___closed__0_value;
LEAN_EXPORT const lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprControllerMode___closed__0_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_combinedForceForCommand(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandPhysics(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_plantTransition(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_square(lean_object* v_x_1_){
_start:
{
lean_object* v___x_2_; 
lean_inc_ref(v_x_1_);
v___x_2_ = l_Rat_mul(v_x_1_, v_x_1_);
lean_dec_ref(v_x_1_);
return v___x_2_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_absQ___closed__0(void){
_start:
{
lean_object* v___x_3_; lean_object* v___x_4_; 
v___x_3_ = lean_unsigned_to_nat(0u);
v___x_4_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_3_);
return v___x_4_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_absQ(lean_object* v_x_5_){
_start:
{
lean_object* v___x_6_; uint8_t v___x_7_; 
v___x_6_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
lean_inc_ref(v_x_5_);
v___x_7_ = l_Rat_instDecidableLe(v___x_6_, v_x_5_);
if (v___x_7_ == 0)
{
lean_object* v___x_8_; 
v___x_8_ = l_Rat_neg(v_x_5_);
return v___x_8_;
}
else
{
return v_x_5_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_clamp(lean_object* v_lo_9_, lean_object* v_hi_10_, lean_object* v_x_11_){
_start:
{
uint8_t v___x_12_; 
lean_inc_ref(v_lo_9_);
lean_inc_ref(v_x_11_);
v___x_12_ = l_Rat_blt(v_x_11_, v_lo_9_);
if (v___x_12_ == 0)
{
uint8_t v___x_13_; 
lean_dec_ref(v_lo_9_);
lean_inc_ref(v_x_11_);
lean_inc_ref(v_hi_10_);
v___x_13_ = l_Rat_blt(v_hi_10_, v_x_11_);
if (v___x_13_ == 0)
{
lean_dec_ref(v_hi_10_);
return v_x_11_;
}
else
{
lean_dec_ref(v_x_11_);
return v_hi_10_;
}
}
else
{
lean_dec_ref(v_x_11_);
lean_dec_ref(v_hi_10_);
return v_lo_9_;
}
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_sat01___closed__0(void){
_start:
{
lean_object* v___x_14_; lean_object* v___x_15_; 
v___x_14_ = lean_unsigned_to_nat(1u);
v___x_15_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_14_);
return v___x_15_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_sat01(lean_object* v_x_16_){
_start:
{
lean_object* v___x_17_; lean_object* v___x_18_; lean_object* v___x_19_; 
v___x_17_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_18_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
v___x_19_ = lp_ir_x2dproof_IRProof_clamp(v___x_17_, v___x_18_, v_x_16_);
return v___x_19_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqVec3_decEq(lean_object* v_x_20_, lean_object* v_x_21_){
_start:
{
lean_object* v_x_22_; lean_object* v_y_23_; lean_object* v_z_24_; lean_object* v_x_25_; lean_object* v_y_26_; lean_object* v_z_27_; uint8_t v___x_28_; 
v_x_22_ = lean_ctor_get(v_x_20_, 0);
v_y_23_ = lean_ctor_get(v_x_20_, 1);
v_z_24_ = lean_ctor_get(v_x_20_, 2);
v_x_25_ = lean_ctor_get(v_x_21_, 0);
v_y_26_ = lean_ctor_get(v_x_21_, 1);
v_z_27_ = lean_ctor_get(v_x_21_, 2);
v___x_28_ = l_instDecidableEqRat_decEq(v_x_22_, v_x_25_);
if (v___x_28_ == 0)
{
return v___x_28_;
}
else
{
uint8_t v___x_29_; 
v___x_29_ = l_instDecidableEqRat_decEq(v_y_23_, v_y_26_);
if (v___x_29_ == 0)
{
return v___x_29_;
}
else
{
uint8_t v___x_30_; 
v___x_30_ = l_instDecidableEqRat_decEq(v_z_24_, v_z_27_);
return v___x_30_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqVec3_decEq___boxed(lean_object* v_x_31_, lean_object* v_x_32_){
_start:
{
uint8_t v_res_33_; lean_object* v_r_34_; 
v_res_33_ = lp_ir_x2dproof_IRProof_instDecidableEqVec3_decEq(v_x_31_, v_x_32_);
lean_dec_ref(v_x_32_);
lean_dec_ref(v_x_31_);
v_r_34_ = lean_box(v_res_33_);
return v_r_34_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqVec3(lean_object* v_x_35_, lean_object* v_x_36_){
_start:
{
uint8_t v___x_37_; 
v___x_37_ = lp_ir_x2dproof_IRProof_instDecidableEqVec3_decEq(v_x_35_, v_x_36_);
return v___x_37_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqVec3___boxed(lean_object* v_x_38_, lean_object* v_x_39_){
_start:
{
uint8_t v_res_40_; lean_object* v_r_41_; 
v_res_40_ = lp_ir_x2dproof_IRProof_instDecidableEqVec3(v_x_38_, v_x_39_);
lean_dec_ref(v_x_39_);
lean_dec_ref(v_x_38_);
v_r_41_ = lean_box(v_res_40_);
return v_r_41_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Vec3_add(lean_object* v_a_42_, lean_object* v_b_43_){
_start:
{
lean_object* v_x_44_; lean_object* v_y_45_; lean_object* v_z_46_; lean_object* v_x_47_; lean_object* v_y_48_; lean_object* v_z_49_; lean_object* v___x_51_; uint8_t v_isShared_52_; uint8_t v_isSharedCheck_59_; 
v_x_44_ = lean_ctor_get(v_a_42_, 0);
lean_inc_ref(v_x_44_);
v_y_45_ = lean_ctor_get(v_a_42_, 1);
lean_inc_ref(v_y_45_);
v_z_46_ = lean_ctor_get(v_a_42_, 2);
lean_inc_ref(v_z_46_);
lean_dec_ref(v_a_42_);
v_x_47_ = lean_ctor_get(v_b_43_, 0);
v_y_48_ = lean_ctor_get(v_b_43_, 1);
v_z_49_ = lean_ctor_get(v_b_43_, 2);
v_isSharedCheck_59_ = !lean_is_exclusive(v_b_43_);
if (v_isSharedCheck_59_ == 0)
{
v___x_51_ = v_b_43_;
v_isShared_52_ = v_isSharedCheck_59_;
goto v_resetjp_50_;
}
else
{
lean_inc(v_z_49_);
lean_inc(v_y_48_);
lean_inc(v_x_47_);
lean_dec(v_b_43_);
v___x_51_ = lean_box(0);
v_isShared_52_ = v_isSharedCheck_59_;
goto v_resetjp_50_;
}
v_resetjp_50_:
{
lean_object* v___x_53_; lean_object* v___x_54_; lean_object* v___x_55_; lean_object* v___x_57_; 
v___x_53_ = l_Rat_add(v_x_44_, v_x_47_);
v___x_54_ = l_Rat_add(v_y_45_, v_y_48_);
v___x_55_ = l_Rat_add(v_z_46_, v_z_49_);
if (v_isShared_52_ == 0)
{
lean_ctor_set(v___x_51_, 2, v___x_55_);
lean_ctor_set(v___x_51_, 1, v___x_54_);
lean_ctor_set(v___x_51_, 0, v___x_53_);
v___x_57_ = v___x_51_;
goto v_reusejp_56_;
}
else
{
lean_object* v_reuseFailAlloc_58_; 
v_reuseFailAlloc_58_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_58_, 0, v___x_53_);
lean_ctor_set(v_reuseFailAlloc_58_, 1, v___x_54_);
lean_ctor_set(v_reuseFailAlloc_58_, 2, v___x_55_);
v___x_57_ = v_reuseFailAlloc_58_;
goto v_reusejp_56_;
}
v_reusejp_56_:
{
return v___x_57_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Vec3_sub(lean_object* v_a_60_, lean_object* v_b_61_){
_start:
{
lean_object* v_x_62_; lean_object* v_y_63_; lean_object* v_z_64_; lean_object* v_x_65_; lean_object* v_y_66_; lean_object* v_z_67_; lean_object* v___x_69_; uint8_t v_isShared_70_; uint8_t v_isSharedCheck_77_; 
v_x_62_ = lean_ctor_get(v_a_60_, 0);
lean_inc_ref(v_x_62_);
v_y_63_ = lean_ctor_get(v_a_60_, 1);
lean_inc_ref(v_y_63_);
v_z_64_ = lean_ctor_get(v_a_60_, 2);
lean_inc_ref(v_z_64_);
lean_dec_ref(v_a_60_);
v_x_65_ = lean_ctor_get(v_b_61_, 0);
v_y_66_ = lean_ctor_get(v_b_61_, 1);
v_z_67_ = lean_ctor_get(v_b_61_, 2);
v_isSharedCheck_77_ = !lean_is_exclusive(v_b_61_);
if (v_isSharedCheck_77_ == 0)
{
v___x_69_ = v_b_61_;
v_isShared_70_ = v_isSharedCheck_77_;
goto v_resetjp_68_;
}
else
{
lean_inc(v_z_67_);
lean_inc(v_y_66_);
lean_inc(v_x_65_);
lean_dec(v_b_61_);
v___x_69_ = lean_box(0);
v_isShared_70_ = v_isSharedCheck_77_;
goto v_resetjp_68_;
}
v_resetjp_68_:
{
lean_object* v___x_71_; lean_object* v___x_72_; lean_object* v___x_73_; lean_object* v___x_75_; 
v___x_71_ = l_Rat_sub(v_x_62_, v_x_65_);
v___x_72_ = l_Rat_sub(v_y_63_, v_y_66_);
v___x_73_ = l_Rat_sub(v_z_64_, v_z_67_);
if (v_isShared_70_ == 0)
{
lean_ctor_set(v___x_69_, 2, v___x_73_);
lean_ctor_set(v___x_69_, 1, v___x_72_);
lean_ctor_set(v___x_69_, 0, v___x_71_);
v___x_75_ = v___x_69_;
goto v_reusejp_74_;
}
else
{
lean_object* v_reuseFailAlloc_76_; 
v_reuseFailAlloc_76_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_76_, 0, v___x_71_);
lean_ctor_set(v_reuseFailAlloc_76_, 1, v___x_72_);
lean_ctor_set(v_reuseFailAlloc_76_, 2, v___x_73_);
v___x_75_ = v_reuseFailAlloc_76_;
goto v_reusejp_74_;
}
v_reusejp_74_:
{
return v___x_75_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_distance3Sq(lean_object* v_a_78_, lean_object* v_b_79_){
_start:
{
lean_object* v_x_80_; lean_object* v_y_81_; lean_object* v_z_82_; lean_object* v_x_83_; lean_object* v_y_84_; lean_object* v_z_85_; lean_object* v___x_86_; lean_object* v___x_87_; lean_object* v___x_88_; lean_object* v___x_89_; lean_object* v___x_90_; lean_object* v___x_91_; lean_object* v___x_92_; lean_object* v___x_93_; 
v_x_80_ = lean_ctor_get(v_a_78_, 0);
lean_inc_ref(v_x_80_);
v_y_81_ = lean_ctor_get(v_a_78_, 1);
lean_inc_ref(v_y_81_);
v_z_82_ = lean_ctor_get(v_a_78_, 2);
lean_inc_ref(v_z_82_);
lean_dec_ref(v_a_78_);
v_x_83_ = lean_ctor_get(v_b_79_, 0);
lean_inc_ref(v_x_83_);
v_y_84_ = lean_ctor_get(v_b_79_, 1);
lean_inc_ref(v_y_84_);
v_z_85_ = lean_ctor_get(v_b_79_, 2);
lean_inc_ref(v_z_85_);
lean_dec_ref(v_b_79_);
v___x_86_ = l_Rat_sub(v_x_80_, v_x_83_);
lean_inc_ref(v___x_86_);
v___x_87_ = l_Rat_mul(v___x_86_, v___x_86_);
lean_dec_ref(v___x_86_);
v___x_88_ = l_Rat_sub(v_y_81_, v_y_84_);
lean_inc_ref(v___x_88_);
v___x_89_ = l_Rat_mul(v___x_88_, v___x_88_);
lean_dec_ref(v___x_88_);
v___x_90_ = l_Rat_add(v___x_87_, v___x_89_);
v___x_91_ = l_Rat_sub(v_z_82_, v_z_85_);
lean_inc_ref(v___x_91_);
v___x_92_ = l_Rat_mul(v___x_91_, v___x_91_);
lean_dec_ref(v___x_91_);
v___x_93_ = l_Rat_add(v___x_90_, v___x_92_);
return v___x_93_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_distance3L1(lean_object* v_a_94_, lean_object* v_b_95_){
_start:
{
lean_object* v_x_96_; lean_object* v_y_97_; lean_object* v_z_98_; lean_object* v_x_99_; lean_object* v_y_100_; lean_object* v_z_101_; lean_object* v___x_102_; lean_object* v___x_103_; lean_object* v___x_104_; lean_object* v___x_105_; lean_object* v___x_106_; lean_object* v___x_107_; lean_object* v___x_108_; lean_object* v___x_109_; 
v_x_96_ = lean_ctor_get(v_a_94_, 0);
lean_inc_ref(v_x_96_);
v_y_97_ = lean_ctor_get(v_a_94_, 1);
lean_inc_ref(v_y_97_);
v_z_98_ = lean_ctor_get(v_a_94_, 2);
lean_inc_ref(v_z_98_);
lean_dec_ref(v_a_94_);
v_x_99_ = lean_ctor_get(v_b_95_, 0);
lean_inc_ref(v_x_99_);
v_y_100_ = lean_ctor_get(v_b_95_, 1);
lean_inc_ref(v_y_100_);
v_z_101_ = lean_ctor_get(v_b_95_, 2);
lean_inc_ref(v_z_101_);
lean_dec_ref(v_b_95_);
v___x_102_ = l_Rat_sub(v_x_96_, v_x_99_);
v___x_103_ = lp_ir_x2dproof_IRProof_absQ(v___x_102_);
v___x_104_ = l_Rat_sub(v_y_97_, v_y_100_);
v___x_105_ = lp_ir_x2dproof_IRProof_absQ(v___x_104_);
v___x_106_ = l_Rat_add(v___x_103_, v___x_105_);
v___x_107_ = l_Rat_sub(v_z_98_, v_z_101_);
v___x_108_ = lp_ir_x2dproof_IRProof_absQ(v___x_107_);
v___x_109_ = l_Rat_add(v___x_106_, v___x_108_);
return v___x_109_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_cubicPosition___closed__0(void){
_start:
{
lean_object* v___x_110_; lean_object* v___x_111_; 
v___x_110_ = lean_unsigned_to_nat(3u);
v___x_111_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_110_);
return v___x_111_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_cubicPosition(lean_object* v_c_112_, lean_object* v_t_113_){
_start:
{
lean_object* v_p1_114_; lean_object* v_ctrl1_115_; lean_object* v_ctrl2_116_; lean_object* v_p2_117_; lean_object* v_x_118_; lean_object* v_y_119_; lean_object* v_z_120_; lean_object* v___x_121_; lean_object* v_u_122_; lean_object* v___x_123_; lean_object* v___x_124_; lean_object* v_x_125_; lean_object* v_y_126_; lean_object* v_z_127_; lean_object* v___x_128_; lean_object* v___x_129_; lean_object* v___x_130_; lean_object* v___x_131_; lean_object* v_x_132_; lean_object* v_y_133_; lean_object* v_z_134_; lean_object* v___x_135_; lean_object* v___x_136_; lean_object* v_x_137_; lean_object* v_y_138_; lean_object* v_z_139_; lean_object* v___x_141_; uint8_t v_isShared_142_; uint8_t v_isSharedCheck_169_; 
v_p1_114_ = lean_ctor_get(v_c_112_, 0);
lean_inc_ref(v_p1_114_);
v_ctrl1_115_ = lean_ctor_get(v_c_112_, 1);
lean_inc_ref(v_ctrl1_115_);
v_ctrl2_116_ = lean_ctor_get(v_c_112_, 2);
lean_inc_ref(v_ctrl2_116_);
v_p2_117_ = lean_ctor_get(v_c_112_, 3);
lean_inc_ref(v_p2_117_);
lean_dec_ref(v_c_112_);
v_x_118_ = lean_ctor_get(v_p1_114_, 0);
lean_inc_ref(v_x_118_);
v_y_119_ = lean_ctor_get(v_p1_114_, 1);
lean_inc_ref(v_y_119_);
v_z_120_ = lean_ctor_get(v_p1_114_, 2);
lean_inc_ref(v_z_120_);
lean_dec_ref(v_p1_114_);
v___x_121_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
lean_inc_ref_n(v_t_113_, 4);
v_u_122_ = l_Rat_sub(v___x_121_, v_t_113_);
lean_inc_ref_n(v_u_122_, 3);
v___x_123_ = l_Rat_mul(v_u_122_, v_u_122_);
v___x_124_ = l_Rat_mul(v___x_123_, v_u_122_);
lean_dec_ref(v___x_123_);
v_x_125_ = lean_ctor_get(v_ctrl1_115_, 0);
lean_inc_ref(v_x_125_);
v_y_126_ = lean_ctor_get(v_ctrl1_115_, 1);
lean_inc_ref(v_y_126_);
v_z_127_ = lean_ctor_get(v_ctrl1_115_, 2);
lean_inc_ref(v_z_127_);
lean_dec_ref(v_ctrl1_115_);
v___x_128_ = lean_obj_once(&lp_ir_x2dproof_IRProof_cubicPosition___closed__0, &lp_ir_x2dproof_IRProof_cubicPosition___closed__0_once, _init_lp_ir_x2dproof_IRProof_cubicPosition___closed__0);
v___x_129_ = l_Rat_mul(v___x_128_, v_u_122_);
v___x_130_ = l_Rat_mul(v___x_129_, v_u_122_);
v___x_131_ = l_Rat_mul(v___x_130_, v_t_113_);
lean_dec_ref(v___x_130_);
v_x_132_ = lean_ctor_get(v_ctrl2_116_, 0);
lean_inc_ref(v_x_132_);
v_y_133_ = lean_ctor_get(v_ctrl2_116_, 1);
lean_inc_ref(v_y_133_);
v_z_134_ = lean_ctor_get(v_ctrl2_116_, 2);
lean_inc_ref(v_z_134_);
lean_dec_ref(v_ctrl2_116_);
v___x_135_ = l_Rat_mul(v___x_129_, v_t_113_);
lean_dec_ref(v___x_129_);
v___x_136_ = l_Rat_mul(v___x_135_, v_t_113_);
lean_dec_ref(v___x_135_);
v_x_137_ = lean_ctor_get(v_p2_117_, 0);
v_y_138_ = lean_ctor_get(v_p2_117_, 1);
v_z_139_ = lean_ctor_get(v_p2_117_, 2);
v_isSharedCheck_169_ = !lean_is_exclusive(v_p2_117_);
if (v_isSharedCheck_169_ == 0)
{
v___x_141_ = v_p2_117_;
v_isShared_142_ = v_isSharedCheck_169_;
goto v_resetjp_140_;
}
else
{
lean_inc(v_z_139_);
lean_inc(v_y_138_);
lean_inc(v_x_137_);
lean_dec(v_p2_117_);
v___x_141_ = lean_box(0);
v_isShared_142_ = v_isSharedCheck_169_;
goto v_resetjp_140_;
}
v_resetjp_140_:
{
lean_object* v___x_143_; lean_object* v___x_144_; lean_object* v___x_145_; lean_object* v___x_146_; lean_object* v___x_147_; lean_object* v___x_148_; lean_object* v___x_149_; lean_object* v___x_150_; lean_object* v___x_151_; lean_object* v___x_152_; lean_object* v___x_153_; lean_object* v___x_154_; lean_object* v___x_155_; lean_object* v___x_156_; lean_object* v___x_157_; lean_object* v___x_158_; lean_object* v___x_159_; lean_object* v___x_160_; lean_object* v___x_161_; lean_object* v___x_162_; lean_object* v___x_163_; lean_object* v___x_164_; lean_object* v___x_165_; lean_object* v___x_167_; 
lean_inc_ref(v_t_113_);
v___x_143_ = l_Rat_mul(v_t_113_, v_t_113_);
v___x_144_ = l_Rat_mul(v___x_124_, v_x_118_);
v___x_145_ = l_Rat_mul(v___x_131_, v_x_125_);
v___x_146_ = l_Rat_add(v___x_144_, v___x_145_);
v___x_147_ = l_Rat_mul(v___x_136_, v_x_132_);
v___x_148_ = l_Rat_add(v___x_146_, v___x_147_);
v___x_149_ = l_Rat_mul(v___x_143_, v_t_113_);
lean_dec_ref(v___x_143_);
v___x_150_ = l_Rat_mul(v___x_149_, v_x_137_);
v___x_151_ = l_Rat_add(v___x_148_, v___x_150_);
v___x_152_ = l_Rat_mul(v___x_124_, v_y_119_);
v___x_153_ = l_Rat_mul(v___x_131_, v_y_126_);
v___x_154_ = l_Rat_add(v___x_152_, v___x_153_);
v___x_155_ = l_Rat_mul(v___x_136_, v_y_133_);
v___x_156_ = l_Rat_add(v___x_154_, v___x_155_);
v___x_157_ = l_Rat_mul(v___x_149_, v_y_138_);
v___x_158_ = l_Rat_add(v___x_156_, v___x_157_);
v___x_159_ = l_Rat_mul(v___x_124_, v_z_120_);
lean_dec_ref(v___x_124_);
v___x_160_ = l_Rat_mul(v___x_131_, v_z_127_);
lean_dec_ref(v___x_131_);
v___x_161_ = l_Rat_add(v___x_159_, v___x_160_);
v___x_162_ = l_Rat_mul(v___x_136_, v_z_134_);
lean_dec_ref(v___x_136_);
v___x_163_ = l_Rat_add(v___x_161_, v___x_162_);
v___x_164_ = l_Rat_mul(v___x_149_, v_z_139_);
lean_dec_ref(v___x_149_);
v___x_165_ = l_Rat_add(v___x_163_, v___x_164_);
if (v_isShared_142_ == 0)
{
lean_ctor_set(v___x_141_, 2, v___x_165_);
lean_ctor_set(v___x_141_, 1, v___x_158_);
lean_ctor_set(v___x_141_, 0, v___x_151_);
v___x_167_ = v___x_141_;
goto v_reusejp_166_;
}
else
{
lean_object* v_reuseFailAlloc_168_; 
v_reuseFailAlloc_168_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_168_, 0, v___x_151_);
lean_ctor_set(v_reuseFailAlloc_168_, 1, v___x_158_);
lean_ctor_set(v_reuseFailAlloc_168_, 2, v___x_165_);
v___x_167_ = v_reuseFailAlloc_168_;
goto v_reusejp_166_;
}
v_reusejp_166_:
{
return v___x_167_;
}
}
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_cubicDerivative___closed__0(void){
_start:
{
lean_object* v___x_170_; lean_object* v___x_171_; 
v___x_170_ = lean_unsigned_to_nat(6u);
v___x_171_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_170_);
return v___x_171_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_cubicDerivative(lean_object* v_c_172_, lean_object* v_t_173_){
_start:
{
lean_object* v_ctrl1_174_; lean_object* v_p1_175_; lean_object* v_ctrl2_176_; lean_object* v_p2_177_; lean_object* v_x_178_; lean_object* v_y_179_; lean_object* v_z_180_; lean_object* v_x_181_; lean_object* v_y_182_; lean_object* v_z_183_; lean_object* v___x_184_; lean_object* v_u_185_; lean_object* v___x_186_; lean_object* v___x_187_; lean_object* v_x_188_; lean_object* v_y_189_; lean_object* v_z_190_; lean_object* v___x_191_; lean_object* v___x_192_; lean_object* v___x_193_; lean_object* v___x_194_; lean_object* v_x_195_; lean_object* v_y_196_; lean_object* v_z_197_; lean_object* v___x_199_; uint8_t v_isShared_200_; uint8_t v_isSharedCheck_230_; 
v_ctrl1_174_ = lean_ctor_get(v_c_172_, 1);
lean_inc_ref(v_ctrl1_174_);
v_p1_175_ = lean_ctor_get(v_c_172_, 0);
lean_inc_ref(v_p1_175_);
v_ctrl2_176_ = lean_ctor_get(v_c_172_, 2);
lean_inc_ref(v_ctrl2_176_);
v_p2_177_ = lean_ctor_get(v_c_172_, 3);
lean_inc_ref(v_p2_177_);
lean_dec_ref(v_c_172_);
v_x_178_ = lean_ctor_get(v_ctrl1_174_, 0);
lean_inc_ref(v_x_178_);
v_y_179_ = lean_ctor_get(v_ctrl1_174_, 1);
lean_inc_ref(v_y_179_);
v_z_180_ = lean_ctor_get(v_ctrl1_174_, 2);
lean_inc_ref(v_z_180_);
lean_dec_ref(v_ctrl1_174_);
v_x_181_ = lean_ctor_get(v_p1_175_, 0);
lean_inc_ref(v_x_181_);
v_y_182_ = lean_ctor_get(v_p1_175_, 1);
lean_inc_ref(v_y_182_);
v_z_183_ = lean_ctor_get(v_p1_175_, 2);
lean_inc_ref(v_z_183_);
lean_dec_ref(v_p1_175_);
v___x_184_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
lean_inc_ref_n(v_t_173_, 2);
v_u_185_ = l_Rat_sub(v___x_184_, v_t_173_);
v___x_186_ = lean_obj_once(&lp_ir_x2dproof_IRProof_cubicPosition___closed__0, &lp_ir_x2dproof_IRProof_cubicPosition___closed__0_once, _init_lp_ir_x2dproof_IRProof_cubicPosition___closed__0);
lean_inc_ref_n(v_u_185_, 2);
v___x_187_ = l_Rat_mul(v___x_186_, v_u_185_);
v_x_188_ = lean_ctor_get(v_ctrl2_176_, 0);
lean_inc_ref(v_x_188_);
v_y_189_ = lean_ctor_get(v_ctrl2_176_, 1);
lean_inc_ref(v_y_189_);
v_z_190_ = lean_ctor_get(v_ctrl2_176_, 2);
lean_inc_ref(v_z_190_);
lean_dec_ref(v_ctrl2_176_);
v___x_191_ = l_Rat_mul(v___x_187_, v_u_185_);
lean_dec_ref(v___x_187_);
v___x_192_ = lean_obj_once(&lp_ir_x2dproof_IRProof_cubicDerivative___closed__0, &lp_ir_x2dproof_IRProof_cubicDerivative___closed__0_once, _init_lp_ir_x2dproof_IRProof_cubicDerivative___closed__0);
v___x_193_ = l_Rat_mul(v___x_192_, v_u_185_);
v___x_194_ = l_Rat_mul(v___x_193_, v_t_173_);
lean_dec_ref(v___x_193_);
v_x_195_ = lean_ctor_get(v_p2_177_, 0);
v_y_196_ = lean_ctor_get(v_p2_177_, 1);
v_z_197_ = lean_ctor_get(v_p2_177_, 2);
v_isSharedCheck_230_ = !lean_is_exclusive(v_p2_177_);
if (v_isSharedCheck_230_ == 0)
{
v___x_199_ = v_p2_177_;
v_isShared_200_ = v_isSharedCheck_230_;
goto v_resetjp_198_;
}
else
{
lean_inc(v_z_197_);
lean_inc(v_y_196_);
lean_inc(v_x_195_);
lean_dec(v_p2_177_);
v___x_199_ = lean_box(0);
v_isShared_200_ = v_isSharedCheck_230_;
goto v_resetjp_198_;
}
v_resetjp_198_:
{
lean_object* v___x_201_; lean_object* v___x_202_; lean_object* v___x_203_; lean_object* v___x_204_; lean_object* v___x_205_; lean_object* v___x_206_; lean_object* v___x_207_; lean_object* v___x_208_; lean_object* v___x_209_; lean_object* v___x_210_; lean_object* v___x_211_; lean_object* v___x_212_; lean_object* v___x_213_; lean_object* v___x_214_; lean_object* v___x_215_; lean_object* v___x_216_; lean_object* v___x_217_; lean_object* v___x_218_; lean_object* v___x_219_; lean_object* v___x_220_; lean_object* v___x_221_; lean_object* v___x_222_; lean_object* v___x_223_; lean_object* v___x_224_; lean_object* v___x_225_; lean_object* v___x_226_; lean_object* v___x_228_; 
lean_inc_ref(v_x_178_);
v___x_201_ = l_Rat_sub(v_x_178_, v_x_181_);
lean_inc_ref(v_t_173_);
v___x_202_ = l_Rat_mul(v___x_186_, v_t_173_);
v___x_203_ = l_Rat_mul(v___x_191_, v___x_201_);
lean_inc_ref(v_x_188_);
v___x_204_ = l_Rat_sub(v_x_188_, v_x_178_);
v___x_205_ = l_Rat_mul(v___x_194_, v___x_204_);
v___x_206_ = l_Rat_add(v___x_203_, v___x_205_);
v___x_207_ = l_Rat_mul(v___x_202_, v_t_173_);
lean_dec_ref(v___x_202_);
v___x_208_ = l_Rat_sub(v_x_195_, v_x_188_);
v___x_209_ = l_Rat_mul(v___x_207_, v___x_208_);
v___x_210_ = l_Rat_add(v___x_206_, v___x_209_);
lean_inc_ref(v_y_179_);
v___x_211_ = l_Rat_sub(v_y_179_, v_y_182_);
v___x_212_ = l_Rat_mul(v___x_191_, v___x_211_);
lean_inc_ref(v_y_189_);
v___x_213_ = l_Rat_sub(v_y_189_, v_y_179_);
v___x_214_ = l_Rat_mul(v___x_194_, v___x_213_);
v___x_215_ = l_Rat_add(v___x_212_, v___x_214_);
v___x_216_ = l_Rat_sub(v_y_196_, v_y_189_);
v___x_217_ = l_Rat_mul(v___x_207_, v___x_216_);
v___x_218_ = l_Rat_add(v___x_215_, v___x_217_);
lean_inc_ref(v_z_180_);
v___x_219_ = l_Rat_sub(v_z_180_, v_z_183_);
v___x_220_ = l_Rat_mul(v___x_191_, v___x_219_);
lean_dec_ref(v___x_191_);
lean_inc_ref(v_z_190_);
v___x_221_ = l_Rat_sub(v_z_190_, v_z_180_);
v___x_222_ = l_Rat_mul(v___x_194_, v___x_221_);
lean_dec_ref(v___x_194_);
v___x_223_ = l_Rat_add(v___x_220_, v___x_222_);
v___x_224_ = l_Rat_sub(v_z_197_, v_z_190_);
v___x_225_ = l_Rat_mul(v___x_207_, v___x_224_);
lean_dec_ref(v___x_207_);
v___x_226_ = l_Rat_add(v___x_223_, v___x_225_);
if (v_isShared_200_ == 0)
{
lean_ctor_set(v___x_199_, 2, v___x_226_);
lean_ctor_set(v___x_199_, 1, v___x_218_);
lean_ctor_set(v___x_199_, 0, v___x_210_);
v___x_228_ = v___x_199_;
goto v_reusejp_227_;
}
else
{
lean_object* v_reuseFailAlloc_229_; 
v_reuseFailAlloc_229_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_229_, 0, v___x_210_);
lean_ctor_set(v_reuseFailAlloc_229_, 1, v___x_218_);
lean_ctor_set(v_reuseFailAlloc_229_, 2, v___x_226_);
v___x_228_ = v_reuseFailAlloc_229_;
goto v_reusejp_227_;
}
v_reusejp_227_:
{
return v___x_228_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_cubicReverse(lean_object* v_c_231_){
_start:
{
lean_object* v_p1_232_; lean_object* v_ctrl1_233_; lean_object* v_ctrl2_234_; lean_object* v_p2_235_; lean_object* v___x_237_; uint8_t v_isShared_238_; uint8_t v_isSharedCheck_242_; 
v_p1_232_ = lean_ctor_get(v_c_231_, 0);
v_ctrl1_233_ = lean_ctor_get(v_c_231_, 1);
v_ctrl2_234_ = lean_ctor_get(v_c_231_, 2);
v_p2_235_ = lean_ctor_get(v_c_231_, 3);
v_isSharedCheck_242_ = !lean_is_exclusive(v_c_231_);
if (v_isSharedCheck_242_ == 0)
{
v___x_237_ = v_c_231_;
v_isShared_238_ = v_isSharedCheck_242_;
goto v_resetjp_236_;
}
else
{
lean_inc(v_p2_235_);
lean_inc(v_ctrl2_234_);
lean_inc(v_ctrl1_233_);
lean_inc(v_p1_232_);
lean_dec(v_c_231_);
v___x_237_ = lean_box(0);
v_isShared_238_ = v_isSharedCheck_242_;
goto v_resetjp_236_;
}
v_resetjp_236_:
{
lean_object* v___x_240_; 
if (v_isShared_238_ == 0)
{
lean_ctor_set(v___x_237_, 3, v_p1_232_);
lean_ctor_set(v___x_237_, 2, v_ctrl1_233_);
lean_ctor_set(v___x_237_, 1, v_ctrl2_234_);
lean_ctor_set(v___x_237_, 0, v_p2_235_);
v___x_240_ = v___x_237_;
goto v_reusejp_239_;
}
else
{
lean_object* v_reuseFailAlloc_241_; 
v_reuseFailAlloc_241_ = lean_alloc_ctor(0, 4, 0);
lean_ctor_set(v_reuseFailAlloc_241_, 0, v_p2_235_);
lean_ctor_set(v_reuseFailAlloc_241_, 1, v_ctrl2_234_);
lean_ctor_set(v_reuseFailAlloc_241_, 2, v_ctrl1_233_);
lean_ctor_set(v_reuseFailAlloc_241_, 3, v_p1_232_);
v___x_240_ = v_reuseFailAlloc_241_;
goto v_reusejp_239_;
}
v_reusejp_239_:
{
return v___x_240_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_degenerateStraight(lean_object* v_a_243_, lean_object* v_b_244_){
_start:
{
lean_object* v___x_245_; lean_object* v___x_246_; lean_object* v___x_247_; 
lean_inc_ref_n(v_a_243_, 2);
lean_inc_ref(v_b_244_);
v___x_245_ = lp_ir_x2dproof_IRProof_Vec3_sub(v_b_244_, v_a_243_);
v___x_246_ = lp_ir_x2dproof_IRProof_Vec3_add(v_a_243_, v___x_245_);
lean_inc_ref(v___x_246_);
v___x_247_ = lean_alloc_ctor(0, 4, 0);
lean_ctor_set(v___x_247_, 0, v_a_243_);
lean_ctor_set(v___x_247_, 1, v___x_246_);
lean_ctor_set(v___x_247_, 2, v___x_246_);
lean_ctor_set(v___x_247_, 3, v_b_244_);
return v___x_247_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineFromCurve(lean_object* v_id_248_, lean_object* v_c_249_, lean_object* v_marks_250_, lean_object* v_length_251_, lean_object* v_points_252_, lean_object* v_fit_253_, lean_object* v_traces_254_, lean_object* v_builder_255_){
_start:
{
lean_object* v___x_256_; lean_object* v___x_257_; 
lean_inc_ref(v_c_249_);
v___x_256_ = lp_ir_x2dproof_IRProof_cubicReverse(v_c_249_);
v___x_257_ = lean_alloc_ctor(0, 9, 0);
lean_ctor_set(v___x_257_, 0, v_id_248_);
lean_ctor_set(v___x_257_, 1, v_c_249_);
lean_ctor_set(v___x_257_, 2, v___x_256_);
lean_ctor_set(v___x_257_, 3, v_marks_250_);
lean_ctor_set(v___x_257_, 4, v_length_251_);
lean_ctor_set(v___x_257_, 5, v_points_252_);
lean_ctor_set(v___x_257_, 6, v_fit_253_);
lean_ctor_set(v___x_257_, 7, v_traces_254_);
lean_ctor_set(v___x_257_, 8, v_builder_255_);
return v___x_257_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineOrientation(lean_object* v_s_258_, uint8_t v_forward_259_){
_start:
{
if (v_forward_259_ == 0)
{
lean_object* v_reverseCurve_260_; 
v_reverseCurve_260_ = lean_ctor_get(v_s_258_, 2);
lean_inc_ref(v_reverseCurve_260_);
return v_reverseCurve_260_;
}
else
{
lean_object* v_curve_261_; 
v_curve_261_ = lean_ctor_get(v_s_258_, 1);
lean_inc_ref(v_curve_261_);
return v_curve_261_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineOrientation___boxed(lean_object* v_s_262_, lean_object* v_forward_263_){
_start:
{
uint8_t v_forward_boxed_264_; lean_object* v_res_265_; 
v_forward_boxed_264_ = lean_unbox(v_forward_263_);
v_res_265_ = lp_ir_x2dproof_IRProof_splineOrientation(v_s_262_, v_forward_boxed_264_);
lean_dec_ref(v_s_262_);
return v_res_265_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_tangentAt(lean_object* v_s_266_, uint8_t v_forward_267_, lean_object* v_t_268_){
_start:
{
lean_object* v___x_269_; lean_object* v___x_270_; 
v___x_269_ = lp_ir_x2dproof_IRProof_splineOrientation(v_s_266_, v_forward_267_);
v___x_270_ = lp_ir_x2dproof_IRProof_cubicDerivative(v___x_269_, v_t_268_);
return v___x_270_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_tangentAt___boxed(lean_object* v_s_271_, lean_object* v_forward_272_, lean_object* v_t_273_){
_start:
{
uint8_t v_forward_boxed_274_; lean_object* v_res_275_; 
v_forward_boxed_274_ = lean_unbox(v_forward_272_);
v_res_275_ = lp_ir_x2dproof_IRProof_tangentAt(v_s_271_, v_forward_boxed_274_, v_t_273_);
lean_dec_ref(v_s_271_);
return v_res_275_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_gradeAt(lean_object* v_s_276_, uint8_t v_forward_277_, lean_object* v_t_278_){
_start:
{
lean_object* v___x_279_; lean_object* v_y_280_; 
v___x_279_ = lp_ir_x2dproof_IRProof_tangentAt(v_s_276_, v_forward_277_, v_t_278_);
v_y_280_ = lean_ctor_get(v___x_279_, 1);
lean_inc_ref(v_y_280_);
lean_dec_ref(v___x_279_);
return v_y_280_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_gradeAt___boxed(lean_object* v_s_281_, lean_object* v_forward_282_, lean_object* v_t_283_){
_start:
{
uint8_t v_forward_boxed_284_; lean_object* v_res_285_; 
v_forward_boxed_284_ = lean_unbox(v_forward_282_);
v_res_285_ = lp_ir_x2dproof_IRProof_gradeAt(v_s_281_, v_forward_boxed_284_, v_t_283_);
lean_dec_ref(v_s_281_);
return v_res_285_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAtList(lean_object* v_x_286_, lean_object* v_x_287_){
_start:
{
if (lean_obj_tag(v_x_286_) == 0)
{
lean_object* v___x_288_; 
lean_dec(v_x_287_);
v___x_288_ = lean_box(0);
return v___x_288_;
}
else
{
lean_object* v_head_289_; lean_object* v_tail_290_; lean_object* v_zero_291_; uint8_t v_isZero_292_; 
v_head_289_ = lean_ctor_get(v_x_286_, 0);
v_tail_290_ = lean_ctor_get(v_x_286_, 1);
v_zero_291_ = lean_unsigned_to_nat(0u);
v_isZero_292_ = lean_nat_dec_eq(v_x_287_, v_zero_291_);
if (v_isZero_292_ == 1)
{
lean_object* v_curvature_293_; lean_object* v___x_294_; 
lean_dec(v_x_287_);
v_curvature_293_ = lean_ctor_get(v_head_289_, 4);
lean_inc_ref(v_curvature_293_);
v___x_294_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_294_, 0, v_curvature_293_);
return v___x_294_;
}
else
{
lean_object* v_one_295_; lean_object* v_n_296_; 
v_one_295_ = lean_unsigned_to_nat(1u);
v_n_296_ = lean_nat_sub(v_x_287_, v_one_295_);
lean_dec(v_x_287_);
v_x_286_ = v_tail_290_;
v_x_287_ = v_n_296_;
goto _start;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAtList___boxed(lean_object* v_x_298_, lean_object* v_x_299_){
_start:
{
lean_object* v_res_300_; 
v_res_300_ = lp_ir_x2dproof_IRProof_curvatureAtList(v_x_298_, v_x_299_);
lean_dec(v_x_298_);
return v_res_300_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAt(lean_object* v_s_301_, lean_object* v_i_302_){
_start:
{
lean_object* v_points_303_; lean_object* v___x_304_; 
v_points_303_ = lean_ctor_get(v_s_301_, 5);
v___x_304_ = lp_ir_x2dproof_IRProof_curvatureAtList(v_points_303_, v_i_302_);
return v___x_304_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_curvatureAt___boxed(lean_object* v_s_305_, lean_object* v_i_306_){
_start:
{
lean_object* v_res_307_; 
v_res_307_ = lp_ir_x2dproof_IRProof_curvatureAt(v_s_305_, v_i_306_);
lean_dec_ref(v_s_305_);
return v_res_307_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arcDistance(lean_object* v_a_308_, lean_object* v_b_309_){
_start:
{
lean_object* v_s_310_; lean_object* v_s_311_; lean_object* v___x_312_; 
v_s_310_ = lean_ctor_get(v_b_309_, 1);
lean_inc_ref(v_s_310_);
lean_dec_ref(v_b_309_);
v_s_311_ = lean_ctor_get(v_a_308_, 1);
lean_inc_ref(v_s_311_);
lean_dec_ref(v_a_308_);
v___x_312_ = l_Rat_sub(v_s_310_, v_s_311_);
return v___x_312_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_centreEstimate(lean_object* v_cfg_313_, lean_object* v_sample_314_){
_start:
{
lean_object* v_rawPosition_315_; lean_object* v_referenceOffset_316_; lean_object* v___x_317_; 
v_rawPosition_315_ = lean_ctor_get(v_sample_314_, 1);
lean_inc_ref(v_rawPosition_315_);
lean_dec_ref(v_sample_314_);
v_referenceOffset_316_ = lean_ctor_get(v_cfg_313_, 0);
lean_inc_ref(v_referenceOffset_316_);
lean_dec_ref(v_cfg_313_);
v___x_317_ = lp_ir_x2dproof_IRProof_Vec3_add(v_rawPosition_315_, v_referenceOffset_316_);
return v___x_317_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_centrelineResidualBound(lean_object* v_cfg_318_){
_start:
{
lean_object* v_samplingSpacing_319_; lean_object* v_curvatureBound_320_; lean_object* v_floatingError_321_; lean_object* v_missingObservationBound_322_; lean_object* v___x_323_; lean_object* v___x_324_; lean_object* v___x_325_; 
v_samplingSpacing_319_ = lean_ctor_get(v_cfg_318_, 1);
lean_inc_ref(v_samplingSpacing_319_);
v_curvatureBound_320_ = lean_ctor_get(v_cfg_318_, 2);
lean_inc_ref(v_curvatureBound_320_);
v_floatingError_321_ = lean_ctor_get(v_cfg_318_, 3);
lean_inc_ref(v_floatingError_321_);
v_missingObservationBound_322_ = lean_ctor_get(v_cfg_318_, 4);
lean_inc_ref(v_missingObservationBound_322_);
lean_dec_ref(v_cfg_318_);
v___x_323_ = l_Rat_mul(v_samplingSpacing_319_, v_curvatureBound_320_);
lean_dec_ref(v_samplingSpacing_319_);
v___x_324_ = l_Rat_add(v___x_323_, v_floatingError_321_);
v___x_325_ = l_Rat_add(v___x_324_, v_missingObservationBound_322_);
return v___x_325_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx(uint8_t v_x_326_){
_start:
{
switch(v_x_326_)
{
case 0:
{
lean_object* v___x_327_; 
v___x_327_ = lean_unsigned_to_nat(0u);
return v___x_327_;
}
case 1:
{
lean_object* v___x_328_; 
v___x_328_ = lean_unsigned_to_nat(1u);
return v___x_328_;
}
case 2:
{
lean_object* v___x_329_; 
v___x_329_ = lean_unsigned_to_nat(2u);
return v___x_329_;
}
case 3:
{
lean_object* v___x_330_; 
v___x_330_ = lean_unsigned_to_nat(3u);
return v___x_330_;
}
case 4:
{
lean_object* v___x_331_; 
v___x_331_ = lean_unsigned_to_nat(4u);
return v___x_331_;
}
default: 
{
lean_object* v___x_332_; 
v___x_332_ = lean_unsigned_to_nat(5u);
return v___x_332_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx___boxed(lean_object* v_x_333_){
_start:
{
uint8_t v_x_boxed_334_; lean_object* v_res_335_; 
v_x_boxed_334_ = lean_unbox(v_x_333_);
v_res_335_ = lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx(v_x_boxed_334_);
return v_res_335_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_toCtorIdx(uint8_t v_x_336_){
_start:
{
lean_object* v___x_337_; 
v___x_337_ = lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx(v_x_336_);
return v___x_337_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_toCtorIdx___boxed(lean_object* v_x_338_){
_start:
{
uint8_t v_x_4__boxed_339_; lean_object* v_res_340_; 
v_x_4__boxed_339_ = lean_unbox(v_x_338_);
v_res_340_ = lp_ir_x2dproof_IRProof_TopologyClass_toCtorIdx(v_x_4__boxed_339_);
return v_res_340_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim___redArg(lean_object* v_k_341_){
_start:
{
lean_inc(v_k_341_);
return v_k_341_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim___redArg___boxed(lean_object* v_k_342_){
_start:
{
lean_object* v_res_343_; 
v_res_343_ = lp_ir_x2dproof_IRProof_TopologyClass_ctorElim___redArg(v_k_342_);
lean_dec(v_k_342_);
return v_res_343_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim(lean_object* v_motive_344_, lean_object* v_ctorIdx_345_, uint8_t v_t_346_, lean_object* v_h_347_, lean_object* v_k_348_){
_start:
{
lean_inc(v_k_348_);
return v_k_348_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ctorElim___boxed(lean_object* v_motive_349_, lean_object* v_ctorIdx_350_, lean_object* v_t_351_, lean_object* v_h_352_, lean_object* v_k_353_){
_start:
{
uint8_t v_t_boxed_354_; lean_object* v_res_355_; 
v_t_boxed_354_ = lean_unbox(v_t_351_);
v_res_355_ = lp_ir_x2dproof_IRProof_TopologyClass_ctorElim(v_motive_349_, v_ctorIdx_350_, v_t_boxed_354_, v_h_352_, v_k_353_);
lean_dec(v_k_353_);
lean_dec(v_ctorIdx_350_);
return v_res_355_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim___redArg(lean_object* v_continuation_356_){
_start:
{
lean_inc(v_continuation_356_);
return v_continuation_356_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim___redArg___boxed(lean_object* v_continuation_357_){
_start:
{
lean_object* v_res_358_; 
v_res_358_ = lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim___redArg(v_continuation_357_);
lean_dec(v_continuation_357_);
return v_res_358_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim(lean_object* v_motive_359_, uint8_t v_t_360_, lean_object* v_h_361_, lean_object* v_continuation_362_){
_start:
{
lean_inc(v_continuation_362_);
return v_continuation_362_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim___boxed(lean_object* v_motive_363_, lean_object* v_t_364_, lean_object* v_h_365_, lean_object* v_continuation_366_){
_start:
{
uint8_t v_t_boxed_367_; lean_object* v_res_368_; 
v_t_boxed_367_ = lean_unbox(v_t_364_);
v_res_368_ = lp_ir_x2dproof_IRProof_TopologyClass_continuation_elim(v_motive_363_, v_t_boxed_367_, v_h_365_, v_continuation_366_);
lean_dec(v_continuation_366_);
return v_res_368_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim___redArg(lean_object* v_extension_369_){
_start:
{
lean_inc(v_extension_369_);
return v_extension_369_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim___redArg___boxed(lean_object* v_extension_370_){
_start:
{
lean_object* v_res_371_; 
v_res_371_ = lp_ir_x2dproof_IRProof_TopologyClass_extension_elim___redArg(v_extension_370_);
lean_dec(v_extension_370_);
return v_res_371_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim(lean_object* v_motive_372_, uint8_t v_t_373_, lean_object* v_h_374_, lean_object* v_extension_375_){
_start:
{
lean_inc(v_extension_375_);
return v_extension_375_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_extension_elim___boxed(lean_object* v_motive_376_, lean_object* v_t_377_, lean_object* v_h_378_, lean_object* v_extension_379_){
_start:
{
uint8_t v_t_boxed_380_; lean_object* v_res_381_; 
v_t_boxed_380_ = lean_unbox(v_t_377_);
v_res_381_ = lp_ir_x2dproof_IRProof_TopologyClass_extension_elim(v_motive_376_, v_t_boxed_380_, v_h_378_, v_extension_379_);
lean_dec(v_extension_379_);
return v_res_381_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim___redArg(lean_object* v_sharedConnection_382_){
_start:
{
lean_inc(v_sharedConnection_382_);
return v_sharedConnection_382_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim___redArg___boxed(lean_object* v_sharedConnection_383_){
_start:
{
lean_object* v_res_384_; 
v_res_384_ = lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim___redArg(v_sharedConnection_383_);
lean_dec(v_sharedConnection_383_);
return v_res_384_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim(lean_object* v_motive_385_, uint8_t v_t_386_, lean_object* v_h_387_, lean_object* v_sharedConnection_388_){
_start:
{
lean_inc(v_sharedConnection_388_);
return v_sharedConnection_388_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim___boxed(lean_object* v_motive_389_, lean_object* v_t_390_, lean_object* v_h_391_, lean_object* v_sharedConnection_392_){
_start:
{
uint8_t v_t_boxed_393_; lean_object* v_res_394_; 
v_t_boxed_393_ = lean_unbox(v_t_390_);
v_res_394_ = lp_ir_x2dproof_IRProof_TopologyClass_sharedConnection_elim(v_motive_389_, v_t_boxed_393_, v_h_391_, v_sharedConnection_392_);
lean_dec(v_sharedConnection_392_);
return v_res_394_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim___redArg(lean_object* v_isolatedCrossing_395_){
_start:
{
lean_inc(v_isolatedCrossing_395_);
return v_isolatedCrossing_395_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim___redArg___boxed(lean_object* v_isolatedCrossing_396_){
_start:
{
lean_object* v_res_397_; 
v_res_397_ = lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim___redArg(v_isolatedCrossing_396_);
lean_dec(v_isolatedCrossing_396_);
return v_res_397_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim(lean_object* v_motive_398_, uint8_t v_t_399_, lean_object* v_h_400_, lean_object* v_isolatedCrossing_401_){
_start:
{
lean_inc(v_isolatedCrossing_401_);
return v_isolatedCrossing_401_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim___boxed(lean_object* v_motive_402_, lean_object* v_t_403_, lean_object* v_h_404_, lean_object* v_isolatedCrossing_405_){
_start:
{
uint8_t v_t_boxed_406_; lean_object* v_res_407_; 
v_t_boxed_406_ = lean_unbox(v_t_403_);
v_res_407_ = lp_ir_x2dproof_IRProof_TopologyClass_isolatedCrossing_elim(v_motive_402_, v_t_boxed_406_, v_h_404_, v_isolatedCrossing_405_);
lean_dec(v_isolatedCrossing_405_);
return v_res_407_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim___redArg(lean_object* v_overpass_408_){
_start:
{
lean_inc(v_overpass_408_);
return v_overpass_408_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim___redArg___boxed(lean_object* v_overpass_409_){
_start:
{
lean_object* v_res_410_; 
v_res_410_ = lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim___redArg(v_overpass_409_);
lean_dec(v_overpass_409_);
return v_res_410_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim(lean_object* v_motive_411_, uint8_t v_t_412_, lean_object* v_h_413_, lean_object* v_overpass_414_){
_start:
{
lean_inc(v_overpass_414_);
return v_overpass_414_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim___boxed(lean_object* v_motive_415_, lean_object* v_t_416_, lean_object* v_h_417_, lean_object* v_overpass_418_){
_start:
{
uint8_t v_t_boxed_419_; lean_object* v_res_420_; 
v_t_boxed_419_ = lean_unbox(v_t_416_);
v_res_420_ = lp_ir_x2dproof_IRProof_TopologyClass_overpass_elim(v_motive_415_, v_t_boxed_419_, v_h_417_, v_overpass_418_);
lean_dec(v_overpass_418_);
return v_res_420_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim___redArg(lean_object* v_unresolved_421_){
_start:
{
lean_inc(v_unresolved_421_);
return v_unresolved_421_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim___redArg___boxed(lean_object* v_unresolved_422_){
_start:
{
lean_object* v_res_423_; 
v_res_423_ = lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim___redArg(v_unresolved_422_);
lean_dec(v_unresolved_422_);
return v_res_423_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim(lean_object* v_motive_424_, uint8_t v_t_425_, lean_object* v_h_426_, lean_object* v_unresolved_427_){
_start:
{
lean_inc(v_unresolved_427_);
return v_unresolved_427_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim___boxed(lean_object* v_motive_428_, lean_object* v_t_429_, lean_object* v_h_430_, lean_object* v_unresolved_431_){
_start:
{
uint8_t v_t_boxed_432_; lean_object* v_res_433_; 
v_t_boxed_432_ = lean_unbox(v_t_429_);
v_res_433_ = lp_ir_x2dproof_IRProof_TopologyClass_unresolved_elim(v_motive_428_, v_t_boxed_432_, v_h_430_, v_unresolved_431_);
lean_dec(v_unresolved_431_);
return v_res_433_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_TopologyClass_ofNat(lean_object* v_n_434_){
_start:
{
lean_object* v___x_435_; uint8_t v___x_436_; 
v___x_435_ = lean_unsigned_to_nat(2u);
v___x_436_ = lean_nat_dec_le(v_n_434_, v___x_435_);
if (v___x_436_ == 0)
{
lean_object* v___x_437_; uint8_t v___x_438_; 
v___x_437_ = lean_unsigned_to_nat(3u);
v___x_438_ = lean_nat_dec_le(v_n_434_, v___x_437_);
if (v___x_438_ == 0)
{
lean_object* v___x_439_; uint8_t v___x_440_; 
v___x_439_ = lean_unsigned_to_nat(4u);
v___x_440_ = lean_nat_dec_le(v_n_434_, v___x_439_);
if (v___x_440_ == 0)
{
uint8_t v___x_441_; 
v___x_441_ = 5;
return v___x_441_;
}
else
{
uint8_t v___x_442_; 
v___x_442_ = 4;
return v___x_442_;
}
}
else
{
uint8_t v___x_443_; 
v___x_443_ = 3;
return v___x_443_;
}
}
else
{
lean_object* v___x_444_; uint8_t v___x_445_; 
v___x_444_ = lean_unsigned_to_nat(0u);
v___x_445_ = lean_nat_dec_le(v_n_434_, v___x_444_);
if (v___x_445_ == 0)
{
lean_object* v___x_446_; uint8_t v___x_447_; 
v___x_446_ = lean_unsigned_to_nat(1u);
v___x_447_ = lean_nat_dec_le(v_n_434_, v___x_446_);
if (v___x_447_ == 0)
{
uint8_t v___x_448_; 
v___x_448_ = 2;
return v___x_448_;
}
else
{
uint8_t v___x_449_; 
v___x_449_ = 1;
return v___x_449_;
}
}
else
{
uint8_t v___x_450_; 
v___x_450_ = 0;
return v___x_450_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_TopologyClass_ofNat___boxed(lean_object* v_n_451_){
_start:
{
uint8_t v_res_452_; lean_object* v_r_453_; 
v_res_452_ = lp_ir_x2dproof_IRProof_TopologyClass_ofNat(v_n_451_);
lean_dec(v_n_451_);
v_r_453_ = lean_box(v_res_452_);
return v_r_453_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqTopologyClass(uint8_t v_x_454_, uint8_t v_y_455_){
_start:
{
lean_object* v___x_456_; lean_object* v___x_457_; uint8_t v___x_458_; 
v___x_456_ = lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx(v_x_454_);
v___x_457_ = lp_ir_x2dproof_IRProof_TopologyClass_ctorIdx(v_y_455_);
v___x_458_ = lean_nat_dec_eq(v___x_456_, v___x_457_);
lean_dec(v___x_457_);
lean_dec(v___x_456_);
return v___x_458_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqTopologyClass___boxed(lean_object* v_x_459_, lean_object* v_y_460_){
_start:
{
uint8_t v_x_13__boxed_461_; uint8_t v_y_14__boxed_462_; uint8_t v_res_463_; lean_object* v_r_464_; 
v_x_13__boxed_461_ = lean_unbox(v_x_459_);
v_y_14__boxed_462_ = lean_unbox(v_y_460_);
v_res_463_ = lp_ir_x2dproof_IRProof_instDecidableEqTopologyClass(v_x_13__boxed_461_, v_y_14__boxed_462_);
v_r_464_ = lean_box(v_res_463_);
return v_r_464_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12(void){
_start:
{
lean_object* v___x_483_; lean_object* v___x_484_; 
v___x_483_ = lean_unsigned_to_nat(2u);
v___x_484_ = lean_nat_to_int(v___x_483_);
return v___x_484_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13(void){
_start:
{
lean_object* v___x_485_; lean_object* v___x_486_; 
v___x_485_ = lean_unsigned_to_nat(1u);
v___x_486_ = lean_nat_to_int(v___x_485_);
return v___x_486_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr(uint8_t v_x_487_, lean_object* v_prec_488_){
_start:
{
lean_object* v___y_490_; lean_object* v___y_497_; lean_object* v___y_504_; lean_object* v___y_511_; lean_object* v___y_518_; lean_object* v___y_525_; 
switch(v_x_487_)
{
case 0:
{
lean_object* v___x_531_; uint8_t v___x_532_; 
v___x_531_ = lean_unsigned_to_nat(1024u);
v___x_532_ = lean_nat_dec_le(v___x_531_, v_prec_488_);
if (v___x_532_ == 0)
{
lean_object* v___x_533_; 
v___x_533_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_490_ = v___x_533_;
goto v___jp_489_;
}
else
{
lean_object* v___x_534_; 
v___x_534_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_490_ = v___x_534_;
goto v___jp_489_;
}
}
case 1:
{
lean_object* v___x_535_; uint8_t v___x_536_; 
v___x_535_ = lean_unsigned_to_nat(1024u);
v___x_536_ = lean_nat_dec_le(v___x_535_, v_prec_488_);
if (v___x_536_ == 0)
{
lean_object* v___x_537_; 
v___x_537_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_497_ = v___x_537_;
goto v___jp_496_;
}
else
{
lean_object* v___x_538_; 
v___x_538_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_497_ = v___x_538_;
goto v___jp_496_;
}
}
case 2:
{
lean_object* v___x_539_; uint8_t v___x_540_; 
v___x_539_ = lean_unsigned_to_nat(1024u);
v___x_540_ = lean_nat_dec_le(v___x_539_, v_prec_488_);
if (v___x_540_ == 0)
{
lean_object* v___x_541_; 
v___x_541_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_504_ = v___x_541_;
goto v___jp_503_;
}
else
{
lean_object* v___x_542_; 
v___x_542_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_504_ = v___x_542_;
goto v___jp_503_;
}
}
case 3:
{
lean_object* v___x_543_; uint8_t v___x_544_; 
v___x_543_ = lean_unsigned_to_nat(1024u);
v___x_544_ = lean_nat_dec_le(v___x_543_, v_prec_488_);
if (v___x_544_ == 0)
{
lean_object* v___x_545_; 
v___x_545_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_511_ = v___x_545_;
goto v___jp_510_;
}
else
{
lean_object* v___x_546_; 
v___x_546_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_511_ = v___x_546_;
goto v___jp_510_;
}
}
case 4:
{
lean_object* v___x_547_; uint8_t v___x_548_; 
v___x_547_ = lean_unsigned_to_nat(1024u);
v___x_548_ = lean_nat_dec_le(v___x_547_, v_prec_488_);
if (v___x_548_ == 0)
{
lean_object* v___x_549_; 
v___x_549_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_518_ = v___x_549_;
goto v___jp_517_;
}
else
{
lean_object* v___x_550_; 
v___x_550_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_518_ = v___x_550_;
goto v___jp_517_;
}
}
default: 
{
lean_object* v___x_551_; uint8_t v___x_552_; 
v___x_551_ = lean_unsigned_to_nat(1024u);
v___x_552_ = lean_nat_dec_le(v___x_551_, v_prec_488_);
if (v___x_552_ == 0)
{
lean_object* v___x_553_; 
v___x_553_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_525_ = v___x_553_;
goto v___jp_524_;
}
else
{
lean_object* v___x_554_; 
v___x_554_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_525_ = v___x_554_;
goto v___jp_524_;
}
}
}
v___jp_489_:
{
lean_object* v___x_491_; lean_object* v___x_492_; uint8_t v___x_493_; lean_object* v___x_494_; lean_object* v___x_495_; 
v___x_491_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__1));
lean_inc(v___y_490_);
v___x_492_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_492_, 0, v___y_490_);
lean_ctor_set(v___x_492_, 1, v___x_491_);
v___x_493_ = 0;
v___x_494_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_494_, 0, v___x_492_);
lean_ctor_set_uint8(v___x_494_, sizeof(void*)*1, v___x_493_);
v___x_495_ = l_Repr_addAppParen(v___x_494_, v_prec_488_);
return v___x_495_;
}
v___jp_496_:
{
lean_object* v___x_498_; lean_object* v___x_499_; uint8_t v___x_500_; lean_object* v___x_501_; lean_object* v___x_502_; 
v___x_498_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__3));
lean_inc(v___y_497_);
v___x_499_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_499_, 0, v___y_497_);
lean_ctor_set(v___x_499_, 1, v___x_498_);
v___x_500_ = 0;
v___x_501_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_501_, 0, v___x_499_);
lean_ctor_set_uint8(v___x_501_, sizeof(void*)*1, v___x_500_);
v___x_502_ = l_Repr_addAppParen(v___x_501_, v_prec_488_);
return v___x_502_;
}
v___jp_503_:
{
lean_object* v___x_505_; lean_object* v___x_506_; uint8_t v___x_507_; lean_object* v___x_508_; lean_object* v___x_509_; 
v___x_505_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__5));
lean_inc(v___y_504_);
v___x_506_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_506_, 0, v___y_504_);
lean_ctor_set(v___x_506_, 1, v___x_505_);
v___x_507_ = 0;
v___x_508_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_508_, 0, v___x_506_);
lean_ctor_set_uint8(v___x_508_, sizeof(void*)*1, v___x_507_);
v___x_509_ = l_Repr_addAppParen(v___x_508_, v_prec_488_);
return v___x_509_;
}
v___jp_510_:
{
lean_object* v___x_512_; lean_object* v___x_513_; uint8_t v___x_514_; lean_object* v___x_515_; lean_object* v___x_516_; 
v___x_512_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__7));
lean_inc(v___y_511_);
v___x_513_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_513_, 0, v___y_511_);
lean_ctor_set(v___x_513_, 1, v___x_512_);
v___x_514_ = 0;
v___x_515_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_515_, 0, v___x_513_);
lean_ctor_set_uint8(v___x_515_, sizeof(void*)*1, v___x_514_);
v___x_516_ = l_Repr_addAppParen(v___x_515_, v_prec_488_);
return v___x_516_;
}
v___jp_517_:
{
lean_object* v___x_519_; lean_object* v___x_520_; uint8_t v___x_521_; lean_object* v___x_522_; lean_object* v___x_523_; 
v___x_519_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__9));
lean_inc(v___y_518_);
v___x_520_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_520_, 0, v___y_518_);
lean_ctor_set(v___x_520_, 1, v___x_519_);
v___x_521_ = 0;
v___x_522_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_522_, 0, v___x_520_);
lean_ctor_set_uint8(v___x_522_, sizeof(void*)*1, v___x_521_);
v___x_523_ = l_Repr_addAppParen(v___x_522_, v_prec_488_);
return v___x_523_;
}
v___jp_524_:
{
lean_object* v___x_526_; lean_object* v___x_527_; uint8_t v___x_528_; lean_object* v___x_529_; lean_object* v___x_530_; 
v___x_526_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__11));
lean_inc(v___y_525_);
v___x_527_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_527_, 0, v___y_525_);
lean_ctor_set(v___x_527_, 1, v___x_526_);
v___x_528_ = 0;
v___x_529_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_529_, 0, v___x_527_);
lean_ctor_set_uint8(v___x_529_, sizeof(void*)*1, v___x_528_);
v___x_530_ = l_Repr_addAppParen(v___x_529_, v_prec_488_);
return v___x_530_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___boxed(lean_object* v_x_555_, lean_object* v_prec_556_){
_start:
{
uint8_t v_x_345__boxed_557_; lean_object* v_res_558_; 
v_x_345__boxed_557_ = lean_unbox(v_x_555_);
v_res_558_ = lp_ir_x2dproof_IRProof_instReprTopologyClass_repr(v_x_345__boxed_557_, v_prec_556_);
lean_dec(v_prec_556_);
return v_res_558_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_classifyTopology(lean_object* v_e_561_){
_start:
{
uint8_t v_unresolvedObservation_562_; uint8_t v_sameInterval_563_; uint8_t v_extendsInterval_564_; uint8_t v_knownConnection_565_; uint8_t v_bothContinue_566_; uint8_t v_sameLevel_567_; lean_object* v_heightSeparationSq_568_; lean_object* v_certifiedToleranceSq_569_; 
v_unresolvedObservation_562_ = lean_ctor_get_uint8(v_e_561_, sizeof(void*)*2);
v_sameInterval_563_ = lean_ctor_get_uint8(v_e_561_, sizeof(void*)*2 + 1);
v_extendsInterval_564_ = lean_ctor_get_uint8(v_e_561_, sizeof(void*)*2 + 2);
v_knownConnection_565_ = lean_ctor_get_uint8(v_e_561_, sizeof(void*)*2 + 3);
v_bothContinue_566_ = lean_ctor_get_uint8(v_e_561_, sizeof(void*)*2 + 4);
v_sameLevel_567_ = lean_ctor_get_uint8(v_e_561_, sizeof(void*)*2 + 5);
v_heightSeparationSq_568_ = lean_ctor_get(v_e_561_, 0);
lean_inc_ref(v_heightSeparationSq_568_);
v_certifiedToleranceSq_569_ = lean_ctor_get(v_e_561_, 1);
lean_inc_ref(v_certifiedToleranceSq_569_);
lean_dec_ref(v_e_561_);
if (v_unresolvedObservation_562_ == 0)
{
uint8_t v___x_575_; 
v___x_575_ = l_Rat_blt(v_certifiedToleranceSq_569_, v_heightSeparationSq_568_);
if (v___x_575_ == 0)
{
if (v_bothContinue_566_ == 0)
{
goto v___jp_570_;
}
else
{
if (v_sameLevel_567_ == 0)
{
goto v___jp_570_;
}
else
{
if (v_knownConnection_565_ == 0)
{
uint8_t v___x_576_; 
v___x_576_ = 3;
return v___x_576_;
}
else
{
goto v___jp_570_;
}
}
}
}
else
{
uint8_t v___x_577_; 
v___x_577_ = 4;
return v___x_577_;
}
}
else
{
uint8_t v___x_578_; 
lean_dec_ref(v_certifiedToleranceSq_569_);
lean_dec_ref(v_heightSeparationSq_568_);
v___x_578_ = 5;
return v___x_578_;
}
v___jp_570_:
{
if (v_knownConnection_565_ == 0)
{
if (v_extendsInterval_564_ == 0)
{
if (v_sameInterval_563_ == 0)
{
uint8_t v___x_571_; 
v___x_571_ = 5;
return v___x_571_;
}
else
{
uint8_t v___x_572_; 
v___x_572_ = 0;
return v___x_572_;
}
}
else
{
uint8_t v___x_573_; 
v___x_573_ = 1;
return v___x_573_;
}
}
else
{
uint8_t v___x_574_; 
v___x_574_ = 2;
return v___x_574_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_classifyTopology___boxed(lean_object* v_e_579_){
_start:
{
uint8_t v_res_580_; lean_object* v_r_581_; 
v_res_580_ = lp_ir_x2dproof_IRProof_classifyTopology(v_e_579_);
v_r_581_ = lean_box(v_res_580_);
return v_r_581_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_topologyRoutable(uint8_t v_x_582_){
_start:
{
switch(v_x_582_)
{
case 3:
{
uint8_t v___x_583_; 
v___x_583_ = 0;
return v___x_583_;
}
case 4:
{
uint8_t v___x_584_; 
v___x_584_ = 0;
return v___x_584_;
}
case 5:
{
uint8_t v___x_585_; 
v___x_585_ = 0;
return v___x_585_;
}
default: 
{
uint8_t v___x_586_; 
v___x_586_ = 1;
return v___x_586_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_topologyRoutable___boxed(lean_object* v_x_587_){
_start:
{
uint8_t v_x_38__boxed_588_; uint8_t v_res_589_; lean_object* v_r_590_; 
v_x_38__boxed_588_ = lean_unbox(v_x_587_);
v_res_589_ = lp_ir_x2dproof_IRProof_topologyRoutable(v_x_38__boxed_588_);
v_r_590_ = lean_box(v_res_589_);
return v_r_590_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter___redArg(uint8_t v_x_591_, lean_object* v_h__1_592_, lean_object* v_h__2_593_, lean_object* v_h__3_594_, lean_object* v_h__4_595_, lean_object* v_h__5_596_, lean_object* v_h__6_597_){
_start:
{
switch(v_x_591_)
{
case 0:
{
lean_object* v___x_598_; lean_object* v___x_599_; 
lean_dec(v_h__6_597_);
lean_dec(v_h__5_596_);
lean_dec(v_h__4_595_);
lean_dec(v_h__3_594_);
lean_dec(v_h__2_593_);
v___x_598_ = lean_box(0);
v___x_599_ = lean_apply_1(v_h__1_592_, v___x_598_);
return v___x_599_;
}
case 1:
{
lean_object* v___x_600_; lean_object* v___x_601_; 
lean_dec(v_h__6_597_);
lean_dec(v_h__5_596_);
lean_dec(v_h__4_595_);
lean_dec(v_h__3_594_);
lean_dec(v_h__1_592_);
v___x_600_ = lean_box(0);
v___x_601_ = lean_apply_1(v_h__2_593_, v___x_600_);
return v___x_601_;
}
case 2:
{
lean_object* v___x_602_; lean_object* v___x_603_; 
lean_dec(v_h__6_597_);
lean_dec(v_h__5_596_);
lean_dec(v_h__4_595_);
lean_dec(v_h__2_593_);
lean_dec(v_h__1_592_);
v___x_602_ = lean_box(0);
v___x_603_ = lean_apply_1(v_h__3_594_, v___x_602_);
return v___x_603_;
}
case 3:
{
lean_object* v___x_604_; lean_object* v___x_605_; 
lean_dec(v_h__6_597_);
lean_dec(v_h__5_596_);
lean_dec(v_h__3_594_);
lean_dec(v_h__2_593_);
lean_dec(v_h__1_592_);
v___x_604_ = lean_box(0);
v___x_605_ = lean_apply_1(v_h__4_595_, v___x_604_);
return v___x_605_;
}
case 4:
{
lean_object* v___x_606_; lean_object* v___x_607_; 
lean_dec(v_h__6_597_);
lean_dec(v_h__4_595_);
lean_dec(v_h__3_594_);
lean_dec(v_h__2_593_);
lean_dec(v_h__1_592_);
v___x_606_ = lean_box(0);
v___x_607_ = lean_apply_1(v_h__5_596_, v___x_606_);
return v___x_607_;
}
default: 
{
lean_object* v___x_608_; lean_object* v___x_609_; 
lean_dec(v_h__5_596_);
lean_dec(v_h__4_595_);
lean_dec(v_h__3_594_);
lean_dec(v_h__2_593_);
lean_dec(v_h__1_592_);
v___x_608_ = lean_box(0);
v___x_609_ = lean_apply_1(v_h__6_597_, v___x_608_);
return v___x_609_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter___redArg___boxed(lean_object* v_x_610_, lean_object* v_h__1_611_, lean_object* v_h__2_612_, lean_object* v_h__3_613_, lean_object* v_h__4_614_, lean_object* v_h__5_615_, lean_object* v_h__6_616_){
_start:
{
uint8_t v_x_60__boxed_617_; lean_object* v_res_618_; 
v_x_60__boxed_617_ = lean_unbox(v_x_610_);
v_res_618_ = lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter___redArg(v_x_60__boxed_617_, v_h__1_611_, v_h__2_612_, v_h__3_613_, v_h__4_614_, v_h__5_615_, v_h__6_616_);
return v_res_618_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter(lean_object* v_motive_619_, uint8_t v_x_620_, lean_object* v_h__1_621_, lean_object* v_h__2_622_, lean_object* v_h__3_623_, lean_object* v_h__4_624_, lean_object* v_h__5_625_, lean_object* v_h__6_626_){
_start:
{
switch(v_x_620_)
{
case 0:
{
lean_object* v___x_627_; lean_object* v___x_628_; 
lean_dec(v_h__6_626_);
lean_dec(v_h__5_625_);
lean_dec(v_h__4_624_);
lean_dec(v_h__3_623_);
lean_dec(v_h__2_622_);
v___x_627_ = lean_box(0);
v___x_628_ = lean_apply_1(v_h__1_621_, v___x_627_);
return v___x_628_;
}
case 1:
{
lean_object* v___x_629_; lean_object* v___x_630_; 
lean_dec(v_h__6_626_);
lean_dec(v_h__5_625_);
lean_dec(v_h__4_624_);
lean_dec(v_h__3_623_);
lean_dec(v_h__1_621_);
v___x_629_ = lean_box(0);
v___x_630_ = lean_apply_1(v_h__2_622_, v___x_629_);
return v___x_630_;
}
case 2:
{
lean_object* v___x_631_; lean_object* v___x_632_; 
lean_dec(v_h__6_626_);
lean_dec(v_h__5_625_);
lean_dec(v_h__4_624_);
lean_dec(v_h__2_622_);
lean_dec(v_h__1_621_);
v___x_631_ = lean_box(0);
v___x_632_ = lean_apply_1(v_h__3_623_, v___x_631_);
return v___x_632_;
}
case 3:
{
lean_object* v___x_633_; lean_object* v___x_634_; 
lean_dec(v_h__6_626_);
lean_dec(v_h__5_625_);
lean_dec(v_h__3_623_);
lean_dec(v_h__2_622_);
lean_dec(v_h__1_621_);
v___x_633_ = lean_box(0);
v___x_634_ = lean_apply_1(v_h__4_624_, v___x_633_);
return v___x_634_;
}
case 4:
{
lean_object* v___x_635_; lean_object* v___x_636_; 
lean_dec(v_h__6_626_);
lean_dec(v_h__4_624_);
lean_dec(v_h__3_623_);
lean_dec(v_h__2_622_);
lean_dec(v_h__1_621_);
v___x_635_ = lean_box(0);
v___x_636_ = lean_apply_1(v_h__5_625_, v___x_635_);
return v___x_636_;
}
default: 
{
lean_object* v___x_637_; lean_object* v___x_638_; 
lean_dec(v_h__5_625_);
lean_dec(v_h__4_624_);
lean_dec(v_h__3_623_);
lean_dec(v_h__2_622_);
lean_dec(v_h__1_621_);
v___x_637_ = lean_box(0);
v___x_638_ = lean_apply_1(v_h__6_626_, v___x_637_);
return v___x_638_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter___boxed(lean_object* v_motive_639_, lean_object* v_x_640_, lean_object* v_h__1_641_, lean_object* v_h__2_642_, lean_object* v_h__3_643_, lean_object* v_h__4_644_, lean_object* v_h__5_645_, lean_object* v_h__6_646_){
_start:
{
uint8_t v_x_87__boxed_647_; lean_object* v_res_648_; 
v_x_87__boxed_647_ = lean_unbox(v_x_640_);
v_res_648_ = lp_ir_x2dproof___private_IRProof_0__IRProof_instReprTopologyClass_repr_match__1_splitter(v_motive_639_, v_x_87__boxed_647_, v_h__1_641_, v_h__2_642_, v_h__3_643_, v_h__4_644_, v_h__5_645_, v_h__6_646_);
return v_res_648_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_containsString(lean_object* v_x_649_, lean_object* v_x_650_){
_start:
{
if (lean_obj_tag(v_x_650_) == 0)
{
uint8_t v___x_651_; 
v___x_651_ = 0;
return v___x_651_;
}
else
{
lean_object* v_head_652_; lean_object* v_tail_653_; uint8_t v___x_654_; 
v_head_652_ = lean_ctor_get(v_x_650_, 0);
v_tail_653_ = lean_ctor_get(v_x_650_, 1);
v___x_654_ = lean_string_dec_eq(v_x_649_, v_head_652_);
if (v___x_654_ == 0)
{
v_x_650_ = v_tail_653_;
goto _start;
}
else
{
return v___x_654_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_containsString___boxed(lean_object* v_x_656_, lean_object* v_x_657_){
_start:
{
uint8_t v_res_658_; lean_object* v_r_659_; 
v_res_658_ = lp_ir_x2dproof_IRProof_containsString(v_x_656_, v_x_657_);
lean_dec(v_x_657_);
lean_dec_ref(v_x_656_);
v_r_659_ = lean_box(v_res_658_);
return v_r_659_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeChainValid_spec__0(lean_object* v_fst_660_, lean_object* v_x_661_){
_start:
{
if (lean_obj_tag(v_x_661_) == 0)
{
lean_object* v___x_662_; 
v___x_662_ = lean_box(0);
return v___x_662_;
}
else
{
lean_object* v_head_663_; lean_object* v_tail_664_; lean_object* v_edgeId_665_; uint8_t v___x_666_; 
v_head_663_ = lean_ctor_get(v_x_661_, 0);
v_tail_664_ = lean_ctor_get(v_x_661_, 1);
v_edgeId_665_ = lean_ctor_get(v_head_663_, 0);
v___x_666_ = lean_string_dec_eq(v_edgeId_665_, v_fst_660_);
if (v___x_666_ == 0)
{
v_x_661_ = v_tail_664_;
goto _start;
}
else
{
lean_object* v___x_668_; 
lean_inc(v_head_663_);
v___x_668_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_668_, 0, v_head_663_);
return v___x_668_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeChainValid_spec__0___boxed(lean_object* v_fst_669_, lean_object* v_x_670_){
_start:
{
lean_object* v_res_671_; 
v_res_671_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeChainValid_spec__0(v_fst_669_, v_x_670_);
lean_dec(v_x_670_);
lean_dec_ref(v_fst_669_);
return v_res_671_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeChainValid(lean_object* v_g_672_, lean_object* v_x_673_){
_start:
{
if (lean_obj_tag(v_x_673_) == 0)
{
uint8_t v___x_674_; 
v___x_674_ = 1;
return v___x_674_;
}
else
{
lean_object* v_tail_675_; 
v_tail_675_ = lean_ctor_get(v_x_673_, 1);
if (lean_obj_tag(v_tail_675_) == 0)
{
uint8_t v___x_676_; 
v___x_676_ = 1;
return v___x_676_;
}
else
{
lean_object* v_head_677_; lean_object* v_head_678_; lean_object* v_fst_679_; lean_object* v_snd_680_; lean_object* v_fst_681_; lean_object* v_snd_682_; lean_object* v_edges_683_; lean_object* v___x_684_; 
v_head_677_ = lean_ctor_get(v_tail_675_, 0);
v_head_678_ = lean_ctor_get(v_x_673_, 0);
v_fst_679_ = lean_ctor_get(v_head_677_, 0);
v_snd_680_ = lean_ctor_get(v_head_677_, 1);
v_fst_681_ = lean_ctor_get(v_head_678_, 0);
v_snd_682_ = lean_ctor_get(v_head_678_, 1);
v_edges_683_ = lean_ctor_get(v_g_672_, 3);
v___x_684_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeChainValid_spec__0(v_fst_681_, v_edges_683_);
if (lean_obj_tag(v___x_684_) == 0)
{
uint8_t v___x_685_; 
v___x_685_ = 0;
return v___x_685_;
}
else
{
lean_object* v_val_686_; lean_object* v___x_687_; 
v_val_686_ = lean_ctor_get(v___x_684_, 0);
lean_inc(v_val_686_);
lean_dec_ref_known(v___x_684_, 1);
v___x_687_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeChainValid_spec__0(v_fst_679_, v_edges_683_);
if (lean_obj_tag(v___x_687_) == 0)
{
uint8_t v___x_688_; 
lean_dec(v_val_686_);
v___x_688_ = 0;
return v___x_688_;
}
else
{
lean_object* v_val_689_; uint8_t v_forward_690_; lean_object* v_endVertexId_691_; 
v_val_689_ = lean_ctor_get(v___x_687_, 0);
lean_inc(v_val_689_);
lean_dec_ref_known(v___x_687_, 1);
v_forward_690_ = lean_ctor_get_uint8(v_val_686_, sizeof(void*)*6);
v_endVertexId_691_ = lean_ctor_get(v_val_686_, 5);
lean_inc_ref(v_endVertexId_691_);
lean_dec(v_val_686_);
if (v_forward_690_ == 0)
{
uint8_t v___x_701_; 
v___x_701_ = lean_unbox(v_snd_682_);
if (v___x_701_ == 0)
{
goto v___jp_696_;
}
else
{
lean_dec_ref(v_endVertexId_691_);
lean_dec(v_val_689_);
return v_forward_690_;
}
}
else
{
uint8_t v___x_702_; 
v___x_702_ = lean_unbox(v_snd_682_);
if (v___x_702_ == 0)
{
uint8_t v___x_703_; 
lean_dec_ref(v_endVertexId_691_);
lean_dec(v_val_689_);
v___x_703_ = lean_unbox(v_snd_682_);
return v___x_703_;
}
else
{
goto v___jp_696_;
}
}
v___jp_692_:
{
lean_object* v_startVertexId_693_; uint8_t v___x_694_; 
v_startVertexId_693_ = lean_ctor_get(v_val_689_, 4);
lean_inc_ref(v_startVertexId_693_);
lean_dec(v_val_689_);
v___x_694_ = lean_string_dec_eq(v_endVertexId_691_, v_startVertexId_693_);
lean_dec_ref(v_startVertexId_693_);
lean_dec_ref(v_endVertexId_691_);
if (v___x_694_ == 0)
{
return v___x_694_;
}
else
{
v_x_673_ = v_tail_675_;
goto _start;
}
}
v___jp_696_:
{
uint8_t v_forward_697_; 
v_forward_697_ = lean_ctor_get_uint8(v_val_689_, sizeof(void*)*6);
if (v_forward_697_ == 0)
{
uint8_t v___x_698_; 
v___x_698_ = lean_unbox(v_snd_680_);
if (v___x_698_ == 0)
{
goto v___jp_692_;
}
else
{
lean_dec_ref(v_endVertexId_691_);
lean_dec(v_val_689_);
return v_forward_697_;
}
}
else
{
uint8_t v___x_699_; 
v___x_699_ = lean_unbox(v_snd_680_);
if (v___x_699_ == 0)
{
uint8_t v___x_700_; 
lean_dec_ref(v_endVertexId_691_);
lean_dec(v_val_689_);
v___x_700_ = lean_unbox(v_snd_680_);
return v___x_700_;
}
else
{
goto v___jp_692_;
}
}
}
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeChainValid___boxed(lean_object* v_g_704_, lean_object* v_x_705_){
_start:
{
uint8_t v_res_706_; lean_object* v_r_707_; 
v_res_706_ = lp_ir_x2dproof_IRProof_routeChainValid(v_g_704_, v_x_705_);
lean_dec(v_x_705_);
lean_dec_ref(v_g_704_);
v_r_707_ = lean_box(v_res_706_);
return v_r_707_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__2(lean_object* v_vid_708_, lean_object* v_x_709_){
_start:
{
if (lean_obj_tag(v_x_709_) == 0)
{
lean_object* v___x_710_; 
v___x_710_ = lean_box(0);
return v___x_710_;
}
else
{
lean_object* v_head_711_; lean_object* v_tail_712_; lean_object* v_vertexId_713_; uint8_t v___x_714_; 
v_head_711_ = lean_ctor_get(v_x_709_, 0);
v_tail_712_ = lean_ctor_get(v_x_709_, 1);
v_vertexId_713_ = lean_ctor_get(v_head_711_, 0);
v___x_714_ = lean_string_dec_eq(v_vertexId_713_, v_vid_708_);
if (v___x_714_ == 0)
{
v_x_709_ = v_tail_712_;
goto _start;
}
else
{
lean_object* v___x_716_; 
lean_inc(v_head_711_);
v___x_716_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_716_, 0, v_head_711_);
return v___x_716_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__2___boxed(lean_object* v_vid_717_, lean_object* v_x_718_){
_start:
{
lean_object* v_res_719_; 
v_res_719_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__2(v_vid_717_, v_x_718_);
lean_dec(v_x_718_);
lean_dec_ref(v_vid_717_);
return v_res_719_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__3(lean_object* v_val_720_, lean_object* v_x_721_){
_start:
{
if (lean_obj_tag(v_x_721_) == 0)
{
lean_object* v___x_722_; 
v___x_722_ = lean_box(0);
return v___x_722_;
}
else
{
lean_object* v_head_723_; lean_object* v_tail_724_; lean_object* v_stableId_725_; lean_object* v_splineId_726_; uint8_t v___x_727_; 
v_head_723_ = lean_ctor_get(v_x_721_, 0);
v_tail_724_ = lean_ctor_get(v_x_721_, 1);
v_stableId_725_ = lean_ctor_get(v_head_723_, 0);
v_splineId_726_ = lean_ctor_get(v_val_720_, 1);
v___x_727_ = lean_string_dec_eq(v_stableId_725_, v_splineId_726_);
if (v___x_727_ == 0)
{
v_x_721_ = v_tail_724_;
goto _start;
}
else
{
lean_object* v___x_729_; 
lean_inc(v_head_723_);
v___x_729_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_729_, 0, v_head_723_);
return v___x_729_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__3___boxed(lean_object* v_val_730_, lean_object* v_x_731_){
_start:
{
lean_object* v_res_732_; 
v_res_732_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__3(v_val_730_, v_x_731_);
lean_dec(v_x_731_);
lean_dec_ref(v_val_730_);
return v_res_732_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__6(lean_object* v_g_733_, lean_object* v_route_734_, lean_object* v_x_735_){
_start:
{
if (lean_obj_tag(v_x_735_) == 0)
{
uint8_t v___x_736_; 
v___x_736_ = 1;
return v___x_736_;
}
else
{
lean_object* v_head_737_; lean_object* v_tail_738_; uint8_t v___y_740_; lean_object* v_splines_742_; lean_object* v_vertices_743_; lean_object* v___x_744_; 
v_head_737_ = lean_ctor_get(v_x_735_, 0);
v_tail_738_ = lean_ctor_get(v_x_735_, 1);
v_splines_742_ = lean_ctor_get(v_g_733_, 1);
v_vertices_743_ = lean_ctor_get(v_g_733_, 2);
v___x_744_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__2(v_head_737_, v_vertices_743_);
if (lean_obj_tag(v___x_744_) == 0)
{
uint8_t v___x_745_; 
v___x_745_ = 0;
return v___x_745_;
}
else
{
lean_object* v_val_746_; lean_object* v_splineId_747_; lean_object* v_s_748_; lean_object* v_splineIds_749_; uint8_t v___x_750_; 
v_val_746_ = lean_ctor_get(v___x_744_, 0);
lean_inc(v_val_746_);
lean_dec_ref_known(v___x_744_, 1);
v_splineId_747_ = lean_ctor_get(v_val_746_, 1);
v_s_748_ = lean_ctor_get(v_val_746_, 2);
lean_inc_ref(v_s_748_);
v_splineIds_749_ = lean_ctor_get(v_route_734_, 1);
v___x_750_ = lp_ir_x2dproof_IRProof_containsString(v_splineId_747_, v_splineIds_749_);
if (v___x_750_ == 0)
{
lean_dec_ref(v_s_748_);
lean_dec(v_val_746_);
v___y_740_ = v___x_750_;
goto v___jp_739_;
}
else
{
lean_object* v___x_751_; 
v___x_751_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__3(v_val_746_, v_splines_742_);
lean_dec(v_val_746_);
if (lean_obj_tag(v___x_751_) == 0)
{
uint8_t v___x_752_; 
lean_dec_ref(v_s_748_);
v___x_752_ = 0;
return v___x_752_;
}
else
{
lean_object* v_val_753_; lean_object* v___x_754_; uint8_t v___x_755_; 
v_val_753_ = lean_ctor_get(v___x_751_, 0);
lean_inc(v_val_753_);
lean_dec_ref_known(v___x_751_, 1);
v___x_754_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
lean_inc_ref(v_s_748_);
v___x_755_ = l_Rat_instDecidableLe(v___x_754_, v_s_748_);
if (v___x_755_ == 0)
{
lean_dec(v_val_753_);
lean_dec_ref(v_s_748_);
v___y_740_ = v___x_755_;
goto v___jp_739_;
}
else
{
lean_object* v_totalLength_756_; uint8_t v___x_757_; 
v_totalLength_756_ = lean_ctor_get(v_val_753_, 4);
lean_inc_ref(v_totalLength_756_);
lean_dec(v_val_753_);
v___x_757_ = l_Rat_instDecidableLe(v_s_748_, v_totalLength_756_);
v___y_740_ = v___x_757_;
goto v___jp_739_;
}
}
}
}
v___jp_739_:
{
if (v___y_740_ == 0)
{
return v___y_740_;
}
else
{
v_x_735_ = v_tail_738_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__6___boxed(lean_object* v_g_758_, lean_object* v_route_759_, lean_object* v_x_760_){
_start:
{
uint8_t v_res_761_; lean_object* v_r_762_; 
v_res_761_ = lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__6(v_g_758_, v_route_759_, v_x_760_);
lean_dec(v_x_760_);
lean_dec_ref(v_route_759_);
lean_dec_ref(v_g_758_);
v_r_762_ = lean_box(v_res_761_);
return v_r_762_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_any___at___00IRProof_routeEdgeSetValid_spec__4(lean_object* v_sid_763_, lean_object* v_x_764_){
_start:
{
if (lean_obj_tag(v_x_764_) == 0)
{
uint8_t v___x_765_; 
v___x_765_ = 0;
return v___x_765_;
}
else
{
lean_object* v_head_766_; lean_object* v_tail_767_; lean_object* v_stableId_768_; uint8_t v___x_769_; 
v_head_766_ = lean_ctor_get(v_x_764_, 0);
v_tail_767_ = lean_ctor_get(v_x_764_, 1);
v_stableId_768_ = lean_ctor_get(v_head_766_, 0);
v___x_769_ = lean_string_dec_eq(v_stableId_768_, v_sid_763_);
if (v___x_769_ == 0)
{
v_x_764_ = v_tail_767_;
goto _start;
}
else
{
return v___x_769_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_any___at___00IRProof_routeEdgeSetValid_spec__4___boxed(lean_object* v_sid_771_, lean_object* v_x_772_){
_start:
{
uint8_t v_res_773_; lean_object* v_r_774_; 
v_res_773_ = lp_ir_x2dproof_List_any___at___00IRProof_routeEdgeSetValid_spec__4(v_sid_771_, v_x_772_);
lean_dec(v_x_772_);
lean_dec_ref(v_sid_771_);
v_r_774_ = lean_box(v_res_773_);
return v_r_774_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__7(lean_object* v_g_775_, lean_object* v_x_776_){
_start:
{
if (lean_obj_tag(v_x_776_) == 0)
{
uint8_t v___x_777_; 
v___x_777_ = 1;
return v___x_777_;
}
else
{
lean_object* v_head_778_; lean_object* v_tail_779_; lean_object* v_splines_780_; uint8_t v___x_781_; 
v_head_778_ = lean_ctor_get(v_x_776_, 0);
v_tail_779_ = lean_ctor_get(v_x_776_, 1);
v_splines_780_ = lean_ctor_get(v_g_775_, 1);
v___x_781_ = lp_ir_x2dproof_List_any___at___00IRProof_routeEdgeSetValid_spec__4(v_head_778_, v_splines_780_);
if (v___x_781_ == 0)
{
return v___x_781_;
}
else
{
v_x_776_ = v_tail_779_;
goto _start;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__7___boxed(lean_object* v_g_783_, lean_object* v_x_784_){
_start:
{
uint8_t v_res_785_; lean_object* v_r_786_; 
v_res_785_ = lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__7(v_g_783_, v_x_784_);
lean_dec(v_x_784_);
lean_dec_ref(v_g_783_);
v_r_786_ = lean_box(v_res_785_);
return v_r_786_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__0(lean_object* v_pair_787_, lean_object* v_x_788_){
_start:
{
if (lean_obj_tag(v_x_788_) == 0)
{
lean_object* v___x_789_; 
v___x_789_ = lean_box(0);
return v___x_789_;
}
else
{
lean_object* v_head_790_; lean_object* v_tail_791_; lean_object* v_edgeId_792_; lean_object* v_fst_793_; uint8_t v___x_794_; 
v_head_790_ = lean_ctor_get(v_x_788_, 0);
v_tail_791_ = lean_ctor_get(v_x_788_, 1);
v_edgeId_792_ = lean_ctor_get(v_head_790_, 0);
v_fst_793_ = lean_ctor_get(v_pair_787_, 0);
v___x_794_ = lean_string_dec_eq(v_edgeId_792_, v_fst_793_);
if (v___x_794_ == 0)
{
v_x_788_ = v_tail_791_;
goto _start;
}
else
{
lean_object* v___x_796_; 
lean_inc(v_head_790_);
v___x_796_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_796_, 0, v_head_790_);
return v___x_796_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__0___boxed(lean_object* v_pair_797_, lean_object* v_x_798_){
_start:
{
lean_object* v_res_799_; 
v_res_799_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__0(v_pair_797_, v_x_798_);
lean_dec(v_x_798_);
lean_dec_ref(v_pair_797_);
return v_res_799_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__1(lean_object* v_val_800_, lean_object* v_x_801_){
_start:
{
if (lean_obj_tag(v_x_801_) == 0)
{
lean_object* v___x_802_; 
v___x_802_ = lean_box(0);
return v___x_802_;
}
else
{
lean_object* v_head_803_; lean_object* v_tail_804_; lean_object* v_stableId_805_; lean_object* v_splineId_806_; uint8_t v___x_807_; 
v_head_803_ = lean_ctor_get(v_x_801_, 0);
v_tail_804_ = lean_ctor_get(v_x_801_, 1);
v_stableId_805_ = lean_ctor_get(v_head_803_, 0);
v_splineId_806_ = lean_ctor_get(v_val_800_, 1);
v___x_807_ = lean_string_dec_eq(v_stableId_805_, v_splineId_806_);
if (v___x_807_ == 0)
{
v_x_801_ = v_tail_804_;
goto _start;
}
else
{
lean_object* v___x_809_; 
lean_inc(v_head_803_);
v___x_809_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_809_, 0, v_head_803_);
return v___x_809_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__1___boxed(lean_object* v_val_810_, lean_object* v_x_811_){
_start:
{
lean_object* v_res_812_; 
v_res_812_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__1(v_val_810_, v_x_811_);
lean_dec(v_x_811_);
lean_dec_ref(v_val_810_);
return v_res_812_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__5(lean_object* v_g_813_, lean_object* v_route_814_, lean_object* v_x_815_){
_start:
{
if (lean_obj_tag(v_x_815_) == 0)
{
uint8_t v___x_816_; 
v___x_816_ = 1;
return v___x_816_;
}
else
{
lean_object* v_head_817_; lean_object* v_tail_818_; uint8_t v___y_820_; lean_object* v_splines_822_; lean_object* v_edges_823_; lean_object* v___x_824_; 
v_head_817_ = lean_ctor_get(v_x_815_, 0);
v_tail_818_ = lean_ctor_get(v_x_815_, 1);
v_splines_822_ = lean_ctor_get(v_g_813_, 1);
v_edges_823_ = lean_ctor_get(v_g_813_, 3);
v___x_824_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__0(v_head_817_, v_edges_823_);
if (lean_obj_tag(v___x_824_) == 0)
{
uint8_t v___x_825_; 
v___x_825_ = 0;
return v___x_825_;
}
else
{
lean_object* v_val_826_; lean_object* v_splineId_827_; lean_object* v_startS_828_; lean_object* v_endS_829_; uint8_t v_forward_830_; lean_object* v_startVertexId_831_; lean_object* v_endVertexId_832_; lean_object* v___y_834_; uint8_t v___y_835_; lean_object* v___y_840_; uint8_t v___y_841_; lean_object* v_splineIds_851_; lean_object* v_vertexIds_852_; uint8_t v___y_854_; uint8_t v___x_861_; 
v_val_826_ = lean_ctor_get(v___x_824_, 0);
lean_inc(v_val_826_);
lean_dec_ref_known(v___x_824_, 1);
v_splineId_827_ = lean_ctor_get(v_val_826_, 1);
v_startS_828_ = lean_ctor_get(v_val_826_, 2);
lean_inc_ref(v_startS_828_);
v_endS_829_ = lean_ctor_get(v_val_826_, 3);
lean_inc_ref(v_endS_829_);
v_forward_830_ = lean_ctor_get_uint8(v_val_826_, sizeof(void*)*6);
v_startVertexId_831_ = lean_ctor_get(v_val_826_, 4);
v_endVertexId_832_ = lean_ctor_get(v_val_826_, 5);
v_splineIds_851_ = lean_ctor_get(v_route_814_, 1);
v_vertexIds_852_ = lean_ctor_get(v_route_814_, 2);
v___x_861_ = lp_ir_x2dproof_IRProof_containsString(v_splineId_827_, v_splineIds_851_);
if (v___x_861_ == 0)
{
v___y_854_ = v___x_861_;
goto v___jp_853_;
}
else
{
uint8_t v___x_862_; 
v___x_862_ = lp_ir_x2dproof_IRProof_containsString(v_startVertexId_831_, v_vertexIds_852_);
v___y_854_ = v___x_862_;
goto v___jp_853_;
}
v___jp_833_:
{
if (v___y_835_ == 0)
{
lean_dec_ref(v___y_834_);
lean_dec_ref(v_endS_829_);
lean_dec_ref(v_startS_828_);
return v___y_835_;
}
else
{
lean_object* v_totalLength_836_; uint8_t v___x_837_; 
v_totalLength_836_ = lean_ctor_get(v___y_834_, 4);
lean_inc_ref_n(v_totalLength_836_, 2);
lean_dec_ref(v___y_834_);
v___x_837_ = l_Rat_instDecidableLe(v_startS_828_, v_totalLength_836_);
if (v___x_837_ == 0)
{
lean_dec_ref(v_totalLength_836_);
lean_dec_ref(v_endS_829_);
v___y_820_ = v___x_837_;
goto v___jp_819_;
}
else
{
uint8_t v___x_838_; 
v___x_838_ = l_Rat_instDecidableLe(v_endS_829_, v_totalLength_836_);
v___y_820_ = v___x_838_;
goto v___jp_819_;
}
}
}
v___jp_839_:
{
if (v___y_841_ == 0)
{
lean_dec_ref(v___y_840_);
lean_dec_ref(v_endS_829_);
lean_dec_ref(v_startS_828_);
return v___y_841_;
}
else
{
if (v_forward_830_ == 0)
{
uint8_t v___x_842_; 
lean_inc_ref(v_startS_828_);
lean_inc_ref(v_endS_829_);
v___x_842_ = l_Rat_instDecidableLe(v_endS_829_, v_startS_828_);
v___y_834_ = v___y_840_;
v___y_835_ = v___x_842_;
goto v___jp_833_;
}
else
{
uint8_t v___x_843_; 
lean_inc_ref(v_endS_829_);
lean_inc_ref(v_startS_828_);
v___x_843_ = l_Rat_instDecidableLe(v_startS_828_, v_endS_829_);
v___y_834_ = v___y_840_;
v___y_835_ = v___x_843_;
goto v___jp_833_;
}
}
}
v___jp_844_:
{
lean_object* v___x_845_; 
v___x_845_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_routeEdgeSetValid_spec__1(v_val_826_, v_splines_822_);
lean_dec(v_val_826_);
if (lean_obj_tag(v___x_845_) == 0)
{
uint8_t v___x_846_; 
lean_dec_ref(v_endS_829_);
lean_dec_ref(v_startS_828_);
v___x_846_ = 0;
return v___x_846_;
}
else
{
lean_object* v_val_847_; lean_object* v___x_848_; uint8_t v___x_849_; 
v_val_847_ = lean_ctor_get(v___x_845_, 0);
lean_inc(v_val_847_);
lean_dec_ref_known(v___x_845_, 1);
v___x_848_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
lean_inc_ref(v_startS_828_);
v___x_849_ = l_Rat_instDecidableLe(v___x_848_, v_startS_828_);
if (v___x_849_ == 0)
{
v___y_840_ = v_val_847_;
v___y_841_ = v___x_849_;
goto v___jp_839_;
}
else
{
uint8_t v___x_850_; 
lean_inc_ref(v_endS_829_);
v___x_850_ = l_Rat_instDecidableLe(v___x_848_, v_endS_829_);
v___y_840_ = v_val_847_;
v___y_841_ = v___x_850_;
goto v___jp_839_;
}
}
}
v___jp_853_:
{
if (v___y_854_ == 0)
{
lean_dec_ref(v_endS_829_);
lean_dec_ref(v_startS_828_);
lean_dec(v_val_826_);
return v___y_854_;
}
else
{
uint8_t v___x_855_; 
v___x_855_ = lp_ir_x2dproof_IRProof_containsString(v_endVertexId_832_, v_vertexIds_852_);
if (v___x_855_ == 0)
{
lean_dec_ref(v_endS_829_);
lean_dec_ref(v_startS_828_);
lean_dec(v_val_826_);
v___y_820_ = v___x_855_;
goto v___jp_819_;
}
else
{
if (v_forward_830_ == 0)
{
lean_object* v_snd_856_; uint8_t v___x_857_; 
v_snd_856_ = lean_ctor_get(v_head_817_, 1);
v___x_857_ = lean_unbox(v_snd_856_);
if (v___x_857_ == 0)
{
goto v___jp_844_;
}
else
{
lean_dec_ref(v_endS_829_);
lean_dec_ref(v_startS_828_);
lean_dec(v_val_826_);
return v_forward_830_;
}
}
else
{
lean_object* v_snd_858_; uint8_t v___x_859_; 
v_snd_858_ = lean_ctor_get(v_head_817_, 1);
v___x_859_ = lean_unbox(v_snd_858_);
if (v___x_859_ == 0)
{
uint8_t v___x_860_; 
lean_dec_ref(v_endS_829_);
lean_dec_ref(v_startS_828_);
lean_dec(v_val_826_);
v___x_860_ = lean_unbox(v_snd_858_);
return v___x_860_;
}
else
{
goto v___jp_844_;
}
}
}
}
}
}
v___jp_819_:
{
if (v___y_820_ == 0)
{
return v___y_820_;
}
else
{
v_x_815_ = v_tail_818_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__5___boxed(lean_object* v_g_863_, lean_object* v_route_864_, lean_object* v_x_865_){
_start:
{
uint8_t v_res_866_; lean_object* v_r_867_; 
v_res_866_ = lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__5(v_g_863_, v_route_864_, v_x_865_);
lean_dec(v_x_865_);
lean_dec_ref(v_route_864_);
lean_dec_ref(v_g_863_);
v_r_867_ = lean_box(v_res_866_);
return v_r_867_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeEdgeSetValid(lean_object* v_route_868_, lean_object* v_g_869_){
_start:
{
lean_object* v_graphRevision_870_; lean_object* v_splineIds_871_; lean_object* v_vertexIds_872_; lean_object* v_edgeIds_873_; lean_object* v_edgeDirections_874_; uint8_t v___y_876_; lean_object* v_revision_882_; uint8_t v___x_883_; 
v_graphRevision_870_ = lean_ctor_get(v_route_868_, 0);
v_splineIds_871_ = lean_ctor_get(v_route_868_, 1);
lean_inc(v_splineIds_871_);
v_vertexIds_872_ = lean_ctor_get(v_route_868_, 2);
lean_inc(v_vertexIds_872_);
v_edgeIds_873_ = lean_ctor_get(v_route_868_, 3);
v_edgeDirections_874_ = lean_ctor_get(v_route_868_, 4);
v_revision_882_ = lean_ctor_get(v_g_869_, 0);
v___x_883_ = lean_nat_dec_eq(v_graphRevision_870_, v_revision_882_);
if (v___x_883_ == 0)
{
v___y_876_ = v___x_883_;
goto v___jp_875_;
}
else
{
lean_object* v___x_884_; lean_object* v___x_885_; uint8_t v___x_886_; 
v___x_884_ = l_List_lengthTR___redArg(v_edgeIds_873_);
v___x_885_ = l_List_lengthTR___redArg(v_edgeDirections_874_);
v___x_886_ = lean_nat_dec_eq(v___x_884_, v___x_885_);
lean_dec(v___x_885_);
lean_dec(v___x_884_);
v___y_876_ = v___x_886_;
goto v___jp_875_;
}
v___jp_875_:
{
if (v___y_876_ == 0)
{
lean_dec(v_vertexIds_872_);
lean_dec(v_splineIds_871_);
lean_dec_ref(v_route_868_);
return v___y_876_;
}
else
{
lean_object* v___x_877_; uint8_t v___x_878_; 
lean_inc(v_edgeDirections_874_);
lean_inc(v_edgeIds_873_);
v___x_877_ = l_List_zipWith___at___00List_zip_spec__0___redArg(v_edgeIds_873_, v_edgeDirections_874_);
v___x_878_ = lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__5(v_g_869_, v_route_868_, v___x_877_);
if (v___x_878_ == 0)
{
lean_dec(v___x_877_);
lean_dec(v_vertexIds_872_);
lean_dec(v_splineIds_871_);
lean_dec_ref(v_route_868_);
return v___x_878_;
}
else
{
uint8_t v___x_879_; 
v___x_879_ = lp_ir_x2dproof_IRProof_routeChainValid(v_g_869_, v___x_877_);
lean_dec(v___x_877_);
if (v___x_879_ == 0)
{
lean_dec(v_vertexIds_872_);
lean_dec(v_splineIds_871_);
lean_dec_ref(v_route_868_);
return v___x_879_;
}
else
{
uint8_t v___x_880_; 
v___x_880_ = lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__6(v_g_869_, v_route_868_, v_vertexIds_872_);
lean_dec(v_vertexIds_872_);
lean_dec_ref(v_route_868_);
if (v___x_880_ == 0)
{
lean_dec(v_splineIds_871_);
return v___x_880_;
}
else
{
uint8_t v___x_881_; 
v___x_881_ = lp_ir_x2dproof_List_all___at___00IRProof_routeEdgeSetValid_spec__7(v_g_869_, v_splineIds_871_);
lean_dec(v_splineIds_871_);
return v___x_881_;
}
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeEdgeSetValid___boxed(lean_object* v_route_887_, lean_object* v_g_888_){
_start:
{
uint8_t v_res_889_; lean_object* v_r_890_; 
v_res_889_ = lp_ir_x2dproof_IRProof_routeEdgeSetValid(v_route_887_, v_g_888_);
lean_dec_ref(v_g_888_);
v_r_890_ = lean_box(v_res_889_);
return v_r_890_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeInvalidated(lean_object* v_oldRevision_891_, lean_object* v_newRevision_892_){
_start:
{
uint8_t v___x_893_; 
v___x_893_ = lean_nat_dec_eq(v_oldRevision_891_, v_newRevision_892_);
if (v___x_893_ == 0)
{
uint8_t v___x_894_; 
v___x_894_ = 1;
return v___x_894_;
}
else
{
uint8_t v___x_895_; 
v___x_895_ = 0;
return v___x_895_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeInvalidated___boxed(lean_object* v_oldRevision_896_, lean_object* v_newRevision_897_){
_start:
{
uint8_t v_res_898_; lean_object* v_r_899_; 
v_res_898_ = lp_ir_x2dproof_IRProof_routeInvalidated(v_oldRevision_896_, v_newRevision_897_);
lean_dec(v_newRevision_897_);
lean_dec(v_oldRevision_896_);
v_r_899_ = lean_box(v_res_898_);
return v_r_899_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorIdx(uint8_t v_x_900_){
_start:
{
if (v_x_900_ == 0)
{
lean_object* v___x_901_; 
v___x_901_ = lean_unsigned_to_nat(0u);
return v___x_901_;
}
else
{
lean_object* v___x_902_; 
v___x_902_ = lean_unsigned_to_nat(1u);
return v___x_902_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorIdx___boxed(lean_object* v_x_903_){
_start:
{
uint8_t v_x_boxed_904_; lean_object* v_res_905_; 
v_x_boxed_904_ = lean_unbox(v_x_903_);
v_res_905_ = lp_ir_x2dproof_IRProof_Approach_ctorIdx(v_x_boxed_904_);
return v_res_905_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_toCtorIdx(uint8_t v_x_906_){
_start:
{
lean_object* v___x_907_; 
v___x_907_ = lp_ir_x2dproof_IRProof_Approach_ctorIdx(v_x_906_);
return v___x_907_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_toCtorIdx___boxed(lean_object* v_x_908_){
_start:
{
uint8_t v_x_4__boxed_909_; lean_object* v_res_910_; 
v_x_4__boxed_909_ = lean_unbox(v_x_908_);
v_res_910_ = lp_ir_x2dproof_IRProof_Approach_toCtorIdx(v_x_4__boxed_909_);
return v_res_910_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim___redArg(lean_object* v_k_911_){
_start:
{
lean_inc(v_k_911_);
return v_k_911_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim___redArg___boxed(lean_object* v_k_912_){
_start:
{
lean_object* v_res_913_; 
v_res_913_ = lp_ir_x2dproof_IRProof_Approach_ctorElim___redArg(v_k_912_);
lean_dec(v_k_912_);
return v_res_913_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim(lean_object* v_motive_914_, lean_object* v_ctorIdx_915_, uint8_t v_t_916_, lean_object* v_h_917_, lean_object* v_k_918_){
_start:
{
lean_inc(v_k_918_);
return v_k_918_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ctorElim___boxed(lean_object* v_motive_919_, lean_object* v_ctorIdx_920_, lean_object* v_t_921_, lean_object* v_h_922_, lean_object* v_k_923_){
_start:
{
uint8_t v_t_boxed_924_; lean_object* v_res_925_; 
v_t_boxed_924_ = lean_unbox(v_t_921_);
v_res_925_ = lp_ir_x2dproof_IRProof_Approach_ctorElim(v_motive_919_, v_ctorIdx_920_, v_t_boxed_924_, v_h_922_, v_k_923_);
lean_dec(v_k_923_);
lean_dec(v_ctorIdx_920_);
return v_res_925_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim___redArg(lean_object* v_forward_926_){
_start:
{
lean_inc(v_forward_926_);
return v_forward_926_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim___redArg___boxed(lean_object* v_forward_927_){
_start:
{
lean_object* v_res_928_; 
v_res_928_ = lp_ir_x2dproof_IRProof_Approach_forward_elim___redArg(v_forward_927_);
lean_dec(v_forward_927_);
return v_res_928_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim(lean_object* v_motive_929_, uint8_t v_t_930_, lean_object* v_h_931_, lean_object* v_forward_932_){
_start:
{
lean_inc(v_forward_932_);
return v_forward_932_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_forward_elim___boxed(lean_object* v_motive_933_, lean_object* v_t_934_, lean_object* v_h_935_, lean_object* v_forward_936_){
_start:
{
uint8_t v_t_boxed_937_; lean_object* v_res_938_; 
v_t_boxed_937_ = lean_unbox(v_t_934_);
v_res_938_ = lp_ir_x2dproof_IRProof_Approach_forward_elim(v_motive_933_, v_t_boxed_937_, v_h_935_, v_forward_936_);
lean_dec(v_forward_936_);
return v_res_938_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim___redArg(lean_object* v_reverse_939_){
_start:
{
lean_inc(v_reverse_939_);
return v_reverse_939_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim___redArg___boxed(lean_object* v_reverse_940_){
_start:
{
lean_object* v_res_941_; 
v_res_941_ = lp_ir_x2dproof_IRProof_Approach_reverse_elim___redArg(v_reverse_940_);
lean_dec(v_reverse_940_);
return v_res_941_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim(lean_object* v_motive_942_, uint8_t v_t_943_, lean_object* v_h_944_, lean_object* v_reverse_945_){
_start:
{
lean_inc(v_reverse_945_);
return v_reverse_945_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_reverse_elim___boxed(lean_object* v_motive_946_, lean_object* v_t_947_, lean_object* v_h_948_, lean_object* v_reverse_949_){
_start:
{
uint8_t v_t_boxed_950_; lean_object* v_res_951_; 
v_t_boxed_950_ = lean_unbox(v_t_947_);
v_res_951_ = lp_ir_x2dproof_IRProof_Approach_reverse_elim(v_motive_946_, v_t_boxed_950_, v_h_948_, v_reverse_949_);
lean_dec(v_reverse_949_);
return v_res_951_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_Approach_ofNat(lean_object* v_n_952_){
_start:
{
lean_object* v___x_953_; uint8_t v___x_954_; 
v___x_953_ = lean_unsigned_to_nat(0u);
v___x_954_ = lean_nat_dec_le(v_n_952_, v___x_953_);
if (v___x_954_ == 0)
{
uint8_t v___x_955_; 
v___x_955_ = 1;
return v___x_955_;
}
else
{
uint8_t v___x_956_; 
v___x_956_ = 0;
return v___x_956_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_Approach_ofNat___boxed(lean_object* v_n_957_){
_start:
{
uint8_t v_res_958_; lean_object* v_r_959_; 
v_res_958_ = lp_ir_x2dproof_IRProof_Approach_ofNat(v_n_957_);
lean_dec(v_n_957_);
v_r_959_ = lean_box(v_res_958_);
return v_r_959_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqApproach(uint8_t v_x_960_, uint8_t v_y_961_){
_start:
{
lean_object* v___x_962_; lean_object* v___x_963_; uint8_t v___x_964_; 
v___x_962_ = lp_ir_x2dproof_IRProof_Approach_ctorIdx(v_x_960_);
v___x_963_ = lp_ir_x2dproof_IRProof_Approach_ctorIdx(v_y_961_);
v___x_964_ = lean_nat_dec_eq(v___x_962_, v___x_963_);
lean_dec(v___x_963_);
lean_dec(v___x_962_);
return v___x_964_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqApproach___boxed(lean_object* v_x_965_, lean_object* v_y_966_){
_start:
{
uint8_t v_x_13__boxed_967_; uint8_t v_y_14__boxed_968_; uint8_t v_res_969_; lean_object* v_r_970_; 
v_x_13__boxed_967_ = lean_unbox(v_x_965_);
v_y_14__boxed_968_ = lean_unbox(v_y_966_);
v_res_969_ = lp_ir_x2dproof_IRProof_instDecidableEqApproach(v_x_13__boxed_967_, v_y_14__boxed_968_);
v_r_970_ = lean_box(v_res_969_);
return v_r_970_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr(uint8_t v_x_977_, lean_object* v_prec_978_){
_start:
{
lean_object* v___y_980_; lean_object* v___y_987_; 
if (v_x_977_ == 0)
{
lean_object* v___x_993_; uint8_t v___x_994_; 
v___x_993_ = lean_unsigned_to_nat(1024u);
v___x_994_ = lean_nat_dec_le(v___x_993_, v_prec_978_);
if (v___x_994_ == 0)
{
lean_object* v___x_995_; 
v___x_995_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_980_ = v___x_995_;
goto v___jp_979_;
}
else
{
lean_object* v___x_996_; 
v___x_996_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_980_ = v___x_996_;
goto v___jp_979_;
}
}
else
{
lean_object* v___x_997_; uint8_t v___x_998_; 
v___x_997_ = lean_unsigned_to_nat(1024u);
v___x_998_ = lean_nat_dec_le(v___x_997_, v_prec_978_);
if (v___x_998_ == 0)
{
lean_object* v___x_999_; 
v___x_999_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_987_ = v___x_999_;
goto v___jp_986_;
}
else
{
lean_object* v___x_1000_; 
v___x_1000_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_987_ = v___x_1000_;
goto v___jp_986_;
}
}
v___jp_979_:
{
lean_object* v___x_981_; lean_object* v___x_982_; uint8_t v___x_983_; lean_object* v___x_984_; lean_object* v___x_985_; 
v___x_981_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__1));
lean_inc(v___y_980_);
v___x_982_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_982_, 0, v___y_980_);
lean_ctor_set(v___x_982_, 1, v___x_981_);
v___x_983_ = 0;
v___x_984_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_984_, 0, v___x_982_);
lean_ctor_set_uint8(v___x_984_, sizeof(void*)*1, v___x_983_);
v___x_985_ = l_Repr_addAppParen(v___x_984_, v_prec_978_);
return v___x_985_;
}
v___jp_986_:
{
lean_object* v___x_988_; lean_object* v___x_989_; uint8_t v___x_990_; lean_object* v___x_991_; lean_object* v___x_992_; 
v___x_988_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprApproach_repr___closed__3));
lean_inc(v___y_987_);
v___x_989_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_989_, 0, v___y_987_);
lean_ctor_set(v___x_989_, 1, v___x_988_);
v___x_990_ = 0;
v___x_991_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_991_, 0, v___x_989_);
lean_ctor_set_uint8(v___x_991_, sizeof(void*)*1, v___x_990_);
v___x_992_ = l_Repr_addAppParen(v___x_991_, v_prec_978_);
return v___x_992_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprApproach_repr___boxed(lean_object* v_x_1001_, lean_object* v_prec_1002_){
_start:
{
uint8_t v_x_117__boxed_1003_; lean_object* v_res_1004_; 
v_x_117__boxed_1003_ = lean_unbox(v_x_1001_);
v_res_1004_ = lp_ir_x2dproof_IRProof_instReprApproach_repr(v_x_117__boxed_1003_, v_prec_1002_);
lean_dec(v_prec_1002_);
return v_res_1004_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarker_decEq(lean_object* v_x_1007_, lean_object* v_x_1008_){
_start:
{
lean_object* v_markerId_1009_; lean_object* v_worldPosition_1010_; lean_object* v_toleranceSq_1011_; uint8_t v_configuredApproach_1012_; lean_object* v_kind_1013_; lean_object* v_markerId_1014_; lean_object* v_worldPosition_1015_; lean_object* v_toleranceSq_1016_; uint8_t v_configuredApproach_1017_; lean_object* v_kind_1018_; uint8_t v___x_1019_; 
v_markerId_1009_ = lean_ctor_get(v_x_1007_, 0);
v_worldPosition_1010_ = lean_ctor_get(v_x_1007_, 1);
v_toleranceSq_1011_ = lean_ctor_get(v_x_1007_, 2);
v_configuredApproach_1012_ = lean_ctor_get_uint8(v_x_1007_, sizeof(void*)*4);
v_kind_1013_ = lean_ctor_get(v_x_1007_, 3);
v_markerId_1014_ = lean_ctor_get(v_x_1008_, 0);
v_worldPosition_1015_ = lean_ctor_get(v_x_1008_, 1);
v_toleranceSq_1016_ = lean_ctor_get(v_x_1008_, 2);
v_configuredApproach_1017_ = lean_ctor_get_uint8(v_x_1008_, sizeof(void*)*4);
v_kind_1018_ = lean_ctor_get(v_x_1008_, 3);
v___x_1019_ = lean_string_dec_eq(v_markerId_1009_, v_markerId_1014_);
if (v___x_1019_ == 0)
{
return v___x_1019_;
}
else
{
uint8_t v___x_1020_; 
v___x_1020_ = lp_ir_x2dproof_IRProof_instDecidableEqVec3_decEq(v_worldPosition_1010_, v_worldPosition_1015_);
if (v___x_1020_ == 0)
{
return v___x_1020_;
}
else
{
uint8_t v___x_1021_; 
v___x_1021_ = l_instDecidableEqRat_decEq(v_toleranceSq_1011_, v_toleranceSq_1016_);
if (v___x_1021_ == 0)
{
return v___x_1021_;
}
else
{
uint8_t v___x_1022_; 
v___x_1022_ = lp_ir_x2dproof_IRProof_instDecidableEqApproach(v_configuredApproach_1012_, v_configuredApproach_1017_);
if (v___x_1022_ == 0)
{
return v___x_1022_;
}
else
{
uint8_t v___x_1023_; 
v___x_1023_ = lean_string_dec_eq(v_kind_1013_, v_kind_1018_);
return v___x_1023_;
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarker_decEq___boxed(lean_object* v_x_1024_, lean_object* v_x_1025_){
_start:
{
uint8_t v_res_1026_; lean_object* v_r_1027_; 
v_res_1026_ = lp_ir_x2dproof_IRProof_instDecidableEqMarker_decEq(v_x_1024_, v_x_1025_);
lean_dec_ref(v_x_1025_);
lean_dec_ref(v_x_1024_);
v_r_1027_ = lean_box(v_res_1026_);
return v_r_1027_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarker(lean_object* v_x_1028_, lean_object* v_x_1029_){
_start:
{
uint8_t v___x_1030_; 
v___x_1030_ = lp_ir_x2dproof_IRProof_instDecidableEqMarker_decEq(v_x_1028_, v_x_1029_);
return v___x_1030_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarker___boxed(lean_object* v_x_1031_, lean_object* v_x_1032_){
_start:
{
uint8_t v_res_1033_; lean_object* v_r_1034_; 
v_res_1033_ = lp_ir_x2dproof_IRProof_instDecidableEqMarker(v_x_1031_, v_x_1032_);
lean_dec_ref(v_x_1032_);
lean_dec_ref(v_x_1031_);
v_r_1034_ = lean_box(v_res_1033_);
return v_r_1034_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping_decEq(lean_object* v_x_1035_, lean_object* v_x_1036_){
_start:
{
lean_object* v_marker_1037_; lean_object* v_splineId_1038_; lean_object* v_s_1039_; lean_object* v_measuredDistanceSq_1040_; lean_object* v_marker_1041_; lean_object* v_splineId_1042_; lean_object* v_s_1043_; lean_object* v_measuredDistanceSq_1044_; uint8_t v___x_1045_; 
v_marker_1037_ = lean_ctor_get(v_x_1035_, 0);
v_splineId_1038_ = lean_ctor_get(v_x_1035_, 1);
v_s_1039_ = lean_ctor_get(v_x_1035_, 2);
v_measuredDistanceSq_1040_ = lean_ctor_get(v_x_1035_, 3);
v_marker_1041_ = lean_ctor_get(v_x_1036_, 0);
v_splineId_1042_ = lean_ctor_get(v_x_1036_, 1);
v_s_1043_ = lean_ctor_get(v_x_1036_, 2);
v_measuredDistanceSq_1044_ = lean_ctor_get(v_x_1036_, 3);
v___x_1045_ = lp_ir_x2dproof_IRProof_instDecidableEqMarker_decEq(v_marker_1037_, v_marker_1041_);
if (v___x_1045_ == 0)
{
return v___x_1045_;
}
else
{
uint8_t v___x_1046_; 
v___x_1046_ = lean_string_dec_eq(v_splineId_1038_, v_splineId_1042_);
if (v___x_1046_ == 0)
{
return v___x_1046_;
}
else
{
uint8_t v___x_1047_; 
v___x_1047_ = l_instDecidableEqRat_decEq(v_s_1039_, v_s_1043_);
if (v___x_1047_ == 0)
{
return v___x_1047_;
}
else
{
uint8_t v___x_1048_; 
v___x_1048_ = l_instDecidableEqRat_decEq(v_measuredDistanceSq_1040_, v_measuredDistanceSq_1044_);
return v___x_1048_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping_decEq___boxed(lean_object* v_x_1049_, lean_object* v_x_1050_){
_start:
{
uint8_t v_res_1051_; lean_object* v_r_1052_; 
v_res_1051_ = lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping_decEq(v_x_1049_, v_x_1050_);
lean_dec_ref(v_x_1050_);
lean_dec_ref(v_x_1049_);
v_r_1052_ = lean_box(v_res_1051_);
return v_r_1052_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping(lean_object* v_x_1053_, lean_object* v_x_1054_){
_start:
{
uint8_t v___x_1055_; 
v___x_1055_ = lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping_decEq(v_x_1053_, v_x_1054_);
return v___x_1055_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping___boxed(lean_object* v_x_1056_, lean_object* v_x_1057_){
_start:
{
uint8_t v_res_1058_; lean_object* v_r_1059_; 
v_res_1058_ = lp_ir_x2dproof_IRProof_instDecidableEqMarkerMapping(v_x_1056_, v_x_1057_);
lean_dec_ref(v_x_1057_);
lean_dec_ref(v_x_1056_);
v_r_1059_ = lean_box(v_res_1058_);
return v_r_1059_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_mapMarker(lean_object* v_m_1060_, lean_object* v_sid_1061_, lean_object* v_s_1062_, lean_object* v_distanceSq_1063_){
_start:
{
lean_object* v_toleranceSq_1064_; uint8_t v___x_1065_; 
v_toleranceSq_1064_ = lean_ctor_get(v_m_1060_, 2);
lean_inc_ref(v_toleranceSq_1064_);
lean_inc_ref(v_distanceSq_1063_);
v___x_1065_ = l_Rat_instDecidableLe(v_distanceSq_1063_, v_toleranceSq_1064_);
if (v___x_1065_ == 0)
{
lean_object* v___x_1066_; 
lean_dec_ref(v_distanceSq_1063_);
lean_dec_ref(v_s_1062_);
lean_dec_ref(v_sid_1061_);
lean_dec_ref(v_m_1060_);
v___x_1066_ = lean_box(0);
return v___x_1066_;
}
else
{
lean_object* v___x_1067_; lean_object* v___x_1068_; 
v___x_1067_ = lean_alloc_ctor(0, 4, 0);
lean_ctor_set(v___x_1067_, 0, v_m_1060_);
lean_ctor_set(v___x_1067_, 1, v_sid_1061_);
lean_ctor_set(v___x_1067_, 2, v_s_1062_);
lean_ctor_set(v___x_1067_, 3, v_distanceSq_1063_);
v___x_1068_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_1068_, 0, v___x_1067_);
return v___x_1068_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stockKey(lean_object* v_s_1070_){
_start:
{
lean_object* v_stockUuid_1071_; lean_object* v_definitionId_1072_; lean_object* v___x_1073_; lean_object* v___x_1074_; lean_object* v___x_1075_; 
v_stockUuid_1071_ = lean_ctor_get(v_s_1070_, 0);
lean_inc_ref(v_stockUuid_1071_);
v_definitionId_1072_ = lean_ctor_get(v_s_1070_, 1);
lean_inc_ref(v_definitionId_1072_);
lean_dec_ref(v_s_1070_);
v___x_1073_ = ((lean_object*)(lp_ir_x2dproof_IRProof_stockKey___closed__0));
v___x_1074_ = lean_string_append(v_stockUuid_1071_, v___x_1073_);
v___x_1075_ = lean_string_append(v___x_1074_, v_definitionId_1072_);
lean_dec_ref(v_definitionId_1072_);
return v___x_1075_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profileKeys_spec__0(lean_object* v_a_1076_, lean_object* v_a_1077_){
_start:
{
if (lean_obj_tag(v_a_1076_) == 0)
{
lean_object* v___x_1078_; 
v___x_1078_ = l_List_reverse___redArg(v_a_1077_);
return v___x_1078_;
}
else
{
lean_object* v_head_1079_; lean_object* v_tail_1080_; lean_object* v___x_1082_; uint8_t v_isShared_1083_; uint8_t v_isSharedCheck_1089_; 
v_head_1079_ = lean_ctor_get(v_a_1076_, 0);
v_tail_1080_ = lean_ctor_get(v_a_1076_, 1);
v_isSharedCheck_1089_ = !lean_is_exclusive(v_a_1076_);
if (v_isSharedCheck_1089_ == 0)
{
v___x_1082_ = v_a_1076_;
v_isShared_1083_ = v_isSharedCheck_1089_;
goto v_resetjp_1081_;
}
else
{
lean_inc(v_tail_1080_);
lean_inc(v_head_1079_);
lean_dec(v_a_1076_);
v___x_1082_ = lean_box(0);
v_isShared_1083_ = v_isSharedCheck_1089_;
goto v_resetjp_1081_;
}
v_resetjp_1081_:
{
lean_object* v___x_1084_; lean_object* v___x_1086_; 
v___x_1084_ = lp_ir_x2dproof_IRProof_stockKey(v_head_1079_);
if (v_isShared_1083_ == 0)
{
lean_ctor_set(v___x_1082_, 1, v_a_1077_);
lean_ctor_set(v___x_1082_, 0, v___x_1084_);
v___x_1086_ = v___x_1082_;
goto v_reusejp_1085_;
}
else
{
lean_object* v_reuseFailAlloc_1088_; 
v_reuseFailAlloc_1088_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_1088_, 0, v___x_1084_);
lean_ctor_set(v_reuseFailAlloc_1088_, 1, v_a_1077_);
v___x_1086_ = v_reuseFailAlloc_1088_;
goto v_reusejp_1085_;
}
v_reusejp_1085_:
{
v_a_1076_ = v_tail_1080_;
v_a_1077_ = v___x_1086_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileKeys(lean_object* v_xs_1090_){
_start:
{
lean_object* v___x_1091_; lean_object* v___x_1092_; 
v___x_1091_ = lean_box(0);
v___x_1092_ = lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profileKeys_spec__0(v_xs_1090_, v___x_1091_);
return v___x_1092_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint_decEq(lean_object* v_x_1093_, lean_object* v_x_1094_){
_start:
{
lean_object* v_stockUuid_1095_; lean_object* v_definitionId_1096_; lean_object* v_weightKg_1097_; uint8_t v_direction_1098_; lean_object* v_speedMps_1099_; lean_object* v_brakeSystemEfficiency_1100_; lean_object* v_brakeAdhesionEfficiency_1101_; lean_object* v_brakeMultiplier_1102_; uint8_t v_hasTrainBrake_1103_; uint8_t v_hasIndependentBrake_1104_; lean_object* v_tractiveEffortN_1105_; uint8_t v_cogging_1106_; lean_object* v_stockUuid_1107_; lean_object* v_definitionId_1108_; lean_object* v_weightKg_1109_; uint8_t v_direction_1110_; lean_object* v_speedMps_1111_; lean_object* v_brakeSystemEfficiency_1112_; lean_object* v_brakeAdhesionEfficiency_1113_; lean_object* v_brakeMultiplier_1114_; uint8_t v_hasTrainBrake_1115_; uint8_t v_hasIndependentBrake_1116_; lean_object* v_tractiveEffortN_1117_; uint8_t v_cogging_1118_; uint8_t v___x_1123_; 
v_stockUuid_1095_ = lean_ctor_get(v_x_1093_, 0);
lean_inc_ref(v_stockUuid_1095_);
v_definitionId_1096_ = lean_ctor_get(v_x_1093_, 1);
lean_inc_ref(v_definitionId_1096_);
v_weightKg_1097_ = lean_ctor_get(v_x_1093_, 2);
lean_inc_ref(v_weightKg_1097_);
v_direction_1098_ = lean_ctor_get_uint8(v_x_1093_, sizeof(void*)*8);
v_speedMps_1099_ = lean_ctor_get(v_x_1093_, 3);
lean_inc_ref(v_speedMps_1099_);
v_brakeSystemEfficiency_1100_ = lean_ctor_get(v_x_1093_, 4);
lean_inc_ref(v_brakeSystemEfficiency_1100_);
v_brakeAdhesionEfficiency_1101_ = lean_ctor_get(v_x_1093_, 5);
lean_inc_ref(v_brakeAdhesionEfficiency_1101_);
v_brakeMultiplier_1102_ = lean_ctor_get(v_x_1093_, 6);
lean_inc_ref(v_brakeMultiplier_1102_);
v_hasTrainBrake_1103_ = lean_ctor_get_uint8(v_x_1093_, sizeof(void*)*8 + 1);
v_hasIndependentBrake_1104_ = lean_ctor_get_uint8(v_x_1093_, sizeof(void*)*8 + 2);
v_tractiveEffortN_1105_ = lean_ctor_get(v_x_1093_, 7);
lean_inc(v_tractiveEffortN_1105_);
v_cogging_1106_ = lean_ctor_get_uint8(v_x_1093_, sizeof(void*)*8 + 3);
lean_dec_ref(v_x_1093_);
v_stockUuid_1107_ = lean_ctor_get(v_x_1094_, 0);
lean_inc_ref(v_stockUuid_1107_);
v_definitionId_1108_ = lean_ctor_get(v_x_1094_, 1);
lean_inc_ref(v_definitionId_1108_);
v_weightKg_1109_ = lean_ctor_get(v_x_1094_, 2);
lean_inc_ref(v_weightKg_1109_);
v_direction_1110_ = lean_ctor_get_uint8(v_x_1094_, sizeof(void*)*8);
v_speedMps_1111_ = lean_ctor_get(v_x_1094_, 3);
lean_inc_ref(v_speedMps_1111_);
v_brakeSystemEfficiency_1112_ = lean_ctor_get(v_x_1094_, 4);
lean_inc_ref(v_brakeSystemEfficiency_1112_);
v_brakeAdhesionEfficiency_1113_ = lean_ctor_get(v_x_1094_, 5);
lean_inc_ref(v_brakeAdhesionEfficiency_1113_);
v_brakeMultiplier_1114_ = lean_ctor_get(v_x_1094_, 6);
lean_inc_ref(v_brakeMultiplier_1114_);
v_hasTrainBrake_1115_ = lean_ctor_get_uint8(v_x_1094_, sizeof(void*)*8 + 1);
v_hasIndependentBrake_1116_ = lean_ctor_get_uint8(v_x_1094_, sizeof(void*)*8 + 2);
v_tractiveEffortN_1117_ = lean_ctor_get(v_x_1094_, 7);
lean_inc(v_tractiveEffortN_1117_);
v_cogging_1118_ = lean_ctor_get_uint8(v_x_1094_, sizeof(void*)*8 + 3);
lean_dec_ref(v_x_1094_);
v___x_1123_ = lean_string_dec_eq(v_stockUuid_1095_, v_stockUuid_1107_);
lean_dec_ref(v_stockUuid_1107_);
lean_dec_ref(v_stockUuid_1095_);
if (v___x_1123_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeAdhesionEfficiency_1113_);
lean_dec_ref(v_brakeSystemEfficiency_1112_);
lean_dec_ref(v_speedMps_1111_);
lean_dec_ref(v_weightKg_1109_);
lean_dec_ref(v_definitionId_1108_);
lean_dec(v_tractiveEffortN_1105_);
lean_dec_ref(v_brakeMultiplier_1102_);
lean_dec_ref(v_brakeAdhesionEfficiency_1101_);
lean_dec_ref(v_brakeSystemEfficiency_1100_);
lean_dec_ref(v_speedMps_1099_);
lean_dec_ref(v_weightKg_1097_);
lean_dec_ref(v_definitionId_1096_);
return v___x_1123_;
}
else
{
uint8_t v___x_1124_; 
v___x_1124_ = lean_string_dec_eq(v_definitionId_1096_, v_definitionId_1108_);
lean_dec_ref(v_definitionId_1108_);
lean_dec_ref(v_definitionId_1096_);
if (v___x_1124_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeAdhesionEfficiency_1113_);
lean_dec_ref(v_brakeSystemEfficiency_1112_);
lean_dec_ref(v_speedMps_1111_);
lean_dec_ref(v_weightKg_1109_);
lean_dec(v_tractiveEffortN_1105_);
lean_dec_ref(v_brakeMultiplier_1102_);
lean_dec_ref(v_brakeAdhesionEfficiency_1101_);
lean_dec_ref(v_brakeSystemEfficiency_1100_);
lean_dec_ref(v_speedMps_1099_);
lean_dec_ref(v_weightKg_1097_);
return v___x_1124_;
}
else
{
uint8_t v___x_1125_; 
v___x_1125_ = l_instDecidableEqRat_decEq(v_weightKg_1097_, v_weightKg_1109_);
lean_dec_ref(v_weightKg_1109_);
lean_dec_ref(v_weightKg_1097_);
if (v___x_1125_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeAdhesionEfficiency_1113_);
lean_dec_ref(v_brakeSystemEfficiency_1112_);
lean_dec_ref(v_speedMps_1111_);
lean_dec(v_tractiveEffortN_1105_);
lean_dec_ref(v_brakeMultiplier_1102_);
lean_dec_ref(v_brakeAdhesionEfficiency_1101_);
lean_dec_ref(v_brakeSystemEfficiency_1100_);
lean_dec_ref(v_speedMps_1099_);
return v___x_1125_;
}
else
{
uint8_t v___x_1126_; 
v___x_1126_ = lp_ir_x2dproof_IRProof_instDecidableEqApproach(v_direction_1098_, v_direction_1110_);
if (v___x_1126_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeAdhesionEfficiency_1113_);
lean_dec_ref(v_brakeSystemEfficiency_1112_);
lean_dec_ref(v_speedMps_1111_);
lean_dec(v_tractiveEffortN_1105_);
lean_dec_ref(v_brakeMultiplier_1102_);
lean_dec_ref(v_brakeAdhesionEfficiency_1101_);
lean_dec_ref(v_brakeSystemEfficiency_1100_);
lean_dec_ref(v_speedMps_1099_);
return v___x_1126_;
}
else
{
uint8_t v___x_1127_; 
v___x_1127_ = l_instDecidableEqRat_decEq(v_speedMps_1099_, v_speedMps_1111_);
lean_dec_ref(v_speedMps_1111_);
lean_dec_ref(v_speedMps_1099_);
if (v___x_1127_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeAdhesionEfficiency_1113_);
lean_dec_ref(v_brakeSystemEfficiency_1112_);
lean_dec(v_tractiveEffortN_1105_);
lean_dec_ref(v_brakeMultiplier_1102_);
lean_dec_ref(v_brakeAdhesionEfficiency_1101_);
lean_dec_ref(v_brakeSystemEfficiency_1100_);
return v___x_1127_;
}
else
{
uint8_t v___x_1128_; 
v___x_1128_ = l_instDecidableEqRat_decEq(v_brakeSystemEfficiency_1100_, v_brakeSystemEfficiency_1112_);
lean_dec_ref(v_brakeSystemEfficiency_1112_);
lean_dec_ref(v_brakeSystemEfficiency_1100_);
if (v___x_1128_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeAdhesionEfficiency_1113_);
lean_dec(v_tractiveEffortN_1105_);
lean_dec_ref(v_brakeMultiplier_1102_);
lean_dec_ref(v_brakeAdhesionEfficiency_1101_);
return v___x_1128_;
}
else
{
uint8_t v___x_1129_; 
v___x_1129_ = l_instDecidableEqRat_decEq(v_brakeAdhesionEfficiency_1101_, v_brakeAdhesionEfficiency_1113_);
lean_dec_ref(v_brakeAdhesionEfficiency_1113_);
lean_dec_ref(v_brakeAdhesionEfficiency_1101_);
if (v___x_1129_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec(v_tractiveEffortN_1105_);
lean_dec_ref(v_brakeMultiplier_1102_);
return v___x_1129_;
}
else
{
uint8_t v___x_1130_; 
v___x_1130_ = l_instDecidableEqRat_decEq(v_brakeMultiplier_1102_, v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeMultiplier_1114_);
lean_dec_ref(v_brakeMultiplier_1102_);
if (v___x_1130_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec(v_tractiveEffortN_1105_);
return v___x_1130_;
}
else
{
if (v_hasTrainBrake_1103_ == 0)
{
if (v_hasTrainBrake_1115_ == 0)
{
goto v___jp_1122_;
}
else
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec(v_tractiveEffortN_1105_);
return v_hasTrainBrake_1103_;
}
}
else
{
if (v_hasTrainBrake_1115_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec(v_tractiveEffortN_1105_);
return v_hasTrainBrake_1115_;
}
else
{
goto v___jp_1122_;
}
}
}
}
}
}
}
}
}
}
v___jp_1119_:
{
lean_object* v___x_1120_; uint8_t v___x_1121_; 
v___x_1120_ = lean_alloc_closure((void*)(l_instDecidableEqRat___boxed), 2, 0);
v___x_1121_ = l_Option_instDecidableEq___redArg(v___x_1120_, v_tractiveEffortN_1105_, v_tractiveEffortN_1117_);
if (v___x_1121_ == 0)
{
return v___x_1121_;
}
else
{
if (v_cogging_1106_ == 0)
{
if (v_cogging_1118_ == 0)
{
return v___x_1121_;
}
else
{
return v_cogging_1106_;
}
}
else
{
return v_cogging_1118_;
}
}
}
v___jp_1122_:
{
if (v_hasIndependentBrake_1104_ == 0)
{
if (v_hasIndependentBrake_1116_ == 0)
{
goto v___jp_1119_;
}
else
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec(v_tractiveEffortN_1105_);
return v_hasIndependentBrake_1104_;
}
}
else
{
if (v_hasIndependentBrake_1116_ == 0)
{
lean_dec(v_tractiveEffortN_1117_);
lean_dec(v_tractiveEffortN_1105_);
return v_hasIndependentBrake_1116_;
}
else
{
goto v___jp_1119_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint_decEq___boxed(lean_object* v_x_1131_, lean_object* v_x_1132_){
_start:
{
uint8_t v_res_1133_; lean_object* v_r_1134_; 
v_res_1133_ = lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint_decEq(v_x_1131_, v_x_1132_);
v_r_1134_ = lean_box(v_res_1133_);
return v_r_1134_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint(lean_object* v_x_1135_, lean_object* v_x_1136_){
_start:
{
uint8_t v___x_1137_; 
v___x_1137_ = lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint_decEq(v_x_1135_, v_x_1136_);
return v___x_1137_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint___boxed(lean_object* v_x_1138_, lean_object* v_x_1139_){
_start:
{
uint8_t v_res_1140_; lean_object* v_r_1141_; 
v_res_1140_ = lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint(v_x_1138_, v_x_1139_);
v_r_1141_ = lean_box(v_res_1140_);
return v_r_1141_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileFingerprint(lean_object* v_s_1142_){
_start:
{
lean_object* v_stockUuid_1143_; lean_object* v_definitionId_1144_; lean_object* v_weightKg_1145_; uint8_t v_direction_1146_; lean_object* v_speedMps_1147_; lean_object* v_brakeSystemEfficiency_1148_; lean_object* v_brakeAdhesionEfficiency_1149_; lean_object* v_brakeMultiplier_1150_; uint8_t v_hasTrainBrake_1151_; uint8_t v_hasIndependentBrake_1152_; lean_object* v_tractiveEffortN_1153_; uint8_t v_cogging_1154_; lean_object* v___x_1156_; uint8_t v_isShared_1157_; uint8_t v_isSharedCheck_1161_; 
v_stockUuid_1143_ = lean_ctor_get(v_s_1142_, 0);
v_definitionId_1144_ = lean_ctor_get(v_s_1142_, 1);
v_weightKg_1145_ = lean_ctor_get(v_s_1142_, 2);
v_direction_1146_ = lean_ctor_get_uint8(v_s_1142_, sizeof(void*)*8);
v_speedMps_1147_ = lean_ctor_get(v_s_1142_, 3);
v_brakeSystemEfficiency_1148_ = lean_ctor_get(v_s_1142_, 4);
v_brakeAdhesionEfficiency_1149_ = lean_ctor_get(v_s_1142_, 5);
v_brakeMultiplier_1150_ = lean_ctor_get(v_s_1142_, 6);
v_hasTrainBrake_1151_ = lean_ctor_get_uint8(v_s_1142_, sizeof(void*)*8 + 1);
v_hasIndependentBrake_1152_ = lean_ctor_get_uint8(v_s_1142_, sizeof(void*)*8 + 2);
v_tractiveEffortN_1153_ = lean_ctor_get(v_s_1142_, 7);
v_cogging_1154_ = lean_ctor_get_uint8(v_s_1142_, sizeof(void*)*8 + 3);
v_isSharedCheck_1161_ = !lean_is_exclusive(v_s_1142_);
if (v_isSharedCheck_1161_ == 0)
{
v___x_1156_ = v_s_1142_;
v_isShared_1157_ = v_isSharedCheck_1161_;
goto v_resetjp_1155_;
}
else
{
lean_inc(v_tractiveEffortN_1153_);
lean_inc(v_brakeMultiplier_1150_);
lean_inc(v_brakeAdhesionEfficiency_1149_);
lean_inc(v_brakeSystemEfficiency_1148_);
lean_inc(v_speedMps_1147_);
lean_inc(v_weightKg_1145_);
lean_inc(v_definitionId_1144_);
lean_inc(v_stockUuid_1143_);
lean_dec(v_s_1142_);
v___x_1156_ = lean_box(0);
v_isShared_1157_ = v_isSharedCheck_1161_;
goto v_resetjp_1155_;
}
v_resetjp_1155_:
{
lean_object* v___x_1159_; 
if (v_isShared_1157_ == 0)
{
v___x_1159_ = v___x_1156_;
goto v_reusejp_1158_;
}
else
{
lean_object* v_reuseFailAlloc_1160_; 
v_reuseFailAlloc_1160_ = lean_alloc_ctor(0, 8, 4);
lean_ctor_set(v_reuseFailAlloc_1160_, 0, v_stockUuid_1143_);
lean_ctor_set(v_reuseFailAlloc_1160_, 1, v_definitionId_1144_);
lean_ctor_set(v_reuseFailAlloc_1160_, 2, v_weightKg_1145_);
lean_ctor_set(v_reuseFailAlloc_1160_, 3, v_speedMps_1147_);
lean_ctor_set(v_reuseFailAlloc_1160_, 4, v_brakeSystemEfficiency_1148_);
lean_ctor_set(v_reuseFailAlloc_1160_, 5, v_brakeAdhesionEfficiency_1149_);
lean_ctor_set(v_reuseFailAlloc_1160_, 6, v_brakeMultiplier_1150_);
lean_ctor_set(v_reuseFailAlloc_1160_, 7, v_tractiveEffortN_1153_);
lean_ctor_set_uint8(v_reuseFailAlloc_1160_, sizeof(void*)*8, v_direction_1146_);
lean_ctor_set_uint8(v_reuseFailAlloc_1160_, sizeof(void*)*8 + 1, v_hasTrainBrake_1151_);
lean_ctor_set_uint8(v_reuseFailAlloc_1160_, sizeof(void*)*8 + 2, v_hasIndependentBrake_1152_);
lean_ctor_set_uint8(v_reuseFailAlloc_1160_, sizeof(void*)*8 + 3, v_cogging_1154_);
v___x_1159_ = v_reuseFailAlloc_1160_;
goto v_reusejp_1158_;
}
v_reusejp_1158_:
{
return v___x_1159_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profileFingerprints_spec__0(lean_object* v_a_1162_, lean_object* v_a_1163_){
_start:
{
if (lean_obj_tag(v_a_1162_) == 0)
{
lean_object* v___x_1164_; 
v___x_1164_ = l_List_reverse___redArg(v_a_1163_);
return v___x_1164_;
}
else
{
lean_object* v_head_1165_; lean_object* v_tail_1166_; lean_object* v___x_1168_; uint8_t v_isShared_1169_; uint8_t v_isSharedCheck_1175_; 
v_head_1165_ = lean_ctor_get(v_a_1162_, 0);
v_tail_1166_ = lean_ctor_get(v_a_1162_, 1);
v_isSharedCheck_1175_ = !lean_is_exclusive(v_a_1162_);
if (v_isSharedCheck_1175_ == 0)
{
v___x_1168_ = v_a_1162_;
v_isShared_1169_ = v_isSharedCheck_1175_;
goto v_resetjp_1167_;
}
else
{
lean_inc(v_tail_1166_);
lean_inc(v_head_1165_);
lean_dec(v_a_1162_);
v___x_1168_ = lean_box(0);
v_isShared_1169_ = v_isSharedCheck_1175_;
goto v_resetjp_1167_;
}
v_resetjp_1167_:
{
lean_object* v___x_1170_; lean_object* v___x_1172_; 
v___x_1170_ = lp_ir_x2dproof_IRProof_profileFingerprint(v_head_1165_);
if (v_isShared_1169_ == 0)
{
lean_ctor_set(v___x_1168_, 1, v_a_1163_);
lean_ctor_set(v___x_1168_, 0, v___x_1170_);
v___x_1172_ = v___x_1168_;
goto v_reusejp_1171_;
}
else
{
lean_object* v_reuseFailAlloc_1174_; 
v_reuseFailAlloc_1174_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_1174_, 0, v___x_1170_);
lean_ctor_set(v_reuseFailAlloc_1174_, 1, v_a_1163_);
v___x_1172_ = v_reuseFailAlloc_1174_;
goto v_reusejp_1171_;
}
v_reusejp_1171_:
{
v_a_1162_ = v_tail_1166_;
v_a_1163_ = v___x_1172_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileFingerprints(lean_object* v_xs_1176_){
_start:
{
lean_object* v___x_1177_; lean_object* v___x_1178_; 
v___x_1177_ = lean_box(0);
v___x_1178_ = lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profileFingerprints_spec__0(v_xs_1176_, v___x_1177_);
return v___x_1178_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_List_beq___at___00IRProof_profileMismatch_spec__0(lean_object* v_x_1179_, lean_object* v_x_1180_){
_start:
{
if (lean_obj_tag(v_x_1179_) == 0)
{
if (lean_obj_tag(v_x_1180_) == 0)
{
uint8_t v___x_1181_; 
v___x_1181_ = 1;
return v___x_1181_;
}
else
{
uint8_t v___x_1182_; 
lean_dec_ref_known(v_x_1180_, 2);
v___x_1182_ = 0;
return v___x_1182_;
}
}
else
{
if (lean_obj_tag(v_x_1180_) == 0)
{
uint8_t v___x_1183_; 
lean_dec_ref_known(v_x_1179_, 2);
v___x_1183_ = 0;
return v___x_1183_;
}
else
{
lean_object* v_head_1184_; lean_object* v_tail_1185_; lean_object* v_head_1186_; lean_object* v_tail_1187_; uint8_t v___x_1188_; 
v_head_1184_ = lean_ctor_get(v_x_1179_, 0);
lean_inc(v_head_1184_);
v_tail_1185_ = lean_ctor_get(v_x_1179_, 1);
lean_inc(v_tail_1185_);
lean_dec_ref_known(v_x_1179_, 2);
v_head_1186_ = lean_ctor_get(v_x_1180_, 0);
lean_inc(v_head_1186_);
v_tail_1187_ = lean_ctor_get(v_x_1180_, 1);
lean_inc(v_tail_1187_);
lean_dec_ref_known(v_x_1180_, 2);
v___x_1188_ = lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint_decEq(v_head_1184_, v_head_1186_);
if (v___x_1188_ == 0)
{
lean_dec(v_tail_1187_);
lean_dec(v_tail_1185_);
return v___x_1188_;
}
else
{
v_x_1179_ = v_tail_1185_;
v_x_1180_ = v_tail_1187_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_beq___at___00IRProof_profileMismatch_spec__0___boxed(lean_object* v_x_1190_, lean_object* v_x_1191_){
_start:
{
uint8_t v_res_1192_; lean_object* v_r_1193_; 
v_res_1192_ = lp_ir_x2dproof_List_beq___at___00IRProof_profileMismatch_spec__0(v_x_1190_, v_x_1191_);
v_r_1193_ = lean_box(v_res_1192_);
return v_r_1193_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_profileMismatch(lean_object* v_expected_1194_, lean_object* v_actual_1195_){
_start:
{
lean_object* v___x_1196_; lean_object* v___x_1197_; uint8_t v___x_1198_; 
v___x_1196_ = lp_ir_x2dproof_IRProof_profileFingerprints(v_expected_1194_);
v___x_1197_ = lp_ir_x2dproof_IRProof_profileFingerprints(v_actual_1195_);
v___x_1198_ = lp_ir_x2dproof_List_beq___at___00IRProof_profileMismatch_spec__0(v___x_1196_, v___x_1197_);
if (v___x_1198_ == 0)
{
uint8_t v___x_1199_; 
v___x_1199_ = 1;
return v___x_1199_;
}
else
{
uint8_t v___x_1200_; 
v___x_1200_ = 0;
return v___x_1200_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profileMismatch___boxed(lean_object* v_expected_1201_, lean_object* v_actual_1202_){
_start:
{
uint8_t v_res_1203_; lean_object* v_r_1204_; 
v_res_1203_ = lp_ir_x2dproof_IRProof_profileMismatch(v_expected_1201_, v_actual_1202_);
v_r_1204_ = lean_box(v_res_1203_);
return v_r_1204_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_catalogueOne(lean_object* v_event_1206_, lean_object* v_info_1207_, lean_object* v_catalogue_1208_){
_start:
{
uint8_t v___y_1210_; lean_object* v_stockUuid_1214_; lean_object* v_eventName_1215_; lean_object* v___x_1216_; uint8_t v___x_1217_; 
v_stockUuid_1214_ = lean_ctor_get(v_event_1206_, 0);
v_eventName_1215_ = lean_ctor_get(v_event_1206_, 1);
v___x_1216_ = ((lean_object*)(lp_ir_x2dproof_IRProof_catalogueOne___closed__0));
v___x_1217_ = lean_string_dec_eq(v_eventName_1215_, v___x_1216_);
if (v___x_1217_ == 0)
{
v___y_1210_ = v___x_1217_;
goto v___jp_1209_;
}
else
{
lean_object* v_stockUuid_1218_; uint8_t v___x_1219_; 
v_stockUuid_1218_ = lean_ctor_get(v_info_1207_, 0);
v___x_1219_ = lean_string_dec_eq(v_stockUuid_1214_, v_stockUuid_1218_);
v___y_1210_ = v___x_1219_;
goto v___jp_1209_;
}
v___jp_1209_:
{
if (v___y_1210_ == 0)
{
lean_dec_ref(v_info_1207_);
return v_catalogue_1208_;
}
else
{
lean_object* v___x_1211_; lean_object* v___x_1212_; lean_object* v___x_1213_; 
v___x_1211_ = lean_box(0);
v___x_1212_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_1212_, 0, v_info_1207_);
lean_ctor_set(v___x_1212_, 1, v___x_1211_);
v___x_1213_ = l_List_appendTR___redArg(v_catalogue_1208_, v___x_1212_);
return v___x_1213_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_catalogueOne___boxed(lean_object* v_event_1220_, lean_object* v_info_1221_, lean_object* v_catalogue_1222_){
_start:
{
lean_object* v_res_1223_; 
v_res_1223_ = lp_ir_x2dproof_IRProof_catalogueOne(v_event_1220_, v_info_1221_, v_catalogue_1222_);
lean_dec_ref(v_event_1220_);
return v_res_1223_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_catalogueSpeedBound(lean_object* v_detectorLength_1224_, lean_object* v_responseTime_1225_, lean_object* v_minimumSpacing_1226_){
_start:
{
lean_object* v___x_1227_; lean_object* v___x_1228_; 
v___x_1227_ = l_Rat_add(v_detectorLength_1224_, v_minimumSpacing_1226_);
v___x_1228_ = l_Rat_div(v___x_1227_, v_responseTime_1225_);
lean_dec_ref(v___x_1227_);
return v___x_1228_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistMass_spec__0(lean_object* v_x_1229_, lean_object* v_x_1230_){
_start:
{
if (lean_obj_tag(v_x_1230_) == 0)
{
return v_x_1229_;
}
else
{
lean_object* v_head_1231_; lean_object* v_tail_1232_; lean_object* v_weightKg_1233_; lean_object* v___x_1234_; 
v_head_1231_ = lean_ctor_get(v_x_1230_, 0);
lean_inc(v_head_1231_);
v_tail_1232_ = lean_ctor_get(v_x_1230_, 1);
lean_inc(v_tail_1232_);
lean_dec_ref_known(v_x_1230_, 2);
v_weightKg_1233_ = lean_ctor_get(v_head_1231_, 2);
lean_inc_ref(v_weightKg_1233_);
lean_dec(v_head_1231_);
v___x_1234_ = l_Rat_add(v_x_1229_, v_weightKg_1233_);
v_x_1229_ = v___x_1234_;
v_x_1230_ = v_tail_1232_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistMass(lean_object* v_xs_1236_){
_start:
{
lean_object* v___x_1237_; lean_object* v___x_1238_; 
v___x_1237_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1238_ = lp_ir_x2dproof_List_foldl___at___00IRProof_consistMass_spec__0(v___x_1237_, v_xs_1236_);
return v___x_1238_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelStatic___closed__0(void){
_start:
{
lean_object* v___x_1239_; lean_object* v___x_1240_; 
v___x_1239_ = lean_unsigned_to_nat(7u);
v___x_1240_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1239_);
return v___x_1240_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelStatic___closed__1(void){
_start:
{
lean_object* v___x_1241_; lean_object* v___x_1242_; 
v___x_1241_ = lean_unsigned_to_nat(10u);
v___x_1242_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1241_);
return v___x_1242_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelStatic___closed__2(void){
_start:
{
lean_object* v___x_1243_; lean_object* v___x_1244_; lean_object* v___x_1245_; 
v___x_1243_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelStatic___closed__1, &lp_ir_x2dproof_IRProof_steelStatic___closed__1_once, _init_lp_ir_x2dproof_IRProof_steelStatic___closed__1);
v___x_1244_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelStatic___closed__0, &lp_ir_x2dproof_IRProof_steelStatic___closed__0_once, _init_lp_ir_x2dproof_IRProof_steelStatic___closed__0);
v___x_1245_ = l_Rat_div(v___x_1244_, v___x_1243_);
return v___x_1245_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelStatic(void){
_start:
{
lean_object* v___x_1246_; 
v___x_1246_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelStatic___closed__2, &lp_ir_x2dproof_IRProof_steelStatic___closed__2_once, _init_lp_ir_x2dproof_IRProof_steelStatic___closed__2);
return v___x_1246_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelKinetic___closed__0(void){
_start:
{
lean_object* v___x_1247_; lean_object* v___x_1248_; 
v___x_1247_ = lean_unsigned_to_nat(21u);
v___x_1248_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1247_);
return v___x_1248_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelKinetic___closed__1(void){
_start:
{
lean_object* v___x_1249_; lean_object* v___x_1250_; 
v___x_1249_ = lean_unsigned_to_nat(50u);
v___x_1250_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1249_);
return v___x_1250_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelKinetic___closed__2(void){
_start:
{
lean_object* v___x_1251_; lean_object* v___x_1252_; lean_object* v___x_1253_; 
v___x_1251_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelKinetic___closed__1, &lp_ir_x2dproof_IRProof_steelKinetic___closed__1_once, _init_lp_ir_x2dproof_IRProof_steelKinetic___closed__1);
v___x_1252_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelKinetic___closed__0, &lp_ir_x2dproof_IRProof_steelKinetic___closed__0_once, _init_lp_ir_x2dproof_IRProof_steelKinetic___closed__0);
v___x_1253_ = l_Rat_div(v___x_1252_, v___x_1251_);
return v___x_1253_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelKinetic(void){
_start:
{
lean_object* v___x_1254_; 
v___x_1254_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelKinetic___closed__2, &lp_ir_x2dproof_IRProof_steelKinetic___closed__2_once, _init_lp_ir_x2dproof_IRProof_steelKinetic___closed__2);
return v___x_1254_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__0(void){
_start:
{
lean_object* v___x_1255_; lean_object* v___x_1256_; 
v___x_1255_ = lean_unsigned_to_nat(4u);
v___x_1256_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1255_);
return v___x_1256_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__1(void){
_start:
{
lean_object* v___x_1257_; lean_object* v___x_1258_; lean_object* v___x_1259_; 
v___x_1257_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__0, &lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__0_once, _init_lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__0);
v___x_1258_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
v___x_1259_ = l_Rat_div(v___x_1258_, v___x_1257_);
return v___x_1259_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_steelCastIronKinetic(void){
_start:
{
lean_object* v___x_1260_; 
v___x_1260_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__1, &lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__1_once, _init_lp_ir_x2dproof_IRProof_steelCastIronKinetic___closed__1);
return v___x_1260_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_gravity___closed__0(void){
_start:
{
lean_object* v___x_1261_; lean_object* v___x_1262_; 
v___x_1261_ = lean_unsigned_to_nat(49u);
v___x_1262_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1261_);
return v___x_1262_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_gravity___closed__1(void){
_start:
{
lean_object* v___x_1263_; lean_object* v___x_1264_; 
v___x_1263_ = lean_unsigned_to_nat(5u);
v___x_1264_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1263_);
return v___x_1264_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_gravity___closed__2(void){
_start:
{
lean_object* v___x_1265_; lean_object* v___x_1266_; lean_object* v___x_1267_; 
v___x_1265_ = lean_obj_once(&lp_ir_x2dproof_IRProof_gravity___closed__1, &lp_ir_x2dproof_IRProof_gravity___closed__1_once, _init_lp_ir_x2dproof_IRProof_gravity___closed__1);
v___x_1266_ = lean_obj_once(&lp_ir_x2dproof_IRProof_gravity___closed__0, &lp_ir_x2dproof_IRProof_gravity___closed__0_once, _init_lp_ir_x2dproof_IRProof_gravity___closed__0);
v___x_1267_ = l_Rat_div(v___x_1266_, v___x_1265_);
return v___x_1267_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_gravity(void){
_start:
{
lean_object* v___x_1268_; 
v___x_1268_ = lean_obj_once(&lp_ir_x2dproof_IRProof_gravity___closed__2, &lp_ir_x2dproof_IRProof_gravity___closed__2_once, _init_lp_ir_x2dproof_IRProof_gravity___closed__2);
return v___x_1268_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_defaultBrakeMultiplier(void){
_start:
{
lean_object* v___x_1269_; 
v___x_1269_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
return v___x_1269_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_physicalPressure(lean_object* v_train_1270_, lean_object* v_independent_1271_){
_start:
{
lean_object* v___x_1272_; lean_object* v___y_1274_; lean_object* v___x_1276_; lean_object* v___y_1278_; uint8_t v___x_1280_; 
v___x_1272_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
v___x_1276_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
lean_inc_ref(v_independent_1271_);
lean_inc_ref(v_train_1270_);
v___x_1280_ = l_Rat_instDecidableLe(v_train_1270_, v_independent_1271_);
if (v___x_1280_ == 0)
{
lean_dec_ref(v_independent_1271_);
v___y_1278_ = v_train_1270_;
goto v___jp_1277_;
}
else
{
lean_dec_ref(v_train_1270_);
v___y_1278_ = v_independent_1271_;
goto v___jp_1277_;
}
v___jp_1273_:
{
uint8_t v___x_1275_; 
lean_inc_ref(v___y_1274_);
v___x_1275_ = l_Rat_instDecidableLe(v___x_1272_, v___y_1274_);
if (v___x_1275_ == 0)
{
return v___y_1274_;
}
else
{
lean_dec_ref(v___y_1274_);
return v___x_1272_;
}
}
v___jp_1277_:
{
uint8_t v___x_1279_; 
lean_inc_ref(v___y_1278_);
v___x_1279_ = l_Rat_instDecidableLe(v___x_1276_, v___y_1278_);
if (v___x_1279_ == 0)
{
lean_dec_ref(v___y_1278_);
v___y_1274_ = v___x_1276_;
goto v___jp_1273_;
}
else
{
v___y_1274_ = v___y_1278_;
goto v___jp_1273_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeSystemEfficiency(lean_object* v_x_1281_){
_start:
{
uint8_t v_cogging_1282_; 
v_cogging_1282_ = lean_ctor_get_uint8(v_x_1281_, sizeof(void*)*19 + 2);
if (v_cogging_1282_ == 0)
{
lean_object* v_brakeShoeFriction_1283_; 
v_brakeShoeFriction_1283_ = lean_ctor_get(v_x_1281_, 13);
lean_inc_ref(v_brakeShoeFriction_1283_);
return v_brakeShoeFriction_1283_;
}
else
{
lean_object* v___x_1284_; 
v___x_1284_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelStatic___closed__1, &lp_ir_x2dproof_IRProof_steelStatic___closed__1_once, _init_lp_ir_x2dproof_IRProof_steelStatic___closed__1);
return v___x_1284_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeSystemEfficiency___boxed(lean_object* v_x_1285_){
_start:
{
lean_object* v_res_1286_; 
v_res_1286_ = lp_ir_x2dproof_IRProof_brakeSystemEfficiency(v_x_1285_);
lean_dec_ref(v_x_1285_);
return v_res_1286_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeAdhesionEfficiency(lean_object* v_x_1287_){
_start:
{
uint8_t v_cogging_1288_; 
v_cogging_1288_ = lean_ctor_get_uint8(v_x_1287_, sizeof(void*)*19 + 2);
if (v_cogging_1288_ == 0)
{
lean_object* v_configuredBrakeAdhesionEfficiency_1289_; 
v_configuredBrakeAdhesionEfficiency_1289_ = lean_ctor_get(v_x_1287_, 14);
lean_inc_ref(v_configuredBrakeAdhesionEfficiency_1289_);
return v_configuredBrakeAdhesionEfficiency_1289_;
}
else
{
lean_object* v___x_1290_; 
v___x_1290_ = lean_obj_once(&lp_ir_x2dproof_IRProof_steelStatic___closed__1, &lp_ir_x2dproof_IRProof_steelStatic___closed__1_once, _init_lp_ir_x2dproof_IRProof_steelStatic___closed__1);
return v___x_1290_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeAdhesionEfficiency___boxed(lean_object* v_x_1291_){
_start:
{
lean_object* v_res_1292_; 
v_res_1292_ = lp_ir_x2dproof_IRProof_brakeAdhesionEfficiency(v_x_1291_);
lean_dec_ref(v_x_1291_);
return v_res_1292_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_maximumAdhesionN(lean_object* v_x_1293_){
_start:
{
lean_object* v_massKg_1294_; lean_object* v___x_1295_; lean_object* v___x_1296_; lean_object* v___x_1297_; lean_object* v___x_1298_; lean_object* v___x_1299_; lean_object* v___x_1300_; 
v_massKg_1294_ = lean_ctor_get(v_x_1293_, 0);
v___x_1295_ = lp_ir_x2dproof_IRProof_steelStatic;
v___x_1296_ = l_Rat_mul(v_massKg_1294_, v___x_1295_);
v___x_1297_ = lp_ir_x2dproof_IRProof_gravity;
v___x_1298_ = l_Rat_mul(v___x_1296_, v___x_1297_);
lean_dec_ref(v___x_1296_);
v___x_1299_ = lp_ir_x2dproof_IRProof_brakeAdhesionEfficiency(v_x_1293_);
v___x_1300_ = l_Rat_mul(v___x_1298_, v___x_1299_);
lean_dec_ref(v___x_1298_);
return v___x_1300_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_maximumAdhesionN___boxed(lean_object* v_x_1301_){
_start:
{
lean_object* v_res_1302_; 
v_res_1302_ = lp_ir_x2dproof_IRProof_maximumAdhesionN(v_x_1301_);
lean_dec_ref(v_x_1301_);
return v_res_1302_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_designAdhesionN(lean_object* v_x_1303_){
_start:
{
lean_object* v_designMassKg_1304_; lean_object* v___x_1305_; lean_object* v___x_1306_; lean_object* v___x_1307_; lean_object* v___x_1308_; lean_object* v___x_1309_; lean_object* v___x_1310_; 
v_designMassKg_1304_ = lean_ctor_get(v_x_1303_, 1);
v___x_1305_ = lp_ir_x2dproof_IRProof_steelStatic;
v___x_1306_ = l_Rat_mul(v_designMassKg_1304_, v___x_1305_);
v___x_1307_ = lp_ir_x2dproof_IRProof_gravity;
v___x_1308_ = l_Rat_mul(v___x_1306_, v___x_1307_);
lean_dec_ref(v___x_1306_);
v___x_1309_ = lp_ir_x2dproof_IRProof_brakeSystemEfficiency(v_x_1303_);
v___x_1310_ = l_Rat_mul(v___x_1308_, v___x_1309_);
lean_dec_ref(v___x_1308_);
return v___x_1310_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_designAdhesionN___boxed(lean_object* v_x_1311_){
_start:
{
lean_object* v_res_1312_; 
v_res_1312_ = lp_ir_x2dproof_IRProof_designAdhesionN(v_x_1311_);
lean_dec_ref(v_x_1311_);
return v_res_1312_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeDemandN(lean_object* v_x_1313_){
_start:
{
lean_object* v_trainBrake_1314_; lean_object* v_independentBrake_1315_; lean_object* v___x_1316_; lean_object* v___x_1317_; lean_object* v___x_1318_; 
v_trainBrake_1314_ = lean_ctor_get(v_x_1313_, 11);
lean_inc_ref(v_trainBrake_1314_);
v_independentBrake_1315_ = lean_ctor_get(v_x_1313_, 12);
lean_inc_ref(v_independentBrake_1315_);
v___x_1316_ = lp_ir_x2dproof_IRProof_designAdhesionN(v_x_1313_);
lean_dec_ref(v_x_1313_);
v___x_1317_ = lp_ir_x2dproof_IRProof_physicalPressure(v_trainBrake_1314_, v_independentBrake_1315_);
v___x_1318_ = l_Rat_mul(v___x_1316_, v___x_1317_);
lean_dec_ref(v___x_1316_);
return v___x_1318_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_wheelSlipBrakeN(lean_object* v_x_1319_){
_start:
{
lean_object* v_massKg_1320_; lean_object* v___x_1321_; lean_object* v___x_1322_; 
v_massKg_1320_ = lean_ctor_get(v_x_1319_, 0);
v___x_1321_ = lp_ir_x2dproof_IRProof_steelKinetic;
v___x_1322_ = l_Rat_mul(v_massKg_1320_, v___x_1321_);
return v___x_1322_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_wheelSlipBrakeN___boxed(lean_object* v_x_1323_){
_start:
{
lean_object* v_res_1324_; 
v_res_1324_ = lp_ir_x2dproof_IRProof_wheelSlipBrakeN(v_x_1323_);
lean_dec_ref(v_x_1323_);
return v_res_1324_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_brakeBranch___closed__0(void){
_start:
{
lean_object* v___x_1325_; lean_object* v___x_1326_; 
v___x_1325_ = lean_unsigned_to_nat(100u);
v___x_1326_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1325_);
return v___x_1326_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_brakeBranch___closed__1(void){
_start:
{
lean_object* v___x_1327_; lean_object* v___x_1328_; lean_object* v___x_1329_; 
v___x_1327_ = lean_obj_once(&lp_ir_x2dproof_IRProof_brakeBranch___closed__0, &lp_ir_x2dproof_IRProof_brakeBranch___closed__0_once, _init_lp_ir_x2dproof_IRProof_brakeBranch___closed__0);
v___x_1328_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
v___x_1329_ = l_Rat_div(v___x_1328_, v___x_1327_);
return v___x_1329_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeBranch(lean_object* v_x_1330_){
_start:
{
uint8_t v_wheelSlip_1331_; 
v_wheelSlip_1331_ = lean_ctor_get_uint8(v_x_1330_, sizeof(void*)*19 + 3);
if (v_wheelSlip_1331_ == 0)
{
lean_object* v___x_1332_; 
v___x_1332_ = lp_ir_x2dproof_IRProof_brakeDemandN(v_x_1330_);
return v___x_1332_;
}
else
{
lean_object* v_velocityMps_1333_; lean_object* v___x_1334_; lean_object* v___x_1335_; uint8_t v___x_1336_; 
v_velocityMps_1333_ = lean_ctor_get(v_x_1330_, 2);
v___x_1334_ = lean_obj_once(&lp_ir_x2dproof_IRProof_brakeBranch___closed__1, &lp_ir_x2dproof_IRProof_brakeBranch___closed__1_once, _init_lp_ir_x2dproof_IRProof_brakeBranch___closed__1);
lean_inc_ref(v_velocityMps_1333_);
v___x_1335_ = lp_ir_x2dproof_IRProof_absQ(v_velocityMps_1333_);
v___x_1336_ = l_Rat_blt(v___x_1334_, v___x_1335_);
if (v___x_1336_ == 0)
{
lean_object* v___x_1337_; 
v___x_1337_ = lp_ir_x2dproof_IRProof_brakeDemandN(v_x_1330_);
return v___x_1337_;
}
else
{
lean_object* v___x_1338_; 
v___x_1338_ = lp_ir_x2dproof_IRProof_wheelSlipBrakeN(v_x_1330_);
lean_dec_ref(v_x_1330_);
return v___x_1338_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeForceN(lean_object* v_x_1339_){
_start:
{
lean_object* v_configuredBrakeMultiplier_1340_; lean_object* v___x_1341_; lean_object* v___x_1342_; 
v_configuredBrakeMultiplier_1340_ = lean_ctor_get(v_x_1339_, 15);
lean_inc_ref(v_configuredBrakeMultiplier_1340_);
v___x_1341_ = lp_ir_x2dproof_IRProof_brakeBranch(v_x_1339_);
v___x_1342_ = l_Rat_mul(v_configuredBrakeMultiplier_1340_, v___x_1341_);
lean_dec_ref(v_configuredBrakeMultiplier_1340_);
return v___x_1342_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_gradeForceN___closed__0(void){
_start:
{
lean_object* v___x_1343_; lean_object* v___x_1344_; 
v___x_1343_ = lp_ir_x2dproof_IRProof_gravity;
v___x_1344_ = l_Rat_neg(v___x_1343_);
return v___x_1344_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_gradeForceN(lean_object* v_x_1345_){
_start:
{
lean_object* v_massKg_1346_; lean_object* v_slopeSine_1347_; lean_object* v_slopeMultiplier_1348_; lean_object* v___x_1349_; lean_object* v___x_1350_; lean_object* v___x_1351_; lean_object* v___x_1352_; 
v_massKg_1346_ = lean_ctor_get(v_x_1345_, 0);
lean_inc_ref(v_massKg_1346_);
v_slopeSine_1347_ = lean_ctor_get(v_x_1345_, 3);
lean_inc_ref(v_slopeSine_1347_);
v_slopeMultiplier_1348_ = lean_ctor_get(v_x_1345_, 4);
lean_inc_ref(v_slopeMultiplier_1348_);
lean_dec_ref(v_x_1345_);
v___x_1349_ = lean_obj_once(&lp_ir_x2dproof_IRProof_gradeForceN___closed__0, &lp_ir_x2dproof_IRProof_gradeForceN___closed__0_once, _init_lp_ir_x2dproof_IRProof_gradeForceN___closed__0);
v___x_1350_ = l_Rat_mul(v_massKg_1346_, v___x_1349_);
lean_dec_ref(v_massKg_1346_);
v___x_1351_ = l_Rat_mul(v___x_1350_, v_slopeSine_1347_);
lean_dec_ref(v___x_1350_);
v___x_1352_ = l_Rat_mul(v___x_1351_, v_slopeMultiplier_1348_);
lean_dec_ref(v___x_1351_);
return v___x_1352_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_tractiveForceN(lean_object* v_x_1353_){
_start:
{
lean_object* v_throttle_1354_; lean_object* v_availableTractionN_1355_; lean_object* v___x_1356_; 
v_throttle_1354_ = lean_ctor_get(v_x_1353_, 5);
lean_inc_ref(v_throttle_1354_);
v_availableTractionN_1355_ = lean_ctor_get(v_x_1353_, 6);
lean_inc_ref(v_availableTractionN_1355_);
lean_dec_ref(v_x_1353_);
v___x_1356_ = l_Rat_mul(v_throttle_1354_, v_availableTractionN_1355_);
lean_dec_ref(v_throttle_1354_);
return v___x_1356_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_rollingDirectInterferenceN(lean_object* v_x_1357_){
_start:
{
lean_object* v_rollingResistanceN_1358_; lean_object* v_directResistanceN_1359_; lean_object* v_interferenceResistanceN_1360_; lean_object* v_nearZeroResistanceN_1361_; lean_object* v___x_1362_; lean_object* v___x_1363_; lean_object* v___x_1364_; 
v_rollingResistanceN_1358_ = lean_ctor_get(v_x_1357_, 7);
lean_inc_ref(v_rollingResistanceN_1358_);
v_directResistanceN_1359_ = lean_ctor_get(v_x_1357_, 8);
lean_inc_ref(v_directResistanceN_1359_);
v_interferenceResistanceN_1360_ = lean_ctor_get(v_x_1357_, 9);
lean_inc_ref(v_interferenceResistanceN_1360_);
v_nearZeroResistanceN_1361_ = lean_ctor_get(v_x_1357_, 10);
lean_inc_ref(v_nearZeroResistanceN_1361_);
lean_dec_ref(v_x_1357_);
v___x_1362_ = l_Rat_add(v_rollingResistanceN_1358_, v_directResistanceN_1359_);
v___x_1363_ = l_Rat_add(v___x_1362_, v_interferenceResistanceN_1360_);
v___x_1364_ = l_Rat_add(v___x_1363_, v_nearZeroResistanceN_1361_);
return v___x_1364_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_couplerAdverseN(lean_object* v_x_1365_){
_start:
{
lean_object* v_curvatureBoundN_1366_; lean_object* v_slackBoundN_1367_; lean_object* v_pushPullBoundN_1368_; lean_object* v___x_1369_; lean_object* v___x_1370_; 
v_curvatureBoundN_1366_ = lean_ctor_get(v_x_1365_, 16);
lean_inc_ref(v_curvatureBoundN_1366_);
v_slackBoundN_1367_ = lean_ctor_get(v_x_1365_, 17);
lean_inc_ref(v_slackBoundN_1367_);
v_pushPullBoundN_1368_ = lean_ctor_get(v_x_1365_, 18);
lean_inc_ref(v_pushPullBoundN_1368_);
lean_dec_ref(v_x_1365_);
v___x_1369_ = l_Rat_add(v_curvatureBoundN_1366_, v_slackBoundN_1367_);
v___x_1370_ = l_Rat_add(v___x_1369_, v_pushPullBoundN_1368_);
return v___x_1370_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_signedNetForceN(lean_object* v_x_1371_){
_start:
{
lean_object* v___x_1372_; lean_object* v___x_1373_; lean_object* v___x_1374_; lean_object* v___x_1375_; lean_object* v___x_1376_; lean_object* v___x_1377_; lean_object* v___x_1378_; lean_object* v___x_1379_; lean_object* v___x_1380_; 
lean_inc_ref_n(v_x_1371_, 4);
v___x_1372_ = lp_ir_x2dproof_IRProof_gradeForceN(v_x_1371_);
v___x_1373_ = lp_ir_x2dproof_IRProof_tractiveForceN(v_x_1371_);
v___x_1374_ = l_Rat_add(v___x_1372_, v___x_1373_);
v___x_1375_ = lp_ir_x2dproof_IRProof_rollingDirectInterferenceN(v_x_1371_);
v___x_1376_ = l_Rat_sub(v___x_1374_, v___x_1375_);
v___x_1377_ = lp_ir_x2dproof_IRProof_brakeForceN(v_x_1371_);
v___x_1378_ = l_Rat_sub(v___x_1376_, v___x_1377_);
v___x_1379_ = lp_ir_x2dproof_IRProof_couplerAdverseN(v_x_1371_);
v___x_1380_ = l_Rat_sub(v___x_1378_, v___x_1379_);
return v___x_1380_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_forceLedger(lean_object* v_x_1381_){
_start:
{
lean_object* v___x_1382_; lean_object* v___x_1383_; lean_object* v___x_1384_; lean_object* v___x_1385_; lean_object* v___x_1386_; lean_object* v___x_1387_; lean_object* v___x_1388_; 
lean_inc_ref_n(v_x_1381_, 5);
v___x_1382_ = lp_ir_x2dproof_IRProof_gradeForceN(v_x_1381_);
v___x_1383_ = lp_ir_x2dproof_IRProof_tractiveForceN(v_x_1381_);
v___x_1384_ = lp_ir_x2dproof_IRProof_rollingDirectInterferenceN(v_x_1381_);
v___x_1385_ = lp_ir_x2dproof_IRProof_brakeForceN(v_x_1381_);
v___x_1386_ = lp_ir_x2dproof_IRProof_couplerAdverseN(v_x_1381_);
v___x_1387_ = lp_ir_x2dproof_IRProof_signedNetForceN(v_x_1381_);
v___x_1388_ = lean_alloc_ctor(0, 6, 0);
lean_ctor_set(v___x_1388_, 0, v___x_1382_);
lean_ctor_set(v___x_1388_, 1, v___x_1383_);
lean_ctor_set(v___x_1388_, 2, v___x_1384_);
lean_ctor_set(v___x_1388_, 3, v___x_1385_);
lean_ctor_set(v___x_1388_, 4, v___x_1386_);
lean_ctor_set(v___x_1388_, 5, v___x_1387_);
return v___x_1388_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_particleAcceleration(lean_object* v_p_1389_){
_start:
{
lean_object* v_physics_1390_; lean_object* v_massKg_1391_; lean_object* v___x_1392_; lean_object* v___x_1393_; 
v_physics_1390_ = lean_ctor_get(v_p_1389_, 2);
lean_inc_ref(v_physics_1390_);
lean_dec_ref(v_p_1389_);
v_massKg_1391_ = lean_ctor_get(v_physics_1390_, 0);
lean_inc_ref(v_massKg_1391_);
v___x_1392_ = lp_ir_x2dproof_IRProof_signedNetForceN(v_physics_1390_);
v___x_1393_ = l_Rat_div(v___x_1392_, v_massKg_1391_);
lean_dec_ref(v___x_1392_);
return v___x_1393_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_irParticleStep(lean_object* v_dt_1394_, lean_object* v_p_1395_){
_start:
{
lean_object* v_positionS_1396_; lean_object* v_velocityMps_1397_; lean_object* v_physics_1398_; lean_object* v___x_1399_; lean_object* v___x_1400_; lean_object* v___x_1401_; lean_object* v___x_1402_; lean_object* v___x_1403_; lean_object* v___x_1404_; 
v_positionS_1396_ = lean_ctor_get(v_p_1395_, 0);
v_velocityMps_1397_ = lean_ctor_get(v_p_1395_, 1);
lean_inc_ref(v_velocityMps_1397_);
v_physics_1398_ = lean_ctor_get(v_p_1395_, 2);
lean_inc_ref(v_physics_1398_);
lean_inc_ref(v_dt_1394_);
v___x_1399_ = l_Rat_mul(v_velocityMps_1397_, v_dt_1394_);
lean_inc_ref(v_positionS_1396_);
v___x_1400_ = l_Rat_add(v_positionS_1396_, v___x_1399_);
v___x_1401_ = lp_ir_x2dproof_IRProof_particleAcceleration(v_p_1395_);
v___x_1402_ = l_Rat_mul(v___x_1401_, v_dt_1394_);
lean_dec_ref(v___x_1401_);
v___x_1403_ = l_Rat_add(v_velocityMps_1397_, v___x_1402_);
v___x_1404_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_1404_, 0, v___x_1400_);
lean_ctor_set(v___x_1404_, 1, v___x_1403_);
lean_ctor_set(v___x_1404_, 2, v_physics_1398_);
return v___x_1404_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistMassQ_spec__0(lean_object* v_x_1405_, lean_object* v_x_1406_){
_start:
{
if (lean_obj_tag(v_x_1406_) == 0)
{
return v_x_1405_;
}
else
{
lean_object* v_head_1407_; lean_object* v_physics_1408_; lean_object* v_tail_1409_; lean_object* v_massKg_1410_; lean_object* v___x_1411_; 
v_head_1407_ = lean_ctor_get(v_x_1406_, 0);
v_physics_1408_ = lean_ctor_get(v_head_1407_, 2);
lean_inc_ref(v_physics_1408_);
v_tail_1409_ = lean_ctor_get(v_x_1406_, 1);
lean_inc(v_tail_1409_);
lean_dec_ref_known(v_x_1406_, 2);
v_massKg_1410_ = lean_ctor_get(v_physics_1408_, 0);
lean_inc_ref(v_massKg_1410_);
lean_dec_ref(v_physics_1408_);
v___x_1411_ = l_Rat_add(v_x_1405_, v_massKg_1410_);
v_x_1405_ = v___x_1411_;
v_x_1406_ = v_tail_1409_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistMassQ(lean_object* v_c_1413_){
_start:
{
lean_object* v_particles_1414_; lean_object* v___x_1415_; lean_object* v___x_1416_; 
v_particles_1414_ = lean_ctor_get(v_c_1413_, 0);
lean_inc(v_particles_1414_);
lean_dec_ref(v_c_1413_);
v___x_1415_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1416_ = lp_ir_x2dproof_List_foldl___at___00IRProof_consistMassQ_spec__0(v___x_1415_, v_particles_1414_);
return v___x_1416_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistBrakeQ_spec__0(lean_object* v_x_1417_, lean_object* v_x_1418_){
_start:
{
if (lean_obj_tag(v_x_1418_) == 0)
{
return v_x_1417_;
}
else
{
lean_object* v_head_1419_; lean_object* v_tail_1420_; lean_object* v_physics_1421_; lean_object* v___x_1422_; lean_object* v___x_1423_; 
v_head_1419_ = lean_ctor_get(v_x_1418_, 0);
lean_inc(v_head_1419_);
v_tail_1420_ = lean_ctor_get(v_x_1418_, 1);
lean_inc(v_tail_1420_);
lean_dec_ref_known(v_x_1418_, 2);
v_physics_1421_ = lean_ctor_get(v_head_1419_, 2);
lean_inc_ref(v_physics_1421_);
lean_dec(v_head_1419_);
v___x_1422_ = lp_ir_x2dproof_IRProof_brakeForceN(v_physics_1421_);
v___x_1423_ = l_Rat_add(v_x_1417_, v___x_1422_);
v_x_1417_ = v___x_1423_;
v_x_1418_ = v_tail_1420_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistBrakeQ(lean_object* v_c_1425_){
_start:
{
lean_object* v_particles_1426_; lean_object* v___x_1427_; lean_object* v___x_1428_; 
v_particles_1426_ = lean_ctor_get(v_c_1425_, 0);
lean_inc(v_particles_1426_);
lean_dec_ref(v_c_1425_);
v___x_1427_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1428_ = lp_ir_x2dproof_List_foldl___at___00IRProof_consistBrakeQ_spec__0(v___x_1427_, v_particles_1426_);
return v___x_1428_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistTractionQ_spec__0(lean_object* v_x_1429_, lean_object* v_x_1430_){
_start:
{
if (lean_obj_tag(v_x_1430_) == 0)
{
return v_x_1429_;
}
else
{
lean_object* v_head_1431_; lean_object* v_tail_1432_; lean_object* v_physics_1433_; lean_object* v___x_1434_; lean_object* v___x_1435_; 
v_head_1431_ = lean_ctor_get(v_x_1430_, 0);
lean_inc(v_head_1431_);
v_tail_1432_ = lean_ctor_get(v_x_1430_, 1);
lean_inc(v_tail_1432_);
lean_dec_ref_known(v_x_1430_, 2);
v_physics_1433_ = lean_ctor_get(v_head_1431_, 2);
lean_inc_ref(v_physics_1433_);
lean_dec(v_head_1431_);
v___x_1434_ = lp_ir_x2dproof_IRProof_tractiveForceN(v_physics_1433_);
v___x_1435_ = l_Rat_add(v_x_1429_, v___x_1434_);
v_x_1429_ = v___x_1435_;
v_x_1430_ = v_tail_1432_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistTractionQ(lean_object* v_c_1437_){
_start:
{
lean_object* v_particles_1438_; lean_object* v___x_1439_; lean_object* v___x_1440_; 
v_particles_1438_ = lean_ctor_get(v_c_1437_, 0);
lean_inc(v_particles_1438_);
lean_dec_ref(v_c_1437_);
v___x_1439_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1440_ = lp_ir_x2dproof_List_foldl___at___00IRProof_consistTractionQ_spec__0(v___x_1439_, v_particles_1438_);
return v___x_1440_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_foldl___at___00IRProof_consistAdverseQ_spec__0(lean_object* v_x_1441_, lean_object* v_x_1442_){
_start:
{
if (lean_obj_tag(v_x_1442_) == 0)
{
return v_x_1441_;
}
else
{
lean_object* v_head_1443_; lean_object* v_tail_1444_; lean_object* v_physics_1445_; lean_object* v___x_1446_; lean_object* v___x_1447_; 
v_head_1443_ = lean_ctor_get(v_x_1442_, 0);
lean_inc(v_head_1443_);
v_tail_1444_ = lean_ctor_get(v_x_1442_, 1);
lean_inc(v_tail_1444_);
lean_dec_ref_known(v_x_1442_, 2);
v_physics_1445_ = lean_ctor_get(v_head_1443_, 2);
lean_inc_ref(v_physics_1445_);
lean_dec(v_head_1443_);
v___x_1446_ = lp_ir_x2dproof_IRProof_couplerAdverseN(v_physics_1445_);
v___x_1447_ = l_Rat_add(v_x_1441_, v___x_1446_);
v_x_1441_ = v___x_1447_;
v_x_1442_ = v_tail_1444_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistAdverseQ(lean_object* v_c_1449_){
_start:
{
lean_object* v_particles_1450_; lean_object* v___x_1451_; lean_object* v___x_1452_; 
v_particles_1450_ = lean_ctor_get(v_c_1449_, 0);
lean_inc(v_particles_1450_);
lean_dec_ref(v_c_1449_);
v___x_1451_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1452_ = lp_ir_x2dproof_List_foldl___at___00IRProof_consistAdverseQ_spec__0(v___x_1451_, v_particles_1450_);
return v___x_1452_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_consistStep_spec__0(lean_object* v_dt_1453_, lean_object* v_a_1454_, lean_object* v_a_1455_){
_start:
{
if (lean_obj_tag(v_a_1454_) == 0)
{
lean_object* v___x_1456_; 
lean_dec_ref(v_dt_1453_);
v___x_1456_ = l_List_reverse___redArg(v_a_1455_);
return v___x_1456_;
}
else
{
lean_object* v_head_1457_; lean_object* v_tail_1458_; lean_object* v___x_1460_; uint8_t v_isShared_1461_; uint8_t v_isSharedCheck_1467_; 
v_head_1457_ = lean_ctor_get(v_a_1454_, 0);
v_tail_1458_ = lean_ctor_get(v_a_1454_, 1);
v_isSharedCheck_1467_ = !lean_is_exclusive(v_a_1454_);
if (v_isSharedCheck_1467_ == 0)
{
v___x_1460_ = v_a_1454_;
v_isShared_1461_ = v_isSharedCheck_1467_;
goto v_resetjp_1459_;
}
else
{
lean_inc(v_tail_1458_);
lean_inc(v_head_1457_);
lean_dec(v_a_1454_);
v___x_1460_ = lean_box(0);
v_isShared_1461_ = v_isSharedCheck_1467_;
goto v_resetjp_1459_;
}
v_resetjp_1459_:
{
lean_object* v___x_1462_; lean_object* v___x_1464_; 
lean_inc_ref(v_dt_1453_);
v___x_1462_ = lp_ir_x2dproof_IRProof_irParticleStep(v_dt_1453_, v_head_1457_);
if (v_isShared_1461_ == 0)
{
lean_ctor_set(v___x_1460_, 1, v_a_1455_);
lean_ctor_set(v___x_1460_, 0, v___x_1462_);
v___x_1464_ = v___x_1460_;
goto v_reusejp_1463_;
}
else
{
lean_object* v_reuseFailAlloc_1466_; 
v_reuseFailAlloc_1466_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_1466_, 0, v___x_1462_);
lean_ctor_set(v_reuseFailAlloc_1466_, 1, v_a_1455_);
v___x_1464_ = v_reuseFailAlloc_1466_;
goto v_reusejp_1463_;
}
v_reusejp_1463_:
{
v_a_1454_ = v_tail_1458_;
v_a_1455_ = v___x_1464_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_consistStep(lean_object* v_dt_1468_, lean_object* v_c_1469_){
_start:
{
lean_object* v_particles_1470_; lean_object* v_trainLengthM_1471_; lean_object* v_frontCouplerS_1472_; lean_object* v_frontSlackM_1473_; lean_object* v_rearSlackM_1474_; uint8_t v_frontPushing_1475_; uint8_t v_frontPulling_1476_; uint8_t v_rearPushing_1477_; uint8_t v_rearPulling_1478_; lean_object* v___x_1480_; uint8_t v_isShared_1481_; uint8_t v_isSharedCheck_1487_; 
v_particles_1470_ = lean_ctor_get(v_c_1469_, 0);
v_trainLengthM_1471_ = lean_ctor_get(v_c_1469_, 1);
v_frontCouplerS_1472_ = lean_ctor_get(v_c_1469_, 2);
v_frontSlackM_1473_ = lean_ctor_get(v_c_1469_, 3);
v_rearSlackM_1474_ = lean_ctor_get(v_c_1469_, 4);
v_frontPushing_1475_ = lean_ctor_get_uint8(v_c_1469_, sizeof(void*)*5);
v_frontPulling_1476_ = lean_ctor_get_uint8(v_c_1469_, sizeof(void*)*5 + 1);
v_rearPushing_1477_ = lean_ctor_get_uint8(v_c_1469_, sizeof(void*)*5 + 2);
v_rearPulling_1478_ = lean_ctor_get_uint8(v_c_1469_, sizeof(void*)*5 + 3);
v_isSharedCheck_1487_ = !lean_is_exclusive(v_c_1469_);
if (v_isSharedCheck_1487_ == 0)
{
v___x_1480_ = v_c_1469_;
v_isShared_1481_ = v_isSharedCheck_1487_;
goto v_resetjp_1479_;
}
else
{
lean_inc(v_rearSlackM_1474_);
lean_inc(v_frontSlackM_1473_);
lean_inc(v_frontCouplerS_1472_);
lean_inc(v_trainLengthM_1471_);
lean_inc(v_particles_1470_);
lean_dec(v_c_1469_);
v___x_1480_ = lean_box(0);
v_isShared_1481_ = v_isSharedCheck_1487_;
goto v_resetjp_1479_;
}
v_resetjp_1479_:
{
lean_object* v___x_1482_; lean_object* v___x_1483_; lean_object* v___x_1485_; 
v___x_1482_ = lean_box(0);
v___x_1483_ = lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_consistStep_spec__0(v_dt_1468_, v_particles_1470_, v___x_1482_);
if (v_isShared_1481_ == 0)
{
lean_ctor_set(v___x_1480_, 0, v___x_1483_);
v___x_1485_ = v___x_1480_;
goto v_reusejp_1484_;
}
else
{
lean_object* v_reuseFailAlloc_1486_; 
v_reuseFailAlloc_1486_ = lean_alloc_ctor(0, 5, 4);
lean_ctor_set(v_reuseFailAlloc_1486_, 0, v___x_1483_);
lean_ctor_set(v_reuseFailAlloc_1486_, 1, v_trainLengthM_1471_);
lean_ctor_set(v_reuseFailAlloc_1486_, 2, v_frontCouplerS_1472_);
lean_ctor_set(v_reuseFailAlloc_1486_, 3, v_frontSlackM_1473_);
lean_ctor_set(v_reuseFailAlloc_1486_, 4, v_rearSlackM_1474_);
lean_ctor_set_uint8(v_reuseFailAlloc_1486_, sizeof(void*)*5, v_frontPushing_1475_);
lean_ctor_set_uint8(v_reuseFailAlloc_1486_, sizeof(void*)*5 + 1, v_frontPulling_1476_);
lean_ctor_set_uint8(v_reuseFailAlloc_1486_, sizeof(void*)*5 + 2, v_rearPushing_1477_);
lean_ctor_set_uint8(v_reuseFailAlloc_1486_, sizeof(void*)*5 + 3, v_rearPulling_1478_);
v___x_1485_ = v_reuseFailAlloc_1486_;
goto v_reusejp_1484_;
}
v_reusejp_1484_:
{
return v___x_1485_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_localizeFrontCoupler(lean_object* v_tracerCentreS_1488_, lean_object* v_offsetS_1489_, lean_object* v_error_1490_){
_start:
{
lean_object* v___x_1491_; lean_object* v___x_1492_; 
lean_inc_ref(v_offsetS_1489_);
lean_inc_ref(v_tracerCentreS_1488_);
v___x_1491_ = l_Rat_add(v_tracerCentreS_1488_, v_offsetS_1489_);
v___x_1492_ = lean_alloc_ctor(0, 4, 0);
lean_ctor_set(v___x_1492_, 0, v_tracerCentreS_1488_);
lean_ctor_set(v___x_1492_, 1, v_offsetS_1489_);
lean_ctor_set(v___x_1492_, 2, v___x_1491_);
lean_ctor_set(v___x_1492_, 3, v_error_1490_);
return v___x_1492_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedTargetFromLocalization(lean_object* v_targetS_1493_, lean_object* v_localization_1494_, lean_object* v_velocity_1495_, uint8_t v_orientation_1496_){
_start:
{
lean_object* v_frontCouplerS_1497_; lean_object* v___x_1498_; 
v_frontCouplerS_1497_ = lean_ctor_get(v_localization_1494_, 2);
lean_inc_ref(v_frontCouplerS_1497_);
v___x_1498_ = lean_alloc_ctor(0, 3, 1);
lean_ctor_set(v___x_1498_, 0, v_targetS_1493_);
lean_ctor_set(v___x_1498_, 1, v_frontCouplerS_1497_);
lean_ctor_set(v___x_1498_, 2, v_velocity_1495_);
lean_ctor_set_uint8(v___x_1498_, sizeof(void*)*3, v_orientation_1496_);
return v___x_1498_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedTargetFromLocalization___boxed(lean_object* v_targetS_1499_, lean_object* v_localization_1500_, lean_object* v_velocity_1501_, lean_object* v_orientation_1502_){
_start:
{
uint8_t v_orientation_boxed_1503_; lean_object* v_res_1504_; 
v_orientation_boxed_1503_ = lean_unbox(v_orientation_1502_);
v_res_1504_ = lp_ir_x2dproof_IRProof_directedTargetFromLocalization(v_targetS_1499_, v_localization_1500_, v_velocity_1501_, v_orientation_boxed_1503_);
lean_dec_ref(v_localization_1500_);
return v_res_1504_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stoppingError(lean_object* v_t_1505_){
_start:
{
lean_object* v_targetS_1506_; lean_object* v_frontCouplerS_1507_; lean_object* v___x_1508_; 
v_targetS_1506_ = lean_ctor_get(v_t_1505_, 0);
lean_inc_ref(v_targetS_1506_);
v_frontCouplerS_1507_ = lean_ctor_get(v_t_1505_, 1);
lean_inc_ref(v_frontCouplerS_1507_);
lean_dec_ref(v_t_1505_);
v___x_1508_ = l_Rat_sub(v_targetS_1506_, v_frontCouplerS_1507_);
return v___x_1508_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedVelocity(lean_object* v_t_1509_){
_start:
{
lean_object* v_frontCouplerVelocity_1510_; 
v_frontCouplerVelocity_1510_ = lean_ctor_get(v_t_1509_, 2);
lean_inc_ref(v_frontCouplerVelocity_1510_);
return v_frontCouplerVelocity_1510_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_directedVelocity___boxed(lean_object* v_t_1511_){
_start:
{
lean_object* v_res_1512_; 
v_res_1512_ = lp_ir_x2dproof_IRProof_directedVelocity(v_t_1511_);
lean_dec_ref(v_t_1511_);
return v_res_1512_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_totalPositionError(lean_object* v_trace_1513_, lean_object* v_fit_1514_, lean_object* v_coupler_1515_, lean_object* v_sample_1516_, lean_object* v_command_1517_, lean_object* v_numeric_1518_){
_start:
{
lean_object* v___x_1519_; lean_object* v___x_1520_; lean_object* v___x_1521_; lean_object* v___x_1522_; lean_object* v___x_1523_; 
v___x_1519_ = l_Rat_add(v_trace_1513_, v_fit_1514_);
v___x_1520_ = l_Rat_add(v___x_1519_, v_coupler_1515_);
v___x_1521_ = l_Rat_add(v___x_1520_, v_sample_1516_);
v___x_1522_ = l_Rat_add(v___x_1521_, v_command_1517_);
v___x_1523_ = l_Rat_add(v___x_1522_, v_numeric_1518_);
return v___x_1523_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_stoppingDistance___closed__0(void){
_start:
{
lean_object* v___x_1524_; lean_object* v___x_1525_; 
v___x_1524_ = lean_unsigned_to_nat(2u);
v___x_1525_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_1524_);
return v___x_1525_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stoppingDistance(lean_object* v_v_1526_, lean_object* v_a_1527_){
_start:
{
lean_object* v___x_1528_; lean_object* v___x_1529_; lean_object* v___x_1530_; lean_object* v___x_1531_; 
lean_inc_ref(v_v_1526_);
v___x_1528_ = l_Rat_mul(v_v_1526_, v_v_1526_);
lean_dec_ref(v_v_1526_);
v___x_1529_ = lean_obj_once(&lp_ir_x2dproof_IRProof_stoppingDistance___closed__0, &lp_ir_x2dproof_IRProof_stoppingDistance___closed__0_once, _init_lp_ir_x2dproof_IRProof_stoppingDistance___closed__0);
v___x_1530_ = l_Rat_mul(v___x_1529_, v_a_1527_);
v___x_1531_ = l_Rat_div(v___x_1528_, v___x_1530_);
lean_dec_ref(v___x_1528_);
return v___x_1531_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_delayDistance(lean_object* v_v_1532_, lean_object* v_delay_1533_, lean_object* v_adverse_1534_){
_start:
{
lean_object* v___x_1535_; lean_object* v___x_1536_; lean_object* v___x_1537_; lean_object* v___x_1538_; 
lean_inc_ref_n(v_delay_1533_, 2);
v___x_1535_ = l_Rat_mul(v_v_1532_, v_delay_1533_);
v___x_1536_ = l_Rat_mul(v_delay_1533_, v_delay_1533_);
lean_dec_ref(v_delay_1533_);
v___x_1537_ = l_Rat_mul(v_adverse_1534_, v___x_1536_);
v___x_1538_ = l_Rat_add(v___x_1535_, v___x_1537_);
return v___x_1538_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_delayDistance___boxed(lean_object* v_v_1539_, lean_object* v_delay_1540_, lean_object* v_adverse_1541_){
_start:
{
lean_object* v_res_1542_; 
v_res_1542_ = lp_ir_x2dproof_IRProof_delayDistance(v_v_1539_, v_delay_1540_, v_adverse_1541_);
lean_dec_ref(v_adverse_1541_);
lean_dec_ref(v_v_1539_);
return v_res_1542_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_uniformBrakingAcceleration(lean_object* v_brakeLower_1543_, lean_object* v_tractiveUpper_1544_, lean_object* v_adverse_1545_, lean_object* v_mass_1546_){
_start:
{
lean_object* v___x_1547_; lean_object* v___x_1548_; lean_object* v___x_1549_; 
v___x_1547_ = l_Rat_sub(v_brakeLower_1543_, v_tractiveUpper_1544_);
v___x_1548_ = l_Rat_sub(v___x_1547_, v_adverse_1545_);
v___x_1549_ = l_Rat_div(v___x_1548_, v_mass_1546_);
lean_dec_ref(v___x_1548_);
return v___x_1549_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_certifiedBrakeStep(lean_object* v_a_1550_, lean_object* v_dt_1551_, lean_object* v_s_1552_){
_start:
{
lean_object* v_distance_1553_; lean_object* v_velocity_1554_; lean_object* v___x_1556_; uint8_t v_isShared_1557_; uint8_t v_isSharedCheck_1570_; 
v_distance_1553_ = lean_ctor_get(v_s_1552_, 0);
v_velocity_1554_ = lean_ctor_get(v_s_1552_, 1);
v_isSharedCheck_1570_ = !lean_is_exclusive(v_s_1552_);
if (v_isSharedCheck_1570_ == 0)
{
v___x_1556_ = v_s_1552_;
v_isShared_1557_ = v_isSharedCheck_1570_;
goto v_resetjp_1555_;
}
else
{
lean_inc(v_velocity_1554_);
lean_inc(v_distance_1553_);
lean_dec(v_s_1552_);
v___x_1556_ = lean_box(0);
v_isShared_1557_ = v_isSharedCheck_1570_;
goto v_resetjp_1555_;
}
v_resetjp_1555_:
{
lean_object* v___x_1558_; lean_object* v___x_1559_; lean_object* v___x_1560_; lean_object* v___x_1561_; lean_object* v___x_1562_; uint8_t v___x_1563_; 
lean_inc_ref(v_dt_1551_);
v___x_1558_ = l_Rat_mul(v_velocity_1554_, v_dt_1551_);
v___x_1559_ = l_Rat_sub(v_distance_1553_, v___x_1558_);
v___x_1560_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1561_ = l_Rat_mul(v_a_1550_, v_dt_1551_);
v___x_1562_ = l_Rat_sub(v_velocity_1554_, v___x_1561_);
lean_inc_ref(v___x_1562_);
v___x_1563_ = l_Rat_instDecidableLe(v___x_1560_, v___x_1562_);
if (v___x_1563_ == 0)
{
lean_object* v___x_1565_; 
lean_dec_ref(v___x_1562_);
if (v_isShared_1557_ == 0)
{
lean_ctor_set(v___x_1556_, 1, v___x_1560_);
lean_ctor_set(v___x_1556_, 0, v___x_1559_);
v___x_1565_ = v___x_1556_;
goto v_reusejp_1564_;
}
else
{
lean_object* v_reuseFailAlloc_1566_; 
v_reuseFailAlloc_1566_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v_reuseFailAlloc_1566_, 0, v___x_1559_);
lean_ctor_set(v_reuseFailAlloc_1566_, 1, v___x_1560_);
v___x_1565_ = v_reuseFailAlloc_1566_;
goto v_reusejp_1564_;
}
v_reusejp_1564_:
{
return v___x_1565_;
}
}
else
{
lean_object* v___x_1568_; 
if (v_isShared_1557_ == 0)
{
lean_ctor_set(v___x_1556_, 1, v___x_1562_);
lean_ctor_set(v___x_1556_, 0, v___x_1559_);
v___x_1568_ = v___x_1556_;
goto v_reusejp_1567_;
}
else
{
lean_object* v_reuseFailAlloc_1569_; 
v_reuseFailAlloc_1569_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v_reuseFailAlloc_1569_, 0, v___x_1559_);
lean_ctor_set(v_reuseFailAlloc_1569_, 1, v___x_1562_);
v___x_1568_ = v_reuseFailAlloc_1569_;
goto v_reusejp_1567_;
}
v_reusejp_1567_:
{
return v___x_1568_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_certifiedBrakeStep___boxed(lean_object* v_a_1571_, lean_object* v_dt_1572_, lean_object* v_s_1573_){
_start:
{
lean_object* v_res_1574_; 
v_res_1574_ = lp_ir_x2dproof_IRProof_certifiedBrakeStep(v_a_1571_, v_dt_1572_, v_s_1573_);
lean_dec_ref(v_a_1571_);
return v_res_1574_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeVelocity(lean_object* v_a_1575_, lean_object* v_dt_1576_, lean_object* v_n_1577_, lean_object* v_v_1578_){
_start:
{
lean_object* v___x_1579_; lean_object* v___x_1580_; lean_object* v___x_1581_; lean_object* v___x_1582_; lean_object* v___x_1583_; uint8_t v___x_1584_; 
v___x_1579_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1580_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v_n_1577_);
v___x_1581_ = l_Rat_mul(v_a_1575_, v_dt_1576_);
v___x_1582_ = l_Rat_mul(v___x_1580_, v___x_1581_);
lean_dec_ref(v___x_1580_);
v___x_1583_ = l_Rat_sub(v_v_1578_, v___x_1582_);
lean_inc_ref(v___x_1583_);
v___x_1584_ = l_Rat_instDecidableLe(v___x_1579_, v___x_1583_);
if (v___x_1584_ == 0)
{
lean_dec_ref(v___x_1583_);
return v___x_1579_;
}
else
{
return v___x_1583_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_brakeVelocity___boxed(lean_object* v_a_1585_, lean_object* v_dt_1586_, lean_object* v_n_1587_, lean_object* v_v_1588_){
_start:
{
lean_object* v_res_1589_; 
v_res_1589_ = lp_ir_x2dproof_IRProof_brakeVelocity(v_a_1585_, v_dt_1586_, v_n_1587_, v_v_1588_);
lean_dec_ref(v_a_1585_);
return v_res_1589_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandForceUpper(lean_object* v_cmd_1590_, lean_object* v_tractionUpper_1591_){
_start:
{
lean_object* v_throttle_1592_; lean_object* v___x_1593_; 
v_throttle_1592_ = lean_ctor_get(v_cmd_1590_, 0);
v___x_1593_ = l_Rat_mul(v_throttle_1592_, v_tractionUpper_1591_);
return v___x_1593_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandForceUpper___boxed(lean_object* v_cmd_1594_, lean_object* v_tractionUpper_1595_){
_start:
{
lean_object* v_res_1596_; 
v_res_1596_ = lp_ir_x2dproof_IRProof_commandForceUpper(v_cmd_1594_, v_tractionUpper_1595_);
lean_dec_ref(v_cmd_1594_);
return v_res_1596_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandBrakeLower(lean_object* v_cmd_1597_, lean_object* v_brakeUpper_1598_){
_start:
{
lean_object* v_trainBrake_1599_; lean_object* v_independentBrake_1600_; lean_object* v___x_1601_; lean_object* v___x_1602_; 
v_trainBrake_1599_ = lean_ctor_get(v_cmd_1597_, 1);
lean_inc_ref(v_trainBrake_1599_);
v_independentBrake_1600_ = lean_ctor_get(v_cmd_1597_, 2);
lean_inc_ref(v_independentBrake_1600_);
lean_dec_ref(v_cmd_1597_);
v___x_1601_ = lp_ir_x2dproof_IRProof_physicalPressure(v_trainBrake_1599_, v_independentBrake_1600_);
v___x_1602_ = l_Rat_mul(v___x_1601_, v_brakeUpper_1598_);
lean_dec_ref(v___x_1601_);
return v___x_1602_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_stoppingCommand(lean_object* v_throttleCap_1603_, lean_object* v_throttle_1604_){
_start:
{
lean_object* v___x_1605_; lean_object* v___x_1606_; lean_object* v___x_1607_; uint8_t v___x_1608_; lean_object* v___x_1609_; 
v___x_1605_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___x_1606_ = lp_ir_x2dproof_IRProof_clamp(v___x_1605_, v_throttleCap_1603_, v_throttle_1604_);
v___x_1607_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
v___x_1608_ = 1;
v___x_1609_ = lean_alloc_ctor(0, 3, 1);
lean_ctor_set(v___x_1609_, 0, v___x_1606_);
lean_ctor_set(v___x_1609_, 1, v___x_1607_);
lean_ctor_set(v___x_1609_, 2, v___x_1607_);
lean_ctor_set_uint8(v___x_1609_, sizeof(void*)*3, v___x_1608_);
return v___x_1609_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx(uint8_t v_x_1610_){
_start:
{
switch(v_x_1610_)
{
case 0:
{
lean_object* v___x_1611_; 
v___x_1611_ = lean_unsigned_to_nat(0u);
return v___x_1611_;
}
case 1:
{
lean_object* v___x_1612_; 
v___x_1612_ = lean_unsigned_to_nat(1u);
return v___x_1612_;
}
case 2:
{
lean_object* v___x_1613_; 
v___x_1613_ = lean_unsigned_to_nat(2u);
return v___x_1613_;
}
default: 
{
lean_object* v___x_1614_; 
v___x_1614_ = lean_unsigned_to_nat(3u);
return v___x_1614_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx___boxed(lean_object* v_x_1615_){
_start:
{
uint8_t v_x_boxed_1616_; lean_object* v_res_1617_; 
v_x_boxed_1616_ = lean_unbox(v_x_1615_);
v_res_1617_ = lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx(v_x_boxed_1616_);
return v_res_1617_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_toCtorIdx(uint8_t v_x_1618_){
_start:
{
lean_object* v___x_1619_; 
v___x_1619_ = lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx(v_x_1618_);
return v___x_1619_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_toCtorIdx___boxed(lean_object* v_x_1620_){
_start:
{
uint8_t v_x_4__boxed_1621_; lean_object* v_res_1622_; 
v_x_4__boxed_1621_ = lean_unbox(v_x_1620_);
v_res_1622_ = lp_ir_x2dproof_IRProof_ControllerMode_toCtorIdx(v_x_4__boxed_1621_);
return v_res_1622_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim___redArg(lean_object* v_k_1623_){
_start:
{
lean_inc(v_k_1623_);
return v_k_1623_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim___redArg___boxed(lean_object* v_k_1624_){
_start:
{
lean_object* v_res_1625_; 
v_res_1625_ = lp_ir_x2dproof_IRProof_ControllerMode_ctorElim___redArg(v_k_1624_);
lean_dec(v_k_1624_);
return v_res_1625_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim(lean_object* v_motive_1626_, lean_object* v_ctorIdx_1627_, uint8_t v_t_1628_, lean_object* v_h_1629_, lean_object* v_k_1630_){
_start:
{
lean_inc(v_k_1630_);
return v_k_1630_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ctorElim___boxed(lean_object* v_motive_1631_, lean_object* v_ctorIdx_1632_, lean_object* v_t_1633_, lean_object* v_h_1634_, lean_object* v_k_1635_){
_start:
{
uint8_t v_t_boxed_1636_; lean_object* v_res_1637_; 
v_t_boxed_1636_ = lean_unbox(v_t_1633_);
v_res_1637_ = lp_ir_x2dproof_IRProof_ControllerMode_ctorElim(v_motive_1631_, v_ctorIdx_1632_, v_t_boxed_1636_, v_h_1634_, v_k_1635_);
lean_dec(v_k_1635_);
lean_dec(v_ctorIdx_1632_);
return v_res_1637_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim___redArg(lean_object* v_cruise_1638_){
_start:
{
lean_inc(v_cruise_1638_);
return v_cruise_1638_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim___redArg___boxed(lean_object* v_cruise_1639_){
_start:
{
lean_object* v_res_1640_; 
v_res_1640_ = lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim___redArg(v_cruise_1639_);
lean_dec(v_cruise_1639_);
return v_res_1640_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim(lean_object* v_motive_1641_, uint8_t v_t_1642_, lean_object* v_h_1643_, lean_object* v_cruise_1644_){
_start:
{
lean_inc(v_cruise_1644_);
return v_cruise_1644_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim___boxed(lean_object* v_motive_1645_, lean_object* v_t_1646_, lean_object* v_h_1647_, lean_object* v_cruise_1648_){
_start:
{
uint8_t v_t_boxed_1649_; lean_object* v_res_1650_; 
v_t_boxed_1649_ = lean_unbox(v_t_1646_);
v_res_1650_ = lp_ir_x2dproof_IRProof_ControllerMode_cruise_elim(v_motive_1645_, v_t_boxed_1649_, v_h_1647_, v_cruise_1648_);
lean_dec(v_cruise_1648_);
return v_res_1650_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim___redArg(lean_object* v_stopping_1651_){
_start:
{
lean_inc(v_stopping_1651_);
return v_stopping_1651_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim___redArg___boxed(lean_object* v_stopping_1652_){
_start:
{
lean_object* v_res_1653_; 
v_res_1653_ = lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim___redArg(v_stopping_1652_);
lean_dec(v_stopping_1652_);
return v_res_1653_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim(lean_object* v_motive_1654_, uint8_t v_t_1655_, lean_object* v_h_1656_, lean_object* v_stopping_1657_){
_start:
{
lean_inc(v_stopping_1657_);
return v_stopping_1657_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim___boxed(lean_object* v_motive_1658_, lean_object* v_t_1659_, lean_object* v_h_1660_, lean_object* v_stopping_1661_){
_start:
{
uint8_t v_t_boxed_1662_; lean_object* v_res_1663_; 
v_t_boxed_1662_ = lean_unbox(v_t_1659_);
v_res_1663_ = lp_ir_x2dproof_IRProof_ControllerMode_stopping_elim(v_motive_1658_, v_t_boxed_1662_, v_h_1660_, v_stopping_1661_);
lean_dec(v_stopping_1661_);
return v_res_1663_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim___redArg(lean_object* v_holding_1664_){
_start:
{
lean_inc(v_holding_1664_);
return v_holding_1664_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim___redArg___boxed(lean_object* v_holding_1665_){
_start:
{
lean_object* v_res_1666_; 
v_res_1666_ = lp_ir_x2dproof_IRProof_ControllerMode_holding_elim___redArg(v_holding_1665_);
lean_dec(v_holding_1665_);
return v_res_1666_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim(lean_object* v_motive_1667_, uint8_t v_t_1668_, lean_object* v_h_1669_, lean_object* v_holding_1670_){
_start:
{
lean_inc(v_holding_1670_);
return v_holding_1670_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_holding_elim___boxed(lean_object* v_motive_1671_, lean_object* v_t_1672_, lean_object* v_h_1673_, lean_object* v_holding_1674_){
_start:
{
uint8_t v_t_boxed_1675_; lean_object* v_res_1676_; 
v_t_boxed_1675_ = lean_unbox(v_t_1672_);
v_res_1676_ = lp_ir_x2dproof_IRProof_ControllerMode_holding_elim(v_motive_1671_, v_t_boxed_1675_, v_h_1673_, v_holding_1674_);
lean_dec(v_holding_1674_);
return v_res_1676_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim___redArg(lean_object* v_failClosed_1677_){
_start:
{
lean_inc(v_failClosed_1677_);
return v_failClosed_1677_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim___redArg___boxed(lean_object* v_failClosed_1678_){
_start:
{
lean_object* v_res_1679_; 
v_res_1679_ = lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim___redArg(v_failClosed_1678_);
lean_dec(v_failClosed_1678_);
return v_res_1679_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim(lean_object* v_motive_1680_, uint8_t v_t_1681_, lean_object* v_h_1682_, lean_object* v_failClosed_1683_){
_start:
{
lean_inc(v_failClosed_1683_);
return v_failClosed_1683_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim___boxed(lean_object* v_motive_1684_, lean_object* v_t_1685_, lean_object* v_h_1686_, lean_object* v_failClosed_1687_){
_start:
{
uint8_t v_t_boxed_1688_; lean_object* v_res_1689_; 
v_t_boxed_1688_ = lean_unbox(v_t_1685_);
v_res_1689_ = lp_ir_x2dproof_IRProof_ControllerMode_failClosed_elim(v_motive_1684_, v_t_boxed_1688_, v_h_1686_, v_failClosed_1687_);
lean_dec(v_failClosed_1687_);
return v_res_1689_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_ControllerMode_ofNat(lean_object* v_n_1690_){
_start:
{
lean_object* v___x_1691_; uint8_t v___x_1692_; 
v___x_1691_ = lean_unsigned_to_nat(1u);
v___x_1692_ = lean_nat_dec_le(v_n_1690_, v___x_1691_);
if (v___x_1692_ == 0)
{
lean_object* v___x_1693_; uint8_t v___x_1694_; 
v___x_1693_ = lean_unsigned_to_nat(2u);
v___x_1694_ = lean_nat_dec_le(v_n_1690_, v___x_1693_);
if (v___x_1694_ == 0)
{
uint8_t v___x_1695_; 
v___x_1695_ = 3;
return v___x_1695_;
}
else
{
uint8_t v___x_1696_; 
v___x_1696_ = 2;
return v___x_1696_;
}
}
else
{
lean_object* v___x_1697_; uint8_t v___x_1698_; 
v___x_1697_ = lean_unsigned_to_nat(0u);
v___x_1698_ = lean_nat_dec_le(v_n_1690_, v___x_1697_);
if (v___x_1698_ == 0)
{
uint8_t v___x_1699_; 
v___x_1699_ = 1;
return v___x_1699_;
}
else
{
uint8_t v___x_1700_; 
v___x_1700_ = 0;
return v___x_1700_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ControllerMode_ofNat___boxed(lean_object* v_n_1701_){
_start:
{
uint8_t v_res_1702_; lean_object* v_r_1703_; 
v_res_1702_ = lp_ir_x2dproof_IRProof_ControllerMode_ofNat(v_n_1701_);
lean_dec(v_n_1701_);
v_r_1703_ = lean_box(v_res_1702_);
return v_r_1703_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqControllerMode(uint8_t v_x_1704_, uint8_t v_y_1705_){
_start:
{
lean_object* v___x_1706_; lean_object* v___x_1707_; uint8_t v___x_1708_; 
v___x_1706_ = lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx(v_x_1704_);
v___x_1707_ = lp_ir_x2dproof_IRProof_ControllerMode_ctorIdx(v_y_1705_);
v___x_1708_ = lean_nat_dec_eq(v___x_1706_, v___x_1707_);
lean_dec(v___x_1707_);
lean_dec(v___x_1706_);
return v___x_1708_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqControllerMode___boxed(lean_object* v_x_1709_, lean_object* v_y_1710_){
_start:
{
uint8_t v_x_13__boxed_1711_; uint8_t v_y_14__boxed_1712_; uint8_t v_res_1713_; lean_object* v_r_1714_; 
v_x_13__boxed_1711_ = lean_unbox(v_x_1709_);
v_y_14__boxed_1712_ = lean_unbox(v_y_1710_);
v_res_1713_ = lp_ir_x2dproof_IRProof_instDecidableEqControllerMode(v_x_13__boxed_1711_, v_y_14__boxed_1712_);
v_r_1714_ = lean_box(v_res_1713_);
return v_r_1714_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr(uint8_t v_x_1727_, lean_object* v_prec_1728_){
_start:
{
lean_object* v___y_1730_; lean_object* v___y_1737_; lean_object* v___y_1744_; lean_object* v___y_1751_; 
switch(v_x_1727_)
{
case 0:
{
lean_object* v___x_1757_; uint8_t v___x_1758_; 
v___x_1757_ = lean_unsigned_to_nat(1024u);
v___x_1758_ = lean_nat_dec_le(v___x_1757_, v_prec_1728_);
if (v___x_1758_ == 0)
{
lean_object* v___x_1759_; 
v___x_1759_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_1730_ = v___x_1759_;
goto v___jp_1729_;
}
else
{
lean_object* v___x_1760_; 
v___x_1760_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_1730_ = v___x_1760_;
goto v___jp_1729_;
}
}
case 1:
{
lean_object* v___x_1761_; uint8_t v___x_1762_; 
v___x_1761_ = lean_unsigned_to_nat(1024u);
v___x_1762_ = lean_nat_dec_le(v___x_1761_, v_prec_1728_);
if (v___x_1762_ == 0)
{
lean_object* v___x_1763_; 
v___x_1763_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_1737_ = v___x_1763_;
goto v___jp_1736_;
}
else
{
lean_object* v___x_1764_; 
v___x_1764_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_1737_ = v___x_1764_;
goto v___jp_1736_;
}
}
case 2:
{
lean_object* v___x_1765_; uint8_t v___x_1766_; 
v___x_1765_ = lean_unsigned_to_nat(1024u);
v___x_1766_ = lean_nat_dec_le(v___x_1765_, v_prec_1728_);
if (v___x_1766_ == 0)
{
lean_object* v___x_1767_; 
v___x_1767_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_1744_ = v___x_1767_;
goto v___jp_1743_;
}
else
{
lean_object* v___x_1768_; 
v___x_1768_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_1744_ = v___x_1768_;
goto v___jp_1743_;
}
}
default: 
{
lean_object* v___x_1769_; uint8_t v___x_1770_; 
v___x_1769_ = lean_unsigned_to_nat(1024u);
v___x_1770_ = lean_nat_dec_le(v___x_1769_, v_prec_1728_);
if (v___x_1770_ == 0)
{
lean_object* v___x_1771_; 
v___x_1771_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__12);
v___y_1751_ = v___x_1771_;
goto v___jp_1750_;
}
else
{
lean_object* v___x_1772_; 
v___x_1772_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13, &lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13_once, _init_lp_ir_x2dproof_IRProof_instReprTopologyClass_repr___closed__13);
v___y_1751_ = v___x_1772_;
goto v___jp_1750_;
}
}
}
v___jp_1729_:
{
lean_object* v___x_1731_; lean_object* v___x_1732_; uint8_t v___x_1733_; lean_object* v___x_1734_; lean_object* v___x_1735_; 
v___x_1731_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__1));
lean_inc(v___y_1730_);
v___x_1732_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_1732_, 0, v___y_1730_);
lean_ctor_set(v___x_1732_, 1, v___x_1731_);
v___x_1733_ = 0;
v___x_1734_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_1734_, 0, v___x_1732_);
lean_ctor_set_uint8(v___x_1734_, sizeof(void*)*1, v___x_1733_);
v___x_1735_ = l_Repr_addAppParen(v___x_1734_, v_prec_1728_);
return v___x_1735_;
}
v___jp_1736_:
{
lean_object* v___x_1738_; lean_object* v___x_1739_; uint8_t v___x_1740_; lean_object* v___x_1741_; lean_object* v___x_1742_; 
v___x_1738_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__3));
lean_inc(v___y_1737_);
v___x_1739_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_1739_, 0, v___y_1737_);
lean_ctor_set(v___x_1739_, 1, v___x_1738_);
v___x_1740_ = 0;
v___x_1741_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_1741_, 0, v___x_1739_);
lean_ctor_set_uint8(v___x_1741_, sizeof(void*)*1, v___x_1740_);
v___x_1742_ = l_Repr_addAppParen(v___x_1741_, v_prec_1728_);
return v___x_1742_;
}
v___jp_1743_:
{
lean_object* v___x_1745_; lean_object* v___x_1746_; uint8_t v___x_1747_; lean_object* v___x_1748_; lean_object* v___x_1749_; 
v___x_1745_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__5));
lean_inc(v___y_1744_);
v___x_1746_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_1746_, 0, v___y_1744_);
lean_ctor_set(v___x_1746_, 1, v___x_1745_);
v___x_1747_ = 0;
v___x_1748_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_1748_, 0, v___x_1746_);
lean_ctor_set_uint8(v___x_1748_, sizeof(void*)*1, v___x_1747_);
v___x_1749_ = l_Repr_addAppParen(v___x_1748_, v_prec_1728_);
return v___x_1749_;
}
v___jp_1750_:
{
lean_object* v___x_1752_; lean_object* v___x_1753_; uint8_t v___x_1754_; lean_object* v___x_1755_; lean_object* v___x_1756_; 
v___x_1752_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprControllerMode_repr___closed__7));
lean_inc(v___y_1751_);
v___x_1753_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_1753_, 0, v___y_1751_);
lean_ctor_set(v___x_1753_, 1, v___x_1752_);
v___x_1754_ = 0;
v___x_1755_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_1755_, 0, v___x_1753_);
lean_ctor_set_uint8(v___x_1755_, sizeof(void*)*1, v___x_1754_);
v___x_1756_ = l_Repr_addAppParen(v___x_1755_, v_prec_1728_);
return v___x_1756_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprControllerMode_repr___boxed(lean_object* v_x_1773_, lean_object* v_prec_1774_){
_start:
{
uint8_t v_x_229__boxed_1775_; lean_object* v_res_1776_; 
v_x_229__boxed_1775_ = lean_unbox(v_x_1773_);
v_res_1776_ = lp_ir_x2dproof_IRProof_instReprControllerMode_repr(v_x_229__boxed_1775_, v_prec_1774_);
lean_dec(v_prec_1774_);
return v_res_1776_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_combinedForceForCommand(lean_object* v_x_1779_, lean_object* v_cmd_1780_){
_start:
{
lean_object* v_massKg_1781_; lean_object* v_designMassKg_1782_; lean_object* v_velocityMps_1783_; lean_object* v_slopeSine_1784_; lean_object* v_slopeMultiplier_1785_; lean_object* v_availableTractionN_1786_; lean_object* v_rollingResistanceN_1787_; lean_object* v_directResistanceN_1788_; lean_object* v_interferenceResistanceN_1789_; lean_object* v_nearZeroResistanceN_1790_; uint8_t v_trainBrakeAvailable_1791_; uint8_t v_independentBrakeAvailable_1792_; lean_object* v_brakeShoeFriction_1793_; lean_object* v_configuredBrakeAdhesionEfficiency_1794_; lean_object* v_configuredBrakeMultiplier_1795_; uint8_t v_cogging_1796_; uint8_t v_wheelSlip_1797_; lean_object* v_curvatureBoundN_1798_; lean_object* v_slackBoundN_1799_; lean_object* v_pushPullBoundN_1800_; lean_object* v___x_1802_; uint8_t v_isShared_1803_; uint8_t v_isSharedCheck_1820_; 
v_massKg_1781_ = lean_ctor_get(v_x_1779_, 0);
v_designMassKg_1782_ = lean_ctor_get(v_x_1779_, 1);
v_velocityMps_1783_ = lean_ctor_get(v_x_1779_, 2);
v_slopeSine_1784_ = lean_ctor_get(v_x_1779_, 3);
v_slopeMultiplier_1785_ = lean_ctor_get(v_x_1779_, 4);
v_availableTractionN_1786_ = lean_ctor_get(v_x_1779_, 6);
v_rollingResistanceN_1787_ = lean_ctor_get(v_x_1779_, 7);
v_directResistanceN_1788_ = lean_ctor_get(v_x_1779_, 8);
v_interferenceResistanceN_1789_ = lean_ctor_get(v_x_1779_, 9);
v_nearZeroResistanceN_1790_ = lean_ctor_get(v_x_1779_, 10);
v_trainBrakeAvailable_1791_ = lean_ctor_get_uint8(v_x_1779_, sizeof(void*)*19);
v_independentBrakeAvailable_1792_ = lean_ctor_get_uint8(v_x_1779_, sizeof(void*)*19 + 1);
v_brakeShoeFriction_1793_ = lean_ctor_get(v_x_1779_, 13);
v_configuredBrakeAdhesionEfficiency_1794_ = lean_ctor_get(v_x_1779_, 14);
v_configuredBrakeMultiplier_1795_ = lean_ctor_get(v_x_1779_, 15);
v_cogging_1796_ = lean_ctor_get_uint8(v_x_1779_, sizeof(void*)*19 + 2);
v_wheelSlip_1797_ = lean_ctor_get_uint8(v_x_1779_, sizeof(void*)*19 + 3);
v_curvatureBoundN_1798_ = lean_ctor_get(v_x_1779_, 16);
v_slackBoundN_1799_ = lean_ctor_get(v_x_1779_, 17);
v_pushPullBoundN_1800_ = lean_ctor_get(v_x_1779_, 18);
v_isSharedCheck_1820_ = !lean_is_exclusive(v_x_1779_);
if (v_isSharedCheck_1820_ == 0)
{
lean_object* v_unused_1821_; lean_object* v_unused_1822_; lean_object* v_unused_1823_; 
v_unused_1821_ = lean_ctor_get(v_x_1779_, 12);
lean_dec(v_unused_1821_);
v_unused_1822_ = lean_ctor_get(v_x_1779_, 11);
lean_dec(v_unused_1822_);
v_unused_1823_ = lean_ctor_get(v_x_1779_, 5);
lean_dec(v_unused_1823_);
v___x_1802_ = v_x_1779_;
v_isShared_1803_ = v_isSharedCheck_1820_;
goto v_resetjp_1801_;
}
else
{
lean_inc(v_pushPullBoundN_1800_);
lean_inc(v_slackBoundN_1799_);
lean_inc(v_curvatureBoundN_1798_);
lean_inc(v_configuredBrakeMultiplier_1795_);
lean_inc(v_configuredBrakeAdhesionEfficiency_1794_);
lean_inc(v_brakeShoeFriction_1793_);
lean_inc(v_nearZeroResistanceN_1790_);
lean_inc(v_interferenceResistanceN_1789_);
lean_inc(v_directResistanceN_1788_);
lean_inc(v_rollingResistanceN_1787_);
lean_inc(v_availableTractionN_1786_);
lean_inc(v_slopeMultiplier_1785_);
lean_inc(v_slopeSine_1784_);
lean_inc(v_velocityMps_1783_);
lean_inc(v_designMassKg_1782_);
lean_inc(v_massKg_1781_);
lean_dec(v_x_1779_);
v___x_1802_ = lean_box(0);
v_isShared_1803_ = v_isSharedCheck_1820_;
goto v_resetjp_1801_;
}
v_resetjp_1801_:
{
lean_object* v_throttle_1804_; lean_object* v_trainBrake_1805_; lean_object* v_independentBrake_1806_; uint8_t v_emergency_1807_; lean_object* v___y_1809_; lean_object* v___y_1810_; lean_object* v___y_1816_; 
v_throttle_1804_ = lean_ctor_get(v_cmd_1780_, 0);
lean_inc_ref(v_throttle_1804_);
v_trainBrake_1805_ = lean_ctor_get(v_cmd_1780_, 1);
lean_inc_ref(v_trainBrake_1805_);
v_independentBrake_1806_ = lean_ctor_get(v_cmd_1780_, 2);
lean_inc_ref(v_independentBrake_1806_);
v_emergency_1807_ = lean_ctor_get_uint8(v_cmd_1780_, sizeof(void*)*3);
lean_dec_ref(v_cmd_1780_);
if (v_trainBrakeAvailable_1791_ == 0)
{
lean_object* v___x_1818_; 
lean_dec_ref(v_trainBrake_1805_);
v___x_1818_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___y_1816_ = v___x_1818_;
goto v___jp_1815_;
}
else
{
if (v_emergency_1807_ == 0)
{
v___y_1816_ = v_trainBrake_1805_;
goto v___jp_1815_;
}
else
{
lean_object* v___x_1819_; 
lean_dec_ref(v_trainBrake_1805_);
v___x_1819_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
v___y_1816_ = v___x_1819_;
goto v___jp_1815_;
}
}
v___jp_1808_:
{
lean_object* v___x_1812_; 
if (v_isShared_1803_ == 0)
{
lean_ctor_set(v___x_1802_, 12, v___y_1810_);
lean_ctor_set(v___x_1802_, 11, v___y_1809_);
lean_ctor_set(v___x_1802_, 5, v_throttle_1804_);
v___x_1812_ = v___x_1802_;
goto v_reusejp_1811_;
}
else
{
lean_object* v_reuseFailAlloc_1814_; 
v_reuseFailAlloc_1814_ = lean_alloc_ctor(0, 19, 4);
lean_ctor_set(v_reuseFailAlloc_1814_, 0, v_massKg_1781_);
lean_ctor_set(v_reuseFailAlloc_1814_, 1, v_designMassKg_1782_);
lean_ctor_set(v_reuseFailAlloc_1814_, 2, v_velocityMps_1783_);
lean_ctor_set(v_reuseFailAlloc_1814_, 3, v_slopeSine_1784_);
lean_ctor_set(v_reuseFailAlloc_1814_, 4, v_slopeMultiplier_1785_);
lean_ctor_set(v_reuseFailAlloc_1814_, 5, v_throttle_1804_);
lean_ctor_set(v_reuseFailAlloc_1814_, 6, v_availableTractionN_1786_);
lean_ctor_set(v_reuseFailAlloc_1814_, 7, v_rollingResistanceN_1787_);
lean_ctor_set(v_reuseFailAlloc_1814_, 8, v_directResistanceN_1788_);
lean_ctor_set(v_reuseFailAlloc_1814_, 9, v_interferenceResistanceN_1789_);
lean_ctor_set(v_reuseFailAlloc_1814_, 10, v_nearZeroResistanceN_1790_);
lean_ctor_set(v_reuseFailAlloc_1814_, 11, v___y_1809_);
lean_ctor_set(v_reuseFailAlloc_1814_, 12, v___y_1810_);
lean_ctor_set(v_reuseFailAlloc_1814_, 13, v_brakeShoeFriction_1793_);
lean_ctor_set(v_reuseFailAlloc_1814_, 14, v_configuredBrakeAdhesionEfficiency_1794_);
lean_ctor_set(v_reuseFailAlloc_1814_, 15, v_configuredBrakeMultiplier_1795_);
lean_ctor_set(v_reuseFailAlloc_1814_, 16, v_curvatureBoundN_1798_);
lean_ctor_set(v_reuseFailAlloc_1814_, 17, v_slackBoundN_1799_);
lean_ctor_set(v_reuseFailAlloc_1814_, 18, v_pushPullBoundN_1800_);
lean_ctor_set_uint8(v_reuseFailAlloc_1814_, sizeof(void*)*19, v_trainBrakeAvailable_1791_);
lean_ctor_set_uint8(v_reuseFailAlloc_1814_, sizeof(void*)*19 + 1, v_independentBrakeAvailable_1792_);
lean_ctor_set_uint8(v_reuseFailAlloc_1814_, sizeof(void*)*19 + 2, v_cogging_1796_);
lean_ctor_set_uint8(v_reuseFailAlloc_1814_, sizeof(void*)*19 + 3, v_wheelSlip_1797_);
v___x_1812_ = v_reuseFailAlloc_1814_;
goto v_reusejp_1811_;
}
v_reusejp_1811_:
{
lean_object* v___x_1813_; 
v___x_1813_ = lp_ir_x2dproof_IRProof_signedNetForceN(v___x_1812_);
return v___x_1813_;
}
}
v___jp_1815_:
{
if (v_independentBrakeAvailable_1792_ == 0)
{
lean_object* v___x_1817_; 
lean_dec_ref(v_independentBrake_1806_);
v___x_1817_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___y_1809_ = v___y_1816_;
v___y_1810_ = v___x_1817_;
goto v___jp_1808_;
}
else
{
v___y_1809_ = v___y_1816_;
v___y_1810_ = v_independentBrake_1806_;
goto v___jp_1808_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandPhysics(lean_object* v_x_1824_, lean_object* v_cmd_1825_){
_start:
{
lean_object* v_massKg_1826_; lean_object* v_designMassKg_1827_; lean_object* v_velocityMps_1828_; lean_object* v_slopeSine_1829_; lean_object* v_slopeMultiplier_1830_; lean_object* v_availableTractionN_1831_; lean_object* v_rollingResistanceN_1832_; lean_object* v_directResistanceN_1833_; lean_object* v_interferenceResistanceN_1834_; lean_object* v_nearZeroResistanceN_1835_; uint8_t v_trainBrakeAvailable_1836_; uint8_t v_independentBrakeAvailable_1837_; lean_object* v_brakeShoeFriction_1838_; lean_object* v_configuredBrakeAdhesionEfficiency_1839_; lean_object* v_configuredBrakeMultiplier_1840_; uint8_t v_cogging_1841_; uint8_t v_wheelSlip_1842_; lean_object* v_curvatureBoundN_1843_; lean_object* v_slackBoundN_1844_; lean_object* v_pushPullBoundN_1845_; lean_object* v___x_1847_; uint8_t v_isShared_1848_; uint8_t v_isSharedCheck_1864_; 
v_massKg_1826_ = lean_ctor_get(v_x_1824_, 0);
v_designMassKg_1827_ = lean_ctor_get(v_x_1824_, 1);
v_velocityMps_1828_ = lean_ctor_get(v_x_1824_, 2);
v_slopeSine_1829_ = lean_ctor_get(v_x_1824_, 3);
v_slopeMultiplier_1830_ = lean_ctor_get(v_x_1824_, 4);
v_availableTractionN_1831_ = lean_ctor_get(v_x_1824_, 6);
v_rollingResistanceN_1832_ = lean_ctor_get(v_x_1824_, 7);
v_directResistanceN_1833_ = lean_ctor_get(v_x_1824_, 8);
v_interferenceResistanceN_1834_ = lean_ctor_get(v_x_1824_, 9);
v_nearZeroResistanceN_1835_ = lean_ctor_get(v_x_1824_, 10);
v_trainBrakeAvailable_1836_ = lean_ctor_get_uint8(v_x_1824_, sizeof(void*)*19);
v_independentBrakeAvailable_1837_ = lean_ctor_get_uint8(v_x_1824_, sizeof(void*)*19 + 1);
v_brakeShoeFriction_1838_ = lean_ctor_get(v_x_1824_, 13);
v_configuredBrakeAdhesionEfficiency_1839_ = lean_ctor_get(v_x_1824_, 14);
v_configuredBrakeMultiplier_1840_ = lean_ctor_get(v_x_1824_, 15);
v_cogging_1841_ = lean_ctor_get_uint8(v_x_1824_, sizeof(void*)*19 + 2);
v_wheelSlip_1842_ = lean_ctor_get_uint8(v_x_1824_, sizeof(void*)*19 + 3);
v_curvatureBoundN_1843_ = lean_ctor_get(v_x_1824_, 16);
v_slackBoundN_1844_ = lean_ctor_get(v_x_1824_, 17);
v_pushPullBoundN_1845_ = lean_ctor_get(v_x_1824_, 18);
v_isSharedCheck_1864_ = !lean_is_exclusive(v_x_1824_);
if (v_isSharedCheck_1864_ == 0)
{
lean_object* v_unused_1865_; lean_object* v_unused_1866_; lean_object* v_unused_1867_; 
v_unused_1865_ = lean_ctor_get(v_x_1824_, 12);
lean_dec(v_unused_1865_);
v_unused_1866_ = lean_ctor_get(v_x_1824_, 11);
lean_dec(v_unused_1866_);
v_unused_1867_ = lean_ctor_get(v_x_1824_, 5);
lean_dec(v_unused_1867_);
v___x_1847_ = v_x_1824_;
v_isShared_1848_ = v_isSharedCheck_1864_;
goto v_resetjp_1846_;
}
else
{
lean_inc(v_pushPullBoundN_1845_);
lean_inc(v_slackBoundN_1844_);
lean_inc(v_curvatureBoundN_1843_);
lean_inc(v_configuredBrakeMultiplier_1840_);
lean_inc(v_configuredBrakeAdhesionEfficiency_1839_);
lean_inc(v_brakeShoeFriction_1838_);
lean_inc(v_nearZeroResistanceN_1835_);
lean_inc(v_interferenceResistanceN_1834_);
lean_inc(v_directResistanceN_1833_);
lean_inc(v_rollingResistanceN_1832_);
lean_inc(v_availableTractionN_1831_);
lean_inc(v_slopeMultiplier_1830_);
lean_inc(v_slopeSine_1829_);
lean_inc(v_velocityMps_1828_);
lean_inc(v_designMassKg_1827_);
lean_inc(v_massKg_1826_);
lean_dec(v_x_1824_);
v___x_1847_ = lean_box(0);
v_isShared_1848_ = v_isSharedCheck_1864_;
goto v_resetjp_1846_;
}
v_resetjp_1846_:
{
lean_object* v_throttle_1849_; lean_object* v_trainBrake_1850_; lean_object* v_independentBrake_1851_; uint8_t v_emergency_1852_; lean_object* v___y_1854_; 
v_throttle_1849_ = lean_ctor_get(v_cmd_1825_, 0);
lean_inc_ref(v_throttle_1849_);
v_trainBrake_1850_ = lean_ctor_get(v_cmd_1825_, 1);
lean_inc_ref(v_trainBrake_1850_);
v_independentBrake_1851_ = lean_ctor_get(v_cmd_1825_, 2);
lean_inc_ref(v_independentBrake_1851_);
v_emergency_1852_ = lean_ctor_get_uint8(v_cmd_1825_, sizeof(void*)*3);
lean_dec_ref(v_cmd_1825_);
if (v_trainBrakeAvailable_1836_ == 0)
{
lean_object* v___x_1862_; 
lean_dec_ref(v_trainBrake_1850_);
v___x_1862_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
v___y_1854_ = v___x_1862_;
goto v___jp_1853_;
}
else
{
if (v_emergency_1852_ == 0)
{
v___y_1854_ = v_trainBrake_1850_;
goto v___jp_1853_;
}
else
{
lean_object* v___x_1863_; 
lean_dec_ref(v_trainBrake_1850_);
v___x_1863_ = lean_obj_once(&lp_ir_x2dproof_IRProof_sat01___closed__0, &lp_ir_x2dproof_IRProof_sat01___closed__0_once, _init_lp_ir_x2dproof_IRProof_sat01___closed__0);
v___y_1854_ = v___x_1863_;
goto v___jp_1853_;
}
}
v___jp_1853_:
{
if (v_independentBrakeAvailable_1837_ == 0)
{
lean_object* v___x_1855_; lean_object* v___x_1857_; 
lean_dec_ref(v_independentBrake_1851_);
v___x_1855_ = lean_obj_once(&lp_ir_x2dproof_IRProof_absQ___closed__0, &lp_ir_x2dproof_IRProof_absQ___closed__0_once, _init_lp_ir_x2dproof_IRProof_absQ___closed__0);
if (v_isShared_1848_ == 0)
{
lean_ctor_set(v___x_1847_, 12, v___x_1855_);
lean_ctor_set(v___x_1847_, 11, v___y_1854_);
lean_ctor_set(v___x_1847_, 5, v_throttle_1849_);
v___x_1857_ = v___x_1847_;
goto v_reusejp_1856_;
}
else
{
lean_object* v_reuseFailAlloc_1858_; 
v_reuseFailAlloc_1858_ = lean_alloc_ctor(0, 19, 4);
lean_ctor_set(v_reuseFailAlloc_1858_, 0, v_massKg_1826_);
lean_ctor_set(v_reuseFailAlloc_1858_, 1, v_designMassKg_1827_);
lean_ctor_set(v_reuseFailAlloc_1858_, 2, v_velocityMps_1828_);
lean_ctor_set(v_reuseFailAlloc_1858_, 3, v_slopeSine_1829_);
lean_ctor_set(v_reuseFailAlloc_1858_, 4, v_slopeMultiplier_1830_);
lean_ctor_set(v_reuseFailAlloc_1858_, 5, v_throttle_1849_);
lean_ctor_set(v_reuseFailAlloc_1858_, 6, v_availableTractionN_1831_);
lean_ctor_set(v_reuseFailAlloc_1858_, 7, v_rollingResistanceN_1832_);
lean_ctor_set(v_reuseFailAlloc_1858_, 8, v_directResistanceN_1833_);
lean_ctor_set(v_reuseFailAlloc_1858_, 9, v_interferenceResistanceN_1834_);
lean_ctor_set(v_reuseFailAlloc_1858_, 10, v_nearZeroResistanceN_1835_);
lean_ctor_set(v_reuseFailAlloc_1858_, 11, v___y_1854_);
lean_ctor_set(v_reuseFailAlloc_1858_, 12, v___x_1855_);
lean_ctor_set(v_reuseFailAlloc_1858_, 13, v_brakeShoeFriction_1838_);
lean_ctor_set(v_reuseFailAlloc_1858_, 14, v_configuredBrakeAdhesionEfficiency_1839_);
lean_ctor_set(v_reuseFailAlloc_1858_, 15, v_configuredBrakeMultiplier_1840_);
lean_ctor_set(v_reuseFailAlloc_1858_, 16, v_curvatureBoundN_1843_);
lean_ctor_set(v_reuseFailAlloc_1858_, 17, v_slackBoundN_1844_);
lean_ctor_set(v_reuseFailAlloc_1858_, 18, v_pushPullBoundN_1845_);
lean_ctor_set_uint8(v_reuseFailAlloc_1858_, sizeof(void*)*19, v_trainBrakeAvailable_1836_);
lean_ctor_set_uint8(v_reuseFailAlloc_1858_, sizeof(void*)*19 + 1, v_independentBrakeAvailable_1837_);
lean_ctor_set_uint8(v_reuseFailAlloc_1858_, sizeof(void*)*19 + 2, v_cogging_1841_);
lean_ctor_set_uint8(v_reuseFailAlloc_1858_, sizeof(void*)*19 + 3, v_wheelSlip_1842_);
v___x_1857_ = v_reuseFailAlloc_1858_;
goto v_reusejp_1856_;
}
v_reusejp_1856_:
{
return v___x_1857_;
}
}
else
{
lean_object* v___x_1860_; 
if (v_isShared_1848_ == 0)
{
lean_ctor_set(v___x_1847_, 12, v_independentBrake_1851_);
lean_ctor_set(v___x_1847_, 11, v___y_1854_);
lean_ctor_set(v___x_1847_, 5, v_throttle_1849_);
v___x_1860_ = v___x_1847_;
goto v_reusejp_1859_;
}
else
{
lean_object* v_reuseFailAlloc_1861_; 
v_reuseFailAlloc_1861_ = lean_alloc_ctor(0, 19, 4);
lean_ctor_set(v_reuseFailAlloc_1861_, 0, v_massKg_1826_);
lean_ctor_set(v_reuseFailAlloc_1861_, 1, v_designMassKg_1827_);
lean_ctor_set(v_reuseFailAlloc_1861_, 2, v_velocityMps_1828_);
lean_ctor_set(v_reuseFailAlloc_1861_, 3, v_slopeSine_1829_);
lean_ctor_set(v_reuseFailAlloc_1861_, 4, v_slopeMultiplier_1830_);
lean_ctor_set(v_reuseFailAlloc_1861_, 5, v_throttle_1849_);
lean_ctor_set(v_reuseFailAlloc_1861_, 6, v_availableTractionN_1831_);
lean_ctor_set(v_reuseFailAlloc_1861_, 7, v_rollingResistanceN_1832_);
lean_ctor_set(v_reuseFailAlloc_1861_, 8, v_directResistanceN_1833_);
lean_ctor_set(v_reuseFailAlloc_1861_, 9, v_interferenceResistanceN_1834_);
lean_ctor_set(v_reuseFailAlloc_1861_, 10, v_nearZeroResistanceN_1835_);
lean_ctor_set(v_reuseFailAlloc_1861_, 11, v___y_1854_);
lean_ctor_set(v_reuseFailAlloc_1861_, 12, v_independentBrake_1851_);
lean_ctor_set(v_reuseFailAlloc_1861_, 13, v_brakeShoeFriction_1838_);
lean_ctor_set(v_reuseFailAlloc_1861_, 14, v_configuredBrakeAdhesionEfficiency_1839_);
lean_ctor_set(v_reuseFailAlloc_1861_, 15, v_configuredBrakeMultiplier_1840_);
lean_ctor_set(v_reuseFailAlloc_1861_, 16, v_curvatureBoundN_1843_);
lean_ctor_set(v_reuseFailAlloc_1861_, 17, v_slackBoundN_1844_);
lean_ctor_set(v_reuseFailAlloc_1861_, 18, v_pushPullBoundN_1845_);
lean_ctor_set_uint8(v_reuseFailAlloc_1861_, sizeof(void*)*19, v_trainBrakeAvailable_1836_);
lean_ctor_set_uint8(v_reuseFailAlloc_1861_, sizeof(void*)*19 + 1, v_independentBrakeAvailable_1837_);
lean_ctor_set_uint8(v_reuseFailAlloc_1861_, sizeof(void*)*19 + 2, v_cogging_1841_);
lean_ctor_set_uint8(v_reuseFailAlloc_1861_, sizeof(void*)*19 + 3, v_wheelSlip_1842_);
v___x_1860_ = v_reuseFailAlloc_1861_;
goto v_reusejp_1859_;
}
v_reusejp_1859_:
{
return v___x_1860_;
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_plantTransition(lean_object* v_dt_1868_, lean_object* v_p_1869_, lean_object* v_cmd_1870_){
_start:
{
lean_object* v_positionS_1871_; lean_object* v_velocityMps_1872_; lean_object* v_physics_1873_; lean_object* v___x_1875_; uint8_t v_isShared_1876_; uint8_t v_isSharedCheck_1888_; 
v_positionS_1871_ = lean_ctor_get(v_p_1869_, 0);
v_velocityMps_1872_ = lean_ctor_get(v_p_1869_, 1);
v_physics_1873_ = lean_ctor_get(v_p_1869_, 2);
v_isSharedCheck_1888_ = !lean_is_exclusive(v_p_1869_);
if (v_isSharedCheck_1888_ == 0)
{
v___x_1875_ = v_p_1869_;
v_isShared_1876_ = v_isSharedCheck_1888_;
goto v_resetjp_1874_;
}
else
{
lean_inc(v_physics_1873_);
lean_inc(v_velocityMps_1872_);
lean_inc(v_positionS_1871_);
lean_dec(v_p_1869_);
v___x_1875_ = lean_box(0);
v_isShared_1876_ = v_isSharedCheck_1888_;
goto v_resetjp_1874_;
}
v_resetjp_1874_:
{
lean_object* v_x_1877_; lean_object* v_massKg_1878_; lean_object* v___x_1879_; lean_object* v___x_1880_; lean_object* v___x_1881_; lean_object* v___x_1882_; lean_object* v___x_1883_; lean_object* v___x_1884_; lean_object* v___x_1886_; 
v_x_1877_ = lp_ir_x2dproof_IRProof_commandPhysics(v_physics_1873_, v_cmd_1870_);
v_massKg_1878_ = lean_ctor_get(v_x_1877_, 0);
lean_inc_ref(v_massKg_1878_);
lean_inc_ref(v_dt_1868_);
v___x_1879_ = l_Rat_mul(v_velocityMps_1872_, v_dt_1868_);
v___x_1880_ = l_Rat_add(v_positionS_1871_, v___x_1879_);
lean_inc_ref(v_x_1877_);
v___x_1881_ = lp_ir_x2dproof_IRProof_signedNetForceN(v_x_1877_);
v___x_1882_ = l_Rat_div(v___x_1881_, v_massKg_1878_);
lean_dec_ref(v___x_1881_);
v___x_1883_ = l_Rat_mul(v___x_1882_, v_dt_1868_);
lean_dec_ref(v___x_1882_);
v___x_1884_ = l_Rat_add(v_velocityMps_1872_, v___x_1883_);
if (v_isShared_1876_ == 0)
{
lean_ctor_set(v___x_1875_, 2, v_x_1877_);
lean_ctor_set(v___x_1875_, 1, v___x_1884_);
lean_ctor_set(v___x_1875_, 0, v___x_1880_);
v___x_1886_ = v___x_1875_;
goto v_reusejp_1885_;
}
else
{
lean_object* v_reuseFailAlloc_1887_; 
v_reuseFailAlloc_1887_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_1887_, 0, v___x_1880_);
lean_ctor_set(v_reuseFailAlloc_1887_, 1, v___x_1884_);
lean_ctor_set(v_reuseFailAlloc_1887_, 2, v_x_1877_);
v___x_1886_ = v_reuseFailAlloc_1887_;
goto v_reusejp_1885_;
}
v_reusejp_1885_:
{
return v___x_1886_;
}
}
}
}
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Lean(uint8_t builtin);
lean_object* initialize_Lean_Elab_Tactic_Grind_Main(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_ir_x2dproof_IRProof(uint8_t builtin) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Lean(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Lean_Elab_Tactic_Grind_Main(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
lp_ir_x2dproof_IRProof_steelStatic = _init_lp_ir_x2dproof_IRProof_steelStatic();
lean_mark_persistent(lp_ir_x2dproof_IRProof_steelStatic);
lp_ir_x2dproof_IRProof_steelKinetic = _init_lp_ir_x2dproof_IRProof_steelKinetic();
lean_mark_persistent(lp_ir_x2dproof_IRProof_steelKinetic);
lp_ir_x2dproof_IRProof_steelCastIronKinetic = _init_lp_ir_x2dproof_IRProof_steelCastIronKinetic();
lean_mark_persistent(lp_ir_x2dproof_IRProof_steelCastIronKinetic);
lp_ir_x2dproof_IRProof_gravity = _init_lp_ir_x2dproof_IRProof_gravity();
lean_mark_persistent(lp_ir_x2dproof_IRProof_gravity);
lp_ir_x2dproof_IRProof_defaultBrakeMultiplier = _init_lp_ir_x2dproof_IRProof_defaultBrakeMultiplier();
lean_mark_persistent(lp_ir_x2dproof_IRProof_defaultBrakeMultiplier);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
