// Lean compiler output
// Module: IRCertifiedModel
// Imports: public import Init public meta import Init public import IRProof
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
lean_object* lean_nat_to_int(lean_object*);
lean_object* lean_string_append(lean_object*, lean_object*);
lean_object* l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(lean_object*);
uint8_t lean_string_dec_eq(lean_object*, lean_object*);
lean_object* l_Repr_addAppParen(lean_object*, lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
lean_object* lean_nat_sub(lean_object*, lean_object*);
lean_object* l_List_reverse___redArg(lean_object*);
lean_object* lp_ir_x2dproof_IRProof_plantTransition(lean_object*, lean_object*, lean_object*);
uint8_t l_Rat_instDecidableLe(lean_object*, lean_object*);
lean_object* lp_ir_x2dproof_IRProof_mapMarker(lean_object*, lean_object*, lean_object*, lean_object*);
uint8_t lp_ir_x2dproof_IRProof_routeEdgeSetValid(lean_object*, lean_object*);
lean_object* l_List_appendTR___redArg(lean_object*, lean_object*);
lean_object* lean_nat_add(lean_object*, lean_object*);
uint8_t lp_ir_x2dproof_IRProof_containsString(lean_object*, lean_object*);
uint8_t l_Rat_blt(lean_object*, lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
lean_object* lean_array_to_list(lean_object*);
lean_object* l_List_foldl___at___00Array_appendList_spec__0___redArg(lean_object*, lean_object*);
lean_object* lean_mk_empty_array_with_capacity(lean_object*);
lean_object* lp_ir_x2dproof_IRProof_certifiedBrakeStep(lean_object*, lean_object*, lean_object*);
lean_object* lp_ir_x2dproof_IRProof_profileFingerprints(lean_object*);
lean_object* lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint___boxed(lean_object*, lean_object*);
uint8_t l_instDecidableEqList___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_qLeBool(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_qLeBool___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_qLtBool(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_qLtBool___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_ReconstructionKind_ofNat(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ofNat___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqReconstructionKind(uint8_t, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqReconstructionKind___boxed(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 40, .m_capacity = 40, .m_length = 39, .m_data = "IRProof.ReconstructionKind.continuation"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__0_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__0_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__1 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__1_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 37, .m_capacity = 37, .m_length = 36, .m_data = "IRProof.ReconstructionKind.extension"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__2 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__2_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__2_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__3 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__3_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 33, .m_capacity = 33, .m_length = 32, .m_data = "IRProof.ReconstructionKind.split"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__4 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__4_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__4_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__5 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__5_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 35, .m_capacity = 35, .m_length = 34, .m_data = "IRProof.ReconstructionKind.overlap"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__6 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__6_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__7_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__6_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__7 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__7_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__8_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 44, .m_capacity = 44, .m_length = 43, .m_data = "IRProof.ReconstructionKind.sharedConnection"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__8 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__8_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__9_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__8_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__9 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__9_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__10_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 44, .m_capacity = 44, .m_length = 43, .m_data = "IRProof.ReconstructionKind.isolatedCrossing"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__10 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__10_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__11_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__10_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__11 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__11_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__12_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 36, .m_capacity = 36, .m_length = 35, .m_data = "IRProof.ReconstructionKind.overpass"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__12 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__12_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__13_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__12_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__13 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__13_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__14_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 39, .m_capacity = 39, .m_length = 38, .m_data = "IRProof.ReconstructionKind.newGeometry"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__14 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__14_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__15_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__14_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__15 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__15_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__16_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 38, .m_capacity = 38, .m_length = 37, .m_data = "IRProof.ReconstructionKind.unresolved"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__16 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__16_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__17_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__16_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__17 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__17_value;
static lean_once_cell_t lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18;
static lean_once_cell_t lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_ir_x2dproof_IRProof_instReprReconstructionKind___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind___closed__0_value;
LEAN_EXPORT const lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprReconstructionKind___closed__0_value;
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_matchWithinBool(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_matchWithinBool___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_reconstructionKind(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_reconstructionKind___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_reconstructionRoutable(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_reconstructionRoutable___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter___redArg(uint8_t, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter___redArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter(lean_object*, uint8_t, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_splineIdPresent(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineIdPresent___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_appendSplineIfNew(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_addTraceId(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commitReconstruction(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_endpointName___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 5, .m_capacity = 5, .m_length = 4, .m_data = ":end"};
static const lean_object* lp_ir_x2dproof_IRProof_endpointName___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_endpointName___closed__0_value;
static const lean_string_object lp_ir_x2dproof_IRProof_endpointName___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 7, .m_capacity = 7, .m_length = 6, .m_data = ":start"};
static const lean_object* lp_ir_x2dproof_IRProof_endpointName___closed__1 = (const lean_object*)&lp_ir_x2dproof_IRProof_endpointName___closed__1_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_endpointName(lean_object*, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_endpointName___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_connectionMatches(lean_object*, lean_object*, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_connectionMatches___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_resolvedEndpoint_spec__0(lean_object*, uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_resolvedEndpoint_spec__0___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_resolvedEndpoint(lean_object*, lean_object*, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_resolvedEndpoint___boxed(lean_object*, lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_splineForwardEdge___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 9, .m_capacity = 9, .m_length = 8, .m_data = ":forward"};
static const lean_object* lp_ir_x2dproof_IRProof_splineForwardEdge___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_splineForwardEdge___closed__0_value;
static lean_once_cell_t lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineForwardEdge(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineForwardEdge___boxed(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_splineReverseEdge___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 9, .m_capacity = 9, .m_length = 8, .m_data = ":reverse"};
static const lean_object* lp_ir_x2dproof_IRProof_splineReverseEdge___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_splineReverseEdge___closed__0_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineReverseEdge(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineReverseEdge___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineEndpointVertices(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_connectionVertices_spec__0(lean_object*, lean_object*);
static const lean_array_object lp_ir_x2dproof_IRProof_connectionVertices___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_array_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 246}, .m_size = 0, .m_capacity = 0, .m_data = {}};
static const lean_object* lp_ir_x2dproof_IRProof_connectionVertices___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_connectionVertices___closed__0_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_connectionVertices(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__1(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__1___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_buildRoutingGraph(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_closestCandidate(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_mapClosestMarker(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_RouteAction_ofNat(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ofNat___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqRouteAction(uint8_t, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqRouteAction___boxed(lean_object*, lean_object*);
static const lean_string_object lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 29, .m_capacity = 29, .m_length = 28, .m_data = "IRProof.RouteAction.continue"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__0_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__0_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__1 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__1_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 27, .m_capacity = 27, .m_length = 26, .m_data = "IRProof.RouteAction.replan"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__2 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__2_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__2_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__3 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__3_value;
static const lean_string_object lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 31, .m_capacity = 31, .m_length = 30, .m_data = "IRProof.RouteAction.failClosed"};
static const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__4 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__4_value;
static const lean_ctor_object lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__4_value)}};
static const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__5 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__5_value;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_ir_x2dproof_IRProof_instReprRouteAction___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_ir_x2dproof_IRProof_instReprRouteAction_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction___closed__0 = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction___closed__0_value;
LEAN_EXPORT const lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction = (const lean_object*)&lp_ir_x2dproof_IRProof_instReprRouteAction___closed__0_value;
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeAction(lean_object*, lean_object*, lean_object*, uint8_t);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeAction___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_freezeProfile(lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_frozenProfileMatches(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_frozenProfileMatches___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_optionQOrZero(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_optionQOrZero___boxed(lean_object*);
static lean_once_cell_t lp_ir_x2dproof_IRProof_physicsFromObservation___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_ir_x2dproof_IRProof_physicsFromObservation___closed__0;
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_physicsFromObservation(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_physicsFromObservation___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profilePhysics_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profilePhysics(lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_commandConsistStep_spec__0(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandConsistStep(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalStep(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalStep___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalRun(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalRun___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter___redArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_qLeBool(lean_object* v_a_1_, lean_object* v_b_2_){
_start:
{
uint8_t v___x_3_; 
v___x_3_ = l_Rat_instDecidableLe(v_a_1_, v_b_2_);
return v___x_3_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_qLeBool___boxed(lean_object* v_a_4_, lean_object* v_b_5_){
_start:
{
uint8_t v_res_6_; lean_object* v_r_7_; 
v_res_6_ = lp_ir_x2dproof_IRProof_qLeBool(v_a_4_, v_b_5_);
v_r_7_ = lean_box(v_res_6_);
return v_r_7_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_qLtBool(lean_object* v_a_8_, lean_object* v_b_9_){
_start:
{
uint8_t v___x_10_; 
v___x_10_ = l_Rat_blt(v_a_8_, v_b_9_);
return v___x_10_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_qLtBool___boxed(lean_object* v_a_11_, lean_object* v_b_12_){
_start:
{
uint8_t v_res_13_; lean_object* v_r_14_; 
v_res_13_ = lp_ir_x2dproof_IRProof_qLtBool(v_a_11_, v_b_12_);
v_r_14_ = lean_box(v_res_13_);
return v_r_14_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx(uint8_t v_x_15_){
_start:
{
switch(v_x_15_)
{
case 0:
{
lean_object* v___x_16_; 
v___x_16_ = lean_unsigned_to_nat(0u);
return v___x_16_;
}
case 1:
{
lean_object* v___x_17_; 
v___x_17_ = lean_unsigned_to_nat(1u);
return v___x_17_;
}
case 2:
{
lean_object* v___x_18_; 
v___x_18_ = lean_unsigned_to_nat(2u);
return v___x_18_;
}
case 3:
{
lean_object* v___x_19_; 
v___x_19_ = lean_unsigned_to_nat(3u);
return v___x_19_;
}
case 4:
{
lean_object* v___x_20_; 
v___x_20_ = lean_unsigned_to_nat(4u);
return v___x_20_;
}
case 5:
{
lean_object* v___x_21_; 
v___x_21_ = lean_unsigned_to_nat(5u);
return v___x_21_;
}
case 6:
{
lean_object* v___x_22_; 
v___x_22_ = lean_unsigned_to_nat(6u);
return v___x_22_;
}
case 7:
{
lean_object* v___x_23_; 
v___x_23_ = lean_unsigned_to_nat(7u);
return v___x_23_;
}
default: 
{
lean_object* v___x_24_; 
v___x_24_ = lean_unsigned_to_nat(8u);
return v___x_24_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx___boxed(lean_object* v_x_25_){
_start:
{
uint8_t v_x_boxed_26_; lean_object* v_res_27_; 
v_x_boxed_26_ = lean_unbox(v_x_25_);
v_res_27_ = lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx(v_x_boxed_26_);
return v_res_27_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_toCtorIdx(uint8_t v_x_28_){
_start:
{
lean_object* v___x_29_; 
v___x_29_ = lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx(v_x_28_);
return v___x_29_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_toCtorIdx___boxed(lean_object* v_x_30_){
_start:
{
uint8_t v_x_4__boxed_31_; lean_object* v_res_32_; 
v_x_4__boxed_31_ = lean_unbox(v_x_30_);
v_res_32_ = lp_ir_x2dproof_IRProof_ReconstructionKind_toCtorIdx(v_x_4__boxed_31_);
return v_res_32_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim___redArg(lean_object* v_k_33_){
_start:
{
lean_inc(v_k_33_);
return v_k_33_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim___redArg___boxed(lean_object* v_k_34_){
_start:
{
lean_object* v_res_35_; 
v_res_35_ = lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim___redArg(v_k_34_);
lean_dec(v_k_34_);
return v_res_35_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim(lean_object* v_motive_36_, lean_object* v_ctorIdx_37_, uint8_t v_t_38_, lean_object* v_h_39_, lean_object* v_k_40_){
_start:
{
lean_inc(v_k_40_);
return v_k_40_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim___boxed(lean_object* v_motive_41_, lean_object* v_ctorIdx_42_, lean_object* v_t_43_, lean_object* v_h_44_, lean_object* v_k_45_){
_start:
{
uint8_t v_t_boxed_46_; lean_object* v_res_47_; 
v_t_boxed_46_ = lean_unbox(v_t_43_);
v_res_47_ = lp_ir_x2dproof_IRProof_ReconstructionKind_ctorElim(v_motive_41_, v_ctorIdx_42_, v_t_boxed_46_, v_h_44_, v_k_45_);
lean_dec(v_k_45_);
lean_dec(v_ctorIdx_42_);
return v_res_47_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim___redArg(lean_object* v_continuation_48_){
_start:
{
lean_inc(v_continuation_48_);
return v_continuation_48_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim___redArg___boxed(lean_object* v_continuation_49_){
_start:
{
lean_object* v_res_50_; 
v_res_50_ = lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim___redArg(v_continuation_49_);
lean_dec(v_continuation_49_);
return v_res_50_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim(lean_object* v_motive_51_, uint8_t v_t_52_, lean_object* v_h_53_, lean_object* v_continuation_54_){
_start:
{
lean_inc(v_continuation_54_);
return v_continuation_54_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim___boxed(lean_object* v_motive_55_, lean_object* v_t_56_, lean_object* v_h_57_, lean_object* v_continuation_58_){
_start:
{
uint8_t v_t_boxed_59_; lean_object* v_res_60_; 
v_t_boxed_59_ = lean_unbox(v_t_56_);
v_res_60_ = lp_ir_x2dproof_IRProof_ReconstructionKind_continuation_elim(v_motive_55_, v_t_boxed_59_, v_h_57_, v_continuation_58_);
lean_dec(v_continuation_58_);
return v_res_60_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim___redArg(lean_object* v_extension_61_){
_start:
{
lean_inc(v_extension_61_);
return v_extension_61_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim___redArg___boxed(lean_object* v_extension_62_){
_start:
{
lean_object* v_res_63_; 
v_res_63_ = lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim___redArg(v_extension_62_);
lean_dec(v_extension_62_);
return v_res_63_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim(lean_object* v_motive_64_, uint8_t v_t_65_, lean_object* v_h_66_, lean_object* v_extension_67_){
_start:
{
lean_inc(v_extension_67_);
return v_extension_67_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim___boxed(lean_object* v_motive_68_, lean_object* v_t_69_, lean_object* v_h_70_, lean_object* v_extension_71_){
_start:
{
uint8_t v_t_boxed_72_; lean_object* v_res_73_; 
v_t_boxed_72_ = lean_unbox(v_t_69_);
v_res_73_ = lp_ir_x2dproof_IRProof_ReconstructionKind_extension_elim(v_motive_68_, v_t_boxed_72_, v_h_70_, v_extension_71_);
lean_dec(v_extension_71_);
return v_res_73_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim___redArg(lean_object* v_split_74_){
_start:
{
lean_inc(v_split_74_);
return v_split_74_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim___redArg___boxed(lean_object* v_split_75_){
_start:
{
lean_object* v_res_76_; 
v_res_76_ = lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim___redArg(v_split_75_);
lean_dec(v_split_75_);
return v_res_76_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim(lean_object* v_motive_77_, uint8_t v_t_78_, lean_object* v_h_79_, lean_object* v_split_80_){
_start:
{
lean_inc(v_split_80_);
return v_split_80_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim___boxed(lean_object* v_motive_81_, lean_object* v_t_82_, lean_object* v_h_83_, lean_object* v_split_84_){
_start:
{
uint8_t v_t_boxed_85_; lean_object* v_res_86_; 
v_t_boxed_85_ = lean_unbox(v_t_82_);
v_res_86_ = lp_ir_x2dproof_IRProof_ReconstructionKind_split_elim(v_motive_81_, v_t_boxed_85_, v_h_83_, v_split_84_);
lean_dec(v_split_84_);
return v_res_86_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim___redArg(lean_object* v_overlap_87_){
_start:
{
lean_inc(v_overlap_87_);
return v_overlap_87_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim___redArg___boxed(lean_object* v_overlap_88_){
_start:
{
lean_object* v_res_89_; 
v_res_89_ = lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim___redArg(v_overlap_88_);
lean_dec(v_overlap_88_);
return v_res_89_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim(lean_object* v_motive_90_, uint8_t v_t_91_, lean_object* v_h_92_, lean_object* v_overlap_93_){
_start:
{
lean_inc(v_overlap_93_);
return v_overlap_93_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim___boxed(lean_object* v_motive_94_, lean_object* v_t_95_, lean_object* v_h_96_, lean_object* v_overlap_97_){
_start:
{
uint8_t v_t_boxed_98_; lean_object* v_res_99_; 
v_t_boxed_98_ = lean_unbox(v_t_95_);
v_res_99_ = lp_ir_x2dproof_IRProof_ReconstructionKind_overlap_elim(v_motive_94_, v_t_boxed_98_, v_h_96_, v_overlap_97_);
lean_dec(v_overlap_97_);
return v_res_99_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim___redArg(lean_object* v_sharedConnection_100_){
_start:
{
lean_inc(v_sharedConnection_100_);
return v_sharedConnection_100_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim___redArg___boxed(lean_object* v_sharedConnection_101_){
_start:
{
lean_object* v_res_102_; 
v_res_102_ = lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim___redArg(v_sharedConnection_101_);
lean_dec(v_sharedConnection_101_);
return v_res_102_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim(lean_object* v_motive_103_, uint8_t v_t_104_, lean_object* v_h_105_, lean_object* v_sharedConnection_106_){
_start:
{
lean_inc(v_sharedConnection_106_);
return v_sharedConnection_106_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim___boxed(lean_object* v_motive_107_, lean_object* v_t_108_, lean_object* v_h_109_, lean_object* v_sharedConnection_110_){
_start:
{
uint8_t v_t_boxed_111_; lean_object* v_res_112_; 
v_t_boxed_111_ = lean_unbox(v_t_108_);
v_res_112_ = lp_ir_x2dproof_IRProof_ReconstructionKind_sharedConnection_elim(v_motive_107_, v_t_boxed_111_, v_h_109_, v_sharedConnection_110_);
lean_dec(v_sharedConnection_110_);
return v_res_112_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim___redArg(lean_object* v_isolatedCrossing_113_){
_start:
{
lean_inc(v_isolatedCrossing_113_);
return v_isolatedCrossing_113_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim___redArg___boxed(lean_object* v_isolatedCrossing_114_){
_start:
{
lean_object* v_res_115_; 
v_res_115_ = lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim___redArg(v_isolatedCrossing_114_);
lean_dec(v_isolatedCrossing_114_);
return v_res_115_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim(lean_object* v_motive_116_, uint8_t v_t_117_, lean_object* v_h_118_, lean_object* v_isolatedCrossing_119_){
_start:
{
lean_inc(v_isolatedCrossing_119_);
return v_isolatedCrossing_119_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim___boxed(lean_object* v_motive_120_, lean_object* v_t_121_, lean_object* v_h_122_, lean_object* v_isolatedCrossing_123_){
_start:
{
uint8_t v_t_boxed_124_; lean_object* v_res_125_; 
v_t_boxed_124_ = lean_unbox(v_t_121_);
v_res_125_ = lp_ir_x2dproof_IRProof_ReconstructionKind_isolatedCrossing_elim(v_motive_120_, v_t_boxed_124_, v_h_122_, v_isolatedCrossing_123_);
lean_dec(v_isolatedCrossing_123_);
return v_res_125_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim___redArg(lean_object* v_overpass_126_){
_start:
{
lean_inc(v_overpass_126_);
return v_overpass_126_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim___redArg___boxed(lean_object* v_overpass_127_){
_start:
{
lean_object* v_res_128_; 
v_res_128_ = lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim___redArg(v_overpass_127_);
lean_dec(v_overpass_127_);
return v_res_128_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim(lean_object* v_motive_129_, uint8_t v_t_130_, lean_object* v_h_131_, lean_object* v_overpass_132_){
_start:
{
lean_inc(v_overpass_132_);
return v_overpass_132_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim___boxed(lean_object* v_motive_133_, lean_object* v_t_134_, lean_object* v_h_135_, lean_object* v_overpass_136_){
_start:
{
uint8_t v_t_boxed_137_; lean_object* v_res_138_; 
v_t_boxed_137_ = lean_unbox(v_t_134_);
v_res_138_ = lp_ir_x2dproof_IRProof_ReconstructionKind_overpass_elim(v_motive_133_, v_t_boxed_137_, v_h_135_, v_overpass_136_);
lean_dec(v_overpass_136_);
return v_res_138_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim___redArg(lean_object* v_newGeometry_139_){
_start:
{
lean_inc(v_newGeometry_139_);
return v_newGeometry_139_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim___redArg___boxed(lean_object* v_newGeometry_140_){
_start:
{
lean_object* v_res_141_; 
v_res_141_ = lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim___redArg(v_newGeometry_140_);
lean_dec(v_newGeometry_140_);
return v_res_141_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim(lean_object* v_motive_142_, uint8_t v_t_143_, lean_object* v_h_144_, lean_object* v_newGeometry_145_){
_start:
{
lean_inc(v_newGeometry_145_);
return v_newGeometry_145_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim___boxed(lean_object* v_motive_146_, lean_object* v_t_147_, lean_object* v_h_148_, lean_object* v_newGeometry_149_){
_start:
{
uint8_t v_t_boxed_150_; lean_object* v_res_151_; 
v_t_boxed_150_ = lean_unbox(v_t_147_);
v_res_151_ = lp_ir_x2dproof_IRProof_ReconstructionKind_newGeometry_elim(v_motive_146_, v_t_boxed_150_, v_h_148_, v_newGeometry_149_);
lean_dec(v_newGeometry_149_);
return v_res_151_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim___redArg(lean_object* v_unresolved_152_){
_start:
{
lean_inc(v_unresolved_152_);
return v_unresolved_152_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim___redArg___boxed(lean_object* v_unresolved_153_){
_start:
{
lean_object* v_res_154_; 
v_res_154_ = lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim___redArg(v_unresolved_153_);
lean_dec(v_unresolved_153_);
return v_res_154_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim(lean_object* v_motive_155_, uint8_t v_t_156_, lean_object* v_h_157_, lean_object* v_unresolved_158_){
_start:
{
lean_inc(v_unresolved_158_);
return v_unresolved_158_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim___boxed(lean_object* v_motive_159_, lean_object* v_t_160_, lean_object* v_h_161_, lean_object* v_unresolved_162_){
_start:
{
uint8_t v_t_boxed_163_; lean_object* v_res_164_; 
v_t_boxed_163_ = lean_unbox(v_t_160_);
v_res_164_ = lp_ir_x2dproof_IRProof_ReconstructionKind_unresolved_elim(v_motive_159_, v_t_boxed_163_, v_h_161_, v_unresolved_162_);
lean_dec(v_unresolved_162_);
return v_res_164_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_ReconstructionKind_ofNat(lean_object* v_n_165_){
_start:
{
lean_object* v___x_166_; uint8_t v___x_167_; 
v___x_166_ = lean_unsigned_to_nat(3u);
v___x_167_ = lean_nat_dec_le(v_n_165_, v___x_166_);
if (v___x_167_ == 0)
{
lean_object* v___x_168_; uint8_t v___x_169_; 
v___x_168_ = lean_unsigned_to_nat(5u);
v___x_169_ = lean_nat_dec_le(v_n_165_, v___x_168_);
if (v___x_169_ == 0)
{
lean_object* v___x_170_; uint8_t v___x_171_; 
v___x_170_ = lean_unsigned_to_nat(6u);
v___x_171_ = lean_nat_dec_le(v_n_165_, v___x_170_);
if (v___x_171_ == 0)
{
lean_object* v___x_172_; uint8_t v___x_173_; 
v___x_172_ = lean_unsigned_to_nat(7u);
v___x_173_ = lean_nat_dec_le(v_n_165_, v___x_172_);
if (v___x_173_ == 0)
{
uint8_t v___x_174_; 
v___x_174_ = 8;
return v___x_174_;
}
else
{
uint8_t v___x_175_; 
v___x_175_ = 7;
return v___x_175_;
}
}
else
{
uint8_t v___x_176_; 
v___x_176_ = 6;
return v___x_176_;
}
}
else
{
lean_object* v___x_177_; uint8_t v___x_178_; 
v___x_177_ = lean_unsigned_to_nat(4u);
v___x_178_ = lean_nat_dec_le(v_n_165_, v___x_177_);
if (v___x_178_ == 0)
{
uint8_t v___x_179_; 
v___x_179_ = 5;
return v___x_179_;
}
else
{
uint8_t v___x_180_; 
v___x_180_ = 4;
return v___x_180_;
}
}
}
else
{
lean_object* v___x_181_; uint8_t v___x_182_; 
v___x_181_ = lean_unsigned_to_nat(1u);
v___x_182_ = lean_nat_dec_le(v_n_165_, v___x_181_);
if (v___x_182_ == 0)
{
lean_object* v___x_183_; uint8_t v___x_184_; 
v___x_183_ = lean_unsigned_to_nat(2u);
v___x_184_ = lean_nat_dec_le(v_n_165_, v___x_183_);
if (v___x_184_ == 0)
{
uint8_t v___x_185_; 
v___x_185_ = 3;
return v___x_185_;
}
else
{
uint8_t v___x_186_; 
v___x_186_ = 2;
return v___x_186_;
}
}
else
{
lean_object* v___x_187_; uint8_t v___x_188_; 
v___x_187_ = lean_unsigned_to_nat(0u);
v___x_188_ = lean_nat_dec_le(v_n_165_, v___x_187_);
if (v___x_188_ == 0)
{
uint8_t v___x_189_; 
v___x_189_ = 1;
return v___x_189_;
}
else
{
uint8_t v___x_190_; 
v___x_190_ = 0;
return v___x_190_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_ReconstructionKind_ofNat___boxed(lean_object* v_n_191_){
_start:
{
uint8_t v_res_192_; lean_object* v_r_193_; 
v_res_192_ = lp_ir_x2dproof_IRProof_ReconstructionKind_ofNat(v_n_191_);
lean_dec(v_n_191_);
v_r_193_ = lean_box(v_res_192_);
return v_r_193_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqReconstructionKind(uint8_t v_x_194_, uint8_t v_y_195_){
_start:
{
lean_object* v___x_196_; lean_object* v___x_197_; uint8_t v___x_198_; 
v___x_196_ = lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx(v_x_194_);
v___x_197_ = lp_ir_x2dproof_IRProof_ReconstructionKind_ctorIdx(v_y_195_);
v___x_198_ = lean_nat_dec_eq(v___x_196_, v___x_197_);
lean_dec(v___x_197_);
lean_dec(v___x_196_);
return v___x_198_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqReconstructionKind___boxed(lean_object* v_x_199_, lean_object* v_y_200_){
_start:
{
uint8_t v_x_13__boxed_201_; uint8_t v_y_14__boxed_202_; uint8_t v_res_203_; lean_object* v_r_204_; 
v_x_13__boxed_201_ = lean_unbox(v_x_199_);
v_y_14__boxed_202_ = lean_unbox(v_y_200_);
v_res_203_ = lp_ir_x2dproof_IRProof_instDecidableEqReconstructionKind(v_x_13__boxed_201_, v_y_14__boxed_202_);
v_r_204_ = lean_box(v_res_203_);
return v_r_204_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18(void){
_start:
{
lean_object* v___x_232_; lean_object* v___x_233_; 
v___x_232_ = lean_unsigned_to_nat(2u);
v___x_233_ = lean_nat_to_int(v___x_232_);
return v___x_233_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19(void){
_start:
{
lean_object* v___x_234_; lean_object* v___x_235_; 
v___x_234_ = lean_unsigned_to_nat(1u);
v___x_235_ = lean_nat_to_int(v___x_234_);
return v___x_235_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr(uint8_t v_x_236_, lean_object* v_prec_237_){
_start:
{
lean_object* v___y_239_; lean_object* v___y_246_; lean_object* v___y_253_; lean_object* v___y_260_; lean_object* v___y_267_; lean_object* v___y_274_; lean_object* v___y_281_; lean_object* v___y_288_; lean_object* v___y_295_; 
switch(v_x_236_)
{
case 0:
{
lean_object* v___x_301_; uint8_t v___x_302_; 
v___x_301_ = lean_unsigned_to_nat(1024u);
v___x_302_ = lean_nat_dec_le(v___x_301_, v_prec_237_);
if (v___x_302_ == 0)
{
lean_object* v___x_303_; 
v___x_303_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_239_ = v___x_303_;
goto v___jp_238_;
}
else
{
lean_object* v___x_304_; 
v___x_304_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_239_ = v___x_304_;
goto v___jp_238_;
}
}
case 1:
{
lean_object* v___x_305_; uint8_t v___x_306_; 
v___x_305_ = lean_unsigned_to_nat(1024u);
v___x_306_ = lean_nat_dec_le(v___x_305_, v_prec_237_);
if (v___x_306_ == 0)
{
lean_object* v___x_307_; 
v___x_307_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_246_ = v___x_307_;
goto v___jp_245_;
}
else
{
lean_object* v___x_308_; 
v___x_308_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_246_ = v___x_308_;
goto v___jp_245_;
}
}
case 2:
{
lean_object* v___x_309_; uint8_t v___x_310_; 
v___x_309_ = lean_unsigned_to_nat(1024u);
v___x_310_ = lean_nat_dec_le(v___x_309_, v_prec_237_);
if (v___x_310_ == 0)
{
lean_object* v___x_311_; 
v___x_311_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_253_ = v___x_311_;
goto v___jp_252_;
}
else
{
lean_object* v___x_312_; 
v___x_312_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_253_ = v___x_312_;
goto v___jp_252_;
}
}
case 3:
{
lean_object* v___x_313_; uint8_t v___x_314_; 
v___x_313_ = lean_unsigned_to_nat(1024u);
v___x_314_ = lean_nat_dec_le(v___x_313_, v_prec_237_);
if (v___x_314_ == 0)
{
lean_object* v___x_315_; 
v___x_315_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_260_ = v___x_315_;
goto v___jp_259_;
}
else
{
lean_object* v___x_316_; 
v___x_316_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_260_ = v___x_316_;
goto v___jp_259_;
}
}
case 4:
{
lean_object* v___x_317_; uint8_t v___x_318_; 
v___x_317_ = lean_unsigned_to_nat(1024u);
v___x_318_ = lean_nat_dec_le(v___x_317_, v_prec_237_);
if (v___x_318_ == 0)
{
lean_object* v___x_319_; 
v___x_319_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_267_ = v___x_319_;
goto v___jp_266_;
}
else
{
lean_object* v___x_320_; 
v___x_320_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_267_ = v___x_320_;
goto v___jp_266_;
}
}
case 5:
{
lean_object* v___x_321_; uint8_t v___x_322_; 
v___x_321_ = lean_unsigned_to_nat(1024u);
v___x_322_ = lean_nat_dec_le(v___x_321_, v_prec_237_);
if (v___x_322_ == 0)
{
lean_object* v___x_323_; 
v___x_323_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_274_ = v___x_323_;
goto v___jp_273_;
}
else
{
lean_object* v___x_324_; 
v___x_324_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_274_ = v___x_324_;
goto v___jp_273_;
}
}
case 6:
{
lean_object* v___x_325_; uint8_t v___x_326_; 
v___x_325_ = lean_unsigned_to_nat(1024u);
v___x_326_ = lean_nat_dec_le(v___x_325_, v_prec_237_);
if (v___x_326_ == 0)
{
lean_object* v___x_327_; 
v___x_327_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_281_ = v___x_327_;
goto v___jp_280_;
}
else
{
lean_object* v___x_328_; 
v___x_328_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_281_ = v___x_328_;
goto v___jp_280_;
}
}
case 7:
{
lean_object* v___x_329_; uint8_t v___x_330_; 
v___x_329_ = lean_unsigned_to_nat(1024u);
v___x_330_ = lean_nat_dec_le(v___x_329_, v_prec_237_);
if (v___x_330_ == 0)
{
lean_object* v___x_331_; 
v___x_331_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_288_ = v___x_331_;
goto v___jp_287_;
}
else
{
lean_object* v___x_332_; 
v___x_332_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_288_ = v___x_332_;
goto v___jp_287_;
}
}
default: 
{
lean_object* v___x_333_; uint8_t v___x_334_; 
v___x_333_ = lean_unsigned_to_nat(1024u);
v___x_334_ = lean_nat_dec_le(v___x_333_, v_prec_237_);
if (v___x_334_ == 0)
{
lean_object* v___x_335_; 
v___x_335_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_295_ = v___x_335_;
goto v___jp_294_;
}
else
{
lean_object* v___x_336_; 
v___x_336_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_295_ = v___x_336_;
goto v___jp_294_;
}
}
}
v___jp_238_:
{
lean_object* v___x_240_; lean_object* v___x_241_; uint8_t v___x_242_; lean_object* v___x_243_; lean_object* v___x_244_; 
v___x_240_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__1));
lean_inc(v___y_239_);
v___x_241_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_241_, 0, v___y_239_);
lean_ctor_set(v___x_241_, 1, v___x_240_);
v___x_242_ = 0;
v___x_243_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_243_, 0, v___x_241_);
lean_ctor_set_uint8(v___x_243_, sizeof(void*)*1, v___x_242_);
v___x_244_ = l_Repr_addAppParen(v___x_243_, v_prec_237_);
return v___x_244_;
}
v___jp_245_:
{
lean_object* v___x_247_; lean_object* v___x_248_; uint8_t v___x_249_; lean_object* v___x_250_; lean_object* v___x_251_; 
v___x_247_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__3));
lean_inc(v___y_246_);
v___x_248_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_248_, 0, v___y_246_);
lean_ctor_set(v___x_248_, 1, v___x_247_);
v___x_249_ = 0;
v___x_250_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_250_, 0, v___x_248_);
lean_ctor_set_uint8(v___x_250_, sizeof(void*)*1, v___x_249_);
v___x_251_ = l_Repr_addAppParen(v___x_250_, v_prec_237_);
return v___x_251_;
}
v___jp_252_:
{
lean_object* v___x_254_; lean_object* v___x_255_; uint8_t v___x_256_; lean_object* v___x_257_; lean_object* v___x_258_; 
v___x_254_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__5));
lean_inc(v___y_253_);
v___x_255_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_255_, 0, v___y_253_);
lean_ctor_set(v___x_255_, 1, v___x_254_);
v___x_256_ = 0;
v___x_257_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_257_, 0, v___x_255_);
lean_ctor_set_uint8(v___x_257_, sizeof(void*)*1, v___x_256_);
v___x_258_ = l_Repr_addAppParen(v___x_257_, v_prec_237_);
return v___x_258_;
}
v___jp_259_:
{
lean_object* v___x_261_; lean_object* v___x_262_; uint8_t v___x_263_; lean_object* v___x_264_; lean_object* v___x_265_; 
v___x_261_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__7));
lean_inc(v___y_260_);
v___x_262_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_262_, 0, v___y_260_);
lean_ctor_set(v___x_262_, 1, v___x_261_);
v___x_263_ = 0;
v___x_264_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_264_, 0, v___x_262_);
lean_ctor_set_uint8(v___x_264_, sizeof(void*)*1, v___x_263_);
v___x_265_ = l_Repr_addAppParen(v___x_264_, v_prec_237_);
return v___x_265_;
}
v___jp_266_:
{
lean_object* v___x_268_; lean_object* v___x_269_; uint8_t v___x_270_; lean_object* v___x_271_; lean_object* v___x_272_; 
v___x_268_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__9));
lean_inc(v___y_267_);
v___x_269_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_269_, 0, v___y_267_);
lean_ctor_set(v___x_269_, 1, v___x_268_);
v___x_270_ = 0;
v___x_271_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_271_, 0, v___x_269_);
lean_ctor_set_uint8(v___x_271_, sizeof(void*)*1, v___x_270_);
v___x_272_ = l_Repr_addAppParen(v___x_271_, v_prec_237_);
return v___x_272_;
}
v___jp_273_:
{
lean_object* v___x_275_; lean_object* v___x_276_; uint8_t v___x_277_; lean_object* v___x_278_; lean_object* v___x_279_; 
v___x_275_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__11));
lean_inc(v___y_274_);
v___x_276_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_276_, 0, v___y_274_);
lean_ctor_set(v___x_276_, 1, v___x_275_);
v___x_277_ = 0;
v___x_278_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_278_, 0, v___x_276_);
lean_ctor_set_uint8(v___x_278_, sizeof(void*)*1, v___x_277_);
v___x_279_ = l_Repr_addAppParen(v___x_278_, v_prec_237_);
return v___x_279_;
}
v___jp_280_:
{
lean_object* v___x_282_; lean_object* v___x_283_; uint8_t v___x_284_; lean_object* v___x_285_; lean_object* v___x_286_; 
v___x_282_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__13));
lean_inc(v___y_281_);
v___x_283_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_283_, 0, v___y_281_);
lean_ctor_set(v___x_283_, 1, v___x_282_);
v___x_284_ = 0;
v___x_285_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_285_, 0, v___x_283_);
lean_ctor_set_uint8(v___x_285_, sizeof(void*)*1, v___x_284_);
v___x_286_ = l_Repr_addAppParen(v___x_285_, v_prec_237_);
return v___x_286_;
}
v___jp_287_:
{
lean_object* v___x_289_; lean_object* v___x_290_; uint8_t v___x_291_; lean_object* v___x_292_; lean_object* v___x_293_; 
v___x_289_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__15));
lean_inc(v___y_288_);
v___x_290_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_290_, 0, v___y_288_);
lean_ctor_set(v___x_290_, 1, v___x_289_);
v___x_291_ = 0;
v___x_292_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_292_, 0, v___x_290_);
lean_ctor_set_uint8(v___x_292_, sizeof(void*)*1, v___x_291_);
v___x_293_ = l_Repr_addAppParen(v___x_292_, v_prec_237_);
return v___x_293_;
}
v___jp_294_:
{
lean_object* v___x_296_; lean_object* v___x_297_; uint8_t v___x_298_; lean_object* v___x_299_; lean_object* v___x_300_; 
v___x_296_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__17));
lean_inc(v___y_295_);
v___x_297_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_297_, 0, v___y_295_);
lean_ctor_set(v___x_297_, 1, v___x_296_);
v___x_298_ = 0;
v___x_299_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_299_, 0, v___x_297_);
lean_ctor_set_uint8(v___x_299_, sizeof(void*)*1, v___x_298_);
v___x_300_ = l_Repr_addAppParen(v___x_299_, v_prec_237_);
return v___x_300_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___boxed(lean_object* v_x_337_, lean_object* v_prec_338_){
_start:
{
uint8_t v_x_513__boxed_339_; lean_object* v_res_340_; 
v_x_513__boxed_339_ = lean_unbox(v_x_337_);
v_res_340_ = lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr(v_x_513__boxed_339_, v_prec_338_);
lean_dec(v_prec_338_);
return v_res_340_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_matchWithinBool(lean_object* v_m_343_){
_start:
{
lean_object* v_distanceSq_344_; lean_object* v_tangentDistanceSq_345_; lean_object* v_curvatureDistance_346_; lean_object* v_arcDistance_347_; lean_object* v_distanceToleranceSq_348_; lean_object* v_tangentToleranceSq_349_; lean_object* v_curvatureTolerance_350_; lean_object* v_arcTolerance_351_; uint8_t v___y_353_; uint8_t v___x_356_; 
v_distanceSq_344_ = lean_ctor_get(v_m_343_, 0);
lean_inc_ref(v_distanceSq_344_);
v_tangentDistanceSq_345_ = lean_ctor_get(v_m_343_, 1);
lean_inc_ref(v_tangentDistanceSq_345_);
v_curvatureDistance_346_ = lean_ctor_get(v_m_343_, 2);
lean_inc_ref(v_curvatureDistance_346_);
v_arcDistance_347_ = lean_ctor_get(v_m_343_, 3);
lean_inc_ref(v_arcDistance_347_);
v_distanceToleranceSq_348_ = lean_ctor_get(v_m_343_, 4);
lean_inc_ref(v_distanceToleranceSq_348_);
v_tangentToleranceSq_349_ = lean_ctor_get(v_m_343_, 5);
lean_inc_ref(v_tangentToleranceSq_349_);
v_curvatureTolerance_350_ = lean_ctor_get(v_m_343_, 6);
lean_inc_ref(v_curvatureTolerance_350_);
v_arcTolerance_351_ = lean_ctor_get(v_m_343_, 7);
lean_inc_ref(v_arcTolerance_351_);
lean_dec_ref(v_m_343_);
v___x_356_ = l_Rat_instDecidableLe(v_distanceSq_344_, v_distanceToleranceSq_348_);
if (v___x_356_ == 0)
{
lean_dec_ref(v_tangentToleranceSq_349_);
lean_dec_ref(v_tangentDistanceSq_345_);
v___y_353_ = v___x_356_;
goto v___jp_352_;
}
else
{
uint8_t v___x_357_; 
v___x_357_ = l_Rat_instDecidableLe(v_tangentDistanceSq_345_, v_tangentToleranceSq_349_);
v___y_353_ = v___x_357_;
goto v___jp_352_;
}
v___jp_352_:
{
if (v___y_353_ == 0)
{
lean_dec_ref(v_arcTolerance_351_);
lean_dec_ref(v_curvatureTolerance_350_);
lean_dec_ref(v_arcDistance_347_);
lean_dec_ref(v_curvatureDistance_346_);
return v___y_353_;
}
else
{
uint8_t v___x_354_; 
v___x_354_ = l_Rat_instDecidableLe(v_curvatureDistance_346_, v_curvatureTolerance_350_);
if (v___x_354_ == 0)
{
lean_dec_ref(v_arcTolerance_351_);
lean_dec_ref(v_arcDistance_347_);
return v___x_354_;
}
else
{
uint8_t v___x_355_; 
v___x_355_ = l_Rat_instDecidableLe(v_arcDistance_347_, v_arcTolerance_351_);
return v___x_355_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_matchWithinBool___boxed(lean_object* v_m_358_){
_start:
{
uint8_t v_res_359_; lean_object* v_r_360_; 
v_res_359_ = lp_ir_x2dproof_IRProof_matchWithinBool(v_m_358_);
v_r_360_ = lean_box(v_res_359_);
return v_r_360_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_reconstructionKind(lean_object* v_e_361_){
_start:
{
uint8_t v_fitCertified_362_; 
v_fitCertified_362_ = lean_ctor_get_uint8(v_e_361_, sizeof(void*)*6);
if (v_fitCertified_362_ == 0)
{
uint8_t v___x_363_; 
lean_dec_ref(v_e_361_);
v___x_363_ = 8;
return v___x_363_;
}
else
{
lean_object* v_candidate_364_; lean_object* v_matchEvidence_365_; lean_object* v_topologyEvidence_366_; lean_object* v_fitBound_367_; uint8_t v_splitRequired_368_; uint8_t v_overlapObserved_369_; uint8_t v___x_370_; 
v_candidate_364_ = lean_ctor_get(v_e_361_, 0);
lean_inc_ref(v_candidate_364_);
v_matchEvidence_365_ = lean_ctor_get(v_e_361_, 2);
lean_inc_ref(v_matchEvidence_365_);
v_topologyEvidence_366_ = lean_ctor_get(v_e_361_, 3);
lean_inc_ref(v_topologyEvidence_366_);
v_fitBound_367_ = lean_ctor_get(v_e_361_, 4);
lean_inc_ref(v_fitBound_367_);
v_splitRequired_368_ = lean_ctor_get_uint8(v_e_361_, sizeof(void*)*6 + 1);
v_overlapObserved_369_ = lean_ctor_get_uint8(v_e_361_, sizeof(void*)*6 + 2);
lean_dec_ref(v_e_361_);
v___x_370_ = lp_ir_x2dproof_IRProof_matchWithinBool(v_matchEvidence_365_);
if (v___x_370_ == 0)
{
uint8_t v___x_371_; 
lean_dec_ref(v_fitBound_367_);
lean_dec_ref(v_topologyEvidence_366_);
lean_dec_ref(v_candidate_364_);
v___x_371_ = 8;
return v___x_371_;
}
else
{
lean_object* v_fittingError_372_; uint8_t v___x_373_; 
v_fittingError_372_ = lean_ctor_get(v_candidate_364_, 6);
lean_inc_ref(v_fittingError_372_);
lean_dec_ref(v_candidate_364_);
v___x_373_ = l_Rat_blt(v_fitBound_367_, v_fittingError_372_);
if (v___x_373_ == 0)
{
uint8_t v_unresolvedObservation_374_; uint8_t v_sameInterval_375_; uint8_t v_extendsInterval_376_; uint8_t v_knownConnection_377_; uint8_t v_bothContinue_378_; uint8_t v_sameLevel_379_; lean_object* v_heightSeparationSq_380_; lean_object* v_certifiedToleranceSq_381_; 
v_unresolvedObservation_374_ = lean_ctor_get_uint8(v_topologyEvidence_366_, sizeof(void*)*2);
v_sameInterval_375_ = lean_ctor_get_uint8(v_topologyEvidence_366_, sizeof(void*)*2 + 1);
v_extendsInterval_376_ = lean_ctor_get_uint8(v_topologyEvidence_366_, sizeof(void*)*2 + 2);
v_knownConnection_377_ = lean_ctor_get_uint8(v_topologyEvidence_366_, sizeof(void*)*2 + 3);
v_bothContinue_378_ = lean_ctor_get_uint8(v_topologyEvidence_366_, sizeof(void*)*2 + 4);
v_sameLevel_379_ = lean_ctor_get_uint8(v_topologyEvidence_366_, sizeof(void*)*2 + 5);
v_heightSeparationSq_380_ = lean_ctor_get(v_topologyEvidence_366_, 0);
lean_inc_ref(v_heightSeparationSq_380_);
v_certifiedToleranceSq_381_ = lean_ctor_get(v_topologyEvidence_366_, 1);
lean_inc_ref(v_certifiedToleranceSq_381_);
lean_dec_ref(v_topologyEvidence_366_);
if (v_unresolvedObservation_374_ == 0)
{
uint8_t v___x_389_; 
v___x_389_ = l_Rat_blt(v_certifiedToleranceSq_381_, v_heightSeparationSq_380_);
if (v___x_389_ == 0)
{
if (v_bothContinue_378_ == 0)
{
goto v___jp_382_;
}
else
{
if (v_sameLevel_379_ == 0)
{
goto v___jp_382_;
}
else
{
if (v_knownConnection_377_ == 0)
{
uint8_t v___x_390_; 
v___x_390_ = 5;
return v___x_390_;
}
else
{
if (v___x_389_ == 0)
{
goto v___jp_382_;
}
else
{
uint8_t v___x_391_; 
v___x_391_ = 5;
return v___x_391_;
}
}
}
}
}
else
{
uint8_t v___x_392_; 
v___x_392_ = 6;
return v___x_392_;
}
}
else
{
uint8_t v___x_393_; 
lean_dec_ref(v_certifiedToleranceSq_381_);
lean_dec_ref(v_heightSeparationSq_380_);
v___x_393_ = 8;
return v___x_393_;
}
v___jp_382_:
{
if (v_splitRequired_368_ == 0)
{
if (v_overlapObserved_369_ == 0)
{
if (v_knownConnection_377_ == 0)
{
if (v_extendsInterval_376_ == 0)
{
if (v_sameInterval_375_ == 0)
{
uint8_t v___x_383_; 
v___x_383_ = 7;
return v___x_383_;
}
else
{
uint8_t v___x_384_; 
v___x_384_ = 0;
return v___x_384_;
}
}
else
{
uint8_t v___x_385_; 
v___x_385_ = 1;
return v___x_385_;
}
}
else
{
uint8_t v___x_386_; 
v___x_386_ = 4;
return v___x_386_;
}
}
else
{
uint8_t v___x_387_; 
v___x_387_ = 3;
return v___x_387_;
}
}
else
{
uint8_t v___x_388_; 
v___x_388_ = 2;
return v___x_388_;
}
}
}
else
{
uint8_t v___x_394_; 
lean_dec_ref(v_topologyEvidence_366_);
v___x_394_ = 8;
return v___x_394_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_reconstructionKind___boxed(lean_object* v_e_395_){
_start:
{
uint8_t v_res_396_; lean_object* v_r_397_; 
v_res_396_ = lp_ir_x2dproof_IRProof_reconstructionKind(v_e_395_);
v_r_397_ = lean_box(v_res_396_);
return v_r_397_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_reconstructionRoutable(uint8_t v_x_398_){
_start:
{
switch(v_x_398_)
{
case 5:
{
uint8_t v___x_399_; 
v___x_399_ = 0;
return v___x_399_;
}
case 6:
{
uint8_t v___x_400_; 
v___x_400_ = 0;
return v___x_400_;
}
case 8:
{
uint8_t v___x_401_; 
v___x_401_ = 0;
return v___x_401_;
}
default: 
{
uint8_t v___x_402_; 
v___x_402_ = 1;
return v___x_402_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_reconstructionRoutable___boxed(lean_object* v_x_403_){
_start:
{
uint8_t v_x_53__boxed_404_; uint8_t v_res_405_; lean_object* v_r_406_; 
v_x_53__boxed_404_ = lean_unbox(v_x_403_);
v_res_405_ = lp_ir_x2dproof_IRProof_reconstructionRoutable(v_x_53__boxed_404_);
v_r_406_ = lean_box(v_res_405_);
return v_r_406_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter___redArg(uint8_t v_x_407_, lean_object* v_h__1_408_, lean_object* v_h__2_409_, lean_object* v_h__3_410_, lean_object* v_h__4_411_, lean_object* v_h__5_412_, lean_object* v_h__6_413_, lean_object* v_h__7_414_, lean_object* v_h__8_415_, lean_object* v_h__9_416_){
_start:
{
switch(v_x_407_)
{
case 0:
{
lean_object* v___x_417_; lean_object* v___x_418_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__8_415_);
lean_dec(v_h__7_414_);
lean_dec(v_h__6_413_);
lean_dec(v_h__5_412_);
lean_dec(v_h__4_411_);
lean_dec(v_h__3_410_);
lean_dec(v_h__2_409_);
v___x_417_ = lean_box(0);
v___x_418_ = lean_apply_1(v_h__1_408_, v___x_417_);
return v___x_418_;
}
case 1:
{
lean_object* v___x_419_; lean_object* v___x_420_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__8_415_);
lean_dec(v_h__7_414_);
lean_dec(v_h__6_413_);
lean_dec(v_h__5_412_);
lean_dec(v_h__4_411_);
lean_dec(v_h__3_410_);
lean_dec(v_h__1_408_);
v___x_419_ = lean_box(0);
v___x_420_ = lean_apply_1(v_h__2_409_, v___x_419_);
return v___x_420_;
}
case 2:
{
lean_object* v___x_421_; lean_object* v___x_422_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__8_415_);
lean_dec(v_h__7_414_);
lean_dec(v_h__6_413_);
lean_dec(v_h__5_412_);
lean_dec(v_h__4_411_);
lean_dec(v_h__2_409_);
lean_dec(v_h__1_408_);
v___x_421_ = lean_box(0);
v___x_422_ = lean_apply_1(v_h__3_410_, v___x_421_);
return v___x_422_;
}
case 3:
{
lean_object* v___x_423_; lean_object* v___x_424_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__8_415_);
lean_dec(v_h__7_414_);
lean_dec(v_h__6_413_);
lean_dec(v_h__5_412_);
lean_dec(v_h__3_410_);
lean_dec(v_h__2_409_);
lean_dec(v_h__1_408_);
v___x_423_ = lean_box(0);
v___x_424_ = lean_apply_1(v_h__4_411_, v___x_423_);
return v___x_424_;
}
case 4:
{
lean_object* v___x_425_; lean_object* v___x_426_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__8_415_);
lean_dec(v_h__7_414_);
lean_dec(v_h__6_413_);
lean_dec(v_h__4_411_);
lean_dec(v_h__3_410_);
lean_dec(v_h__2_409_);
lean_dec(v_h__1_408_);
v___x_425_ = lean_box(0);
v___x_426_ = lean_apply_1(v_h__5_412_, v___x_425_);
return v___x_426_;
}
case 5:
{
lean_object* v___x_427_; lean_object* v___x_428_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__8_415_);
lean_dec(v_h__7_414_);
lean_dec(v_h__5_412_);
lean_dec(v_h__4_411_);
lean_dec(v_h__3_410_);
lean_dec(v_h__2_409_);
lean_dec(v_h__1_408_);
v___x_427_ = lean_box(0);
v___x_428_ = lean_apply_1(v_h__6_413_, v___x_427_);
return v___x_428_;
}
case 6:
{
lean_object* v___x_429_; lean_object* v___x_430_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__8_415_);
lean_dec(v_h__6_413_);
lean_dec(v_h__5_412_);
lean_dec(v_h__4_411_);
lean_dec(v_h__3_410_);
lean_dec(v_h__2_409_);
lean_dec(v_h__1_408_);
v___x_429_ = lean_box(0);
v___x_430_ = lean_apply_1(v_h__7_414_, v___x_429_);
return v___x_430_;
}
case 7:
{
lean_object* v___x_431_; lean_object* v___x_432_; 
lean_dec(v_h__9_416_);
lean_dec(v_h__7_414_);
lean_dec(v_h__6_413_);
lean_dec(v_h__5_412_);
lean_dec(v_h__4_411_);
lean_dec(v_h__3_410_);
lean_dec(v_h__2_409_);
lean_dec(v_h__1_408_);
v___x_431_ = lean_box(0);
v___x_432_ = lean_apply_1(v_h__8_415_, v___x_431_);
return v___x_432_;
}
default: 
{
lean_object* v___x_433_; lean_object* v___x_434_; 
lean_dec(v_h__8_415_);
lean_dec(v_h__7_414_);
lean_dec(v_h__6_413_);
lean_dec(v_h__5_412_);
lean_dec(v_h__4_411_);
lean_dec(v_h__3_410_);
lean_dec(v_h__2_409_);
lean_dec(v_h__1_408_);
v___x_433_ = lean_box(0);
v___x_434_ = lean_apply_1(v_h__9_416_, v___x_433_);
return v___x_434_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter___redArg___boxed(lean_object* v_x_435_, lean_object* v_h__1_436_, lean_object* v_h__2_437_, lean_object* v_h__3_438_, lean_object* v_h__4_439_, lean_object* v_h__5_440_, lean_object* v_h__6_441_, lean_object* v_h__7_442_, lean_object* v_h__8_443_, lean_object* v_h__9_444_){
_start:
{
uint8_t v_x_87__boxed_445_; lean_object* v_res_446_; 
v_x_87__boxed_445_ = lean_unbox(v_x_435_);
v_res_446_ = lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter___redArg(v_x_87__boxed_445_, v_h__1_436_, v_h__2_437_, v_h__3_438_, v_h__4_439_, v_h__5_440_, v_h__6_441_, v_h__7_442_, v_h__8_443_, v_h__9_444_);
return v_res_446_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter(lean_object* v_motive_447_, uint8_t v_x_448_, lean_object* v_h__1_449_, lean_object* v_h__2_450_, lean_object* v_h__3_451_, lean_object* v_h__4_452_, lean_object* v_h__5_453_, lean_object* v_h__6_454_, lean_object* v_h__7_455_, lean_object* v_h__8_456_, lean_object* v_h__9_457_){
_start:
{
switch(v_x_448_)
{
case 0:
{
lean_object* v___x_458_; lean_object* v___x_459_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__8_456_);
lean_dec(v_h__7_455_);
lean_dec(v_h__6_454_);
lean_dec(v_h__5_453_);
lean_dec(v_h__4_452_);
lean_dec(v_h__3_451_);
lean_dec(v_h__2_450_);
v___x_458_ = lean_box(0);
v___x_459_ = lean_apply_1(v_h__1_449_, v___x_458_);
return v___x_459_;
}
case 1:
{
lean_object* v___x_460_; lean_object* v___x_461_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__8_456_);
lean_dec(v_h__7_455_);
lean_dec(v_h__6_454_);
lean_dec(v_h__5_453_);
lean_dec(v_h__4_452_);
lean_dec(v_h__3_451_);
lean_dec(v_h__1_449_);
v___x_460_ = lean_box(0);
v___x_461_ = lean_apply_1(v_h__2_450_, v___x_460_);
return v___x_461_;
}
case 2:
{
lean_object* v___x_462_; lean_object* v___x_463_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__8_456_);
lean_dec(v_h__7_455_);
lean_dec(v_h__6_454_);
lean_dec(v_h__5_453_);
lean_dec(v_h__4_452_);
lean_dec(v_h__2_450_);
lean_dec(v_h__1_449_);
v___x_462_ = lean_box(0);
v___x_463_ = lean_apply_1(v_h__3_451_, v___x_462_);
return v___x_463_;
}
case 3:
{
lean_object* v___x_464_; lean_object* v___x_465_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__8_456_);
lean_dec(v_h__7_455_);
lean_dec(v_h__6_454_);
lean_dec(v_h__5_453_);
lean_dec(v_h__3_451_);
lean_dec(v_h__2_450_);
lean_dec(v_h__1_449_);
v___x_464_ = lean_box(0);
v___x_465_ = lean_apply_1(v_h__4_452_, v___x_464_);
return v___x_465_;
}
case 4:
{
lean_object* v___x_466_; lean_object* v___x_467_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__8_456_);
lean_dec(v_h__7_455_);
lean_dec(v_h__6_454_);
lean_dec(v_h__4_452_);
lean_dec(v_h__3_451_);
lean_dec(v_h__2_450_);
lean_dec(v_h__1_449_);
v___x_466_ = lean_box(0);
v___x_467_ = lean_apply_1(v_h__5_453_, v___x_466_);
return v___x_467_;
}
case 5:
{
lean_object* v___x_468_; lean_object* v___x_469_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__8_456_);
lean_dec(v_h__7_455_);
lean_dec(v_h__5_453_);
lean_dec(v_h__4_452_);
lean_dec(v_h__3_451_);
lean_dec(v_h__2_450_);
lean_dec(v_h__1_449_);
v___x_468_ = lean_box(0);
v___x_469_ = lean_apply_1(v_h__6_454_, v___x_468_);
return v___x_469_;
}
case 6:
{
lean_object* v___x_470_; lean_object* v___x_471_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__8_456_);
lean_dec(v_h__6_454_);
lean_dec(v_h__5_453_);
lean_dec(v_h__4_452_);
lean_dec(v_h__3_451_);
lean_dec(v_h__2_450_);
lean_dec(v_h__1_449_);
v___x_470_ = lean_box(0);
v___x_471_ = lean_apply_1(v_h__7_455_, v___x_470_);
return v___x_471_;
}
case 7:
{
lean_object* v___x_472_; lean_object* v___x_473_; 
lean_dec(v_h__9_457_);
lean_dec(v_h__7_455_);
lean_dec(v_h__6_454_);
lean_dec(v_h__5_453_);
lean_dec(v_h__4_452_);
lean_dec(v_h__3_451_);
lean_dec(v_h__2_450_);
lean_dec(v_h__1_449_);
v___x_472_ = lean_box(0);
v___x_473_ = lean_apply_1(v_h__8_456_, v___x_472_);
return v___x_473_;
}
default: 
{
lean_object* v___x_474_; lean_object* v___x_475_; 
lean_dec(v_h__8_456_);
lean_dec(v_h__7_455_);
lean_dec(v_h__6_454_);
lean_dec(v_h__5_453_);
lean_dec(v_h__4_452_);
lean_dec(v_h__3_451_);
lean_dec(v_h__2_450_);
lean_dec(v_h__1_449_);
v___x_474_ = lean_box(0);
v___x_475_ = lean_apply_1(v_h__9_457_, v___x_474_);
return v___x_475_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter___boxed(lean_object* v_motive_476_, lean_object* v_x_477_, lean_object* v_h__1_478_, lean_object* v_h__2_479_, lean_object* v_h__3_480_, lean_object* v_h__4_481_, lean_object* v_h__5_482_, lean_object* v_h__6_483_, lean_object* v_h__7_484_, lean_object* v_h__8_485_, lean_object* v_h__9_486_){
_start:
{
uint8_t v_x_126__boxed_487_; lean_object* v_res_488_; 
v_x_126__boxed_487_ = lean_unbox(v_x_477_);
v_res_488_ = lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_instReprReconstructionKind_repr_match__1_splitter(v_motive_476_, v_x_126__boxed_487_, v_h__1_478_, v_h__2_479_, v_h__3_480_, v_h__4_481_, v_h__5_482_, v_h__6_483_, v_h__7_484_, v_h__8_485_, v_h__9_486_);
return v_res_488_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_splineIdPresent(lean_object* v_id_489_, lean_object* v_x_490_){
_start:
{
if (lean_obj_tag(v_x_490_) == 0)
{
uint8_t v___x_491_; 
v___x_491_ = 0;
return v___x_491_;
}
else
{
lean_object* v_head_492_; lean_object* v_tail_493_; lean_object* v_stableId_494_; uint8_t v___x_495_; 
v_head_492_ = lean_ctor_get(v_x_490_, 0);
v_tail_493_ = lean_ctor_get(v_x_490_, 1);
v_stableId_494_ = lean_ctor_get(v_head_492_, 0);
v___x_495_ = lean_string_dec_eq(v_stableId_494_, v_id_489_);
if (v___x_495_ == 0)
{
v_x_490_ = v_tail_493_;
goto _start;
}
else
{
return v___x_495_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineIdPresent___boxed(lean_object* v_id_497_, lean_object* v_x_498_){
_start:
{
uint8_t v_res_499_; lean_object* v_r_500_; 
v_res_499_ = lp_ir_x2dproof_IRProof_splineIdPresent(v_id_497_, v_x_498_);
lean_dec(v_x_498_);
lean_dec_ref(v_id_497_);
v_r_500_ = lean_box(v_res_499_);
return v_r_500_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_appendSplineIfNew(lean_object* v_s_501_, lean_object* v_xs_502_){
_start:
{
lean_object* v_stableId_503_; uint8_t v___x_504_; 
v_stableId_503_ = lean_ctor_get(v_s_501_, 0);
v___x_504_ = lp_ir_x2dproof_IRProof_splineIdPresent(v_stableId_503_, v_xs_502_);
if (v___x_504_ == 0)
{
lean_object* v___x_505_; lean_object* v___x_506_; lean_object* v___x_507_; 
v___x_505_ = lean_box(0);
v___x_506_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_506_, 0, v_s_501_);
lean_ctor_set(v___x_506_, 1, v___x_505_);
v___x_507_ = l_List_appendTR___redArg(v_xs_502_, v___x_506_);
return v___x_507_;
}
else
{
lean_dec_ref(v_s_501_);
return v_xs_502_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_addTraceId(lean_object* v_id_508_, lean_object* v_xs_509_){
_start:
{
uint8_t v___x_510_; 
v___x_510_ = lp_ir_x2dproof_IRProof_containsString(v_id_508_, v_xs_509_);
if (v___x_510_ == 0)
{
lean_object* v___x_511_; lean_object* v___x_512_; lean_object* v___x_513_; 
v___x_511_ = lean_box(0);
v___x_512_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_512_, 0, v_id_508_);
lean_ctor_set(v___x_512_, 1, v___x_511_);
v___x_513_ = l_List_appendTR___redArg(v_xs_509_, v___x_512_);
return v___x_513_;
}
else
{
lean_dec_ref(v_id_508_);
return v_xs_509_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commitReconstruction(lean_object* v_store_514_, lean_object* v_e_515_){
_start:
{
lean_object* v___y_517_; uint8_t v_kind_532_; 
lean_inc_ref(v_e_515_);
v_kind_532_ = lp_ir_x2dproof_IRProof_reconstructionKind(v_e_515_);
switch(v_kind_532_)
{
case 0:
{
lean_object* v_splines_533_; 
v_splines_533_ = lean_ctor_get(v_store_514_, 1);
lean_inc(v_splines_533_);
v___y_517_ = v_splines_533_;
goto v___jp_516_;
}
case 8:
{
lean_object* v_splines_534_; 
v_splines_534_ = lean_ctor_get(v_store_514_, 1);
lean_inc(v_splines_534_);
v___y_517_ = v_splines_534_;
goto v___jp_516_;
}
default: 
{
lean_object* v_candidate_535_; lean_object* v_splines_536_; lean_object* v___x_537_; 
v_candidate_535_ = lean_ctor_get(v_e_515_, 0);
v_splines_536_ = lean_ctor_get(v_store_514_, 1);
lean_inc(v_splines_536_);
lean_inc_ref(v_candidate_535_);
v___x_537_ = lp_ir_x2dproof_IRProof_appendSplineIfNew(v_candidate_535_, v_splines_536_);
v___y_517_ = v___x_537_;
goto v___jp_516_;
}
}
v___jp_516_:
{
lean_object* v_revision_518_; lean_object* v_sourceTraceIds_519_; lean_object* v___x_521_; uint8_t v_isShared_522_; uint8_t v_isSharedCheck_530_; 
v_revision_518_ = lean_ctor_get(v_store_514_, 0);
v_sourceTraceIds_519_ = lean_ctor_get(v_store_514_, 2);
v_isSharedCheck_530_ = !lean_is_exclusive(v_store_514_);
if (v_isSharedCheck_530_ == 0)
{
lean_object* v_unused_531_; 
v_unused_531_ = lean_ctor_get(v_store_514_, 1);
lean_dec(v_unused_531_);
v___x_521_ = v_store_514_;
v_isShared_522_ = v_isSharedCheck_530_;
goto v_resetjp_520_;
}
else
{
lean_inc(v_sourceTraceIds_519_);
lean_inc(v_revision_518_);
lean_dec(v_store_514_);
v___x_521_ = lean_box(0);
v_isShared_522_ = v_isSharedCheck_530_;
goto v_resetjp_520_;
}
v_resetjp_520_:
{
lean_object* v_traceId_523_; lean_object* v___x_524_; lean_object* v___x_525_; lean_object* v___x_526_; lean_object* v___x_528_; 
v_traceId_523_ = lean_ctor_get(v_e_515_, 5);
lean_inc_ref(v_traceId_523_);
lean_dec_ref(v_e_515_);
v___x_524_ = lean_unsigned_to_nat(1u);
v___x_525_ = lean_nat_add(v_revision_518_, v___x_524_);
lean_dec(v_revision_518_);
v___x_526_ = lp_ir_x2dproof_IRProof_addTraceId(v_traceId_523_, v_sourceTraceIds_519_);
if (v_isShared_522_ == 0)
{
lean_ctor_set(v___x_521_, 2, v___x_526_);
lean_ctor_set(v___x_521_, 1, v___y_517_);
lean_ctor_set(v___x_521_, 0, v___x_525_);
v___x_528_ = v___x_521_;
goto v_reusejp_527_;
}
else
{
lean_object* v_reuseFailAlloc_529_; 
v_reuseFailAlloc_529_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_529_, 0, v___x_525_);
lean_ctor_set(v_reuseFailAlloc_529_, 1, v___y_517_);
lean_ctor_set(v_reuseFailAlloc_529_, 2, v___x_526_);
v___x_528_ = v_reuseFailAlloc_529_;
goto v_reusejp_527_;
}
v_reusejp_527_:
{
return v___x_528_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_endpointName(lean_object* v_splineId_540_, uint8_t v_atStart_541_){
_start:
{
if (v_atStart_541_ == 0)
{
lean_object* v___x_542_; lean_object* v___x_543_; 
v___x_542_ = ((lean_object*)(lp_ir_x2dproof_IRProof_endpointName___closed__0));
v___x_543_ = lean_string_append(v_splineId_540_, v___x_542_);
return v___x_543_;
}
else
{
lean_object* v___x_544_; lean_object* v___x_545_; 
v___x_544_ = ((lean_object*)(lp_ir_x2dproof_IRProof_endpointName___closed__1));
v___x_545_ = lean_string_append(v_splineId_540_, v___x_544_);
return v___x_545_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_endpointName___boxed(lean_object* v_splineId_546_, lean_object* v_atStart_547_){
_start:
{
uint8_t v_atStart_boxed_548_; lean_object* v_res_549_; 
v_atStart_boxed_548_ = lean_unbox(v_atStart_547_);
v_res_549_ = lp_ir_x2dproof_IRProof_endpointName(v_splineId_546_, v_atStart_boxed_548_);
return v_res_549_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_connectionMatches(lean_object* v_c_550_, lean_object* v_sid_551_, uint8_t v_atStart_552_){
_start:
{
lean_object* v_leftSplineId_553_; uint8_t v_leftAtStart_554_; lean_object* v_rightSplineId_555_; uint8_t v_rightAtStart_556_; uint8_t v___y_560_; uint8_t v___x_561_; 
v_leftSplineId_553_ = lean_ctor_get(v_c_550_, 1);
v_leftAtStart_554_ = lean_ctor_get_uint8(v_c_550_, sizeof(void*)*5);
v_rightSplineId_555_ = lean_ctor_get(v_c_550_, 3);
v_rightAtStart_556_ = lean_ctor_get_uint8(v_c_550_, sizeof(void*)*5 + 1);
v___x_561_ = lean_string_dec_eq(v_leftSplineId_553_, v_sid_551_);
if (v___x_561_ == 0)
{
v___y_560_ = v___x_561_;
goto v___jp_559_;
}
else
{
if (v_leftAtStart_554_ == 0)
{
if (v_atStart_552_ == 0)
{
v___y_560_ = v___x_561_;
goto v___jp_559_;
}
else
{
goto v___jp_557_;
}
}
else
{
v___y_560_ = v_atStart_552_;
goto v___jp_559_;
}
}
v___jp_557_:
{
uint8_t v___x_558_; 
v___x_558_ = lean_string_dec_eq(v_rightSplineId_555_, v_sid_551_);
if (v___x_558_ == 0)
{
return v___x_558_;
}
else
{
if (v_rightAtStart_556_ == 0)
{
if (v_atStart_552_ == 0)
{
return v___x_558_;
}
else
{
return v_rightAtStart_556_;
}
}
else
{
return v_atStart_552_;
}
}
}
v___jp_559_:
{
if (v___y_560_ == 0)
{
goto v___jp_557_;
}
else
{
return v___y_560_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_connectionMatches___boxed(lean_object* v_c_562_, lean_object* v_sid_563_, lean_object* v_atStart_564_){
_start:
{
uint8_t v_atStart_boxed_565_; uint8_t v_res_566_; lean_object* v_r_567_; 
v_atStart_boxed_565_ = lean_unbox(v_atStart_564_);
v_res_566_ = lp_ir_x2dproof_IRProof_connectionMatches(v_c_562_, v_sid_563_, v_atStart_boxed_565_);
lean_dec_ref(v_sid_563_);
lean_dec_ref(v_c_562_);
v_r_567_ = lean_box(v_res_566_);
return v_r_567_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_resolvedEndpoint_spec__0(lean_object* v_sid_568_, uint8_t v_atStart_569_, lean_object* v_x_570_){
_start:
{
if (lean_obj_tag(v_x_570_) == 0)
{
lean_object* v___x_571_; 
v___x_571_ = lean_box(0);
return v___x_571_;
}
else
{
lean_object* v_head_572_; lean_object* v_tail_573_; uint8_t v___x_574_; 
v_head_572_ = lean_ctor_get(v_x_570_, 0);
v_tail_573_ = lean_ctor_get(v_x_570_, 1);
v___x_574_ = lp_ir_x2dproof_IRProof_connectionMatches(v_head_572_, v_sid_568_, v_atStart_569_);
if (v___x_574_ == 0)
{
v_x_570_ = v_tail_573_;
goto _start;
}
else
{
lean_object* v___x_576_; 
lean_inc(v_head_572_);
v___x_576_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_576_, 0, v_head_572_);
return v___x_576_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_find_x3f___at___00IRProof_resolvedEndpoint_spec__0___boxed(lean_object* v_sid_577_, lean_object* v_atStart_578_, lean_object* v_x_579_){
_start:
{
uint8_t v_atStart_boxed_580_; lean_object* v_res_581_; 
v_atStart_boxed_580_ = lean_unbox(v_atStart_578_);
v_res_581_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_resolvedEndpoint_spec__0(v_sid_577_, v_atStart_boxed_580_, v_x_579_);
lean_dec(v_x_579_);
lean_dec_ref(v_sid_577_);
return v_res_581_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_resolvedEndpoint(lean_object* v_connections_582_, lean_object* v_sid_583_, uint8_t v_atStart_584_){
_start:
{
lean_object* v___x_585_; 
v___x_585_ = lp_ir_x2dproof_List_find_x3f___at___00IRProof_resolvedEndpoint_spec__0(v_sid_583_, v_atStart_584_, v_connections_582_);
if (lean_obj_tag(v___x_585_) == 0)
{
lean_object* v___x_586_; 
v___x_586_ = lp_ir_x2dproof_IRProof_endpointName(v_sid_583_, v_atStart_584_);
return v___x_586_;
}
else
{
lean_object* v_val_587_; lean_object* v_connectionId_588_; 
lean_dec_ref(v_sid_583_);
v_val_587_ = lean_ctor_get(v___x_585_, 0);
lean_inc(v_val_587_);
lean_dec_ref_known(v___x_585_, 1);
v_connectionId_588_ = lean_ctor_get(v_val_587_, 0);
lean_inc_ref(v_connectionId_588_);
lean_dec(v_val_587_);
return v_connectionId_588_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_resolvedEndpoint___boxed(lean_object* v_connections_589_, lean_object* v_sid_590_, lean_object* v_atStart_591_){
_start:
{
uint8_t v_atStart_boxed_592_; lean_object* v_res_593_; 
v_atStart_boxed_592_ = lean_unbox(v_atStart_591_);
v_res_593_ = lp_ir_x2dproof_IRProof_resolvedEndpoint(v_connections_589_, v_sid_590_, v_atStart_boxed_592_);
lean_dec(v_connections_589_);
return v_res_593_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1(void){
_start:
{
lean_object* v___x_595_; lean_object* v___x_596_; 
v___x_595_ = lean_unsigned_to_nat(0u);
v___x_596_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_595_);
return v___x_596_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineForwardEdge(lean_object* v_connections_597_, lean_object* v_s_598_){
_start:
{
lean_object* v_stableId_599_; lean_object* v_totalLength_600_; lean_object* v___x_601_; lean_object* v___x_602_; lean_object* v___x_603_; uint8_t v___x_604_; lean_object* v___x_605_; uint8_t v___x_606_; lean_object* v___x_607_; lean_object* v___x_608_; 
v_stableId_599_ = lean_ctor_get(v_s_598_, 0);
lean_inc_ref_n(v_stableId_599_, 4);
v_totalLength_600_ = lean_ctor_get(v_s_598_, 4);
lean_inc_ref(v_totalLength_600_);
lean_dec_ref(v_s_598_);
v___x_601_ = ((lean_object*)(lp_ir_x2dproof_IRProof_splineForwardEdge___closed__0));
v___x_602_ = lean_string_append(v_stableId_599_, v___x_601_);
v___x_603_ = lean_obj_once(&lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1, &lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1_once, _init_lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1);
v___x_604_ = 1;
v___x_605_ = lp_ir_x2dproof_IRProof_resolvedEndpoint(v_connections_597_, v_stableId_599_, v___x_604_);
v___x_606_ = 0;
v___x_607_ = lp_ir_x2dproof_IRProof_resolvedEndpoint(v_connections_597_, v_stableId_599_, v___x_606_);
v___x_608_ = lean_alloc_ctor(0, 6, 1);
lean_ctor_set(v___x_608_, 0, v___x_602_);
lean_ctor_set(v___x_608_, 1, v_stableId_599_);
lean_ctor_set(v___x_608_, 2, v___x_603_);
lean_ctor_set(v___x_608_, 3, v_totalLength_600_);
lean_ctor_set(v___x_608_, 4, v___x_605_);
lean_ctor_set(v___x_608_, 5, v___x_607_);
lean_ctor_set_uint8(v___x_608_, sizeof(void*)*6, v___x_604_);
return v___x_608_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineForwardEdge___boxed(lean_object* v_connections_609_, lean_object* v_s_610_){
_start:
{
lean_object* v_res_611_; 
v_res_611_ = lp_ir_x2dproof_IRProof_splineForwardEdge(v_connections_609_, v_s_610_);
lean_dec(v_connections_609_);
return v_res_611_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineReverseEdge(lean_object* v_connections_613_, lean_object* v_s_614_){
_start:
{
lean_object* v_stableId_615_; lean_object* v_totalLength_616_; lean_object* v___x_617_; lean_object* v___x_618_; lean_object* v___x_619_; uint8_t v___x_620_; lean_object* v___x_621_; uint8_t v___x_622_; lean_object* v___x_623_; lean_object* v___x_624_; 
v_stableId_615_ = lean_ctor_get(v_s_614_, 0);
lean_inc_ref_n(v_stableId_615_, 4);
v_totalLength_616_ = lean_ctor_get(v_s_614_, 4);
lean_inc_ref(v_totalLength_616_);
lean_dec_ref(v_s_614_);
v___x_617_ = ((lean_object*)(lp_ir_x2dproof_IRProof_splineReverseEdge___closed__0));
v___x_618_ = lean_string_append(v_stableId_615_, v___x_617_);
v___x_619_ = lean_obj_once(&lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1, &lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1_once, _init_lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1);
v___x_620_ = 0;
v___x_621_ = lp_ir_x2dproof_IRProof_resolvedEndpoint(v_connections_613_, v_stableId_615_, v___x_620_);
v___x_622_ = 1;
v___x_623_ = lp_ir_x2dproof_IRProof_resolvedEndpoint(v_connections_613_, v_stableId_615_, v___x_622_);
v___x_624_ = lean_alloc_ctor(0, 6, 1);
lean_ctor_set(v___x_624_, 0, v___x_618_);
lean_ctor_set(v___x_624_, 1, v_stableId_615_);
lean_ctor_set(v___x_624_, 2, v_totalLength_616_);
lean_ctor_set(v___x_624_, 3, v___x_619_);
lean_ctor_set(v___x_624_, 4, v___x_621_);
lean_ctor_set(v___x_624_, 5, v___x_623_);
lean_ctor_set_uint8(v___x_624_, sizeof(void*)*6, v___x_620_);
return v___x_624_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineReverseEdge___boxed(lean_object* v_connections_625_, lean_object* v_s_626_){
_start:
{
lean_object* v_res_627_; 
v_res_627_ = lp_ir_x2dproof_IRProof_splineReverseEdge(v_connections_625_, v_s_626_);
lean_dec(v_connections_625_);
return v_res_627_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_splineEndpointVertices(lean_object* v_s_628_){
_start:
{
lean_object* v_stableId_629_; lean_object* v_totalLength_630_; uint8_t v___x_631_; lean_object* v___x_632_; lean_object* v___x_633_; lean_object* v___x_634_; uint8_t v___x_635_; lean_object* v___x_636_; lean_object* v___x_637_; lean_object* v___x_638_; lean_object* v___x_639_; lean_object* v___x_640_; 
v_stableId_629_ = lean_ctor_get(v_s_628_, 0);
lean_inc_ref_n(v_stableId_629_, 4);
v_totalLength_630_ = lean_ctor_get(v_s_628_, 4);
lean_inc_ref(v_totalLength_630_);
lean_dec_ref(v_s_628_);
v___x_631_ = 1;
v___x_632_ = lp_ir_x2dproof_IRProof_endpointName(v_stableId_629_, v___x_631_);
v___x_633_ = lean_obj_once(&lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1, &lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1_once, _init_lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1);
v___x_634_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_634_, 0, v___x_632_);
lean_ctor_set(v___x_634_, 1, v_stableId_629_);
lean_ctor_set(v___x_634_, 2, v___x_633_);
v___x_635_ = 0;
v___x_636_ = lp_ir_x2dproof_IRProof_endpointName(v_stableId_629_, v___x_635_);
v___x_637_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_637_, 0, v___x_636_);
lean_ctor_set(v___x_637_, 1, v_stableId_629_);
lean_ctor_set(v___x_637_, 2, v_totalLength_630_);
v___x_638_ = lean_box(0);
v___x_639_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_639_, 0, v___x_637_);
lean_ctor_set(v___x_639_, 1, v___x_638_);
v___x_640_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_640_, 0, v___x_634_);
lean_ctor_set(v___x_640_, 1, v___x_639_);
return v___x_640_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_connectionVertices_spec__0(lean_object* v_a_641_, lean_object* v_a_642_){
_start:
{
if (lean_obj_tag(v_a_641_) == 0)
{
lean_object* v___x_643_; 
v___x_643_ = lean_array_to_list(v_a_642_);
return v___x_643_;
}
else
{
lean_object* v_head_644_; lean_object* v_tail_645_; lean_object* v___x_647_; uint8_t v_isShared_648_; uint8_t v_isSharedCheck_663_; 
v_head_644_ = lean_ctor_get(v_a_641_, 0);
v_tail_645_ = lean_ctor_get(v_a_641_, 1);
v_isSharedCheck_663_ = !lean_is_exclusive(v_a_641_);
if (v_isSharedCheck_663_ == 0)
{
v___x_647_ = v_a_641_;
v_isShared_648_ = v_isSharedCheck_663_;
goto v_resetjp_646_;
}
else
{
lean_inc(v_tail_645_);
lean_inc(v_head_644_);
lean_dec(v_a_641_);
v___x_647_ = lean_box(0);
v_isShared_648_ = v_isSharedCheck_663_;
goto v_resetjp_646_;
}
v_resetjp_646_:
{
lean_object* v_connectionId_649_; lean_object* v_leftSplineId_650_; lean_object* v_leftS_651_; lean_object* v_rightSplineId_652_; lean_object* v_rightS_653_; lean_object* v___x_654_; lean_object* v___x_655_; lean_object* v___x_656_; lean_object* v___x_658_; 
v_connectionId_649_ = lean_ctor_get(v_head_644_, 0);
lean_inc_ref_n(v_connectionId_649_, 2);
v_leftSplineId_650_ = lean_ctor_get(v_head_644_, 1);
lean_inc_ref(v_leftSplineId_650_);
v_leftS_651_ = lean_ctor_get(v_head_644_, 2);
lean_inc_ref(v_leftS_651_);
v_rightSplineId_652_ = lean_ctor_get(v_head_644_, 3);
lean_inc_ref(v_rightSplineId_652_);
v_rightS_653_ = lean_ctor_get(v_head_644_, 4);
lean_inc_ref(v_rightS_653_);
lean_dec(v_head_644_);
v___x_654_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_654_, 0, v_connectionId_649_);
lean_ctor_set(v___x_654_, 1, v_leftSplineId_650_);
lean_ctor_set(v___x_654_, 2, v_leftS_651_);
v___x_655_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_655_, 0, v_connectionId_649_);
lean_ctor_set(v___x_655_, 1, v_rightSplineId_652_);
lean_ctor_set(v___x_655_, 2, v_rightS_653_);
v___x_656_ = lean_box(0);
if (v_isShared_648_ == 0)
{
lean_ctor_set(v___x_647_, 1, v___x_656_);
lean_ctor_set(v___x_647_, 0, v___x_655_);
v___x_658_ = v___x_647_;
goto v_reusejp_657_;
}
else
{
lean_object* v_reuseFailAlloc_662_; 
v_reuseFailAlloc_662_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_662_, 0, v___x_655_);
lean_ctor_set(v_reuseFailAlloc_662_, 1, v___x_656_);
v___x_658_ = v_reuseFailAlloc_662_;
goto v_reusejp_657_;
}
v_reusejp_657_:
{
lean_object* v___x_659_; lean_object* v___x_660_; 
v___x_659_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_659_, 0, v___x_654_);
lean_ctor_set(v___x_659_, 1, v___x_658_);
v___x_660_ = l_List_foldl___at___00Array_appendList_spec__0___redArg(v_a_642_, v___x_659_);
v_a_641_ = v_tail_645_;
v_a_642_ = v___x_660_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_connectionVertices(lean_object* v_connections_666_){
_start:
{
lean_object* v___x_667_; lean_object* v___x_668_; 
v___x_667_ = ((lean_object*)(lp_ir_x2dproof_IRProof_connectionVertices___closed__0));
v___x_668_ = lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_connectionVertices_spec__0(v_connections_666_, v___x_667_);
return v___x_668_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__1(lean_object* v___x_669_, lean_object* v_a_670_, lean_object* v_a_671_){
_start:
{
if (lean_obj_tag(v_a_670_) == 0)
{
lean_object* v___x_672_; 
v___x_672_ = lean_array_to_list(v_a_671_);
return v___x_672_;
}
else
{
lean_object* v_head_673_; lean_object* v_tail_674_; lean_object* v___x_676_; uint8_t v_isShared_677_; uint8_t v_isSharedCheck_687_; 
v_head_673_ = lean_ctor_get(v_a_670_, 0);
v_tail_674_ = lean_ctor_get(v_a_670_, 1);
v_isSharedCheck_687_ = !lean_is_exclusive(v_a_670_);
if (v_isSharedCheck_687_ == 0)
{
v___x_676_ = v_a_670_;
v_isShared_677_ = v_isSharedCheck_687_;
goto v_resetjp_675_;
}
else
{
lean_inc(v_tail_674_);
lean_inc(v_head_673_);
lean_dec(v_a_670_);
v___x_676_ = lean_box(0);
v_isShared_677_ = v_isSharedCheck_687_;
goto v_resetjp_675_;
}
v_resetjp_675_:
{
lean_object* v___x_678_; lean_object* v___x_679_; lean_object* v___x_680_; lean_object* v___x_682_; 
lean_inc(v_head_673_);
v___x_678_ = lp_ir_x2dproof_IRProof_splineForwardEdge(v___x_669_, v_head_673_);
v___x_679_ = lp_ir_x2dproof_IRProof_splineReverseEdge(v___x_669_, v_head_673_);
v___x_680_ = lean_box(0);
if (v_isShared_677_ == 0)
{
lean_ctor_set(v___x_676_, 1, v___x_680_);
lean_ctor_set(v___x_676_, 0, v___x_679_);
v___x_682_ = v___x_676_;
goto v_reusejp_681_;
}
else
{
lean_object* v_reuseFailAlloc_686_; 
v_reuseFailAlloc_686_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_686_, 0, v___x_679_);
lean_ctor_set(v_reuseFailAlloc_686_, 1, v___x_680_);
v___x_682_ = v_reuseFailAlloc_686_;
goto v_reusejp_681_;
}
v_reusejp_681_:
{
lean_object* v___x_683_; lean_object* v___x_684_; 
v___x_683_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_683_, 0, v___x_678_);
lean_ctor_set(v___x_683_, 1, v___x_682_);
v___x_684_ = l_List_foldl___at___00Array_appendList_spec__0___redArg(v_a_671_, v___x_683_);
v_a_670_ = v_tail_674_;
v_a_671_ = v___x_684_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__1___boxed(lean_object* v___x_688_, lean_object* v_a_689_, lean_object* v_a_690_){
_start:
{
lean_object* v_res_691_; 
v_res_691_ = lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__1(v___x_688_, v_a_689_, v_a_690_);
lean_dec(v___x_688_);
return v_res_691_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__0(lean_object* v_a_692_, lean_object* v_a_693_){
_start:
{
if (lean_obj_tag(v_a_692_) == 0)
{
lean_object* v___x_694_; 
v___x_694_ = lean_array_to_list(v_a_693_);
return v___x_694_;
}
else
{
lean_object* v_head_695_; lean_object* v_tail_696_; lean_object* v___x_697_; lean_object* v___x_698_; 
v_head_695_ = lean_ctor_get(v_a_692_, 0);
lean_inc(v_head_695_);
v_tail_696_ = lean_ctor_get(v_a_692_, 1);
lean_inc(v_tail_696_);
lean_dec_ref_known(v_a_692_, 2);
v___x_697_ = lp_ir_x2dproof_IRProof_splineEndpointVertices(v_head_695_);
v___x_698_ = l_List_foldl___at___00Array_appendList_spec__0___redArg(v_a_693_, v___x_697_);
v_a_692_ = v_tail_696_;
v_a_693_ = v___x_698_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_buildRoutingGraph(lean_object* v_network_700_){
_start:
{
lean_object* v_revision_701_; lean_object* v_splines_702_; lean_object* v_connections_703_; lean_object* v___x_704_; lean_object* v___x_705_; lean_object* v___x_706_; lean_object* v___x_707_; lean_object* v___x_708_; lean_object* v___x_709_; 
v_revision_701_ = lean_ctor_get(v_network_700_, 0);
lean_inc(v_revision_701_);
v_splines_702_ = lean_ctor_get(v_network_700_, 1);
lean_inc_n(v_splines_702_, 3);
v_connections_703_ = lean_ctor_get(v_network_700_, 2);
lean_inc_n(v_connections_703_, 2);
lean_dec_ref(v_network_700_);
v___x_704_ = ((lean_object*)(lp_ir_x2dproof_IRProof_connectionVertices___closed__0));
v___x_705_ = lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__0(v_splines_702_, v___x_704_);
v___x_706_ = lp_ir_x2dproof_IRProof_connectionVertices(v_connections_703_);
v___x_707_ = l_List_appendTR___redArg(v___x_705_, v___x_706_);
v___x_708_ = lp_ir_x2dproof___private_Init_Data_List_Impl_0__List_flatMapTR_go___at___00IRProof_buildRoutingGraph_spec__1(v_connections_703_, v_splines_702_, v___x_704_);
lean_dec(v_connections_703_);
v___x_709_ = lean_alloc_ctor(0, 4, 0);
lean_ctor_set(v___x_709_, 0, v_revision_701_);
lean_ctor_set(v___x_709_, 1, v_splines_702_);
lean_ctor_set(v___x_709_, 2, v___x_707_);
lean_ctor_set(v___x_709_, 3, v___x_708_);
return v___x_709_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_closestCandidate(lean_object* v_xs_710_){
_start:
{
if (lean_obj_tag(v_xs_710_) == 0)
{
lean_object* v___x_711_; 
v___x_711_ = lean_box(0);
return v___x_711_;
}
else
{
lean_object* v_head_712_; lean_object* v_tail_713_; lean_object* v___x_714_; 
v_head_712_ = lean_ctor_get(v_xs_710_, 0);
lean_inc(v_head_712_);
v_tail_713_ = lean_ctor_get(v_xs_710_, 1);
lean_inc(v_tail_713_);
lean_dec_ref_known(v_xs_710_, 2);
v___x_714_ = lp_ir_x2dproof_IRProof_closestCandidate(v_tail_713_);
if (lean_obj_tag(v___x_714_) == 0)
{
lean_object* v___x_715_; 
v___x_715_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_715_, 0, v_head_712_);
return v___x_715_;
}
else
{
lean_object* v_val_716_; lean_object* v_snd_717_; lean_object* v_snd_718_; lean_object* v_snd_719_; lean_object* v_snd_720_; uint8_t v___x_721_; 
v_val_716_ = lean_ctor_get(v___x_714_, 0);
lean_inc(v_val_716_);
v_snd_717_ = lean_ctor_get(v_val_716_, 1);
lean_inc(v_snd_717_);
lean_dec(v_val_716_);
v_snd_718_ = lean_ctor_get(v_head_712_, 1);
v_snd_719_ = lean_ctor_get(v_snd_717_, 1);
lean_inc(v_snd_719_);
lean_dec(v_snd_717_);
v_snd_720_ = lean_ctor_get(v_snd_718_, 1);
lean_inc(v_snd_720_);
v___x_721_ = l_Rat_instDecidableLe(v_snd_719_, v_snd_720_);
if (v___x_721_ == 0)
{
lean_object* v___x_723_; uint8_t v_isShared_724_; uint8_t v_isSharedCheck_728_; 
v_isSharedCheck_728_ = !lean_is_exclusive(v___x_714_);
if (v_isSharedCheck_728_ == 0)
{
lean_object* v_unused_729_; 
v_unused_729_ = lean_ctor_get(v___x_714_, 0);
lean_dec(v_unused_729_);
v___x_723_ = v___x_714_;
v_isShared_724_ = v_isSharedCheck_728_;
goto v_resetjp_722_;
}
else
{
lean_dec(v___x_714_);
v___x_723_ = lean_box(0);
v_isShared_724_ = v_isSharedCheck_728_;
goto v_resetjp_722_;
}
v_resetjp_722_:
{
lean_object* v___x_726_; 
if (v_isShared_724_ == 0)
{
lean_ctor_set(v___x_723_, 0, v_head_712_);
v___x_726_ = v___x_723_;
goto v_reusejp_725_;
}
else
{
lean_object* v_reuseFailAlloc_727_; 
v_reuseFailAlloc_727_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v_reuseFailAlloc_727_, 0, v_head_712_);
v___x_726_ = v_reuseFailAlloc_727_;
goto v_reusejp_725_;
}
v_reusejp_725_:
{
return v___x_726_;
}
}
}
else
{
lean_dec(v_head_712_);
return v___x_714_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_mapClosestMarker(lean_object* v_m_730_, lean_object* v_candidates_731_){
_start:
{
lean_object* v___x_732_; 
v___x_732_ = lp_ir_x2dproof_IRProof_closestCandidate(v_candidates_731_);
if (lean_obj_tag(v___x_732_) == 0)
{
lean_object* v___x_733_; 
lean_dec_ref(v_m_730_);
v___x_733_ = lean_box(0);
return v___x_733_;
}
else
{
lean_object* v_val_734_; lean_object* v_snd_735_; lean_object* v_fst_736_; lean_object* v_fst_737_; lean_object* v_snd_738_; lean_object* v___x_739_; 
v_val_734_ = lean_ctor_get(v___x_732_, 0);
lean_inc(v_val_734_);
lean_dec_ref_known(v___x_732_, 1);
v_snd_735_ = lean_ctor_get(v_val_734_, 1);
lean_inc(v_snd_735_);
v_fst_736_ = lean_ctor_get(v_val_734_, 0);
lean_inc(v_fst_736_);
lean_dec(v_val_734_);
v_fst_737_ = lean_ctor_get(v_snd_735_, 0);
lean_inc(v_fst_737_);
v_snd_738_ = lean_ctor_get(v_snd_735_, 1);
lean_inc(v_snd_738_);
lean_dec(v_snd_735_);
v___x_739_ = lp_ir_x2dproof_IRProof_mapMarker(v_m_730_, v_fst_736_, v_fst_737_, v_snd_738_);
return v___x_739_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorIdx(uint8_t v_x_740_){
_start:
{
switch(v_x_740_)
{
case 0:
{
lean_object* v___x_741_; 
v___x_741_ = lean_unsigned_to_nat(0u);
return v___x_741_;
}
case 1:
{
lean_object* v___x_742_; 
v___x_742_ = lean_unsigned_to_nat(1u);
return v___x_742_;
}
default: 
{
lean_object* v___x_743_; 
v___x_743_ = lean_unsigned_to_nat(2u);
return v___x_743_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorIdx___boxed(lean_object* v_x_744_){
_start:
{
uint8_t v_x_boxed_745_; lean_object* v_res_746_; 
v_x_boxed_745_ = lean_unbox(v_x_744_);
v_res_746_ = lp_ir_x2dproof_IRProof_RouteAction_ctorIdx(v_x_boxed_745_);
return v_res_746_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_toCtorIdx(uint8_t v_x_747_){
_start:
{
lean_object* v___x_748_; 
v___x_748_ = lp_ir_x2dproof_IRProof_RouteAction_ctorIdx(v_x_747_);
return v___x_748_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_toCtorIdx___boxed(lean_object* v_x_749_){
_start:
{
uint8_t v_x_4__boxed_750_; lean_object* v_res_751_; 
v_x_4__boxed_750_ = lean_unbox(v_x_749_);
v_res_751_ = lp_ir_x2dproof_IRProof_RouteAction_toCtorIdx(v_x_4__boxed_750_);
return v_res_751_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim___redArg(lean_object* v_k_752_){
_start:
{
lean_inc(v_k_752_);
return v_k_752_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim___redArg___boxed(lean_object* v_k_753_){
_start:
{
lean_object* v_res_754_; 
v_res_754_ = lp_ir_x2dproof_IRProof_RouteAction_ctorElim___redArg(v_k_753_);
lean_dec(v_k_753_);
return v_res_754_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim(lean_object* v_motive_755_, lean_object* v_ctorIdx_756_, uint8_t v_t_757_, lean_object* v_h_758_, lean_object* v_k_759_){
_start:
{
lean_inc(v_k_759_);
return v_k_759_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ctorElim___boxed(lean_object* v_motive_760_, lean_object* v_ctorIdx_761_, lean_object* v_t_762_, lean_object* v_h_763_, lean_object* v_k_764_){
_start:
{
uint8_t v_t_boxed_765_; lean_object* v_res_766_; 
v_t_boxed_765_ = lean_unbox(v_t_762_);
v_res_766_ = lp_ir_x2dproof_IRProof_RouteAction_ctorElim(v_motive_760_, v_ctorIdx_761_, v_t_boxed_765_, v_h_763_, v_k_764_);
lean_dec(v_k_764_);
lean_dec(v_ctorIdx_761_);
return v_res_766_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim___redArg(lean_object* v_continue_767_){
_start:
{
lean_inc(v_continue_767_);
return v_continue_767_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim___redArg___boxed(lean_object* v_continue_768_){
_start:
{
lean_object* v_res_769_; 
v_res_769_ = lp_ir_x2dproof_IRProof_RouteAction_continue_elim___redArg(v_continue_768_);
lean_dec(v_continue_768_);
return v_res_769_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim(lean_object* v_motive_770_, uint8_t v_t_771_, lean_object* v_h_772_, lean_object* v_continue_773_){
_start:
{
lean_inc(v_continue_773_);
return v_continue_773_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_continue_elim___boxed(lean_object* v_motive_774_, lean_object* v_t_775_, lean_object* v_h_776_, lean_object* v_continue_777_){
_start:
{
uint8_t v_t_boxed_778_; lean_object* v_res_779_; 
v_t_boxed_778_ = lean_unbox(v_t_775_);
v_res_779_ = lp_ir_x2dproof_IRProof_RouteAction_continue_elim(v_motive_774_, v_t_boxed_778_, v_h_776_, v_continue_777_);
lean_dec(v_continue_777_);
return v_res_779_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim___redArg(lean_object* v_replan_780_){
_start:
{
lean_inc(v_replan_780_);
return v_replan_780_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim___redArg___boxed(lean_object* v_replan_781_){
_start:
{
lean_object* v_res_782_; 
v_res_782_ = lp_ir_x2dproof_IRProof_RouteAction_replan_elim___redArg(v_replan_781_);
lean_dec(v_replan_781_);
return v_res_782_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim(lean_object* v_motive_783_, uint8_t v_t_784_, lean_object* v_h_785_, lean_object* v_replan_786_){
_start:
{
lean_inc(v_replan_786_);
return v_replan_786_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_replan_elim___boxed(lean_object* v_motive_787_, lean_object* v_t_788_, lean_object* v_h_789_, lean_object* v_replan_790_){
_start:
{
uint8_t v_t_boxed_791_; lean_object* v_res_792_; 
v_t_boxed_791_ = lean_unbox(v_t_788_);
v_res_792_ = lp_ir_x2dproof_IRProof_RouteAction_replan_elim(v_motive_787_, v_t_boxed_791_, v_h_789_, v_replan_790_);
lean_dec(v_replan_790_);
return v_res_792_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim___redArg(lean_object* v_failClosed_793_){
_start:
{
lean_inc(v_failClosed_793_);
return v_failClosed_793_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim___redArg___boxed(lean_object* v_failClosed_794_){
_start:
{
lean_object* v_res_795_; 
v_res_795_ = lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim___redArg(v_failClosed_794_);
lean_dec(v_failClosed_794_);
return v_res_795_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim(lean_object* v_motive_796_, uint8_t v_t_797_, lean_object* v_h_798_, lean_object* v_failClosed_799_){
_start:
{
lean_inc(v_failClosed_799_);
return v_failClosed_799_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim___boxed(lean_object* v_motive_800_, lean_object* v_t_801_, lean_object* v_h_802_, lean_object* v_failClosed_803_){
_start:
{
uint8_t v_t_boxed_804_; lean_object* v_res_805_; 
v_t_boxed_804_ = lean_unbox(v_t_801_);
v_res_805_ = lp_ir_x2dproof_IRProof_RouteAction_failClosed_elim(v_motive_800_, v_t_boxed_804_, v_h_802_, v_failClosed_803_);
lean_dec(v_failClosed_803_);
return v_res_805_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_RouteAction_ofNat(lean_object* v_n_806_){
_start:
{
lean_object* v___x_807_; uint8_t v___x_808_; 
v___x_807_ = lean_unsigned_to_nat(0u);
v___x_808_ = lean_nat_dec_le(v_n_806_, v___x_807_);
if (v___x_808_ == 0)
{
lean_object* v___x_809_; uint8_t v___x_810_; 
v___x_809_ = lean_unsigned_to_nat(1u);
v___x_810_ = lean_nat_dec_le(v_n_806_, v___x_809_);
if (v___x_810_ == 0)
{
uint8_t v___x_811_; 
v___x_811_ = 2;
return v___x_811_;
}
else
{
uint8_t v___x_812_; 
v___x_812_ = 1;
return v___x_812_;
}
}
else
{
uint8_t v___x_813_; 
v___x_813_ = 0;
return v___x_813_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_RouteAction_ofNat___boxed(lean_object* v_n_814_){
_start:
{
uint8_t v_res_815_; lean_object* v_r_816_; 
v_res_815_ = lp_ir_x2dproof_IRProof_RouteAction_ofNat(v_n_814_);
lean_dec(v_n_814_);
v_r_816_ = lean_box(v_res_815_);
return v_r_816_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_instDecidableEqRouteAction(uint8_t v_x_817_, uint8_t v_y_818_){
_start:
{
lean_object* v___x_819_; lean_object* v___x_820_; uint8_t v___x_821_; 
v___x_819_ = lp_ir_x2dproof_IRProof_RouteAction_ctorIdx(v_x_817_);
v___x_820_ = lp_ir_x2dproof_IRProof_RouteAction_ctorIdx(v_y_818_);
v___x_821_ = lean_nat_dec_eq(v___x_819_, v___x_820_);
lean_dec(v___x_820_);
lean_dec(v___x_819_);
return v___x_821_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instDecidableEqRouteAction___boxed(lean_object* v_x_822_, lean_object* v_y_823_){
_start:
{
uint8_t v_x_13__boxed_824_; uint8_t v_y_14__boxed_825_; uint8_t v_res_826_; lean_object* v_r_827_; 
v_x_13__boxed_824_ = lean_unbox(v_x_822_);
v_y_14__boxed_825_ = lean_unbox(v_y_823_);
v_res_826_ = lp_ir_x2dproof_IRProof_instDecidableEqRouteAction(v_x_13__boxed_824_, v_y_14__boxed_825_);
v_r_827_ = lean_box(v_res_826_);
return v_r_827_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr(uint8_t v_x_837_, lean_object* v_prec_838_){
_start:
{
lean_object* v___y_840_; lean_object* v___y_847_; lean_object* v___y_854_; 
switch(v_x_837_)
{
case 0:
{
lean_object* v___x_860_; uint8_t v___x_861_; 
v___x_860_ = lean_unsigned_to_nat(1024u);
v___x_861_ = lean_nat_dec_le(v___x_860_, v_prec_838_);
if (v___x_861_ == 0)
{
lean_object* v___x_862_; 
v___x_862_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_840_ = v___x_862_;
goto v___jp_839_;
}
else
{
lean_object* v___x_863_; 
v___x_863_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_840_ = v___x_863_;
goto v___jp_839_;
}
}
case 1:
{
lean_object* v___x_864_; uint8_t v___x_865_; 
v___x_864_ = lean_unsigned_to_nat(1024u);
v___x_865_ = lean_nat_dec_le(v___x_864_, v_prec_838_);
if (v___x_865_ == 0)
{
lean_object* v___x_866_; 
v___x_866_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_847_ = v___x_866_;
goto v___jp_846_;
}
else
{
lean_object* v___x_867_; 
v___x_867_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_847_ = v___x_867_;
goto v___jp_846_;
}
}
default: 
{
lean_object* v___x_868_; uint8_t v___x_869_; 
v___x_868_ = lean_unsigned_to_nat(1024u);
v___x_869_ = lean_nat_dec_le(v___x_868_, v_prec_838_);
if (v___x_869_ == 0)
{
lean_object* v___x_870_; 
v___x_870_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__18);
v___y_854_ = v___x_870_;
goto v___jp_853_;
}
else
{
lean_object* v___x_871_; 
v___x_871_ = lean_obj_once(&lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19, &lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19_once, _init_lp_ir_x2dproof_IRProof_instReprReconstructionKind_repr___closed__19);
v___y_854_ = v___x_871_;
goto v___jp_853_;
}
}
}
v___jp_839_:
{
lean_object* v___x_841_; lean_object* v___x_842_; uint8_t v___x_843_; lean_object* v___x_844_; lean_object* v___x_845_; 
v___x_841_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__1));
lean_inc(v___y_840_);
v___x_842_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_842_, 0, v___y_840_);
lean_ctor_set(v___x_842_, 1, v___x_841_);
v___x_843_ = 0;
v___x_844_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_844_, 0, v___x_842_);
lean_ctor_set_uint8(v___x_844_, sizeof(void*)*1, v___x_843_);
v___x_845_ = l_Repr_addAppParen(v___x_844_, v_prec_838_);
return v___x_845_;
}
v___jp_846_:
{
lean_object* v___x_848_; lean_object* v___x_849_; uint8_t v___x_850_; lean_object* v___x_851_; lean_object* v___x_852_; 
v___x_848_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__3));
lean_inc(v___y_847_);
v___x_849_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_849_, 0, v___y_847_);
lean_ctor_set(v___x_849_, 1, v___x_848_);
v___x_850_ = 0;
v___x_851_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_851_, 0, v___x_849_);
lean_ctor_set_uint8(v___x_851_, sizeof(void*)*1, v___x_850_);
v___x_852_ = l_Repr_addAppParen(v___x_851_, v_prec_838_);
return v___x_852_;
}
v___jp_853_:
{
lean_object* v___x_855_; lean_object* v___x_856_; uint8_t v___x_857_; lean_object* v___x_858_; lean_object* v___x_859_; 
v___x_855_ = ((lean_object*)(lp_ir_x2dproof_IRProof_instReprRouteAction_repr___closed__5));
lean_inc(v___y_854_);
v___x_856_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_856_, 0, v___y_854_);
lean_ctor_set(v___x_856_, 1, v___x_855_);
v___x_857_ = 0;
v___x_858_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_858_, 0, v___x_856_);
lean_ctor_set_uint8(v___x_858_, sizeof(void*)*1, v___x_857_);
v___x_859_ = l_Repr_addAppParen(v___x_858_, v_prec_838_);
return v___x_859_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_instReprRouteAction_repr___boxed(lean_object* v_x_872_, lean_object* v_prec_873_){
_start:
{
uint8_t v_x_173__boxed_874_; lean_object* v_res_875_; 
v_x_173__boxed_874_ = lean_unbox(v_x_872_);
v_res_875_ = lp_ir_x2dproof_IRProof_instReprRouteAction_repr(v_x_173__boxed_874_, v_prec_873_);
lean_dec(v_prec_873_);
return v_res_875_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_routeAction(lean_object* v_route_878_, lean_object* v_graph_879_, lean_object* v_latestRevision_880_, uint8_t v_routeFound_881_){
_start:
{
uint8_t v___y_883_; lean_object* v_graphRevision_887_; uint8_t v___x_888_; 
v_graphRevision_887_ = lean_ctor_get(v_route_878_, 0);
v___x_888_ = lean_nat_dec_eq(v_graphRevision_887_, v_latestRevision_880_);
if (v___x_888_ == 0)
{
lean_dec_ref(v_route_878_);
v___y_883_ = v___x_888_;
goto v___jp_882_;
}
else
{
uint8_t v___x_889_; 
v___x_889_ = lp_ir_x2dproof_IRProof_routeEdgeSetValid(v_route_878_, v_graph_879_);
v___y_883_ = v___x_889_;
goto v___jp_882_;
}
v___jp_882_:
{
if (v___y_883_ == 0)
{
if (v_routeFound_881_ == 0)
{
uint8_t v___x_884_; 
v___x_884_ = 2;
return v___x_884_;
}
else
{
uint8_t v___x_885_; 
v___x_885_ = 1;
return v___x_885_;
}
}
else
{
uint8_t v___x_886_; 
v___x_886_ = 0;
return v___x_886_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_routeAction___boxed(lean_object* v_route_890_, lean_object* v_graph_891_, lean_object* v_latestRevision_892_, lean_object* v_routeFound_893_){
_start:
{
uint8_t v_routeFound_boxed_894_; uint8_t v_res_895_; lean_object* v_r_896_; 
v_routeFound_boxed_894_ = lean_unbox(v_routeFound_893_);
v_res_895_ = lp_ir_x2dproof_IRProof_routeAction(v_route_890_, v_graph_891_, v_latestRevision_892_, v_routeFound_boxed_894_);
lean_dec(v_latestRevision_892_);
lean_dec_ref(v_graph_891_);
v_r_896_ = lean_box(v_res_895_);
return v_r_896_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_freezeProfile(lean_object* v_xs_897_){
_start:
{
lean_object* v___x_898_; lean_object* v___x_899_; 
lean_inc(v_xs_897_);
v___x_898_ = lp_ir_x2dproof_IRProof_profileFingerprints(v_xs_897_);
v___x_899_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v___x_899_, 0, v_xs_897_);
lean_ctor_set(v___x_899_, 1, v___x_898_);
return v___x_899_;
}
}
LEAN_EXPORT uint8_t lp_ir_x2dproof_IRProof_frozenProfileMatches(lean_object* v_f_900_, lean_object* v_actual_901_){
_start:
{
lean_object* v_fingerprint_902_; lean_object* v___x_903_; lean_object* v___x_904_; uint8_t v___x_905_; 
v_fingerprint_902_ = lean_ctor_get(v_f_900_, 1);
lean_inc(v_fingerprint_902_);
lean_dec_ref(v_f_900_);
v___x_903_ = lean_alloc_closure((void*)(lp_ir_x2dproof_IRProof_instDecidableEqProfileFingerprint___boxed), 2, 0);
v___x_904_ = lp_ir_x2dproof_IRProof_profileFingerprints(v_actual_901_);
v___x_905_ = l_instDecidableEqList___redArg(v___x_903_, v_fingerprint_902_, v___x_904_);
return v___x_905_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_frozenProfileMatches___boxed(lean_object* v_f_906_, lean_object* v_actual_907_){
_start:
{
uint8_t v_res_908_; lean_object* v_r_909_; 
v_res_908_ = lp_ir_x2dproof_IRProof_frozenProfileMatches(v_f_906_, v_actual_907_);
v_r_909_ = lean_box(v_res_908_);
return v_r_909_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_optionQOrZero(lean_object* v_x_910_){
_start:
{
if (lean_obj_tag(v_x_910_) == 0)
{
lean_object* v___x_911_; 
v___x_911_ = lean_obj_once(&lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1, &lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1_once, _init_lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1);
return v___x_911_;
}
else
{
lean_object* v_val_912_; 
v_val_912_ = lean_ctor_get(v_x_910_, 0);
lean_inc(v_val_912_);
return v_val_912_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_optionQOrZero___boxed(lean_object* v_x_913_){
_start:
{
lean_object* v_res_914_; 
v_res_914_ = lp_ir_x2dproof_IRProof_optionQOrZero(v_x_913_);
lean_dec(v_x_913_);
return v_res_914_;
}
}
static lean_object* _init_lp_ir_x2dproof_IRProof_physicsFromObservation___closed__0(void){
_start:
{
lean_object* v___x_915_; lean_object* v___x_916_; 
v___x_915_ = lean_unsigned_to_nat(1u);
v___x_916_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_915_);
return v___x_916_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_physicsFromObservation(lean_object* v_s_917_){
_start:
{
lean_object* v_weightKg_918_; lean_object* v_speedMps_919_; lean_object* v_brakeSystemEfficiency_920_; lean_object* v_brakeAdhesionEfficiency_921_; lean_object* v_brakeMultiplier_922_; uint8_t v_hasTrainBrake_923_; uint8_t v_hasIndependentBrake_924_; lean_object* v_tractiveEffortN_925_; uint8_t v_cogging_926_; lean_object* v___x_927_; lean_object* v___x_928_; lean_object* v___x_929_; uint8_t v___x_930_; lean_object* v___x_931_; 
v_weightKg_918_ = lean_ctor_get(v_s_917_, 2);
v_speedMps_919_ = lean_ctor_get(v_s_917_, 3);
v_brakeSystemEfficiency_920_ = lean_ctor_get(v_s_917_, 4);
v_brakeAdhesionEfficiency_921_ = lean_ctor_get(v_s_917_, 5);
v_brakeMultiplier_922_ = lean_ctor_get(v_s_917_, 6);
v_hasTrainBrake_923_ = lean_ctor_get_uint8(v_s_917_, sizeof(void*)*8 + 1);
v_hasIndependentBrake_924_ = lean_ctor_get_uint8(v_s_917_, sizeof(void*)*8 + 2);
v_tractiveEffortN_925_ = lean_ctor_get(v_s_917_, 7);
v_cogging_926_ = lean_ctor_get_uint8(v_s_917_, sizeof(void*)*8 + 3);
v___x_927_ = lean_obj_once(&lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1, &lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1_once, _init_lp_ir_x2dproof_IRProof_splineForwardEdge___closed__1);
v___x_928_ = lean_obj_once(&lp_ir_x2dproof_IRProof_physicsFromObservation___closed__0, &lp_ir_x2dproof_IRProof_physicsFromObservation___closed__0_once, _init_lp_ir_x2dproof_IRProof_physicsFromObservation___closed__0);
v___x_929_ = lp_ir_x2dproof_IRProof_optionQOrZero(v_tractiveEffortN_925_);
v___x_930_ = 0;
lean_inc_ref(v_brakeMultiplier_922_);
lean_inc_ref(v_brakeAdhesionEfficiency_921_);
lean_inc_ref(v_brakeSystemEfficiency_920_);
lean_inc_ref(v_speedMps_919_);
lean_inc_ref_n(v_weightKg_918_, 2);
v___x_931_ = lean_alloc_ctor(0, 19, 4);
lean_ctor_set(v___x_931_, 0, v_weightKg_918_);
lean_ctor_set(v___x_931_, 1, v_weightKg_918_);
lean_ctor_set(v___x_931_, 2, v_speedMps_919_);
lean_ctor_set(v___x_931_, 3, v___x_927_);
lean_ctor_set(v___x_931_, 4, v___x_928_);
lean_ctor_set(v___x_931_, 5, v___x_927_);
lean_ctor_set(v___x_931_, 6, v___x_929_);
lean_ctor_set(v___x_931_, 7, v___x_927_);
lean_ctor_set(v___x_931_, 8, v___x_927_);
lean_ctor_set(v___x_931_, 9, v___x_927_);
lean_ctor_set(v___x_931_, 10, v___x_927_);
lean_ctor_set(v___x_931_, 11, v___x_927_);
lean_ctor_set(v___x_931_, 12, v___x_927_);
lean_ctor_set(v___x_931_, 13, v_brakeSystemEfficiency_920_);
lean_ctor_set(v___x_931_, 14, v_brakeAdhesionEfficiency_921_);
lean_ctor_set(v___x_931_, 15, v_brakeMultiplier_922_);
lean_ctor_set(v___x_931_, 16, v___x_927_);
lean_ctor_set(v___x_931_, 17, v___x_927_);
lean_ctor_set(v___x_931_, 18, v___x_927_);
lean_ctor_set_uint8(v___x_931_, sizeof(void*)*19, v_hasTrainBrake_923_);
lean_ctor_set_uint8(v___x_931_, sizeof(void*)*19 + 1, v_hasIndependentBrake_924_);
lean_ctor_set_uint8(v___x_931_, sizeof(void*)*19 + 2, v_cogging_926_);
lean_ctor_set_uint8(v___x_931_, sizeof(void*)*19 + 3, v___x_930_);
return v___x_931_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_physicsFromObservation___boxed(lean_object* v_s_932_){
_start:
{
lean_object* v_res_933_; 
v_res_933_ = lp_ir_x2dproof_IRProof_physicsFromObservation(v_s_932_);
lean_dec_ref(v_s_932_);
return v_res_933_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profilePhysics_spec__0(lean_object* v_a_934_, lean_object* v_a_935_){
_start:
{
if (lean_obj_tag(v_a_934_) == 0)
{
lean_object* v___x_936_; 
v___x_936_ = l_List_reverse___redArg(v_a_935_);
return v___x_936_;
}
else
{
lean_object* v_head_937_; lean_object* v_tail_938_; lean_object* v___x_940_; uint8_t v_isShared_941_; uint8_t v_isSharedCheck_947_; 
v_head_937_ = lean_ctor_get(v_a_934_, 0);
v_tail_938_ = lean_ctor_get(v_a_934_, 1);
v_isSharedCheck_947_ = !lean_is_exclusive(v_a_934_);
if (v_isSharedCheck_947_ == 0)
{
v___x_940_ = v_a_934_;
v_isShared_941_ = v_isSharedCheck_947_;
goto v_resetjp_939_;
}
else
{
lean_inc(v_tail_938_);
lean_inc(v_head_937_);
lean_dec(v_a_934_);
v___x_940_ = lean_box(0);
v_isShared_941_ = v_isSharedCheck_947_;
goto v_resetjp_939_;
}
v_resetjp_939_:
{
lean_object* v___x_942_; lean_object* v___x_944_; 
v___x_942_ = lp_ir_x2dproof_IRProof_physicsFromObservation(v_head_937_);
lean_dec(v_head_937_);
if (v_isShared_941_ == 0)
{
lean_ctor_set(v___x_940_, 1, v_a_935_);
lean_ctor_set(v___x_940_, 0, v___x_942_);
v___x_944_ = v___x_940_;
goto v_reusejp_943_;
}
else
{
lean_object* v_reuseFailAlloc_946_; 
v_reuseFailAlloc_946_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_946_, 0, v___x_942_);
lean_ctor_set(v_reuseFailAlloc_946_, 1, v_a_935_);
v___x_944_ = v_reuseFailAlloc_946_;
goto v_reusejp_943_;
}
v_reusejp_943_:
{
v_a_934_ = v_tail_938_;
v_a_935_ = v___x_944_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_profilePhysics(lean_object* v_xs_948_){
_start:
{
lean_object* v___x_949_; lean_object* v___x_950_; 
v___x_949_ = lean_box(0);
v___x_950_ = lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_profilePhysics_spec__0(v_xs_948_, v___x_949_);
return v___x_950_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_commandConsistStep_spec__0(lean_object* v_dt_951_, lean_object* v_cmd_952_, lean_object* v_a_953_, lean_object* v_a_954_){
_start:
{
if (lean_obj_tag(v_a_953_) == 0)
{
lean_object* v___x_955_; 
lean_dec_ref(v_cmd_952_);
lean_dec_ref(v_dt_951_);
v___x_955_ = l_List_reverse___redArg(v_a_954_);
return v___x_955_;
}
else
{
lean_object* v_head_956_; lean_object* v_tail_957_; lean_object* v___x_959_; uint8_t v_isShared_960_; uint8_t v_isSharedCheck_966_; 
v_head_956_ = lean_ctor_get(v_a_953_, 0);
v_tail_957_ = lean_ctor_get(v_a_953_, 1);
v_isSharedCheck_966_ = !lean_is_exclusive(v_a_953_);
if (v_isSharedCheck_966_ == 0)
{
v___x_959_ = v_a_953_;
v_isShared_960_ = v_isSharedCheck_966_;
goto v_resetjp_958_;
}
else
{
lean_inc(v_tail_957_);
lean_inc(v_head_956_);
lean_dec(v_a_953_);
v___x_959_ = lean_box(0);
v_isShared_960_ = v_isSharedCheck_966_;
goto v_resetjp_958_;
}
v_resetjp_958_:
{
lean_object* v___x_961_; lean_object* v___x_963_; 
lean_inc_ref(v_cmd_952_);
lean_inc_ref(v_dt_951_);
v___x_961_ = lp_ir_x2dproof_IRProof_plantTransition(v_dt_951_, v_head_956_, v_cmd_952_);
if (v_isShared_960_ == 0)
{
lean_ctor_set(v___x_959_, 1, v_a_954_);
lean_ctor_set(v___x_959_, 0, v___x_961_);
v___x_963_ = v___x_959_;
goto v_reusejp_962_;
}
else
{
lean_object* v_reuseFailAlloc_965_; 
v_reuseFailAlloc_965_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_965_, 0, v___x_961_);
lean_ctor_set(v_reuseFailAlloc_965_, 1, v_a_954_);
v___x_963_ = v_reuseFailAlloc_965_;
goto v_reusejp_962_;
}
v_reusejp_962_:
{
v_a_953_ = v_tail_957_;
v_a_954_ = v___x_963_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_commandConsistStep(lean_object* v_dt_967_, lean_object* v_c_968_, lean_object* v_cmd_969_){
_start:
{
lean_object* v_particles_970_; lean_object* v_trainLengthM_971_; lean_object* v_frontCouplerS_972_; lean_object* v_frontSlackM_973_; lean_object* v_rearSlackM_974_; uint8_t v_frontPushing_975_; uint8_t v_frontPulling_976_; uint8_t v_rearPushing_977_; uint8_t v_rearPulling_978_; lean_object* v___x_980_; uint8_t v_isShared_981_; uint8_t v_isSharedCheck_987_; 
v_particles_970_ = lean_ctor_get(v_c_968_, 0);
v_trainLengthM_971_ = lean_ctor_get(v_c_968_, 1);
v_frontCouplerS_972_ = lean_ctor_get(v_c_968_, 2);
v_frontSlackM_973_ = lean_ctor_get(v_c_968_, 3);
v_rearSlackM_974_ = lean_ctor_get(v_c_968_, 4);
v_frontPushing_975_ = lean_ctor_get_uint8(v_c_968_, sizeof(void*)*5);
v_frontPulling_976_ = lean_ctor_get_uint8(v_c_968_, sizeof(void*)*5 + 1);
v_rearPushing_977_ = lean_ctor_get_uint8(v_c_968_, sizeof(void*)*5 + 2);
v_rearPulling_978_ = lean_ctor_get_uint8(v_c_968_, sizeof(void*)*5 + 3);
v_isSharedCheck_987_ = !lean_is_exclusive(v_c_968_);
if (v_isSharedCheck_987_ == 0)
{
v___x_980_ = v_c_968_;
v_isShared_981_ = v_isSharedCheck_987_;
goto v_resetjp_979_;
}
else
{
lean_inc(v_rearSlackM_974_);
lean_inc(v_frontSlackM_973_);
lean_inc(v_frontCouplerS_972_);
lean_inc(v_trainLengthM_971_);
lean_inc(v_particles_970_);
lean_dec(v_c_968_);
v___x_980_ = lean_box(0);
v_isShared_981_ = v_isSharedCheck_987_;
goto v_resetjp_979_;
}
v_resetjp_979_:
{
lean_object* v___x_982_; lean_object* v___x_983_; lean_object* v___x_985_; 
v___x_982_ = lean_box(0);
v___x_983_ = lp_ir_x2dproof_List_mapTR_loop___at___00IRProof_commandConsistStep_spec__0(v_dt_967_, v_cmd_969_, v_particles_970_, v___x_982_);
if (v_isShared_981_ == 0)
{
lean_ctor_set(v___x_980_, 0, v___x_983_);
v___x_985_ = v___x_980_;
goto v_reusejp_984_;
}
else
{
lean_object* v_reuseFailAlloc_986_; 
v_reuseFailAlloc_986_ = lean_alloc_ctor(0, 5, 4);
lean_ctor_set(v_reuseFailAlloc_986_, 0, v___x_983_);
lean_ctor_set(v_reuseFailAlloc_986_, 1, v_trainLengthM_971_);
lean_ctor_set(v_reuseFailAlloc_986_, 2, v_frontCouplerS_972_);
lean_ctor_set(v_reuseFailAlloc_986_, 3, v_frontSlackM_973_);
lean_ctor_set(v_reuseFailAlloc_986_, 4, v_rearSlackM_974_);
lean_ctor_set_uint8(v_reuseFailAlloc_986_, sizeof(void*)*5, v_frontPushing_975_);
lean_ctor_set_uint8(v_reuseFailAlloc_986_, sizeof(void*)*5 + 1, v_frontPulling_976_);
lean_ctor_set_uint8(v_reuseFailAlloc_986_, sizeof(void*)*5 + 2, v_rearPushing_977_);
lean_ctor_set_uint8(v_reuseFailAlloc_986_, sizeof(void*)*5 + 3, v_rearPulling_978_);
v___x_985_ = v_reuseFailAlloc_986_;
goto v_reusejp_984_;
}
v_reusejp_984_:
{
return v___x_985_;
}
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalStep(lean_object* v_a_988_, lean_object* v_dt_989_, lean_object* v_s_990_){
_start:
{
lean_object* v___x_991_; 
v___x_991_ = lp_ir_x2dproof_IRProof_certifiedBrakeStep(v_a_988_, v_dt_989_, v_s_990_);
return v___x_991_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalStep___boxed(lean_object* v_a_992_, lean_object* v_dt_993_, lean_object* v_s_994_){
_start:
{
lean_object* v_res_995_; 
v_res_995_ = lp_ir_x2dproof_IRProof_arrivalStep(v_a_992_, v_dt_993_, v_s_994_);
lean_dec_ref(v_a_992_);
return v_res_995_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalRun(lean_object* v_a_996_, lean_object* v_dt_997_, lean_object* v_x_998_, lean_object* v_x_999_){
_start:
{
lean_object* v_zero_1000_; uint8_t v_isZero_1001_; 
v_zero_1000_ = lean_unsigned_to_nat(0u);
v_isZero_1001_ = lean_nat_dec_eq(v_x_998_, v_zero_1000_);
if (v_isZero_1001_ == 1)
{
lean_dec(v_x_998_);
lean_dec_ref(v_dt_997_);
return v_x_999_;
}
else
{
lean_object* v_one_1002_; lean_object* v_n_1003_; lean_object* v___x_1004_; 
v_one_1002_ = lean_unsigned_to_nat(1u);
v_n_1003_ = lean_nat_sub(v_x_998_, v_one_1002_);
lean_dec(v_x_998_);
lean_inc_ref(v_dt_997_);
v___x_1004_ = lp_ir_x2dproof_IRProof_certifiedBrakeStep(v_a_996_, v_dt_997_, v_x_999_);
v_x_998_ = v_n_1003_;
v_x_999_ = v___x_1004_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof_IRProof_arrivalRun___boxed(lean_object* v_a_1006_, lean_object* v_dt_1007_, lean_object* v_x_1008_, lean_object* v_x_1009_){
_start:
{
lean_object* v_res_1010_; 
v_res_1010_ = lp_ir_x2dproof_IRProof_arrivalRun(v_a_1006_, v_dt_1007_, v_x_1008_, v_x_1009_);
lean_dec_ref(v_a_1006_);
return v_res_1010_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter___redArg(lean_object* v_x_1011_, lean_object* v_x_1012_, lean_object* v_h__1_1013_, lean_object* v_h__2_1014_){
_start:
{
lean_object* v_zero_1015_; uint8_t v_isZero_1016_; 
v_zero_1015_ = lean_unsigned_to_nat(0u);
v_isZero_1016_ = lean_nat_dec_eq(v_x_1011_, v_zero_1015_);
if (v_isZero_1016_ == 1)
{
lean_object* v___x_1017_; 
lean_dec(v_h__2_1014_);
v___x_1017_ = lean_apply_1(v_h__1_1013_, v_x_1012_);
return v___x_1017_;
}
else
{
lean_object* v_one_1018_; lean_object* v_n_1019_; lean_object* v___x_1020_; 
lean_dec(v_h__1_1013_);
v_one_1018_ = lean_unsigned_to_nat(1u);
v_n_1019_ = lean_nat_sub(v_x_1011_, v_one_1018_);
v___x_1020_ = lean_apply_2(v_h__2_1014_, v_n_1019_, v_x_1012_);
return v___x_1020_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter___redArg___boxed(lean_object* v_x_1021_, lean_object* v_x_1022_, lean_object* v_h__1_1023_, lean_object* v_h__2_1024_){
_start:
{
lean_object* v_res_1025_; 
v_res_1025_ = lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter___redArg(v_x_1021_, v_x_1022_, v_h__1_1023_, v_h__2_1024_);
lean_dec(v_x_1021_);
return v_res_1025_;
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter(lean_object* v_motive_1026_, lean_object* v_x_1027_, lean_object* v_x_1028_, lean_object* v_h__1_1029_, lean_object* v_h__2_1030_){
_start:
{
lean_object* v_zero_1031_; uint8_t v_isZero_1032_; 
v_zero_1031_ = lean_unsigned_to_nat(0u);
v_isZero_1032_ = lean_nat_dec_eq(v_x_1027_, v_zero_1031_);
if (v_isZero_1032_ == 1)
{
lean_object* v___x_1033_; 
lean_dec(v_h__2_1030_);
v___x_1033_ = lean_apply_1(v_h__1_1029_, v_x_1028_);
return v___x_1033_;
}
else
{
lean_object* v_one_1034_; lean_object* v_n_1035_; lean_object* v___x_1036_; 
lean_dec(v_h__1_1029_);
v_one_1034_ = lean_unsigned_to_nat(1u);
v_n_1035_ = lean_nat_sub(v_x_1027_, v_one_1034_);
v___x_1036_ = lean_apply_2(v_h__2_1030_, v_n_1035_, v_x_1028_);
return v___x_1036_;
}
}
}
LEAN_EXPORT lean_object* lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter___boxed(lean_object* v_motive_1037_, lean_object* v_x_1038_, lean_object* v_x_1039_, lean_object* v_h__1_1040_, lean_object* v_h__2_1041_){
_start:
{
lean_object* v_res_1042_; 
v_res_1042_ = lp_ir_x2dproof___private_IRCertifiedModel_0__IRProof_arrivalRun_match__1_splitter(v_motive_1037_, v_x_1038_, v_x_1039_, v_h__1_1040_, v_h__2_1041_);
lean_dec(v_x_1038_);
return v_res_1042_;
}
}
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_ir_x2dproof_IRProof(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_ir_x2dproof_IRCertifiedModel(uint8_t builtin) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_ir_x2dproof_IRProof(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
