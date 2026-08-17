// Lean compiler output
// Module: PidProof
// Imports: public import Init public meta import Init public import Lean
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
lean_object* l_Rat_add(lean_object*, lean_object*);
uint8_t l_Rat_instDecidableLe(lean_object*, lean_object*);
lean_object* l_Rat_neg(lean_object*);
uint8_t l_Rat_blt(lean_object*, lean_object*);
lean_object* l_Rat_div(lean_object*, lean_object*);
lean_object* l_Rat_mul(lean_object*, lean_object*);
lean_object* l_Rat_sub(lean_object*, lean_object*);
lean_object* l_Rat_pow(lean_object*, lean_object*);
lean_object* l_List_reverse___redArg(lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
lean_object* lean_nat_sub(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_square(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_clamp(lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_sat01___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_sat01___closed__0;
static lean_once_cell_t lp_pid_x2dproof_PidProof_sat01___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_sat01___closed__1;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sat01(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_satSym(lean_object*, lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelStatic___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelStatic___closed__0;
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelStatic___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelStatic___closed__1;
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelStatic___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelStatic___closed__2;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_steelStatic;
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelKinetic___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelKinetic___closed__0;
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelKinetic___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelKinetic___closed__1;
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelKinetic___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelKinetic___closed__2;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_steelKinetic;
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__0;
static lean_once_cell_t lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__1;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_steelCastIronKinetic;
static lean_once_cell_t lp_pid_x2dproof_PidProof_gravity___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_gravity___closed__0;
static lean_once_cell_t lp_pid_x2dproof_PidProof_gravity___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_gravity___closed__1;
static lean_once_cell_t lp_pid_x2dproof_PidProof_gravity___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_gravity___closed__2;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_gravity;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_defaultBrakeMultiplier;
static lean_once_cell_t lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8ForcesNewtons(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8PhysicalPressure(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8MaximumAdhesion(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8DesignAdhesion(lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__0;
static lean_once_cell_t lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1;
static lean_once_cell_t lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__2;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8BrakeBranch(lean_object*, lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8FrictionNewtons(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8NetForce(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Stock_maximumAdhesion(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Stock_designAdhesion(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_physicalPressure(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_fullServiceBrake(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_wheelSlipBrake(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_wheelSlipBrake___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_uniformBrake(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stockNonBrakeForce(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Stock_fromJava8(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sumBy(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_mass___lam__0(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_mass___lam__0___boxed(lean_object*);
static const lean_closure_object lp_pid_x2dproof_PidProof_Consist_mass___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_pid_x2dproof_PidProof_Consist_mass___lam__0___boxed, .m_arity = 1, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_pid_x2dproof_PidProof_Consist_mass___closed__0 = (const lean_object*)&lp_pid_x2dproof_PidProof_Consist_mass___closed__0_value;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_mass(lean_object*);
static const lean_closure_object lp_pid_x2dproof_PidProof_Consist_uniformBrake___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_pid_x2dproof_PidProof_uniformBrake, .m_arity = 1, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_pid_x2dproof_PidProof_Consist_uniformBrake___closed__0 = (const lean_object*)&lp_pid_x2dproof_PidProof_Consist_uniformBrake___closed__0_value;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_uniformBrake(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_adverseBound___lam__0(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_adverseBound___lam__0___boxed(lean_object*);
static const lean_closure_object lp_pid_x2dproof_PidProof_Consist_adverseBound___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_pid_x2dproof_PidProof_Consist_adverseBound___lam__0___boxed, .m_arity = 1, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_pid_x2dproof_PidProof_Consist_adverseBound___closed__0 = (const lean_object*)&lp_pid_x2dproof_PidProof_Consist_adverseBound___closed__0_value;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_adverseBound(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_List_mapTR_loop___at___00PidProof_Consist_fromJava8_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_fromJava8(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sumJavaBy(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumBy_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumBy_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumJavaBy_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumJavaBy_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_certifiedLowerBound(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_certifiedAcceleration(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_sideSign___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_sideSign___closed__0;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sideSign(uint8_t);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sideSign___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_remainingDistance(uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_remainingDistance___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedVelocity(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedVelocity___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedSpeedError(lean_object*, lean_object*, uint8_t);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedSpeedError___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter___redArg(uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter___redArg___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingEntry(uint8_t, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingEntry___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayVelocity(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayVelocity___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayTravel(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayTravel___boxed(lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_stoppingGuard___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_stoppingGuard___closed__0;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingGuard(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingGuard___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingVelocity(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingVelocity___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingStep(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingStep___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_iterateBraking(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_iterateBraking___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingTravel(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingTravel___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter___redArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter___redArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_det3(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_closedLoopMatrix(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_matrixStep(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_matrixStep___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_closedLoopStep(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_characteristic(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_shiftedCharacteristic(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_poleGains___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_poleGains___closed__0;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_poleGains(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_speedError(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_provisionalIntegral(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_measuredDeceleration(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_rawEffort(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_rawEffort___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_effortSaturation(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_antiWindupIntegral(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_antiWindupIntegral___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_slewLimit(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_slewLimit___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidEffort(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidEffort___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_normalAllocation(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_dynamicBrakeAllocation(lean_object*, lean_object*, lean_object*);
static lean_once_cell_t lp_pid_x2dproof_PidProof_emergencyControl___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_pid_x2dproof_PidProof_emergencyControl___closed__0;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_emergencyControl;
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_zeroThrottleSupervisor(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_zeroThrottleSupervisor___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_aggregateParticleStep(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_aggregateParticleStep___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidStateUpdate(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidStateUpdate___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_commandNormalize(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_apiDispatch(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_apiDispatch___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_commonApiNormalize(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_radioSetBrake(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_commonApiSetTrainBrake(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_radioSetTrainBrake(lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter___redArg(uint8_t, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter___redArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter(lean_object*, uint8_t, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_commandNormalize_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_commandNormalize_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ema(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_square(lean_object* v_a_1_){
_start:
{
lean_object* v___x_2_; 
lean_inc_ref(v_a_1_);
v___x_2_ = l_Rat_mul(v_a_1_, v_a_1_);
lean_dec_ref(v_a_1_);
return v___x_2_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_clamp(lean_object* v_lo_3_, lean_object* v_hi_4_, lean_object* v_x_5_){
_start:
{
uint8_t v___x_6_; 
lean_inc_ref(v_lo_3_);
lean_inc_ref(v_x_5_);
v___x_6_ = l_Rat_blt(v_x_5_, v_lo_3_);
if (v___x_6_ == 0)
{
uint8_t v___x_7_; 
lean_dec_ref(v_lo_3_);
lean_inc_ref(v_x_5_);
lean_inc_ref(v_hi_4_);
v___x_7_ = l_Rat_blt(v_hi_4_, v_x_5_);
if (v___x_7_ == 0)
{
lean_dec_ref(v_hi_4_);
return v_x_5_;
}
else
{
lean_dec_ref(v_x_5_);
return v_hi_4_;
}
}
else
{
lean_dec_ref(v_x_5_);
lean_dec_ref(v_hi_4_);
return v_lo_3_;
}
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_sat01___closed__0(void){
_start:
{
lean_object* v___x_8_; lean_object* v___x_9_; 
v___x_8_ = lean_unsigned_to_nat(0u);
v___x_9_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_8_);
return v___x_9_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_sat01___closed__1(void){
_start:
{
lean_object* v___x_10_; lean_object* v___x_11_; 
v___x_10_ = lean_unsigned_to_nat(1u);
v___x_11_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_10_);
return v___x_11_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sat01(lean_object* v_x_12_){
_start:
{
lean_object* v___x_13_; lean_object* v___x_14_; lean_object* v___x_15_; 
v___x_13_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_14_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_15_ = lp_pid_x2dproof_PidProof_clamp(v___x_13_, v___x_14_, v_x_12_);
return v___x_15_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_satSym(lean_object* v_limit_16_, lean_object* v_x_17_){
_start:
{
lean_object* v___x_18_; lean_object* v___x_19_; 
lean_inc_ref(v_limit_16_);
v___x_18_ = l_Rat_neg(v_limit_16_);
v___x_19_ = lp_pid_x2dproof_PidProof_clamp(v___x_18_, v_limit_16_, v_x_17_);
return v___x_19_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelStatic___closed__0(void){
_start:
{
lean_object* v___x_20_; lean_object* v___x_21_; 
v___x_20_ = lean_unsigned_to_nat(7u);
v___x_21_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_20_);
return v___x_21_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelStatic___closed__1(void){
_start:
{
lean_object* v___x_22_; lean_object* v___x_23_; 
v___x_22_ = lean_unsigned_to_nat(10u);
v___x_23_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_22_);
return v___x_23_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelStatic___closed__2(void){
_start:
{
lean_object* v___x_24_; lean_object* v___x_25_; lean_object* v___x_26_; 
v___x_24_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelStatic___closed__1, &lp_pid_x2dproof_PidProof_steelStatic___closed__1_once, _init_lp_pid_x2dproof_PidProof_steelStatic___closed__1);
v___x_25_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelStatic___closed__0, &lp_pid_x2dproof_PidProof_steelStatic___closed__0_once, _init_lp_pid_x2dproof_PidProof_steelStatic___closed__0);
v___x_26_ = l_Rat_div(v___x_25_, v___x_24_);
return v___x_26_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelStatic(void){
_start:
{
lean_object* v___x_27_; 
v___x_27_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelStatic___closed__2, &lp_pid_x2dproof_PidProof_steelStatic___closed__2_once, _init_lp_pid_x2dproof_PidProof_steelStatic___closed__2);
return v___x_27_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelKinetic___closed__0(void){
_start:
{
lean_object* v___x_28_; lean_object* v___x_29_; 
v___x_28_ = lean_unsigned_to_nat(21u);
v___x_29_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_28_);
return v___x_29_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelKinetic___closed__1(void){
_start:
{
lean_object* v___x_30_; lean_object* v___x_31_; 
v___x_30_ = lean_unsigned_to_nat(50u);
v___x_31_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_30_);
return v___x_31_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelKinetic___closed__2(void){
_start:
{
lean_object* v___x_32_; lean_object* v___x_33_; lean_object* v___x_34_; 
v___x_32_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelKinetic___closed__1, &lp_pid_x2dproof_PidProof_steelKinetic___closed__1_once, _init_lp_pid_x2dproof_PidProof_steelKinetic___closed__1);
v___x_33_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelKinetic___closed__0, &lp_pid_x2dproof_PidProof_steelKinetic___closed__0_once, _init_lp_pid_x2dproof_PidProof_steelKinetic___closed__0);
v___x_34_ = l_Rat_div(v___x_33_, v___x_32_);
return v___x_34_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelKinetic(void){
_start:
{
lean_object* v___x_35_; 
v___x_35_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelKinetic___closed__2, &lp_pid_x2dproof_PidProof_steelKinetic___closed__2_once, _init_lp_pid_x2dproof_PidProof_steelKinetic___closed__2);
return v___x_35_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__0(void){
_start:
{
lean_object* v___x_36_; lean_object* v___x_37_; 
v___x_36_ = lean_unsigned_to_nat(4u);
v___x_37_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_36_);
return v___x_37_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__1(void){
_start:
{
lean_object* v___x_38_; lean_object* v___x_39_; lean_object* v___x_40_; 
v___x_38_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__0, &lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__0_once, _init_lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__0);
v___x_39_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_40_ = l_Rat_div(v___x_39_, v___x_38_);
return v___x_40_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_steelCastIronKinetic(void){
_start:
{
lean_object* v___x_41_; 
v___x_41_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__1, &lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__1_once, _init_lp_pid_x2dproof_PidProof_steelCastIronKinetic___closed__1);
return v___x_41_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_gravity___closed__0(void){
_start:
{
lean_object* v___x_42_; lean_object* v___x_43_; 
v___x_42_ = lean_unsigned_to_nat(49u);
v___x_43_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_42_);
return v___x_43_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_gravity___closed__1(void){
_start:
{
lean_object* v___x_44_; lean_object* v___x_45_; 
v___x_44_ = lean_unsigned_to_nat(5u);
v___x_45_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_44_);
return v___x_45_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_gravity___closed__2(void){
_start:
{
lean_object* v___x_46_; lean_object* v___x_47_; lean_object* v___x_48_; 
v___x_46_ = lean_obj_once(&lp_pid_x2dproof_PidProof_gravity___closed__1, &lp_pid_x2dproof_PidProof_gravity___closed__1_once, _init_lp_pid_x2dproof_PidProof_gravity___closed__1);
v___x_47_ = lean_obj_once(&lp_pid_x2dproof_PidProof_gravity___closed__0, &lp_pid_x2dproof_PidProof_gravity___closed__0_once, _init_lp_pid_x2dproof_PidProof_gravity___closed__0);
v___x_48_ = l_Rat_div(v___x_47_, v___x_46_);
return v___x_48_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_gravity(void){
_start:
{
lean_object* v___x_49_; 
v___x_49_ = lean_obj_once(&lp_pid_x2dproof_PidProof_gravity___closed__2, &lp_pid_x2dproof_PidProof_gravity___closed__2_once, _init_lp_pid_x2dproof_PidProof_gravity___closed__2);
return v___x_49_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_defaultBrakeMultiplier(void){
_start:
{
lean_object* v___x_50_; 
v___x_50_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
return v___x_50_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0(void){
_start:
{
lean_object* v___x_51_; lean_object* v___x_52_; 
v___x_51_ = lp_pid_x2dproof_PidProof_gravity;
v___x_52_ = l_Rat_neg(v___x_51_);
return v___x_52_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8ForcesNewtons(lean_object* v_x_53_){
_start:
{
lean_object* v_massKg_54_; lean_object* v_pitchSine_55_; lean_object* v_slopeMultiplier_56_; lean_object* v_tractiveEffortN_57_; lean_object* v___x_58_; lean_object* v___x_59_; lean_object* v___x_60_; lean_object* v___x_61_; lean_object* v___x_62_; 
v_massKg_54_ = lean_ctor_get(v_x_53_, 0);
lean_inc_ref(v_massKg_54_);
v_pitchSine_55_ = lean_ctor_get(v_x_53_, 2);
lean_inc_ref(v_pitchSine_55_);
v_slopeMultiplier_56_ = lean_ctor_get(v_x_53_, 3);
lean_inc_ref(v_slopeMultiplier_56_);
v_tractiveEffortN_57_ = lean_ctor_get(v_x_53_, 4);
lean_inc_ref(v_tractiveEffortN_57_);
lean_dec_ref(v_x_53_);
v___x_58_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0, &lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0_once, _init_lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0);
v___x_59_ = l_Rat_mul(v_massKg_54_, v___x_58_);
lean_dec_ref(v_massKg_54_);
v___x_60_ = l_Rat_mul(v___x_59_, v_pitchSine_55_);
lean_dec_ref(v___x_59_);
v___x_61_ = l_Rat_mul(v___x_60_, v_slopeMultiplier_56_);
lean_dec_ref(v___x_60_);
v___x_62_ = l_Rat_add(v___x_61_, v_tractiveEffortN_57_);
return v___x_62_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8PhysicalPressure(lean_object* v_train_63_, lean_object* v_independent_64_){
_start:
{
lean_object* v___x_65_; lean_object* v___y_67_; uint8_t v___x_69_; 
v___x_65_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
lean_inc_ref(v_independent_64_);
lean_inc_ref(v_train_63_);
v___x_69_ = l_Rat_instDecidableLe(v_train_63_, v_independent_64_);
if (v___x_69_ == 0)
{
lean_dec_ref(v_independent_64_);
v___y_67_ = v_train_63_;
goto v___jp_66_;
}
else
{
lean_dec_ref(v_train_63_);
v___y_67_ = v_independent_64_;
goto v___jp_66_;
}
v___jp_66_:
{
uint8_t v___x_68_; 
lean_inc_ref(v___y_67_);
v___x_68_ = l_Rat_instDecidableLe(v___x_65_, v___y_67_);
if (v___x_68_ == 0)
{
return v___y_67_;
}
else
{
lean_dec_ref(v___y_67_);
return v___x_65_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8MaximumAdhesion(lean_object* v_x_70_){
_start:
{
lean_object* v_massKg_71_; lean_object* v_brakeAdhesionEfficiency_72_; uint8_t v_cogging_73_; lean_object* v___x_74_; lean_object* v___x_75_; lean_object* v___x_76_; lean_object* v___x_77_; 
v_massKg_71_ = lean_ctor_get(v_x_70_, 0);
lean_inc_ref(v_massKg_71_);
v_brakeAdhesionEfficiency_72_ = lean_ctor_get(v_x_70_, 12);
lean_inc_ref(v_brakeAdhesionEfficiency_72_);
v_cogging_73_ = lean_ctor_get_uint8(v_x_70_, sizeof(void*)*15);
lean_dec_ref(v_x_70_);
v___x_74_ = lp_pid_x2dproof_PidProof_steelStatic;
v___x_75_ = l_Rat_mul(v_massKg_71_, v___x_74_);
lean_dec_ref(v_massKg_71_);
v___x_76_ = lp_pid_x2dproof_PidProof_gravity;
v___x_77_ = l_Rat_mul(v___x_75_, v___x_76_);
lean_dec_ref(v___x_75_);
if (v_cogging_73_ == 0)
{
lean_object* v___x_78_; 
v___x_78_ = l_Rat_mul(v___x_77_, v_brakeAdhesionEfficiency_72_);
lean_dec_ref(v___x_77_);
return v___x_78_;
}
else
{
lean_object* v___x_79_; lean_object* v___x_80_; 
lean_dec_ref(v_brakeAdhesionEfficiency_72_);
v___x_79_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelStatic___closed__1, &lp_pid_x2dproof_PidProof_steelStatic___closed__1_once, _init_lp_pid_x2dproof_PidProof_steelStatic___closed__1);
v___x_80_ = l_Rat_mul(v___x_77_, v___x_79_);
lean_dec_ref(v___x_77_);
return v___x_80_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8DesignAdhesion(lean_object* v_x_81_){
_start:
{
lean_object* v_designMassKg_82_; lean_object* v_brakeShoeFriction_83_; uint8_t v_cogging_84_; lean_object* v___x_85_; lean_object* v___x_86_; lean_object* v___x_87_; lean_object* v___x_88_; 
v_designMassKg_82_ = lean_ctor_get(v_x_81_, 1);
lean_inc_ref(v_designMassKg_82_);
v_brakeShoeFriction_83_ = lean_ctor_get(v_x_81_, 10);
lean_inc_ref(v_brakeShoeFriction_83_);
v_cogging_84_ = lean_ctor_get_uint8(v_x_81_, sizeof(void*)*15);
lean_dec_ref(v_x_81_);
v___x_85_ = lp_pid_x2dproof_PidProof_steelStatic;
v___x_86_ = l_Rat_mul(v_designMassKg_82_, v___x_85_);
lean_dec_ref(v_designMassKg_82_);
v___x_87_ = lp_pid_x2dproof_PidProof_gravity;
v___x_88_ = l_Rat_mul(v___x_86_, v___x_87_);
lean_dec_ref(v___x_86_);
if (v_cogging_84_ == 0)
{
lean_object* v___x_89_; 
v___x_89_ = l_Rat_mul(v___x_88_, v_brakeShoeFriction_83_);
lean_dec_ref(v___x_88_);
return v___x_89_;
}
else
{
lean_object* v___x_90_; lean_object* v___x_91_; 
lean_dec_ref(v_brakeShoeFriction_83_);
v___x_90_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelStatic___closed__1, &lp_pid_x2dproof_PidProof_steelStatic___closed__1_once, _init_lp_pid_x2dproof_PidProof_steelStatic___closed__1);
v___x_91_ = l_Rat_mul(v___x_88_, v___x_90_);
lean_dec_ref(v___x_88_);
return v___x_91_;
}
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__0(void){
_start:
{
lean_object* v___x_92_; lean_object* v___x_93_; 
v___x_92_ = lean_unsigned_to_nat(100u);
v___x_93_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_92_);
return v___x_93_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1(void){
_start:
{
lean_object* v___x_94_; lean_object* v___x_95_; lean_object* v___x_96_; 
v___x_94_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__0, &lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__0_once, _init_lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__0);
v___x_95_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_96_ = l_Rat_div(v___x_95_, v___x_94_);
return v___x_96_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__2(void){
_start:
{
lean_object* v___x_97_; lean_object* v___x_98_; 
v___x_97_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1, &lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1_once, _init_lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1);
v___x_98_ = l_Rat_neg(v___x_97_);
return v___x_98_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8BrakeBranch(lean_object* v_x_99_, lean_object* v_train_100_, lean_object* v_independent_101_, lean_object* v_velocity_102_){
_start:
{
lean_object* v___x_107_; lean_object* v___x_108_; lean_object* v_desired_109_; lean_object* v___x_110_; uint8_t v___x_111_; 
lean_inc_ref_n(v_x_99_, 2);
v___x_107_ = lp_pid_x2dproof_PidProof_java8DesignAdhesion(v_x_99_);
v___x_108_ = lp_pid_x2dproof_PidProof_java8PhysicalPressure(v_train_100_, v_independent_101_);
v_desired_109_ = l_Rat_mul(v___x_107_, v___x_108_);
lean_dec_ref(v___x_107_);
v___x_110_ = lp_pid_x2dproof_PidProof_java8MaximumAdhesion(v_x_99_);
lean_inc_ref(v_desired_109_);
v___x_111_ = l_Rat_blt(v___x_110_, v_desired_109_);
if (v___x_111_ == 0)
{
lean_dec_ref(v_velocity_102_);
lean_dec_ref(v_x_99_);
return v_desired_109_;
}
else
{
lean_object* v___x_112_; uint8_t v___x_113_; 
v___x_112_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1, &lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1_once, _init_lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__1);
lean_inc_ref(v_velocity_102_);
v___x_113_ = l_Rat_blt(v___x_112_, v_velocity_102_);
if (v___x_113_ == 0)
{
lean_object* v___x_114_; uint8_t v___x_115_; 
v___x_114_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__2, &lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__2_once, _init_lp_pid_x2dproof_PidProof_java8BrakeBranch___closed__2);
v___x_115_ = l_Rat_blt(v_velocity_102_, v___x_114_);
if (v___x_115_ == 0)
{
lean_dec_ref(v_x_99_);
return v_desired_109_;
}
else
{
lean_dec_ref(v_desired_109_);
goto v___jp_103_;
}
}
else
{
lean_dec_ref(v_desired_109_);
lean_dec_ref(v_velocity_102_);
goto v___jp_103_;
}
}
v___jp_103_:
{
lean_object* v_massKg_104_; lean_object* v___x_105_; lean_object* v___x_106_; 
v_massKg_104_ = lean_ctor_get(v_x_99_, 0);
lean_inc_ref(v_massKg_104_);
lean_dec_ref(v_x_99_);
v___x_105_ = lp_pid_x2dproof_PidProof_steelKinetic;
v___x_106_ = l_Rat_mul(v_massKg_104_, v___x_105_);
lean_dec_ref(v_massKg_104_);
return v___x_106_;
}
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0(void){
_start:
{
lean_object* v___x_116_; lean_object* v___x_117_; 
v___x_116_ = lean_unsigned_to_nat(1000u);
v___x_117_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_116_);
return v___x_117_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8FrictionNewtons(lean_object* v_x_118_, lean_object* v_train_119_, lean_object* v_independent_120_, lean_object* v_velocity_121_){
_start:
{
lean_object* v_massKg_122_; lean_object* v_rollingResistanceCoeff_123_; lean_object* v_interferingResistance_124_; lean_object* v_blockHardness_125_; lean_object* v_directResistanceN_126_; lean_object* v_nearZeroResistanceN_127_; lean_object* v_brakeMultiplier_128_; lean_object* v___x_129_; lean_object* v___x_130_; lean_object* v___x_131_; lean_object* v___x_132_; lean_object* v___x_133_; lean_object* v___x_134_; lean_object* v___x_135_; lean_object* v___x_136_; lean_object* v___x_137_; lean_object* v___x_138_; lean_object* v___x_139_; lean_object* v___x_140_; 
v_massKg_122_ = lean_ctor_get(v_x_118_, 0);
v_rollingResistanceCoeff_123_ = lean_ctor_get(v_x_118_, 5);
v_interferingResistance_124_ = lean_ctor_get(v_x_118_, 6);
v_blockHardness_125_ = lean_ctor_get(v_x_118_, 7);
v_directResistanceN_126_ = lean_ctor_get(v_x_118_, 8);
lean_inc_ref(v_directResistanceN_126_);
v_nearZeroResistanceN_127_ = lean_ctor_get(v_x_118_, 9);
lean_inc_ref(v_nearZeroResistanceN_127_);
v_brakeMultiplier_128_ = lean_ctor_get(v_x_118_, 13);
lean_inc_ref(v_brakeMultiplier_128_);
lean_inc_ref(v_massKg_122_);
v___x_129_ = l_Rat_mul(v_rollingResistanceCoeff_123_, v_massKg_122_);
v___x_130_ = lp_pid_x2dproof_PidProof_gravity;
v___x_131_ = l_Rat_mul(v___x_129_, v___x_130_);
lean_dec_ref(v___x_129_);
v___x_132_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0, &lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0_once, _init_lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0);
v___x_133_ = l_Rat_mul(v_interferingResistance_124_, v___x_132_);
lean_inc_ref(v_blockHardness_125_);
v___x_134_ = l_Rat_mul(v___x_133_, v_blockHardness_125_);
lean_dec_ref(v___x_133_);
v___x_135_ = l_Rat_add(v___x_131_, v___x_134_);
v___x_136_ = lp_pid_x2dproof_PidProof_java8BrakeBranch(v_x_118_, v_train_119_, v_independent_120_, v_velocity_121_);
v___x_137_ = l_Rat_mul(v_brakeMultiplier_128_, v___x_136_);
lean_dec_ref(v_brakeMultiplier_128_);
v___x_138_ = l_Rat_add(v___x_135_, v___x_137_);
v___x_139_ = l_Rat_add(v___x_138_, v_directResistanceN_126_);
v___x_140_ = l_Rat_add(v___x_139_, v_nearZeroResistanceN_127_);
return v___x_140_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_java8NetForce(lean_object* v_x_141_, lean_object* v_train_142_, lean_object* v_independent_143_, lean_object* v_velocity_144_){
_start:
{
lean_object* v___x_145_; lean_object* v___x_146_; lean_object* v___x_147_; 
lean_inc_ref(v_x_141_);
v___x_145_ = lp_pid_x2dproof_PidProof_java8ForcesNewtons(v_x_141_);
v___x_146_ = lp_pid_x2dproof_PidProof_java8FrictionNewtons(v_x_141_, v_train_142_, v_independent_143_, v_velocity_144_);
v___x_147_ = l_Rat_sub(v___x_145_, v___x_146_);
return v___x_147_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Stock_maximumAdhesion(lean_object* v_s_148_){
_start:
{
lean_object* v_massKg_149_; lean_object* v_brakeAdhesionEfficiency_150_; lean_object* v___x_151_; lean_object* v___x_152_; lean_object* v___x_153_; lean_object* v___x_154_; lean_object* v___x_155_; 
v_massKg_149_ = lean_ctor_get(v_s_148_, 0);
lean_inc_ref(v_massKg_149_);
v_brakeAdhesionEfficiency_150_ = lean_ctor_get(v_s_148_, 4);
lean_inc_ref(v_brakeAdhesionEfficiency_150_);
lean_dec_ref(v_s_148_);
v___x_151_ = lp_pid_x2dproof_PidProof_steelStatic;
v___x_152_ = l_Rat_mul(v_massKg_149_, v___x_151_);
lean_dec_ref(v_massKg_149_);
v___x_153_ = lp_pid_x2dproof_PidProof_gravity;
v___x_154_ = l_Rat_mul(v___x_152_, v___x_153_);
lean_dec_ref(v___x_152_);
v___x_155_ = l_Rat_mul(v___x_154_, v_brakeAdhesionEfficiency_150_);
lean_dec_ref(v___x_154_);
return v___x_155_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Stock_designAdhesion(lean_object* v_s_156_){
_start:
{
lean_object* v_designMassKg_157_; lean_object* v_brakeSystemEfficiency_158_; lean_object* v___x_159_; lean_object* v___x_160_; lean_object* v___x_161_; lean_object* v___x_162_; lean_object* v___x_163_; 
v_designMassKg_157_ = lean_ctor_get(v_s_156_, 1);
lean_inc_ref(v_designMassKg_157_);
v_brakeSystemEfficiency_158_ = lean_ctor_get(v_s_156_, 3);
lean_inc_ref(v_brakeSystemEfficiency_158_);
lean_dec_ref(v_s_156_);
v___x_159_ = lp_pid_x2dproof_PidProof_steelStatic;
v___x_160_ = l_Rat_mul(v_designMassKg_157_, v___x_159_);
lean_dec_ref(v_designMassKg_157_);
v___x_161_ = lp_pid_x2dproof_PidProof_gravity;
v___x_162_ = l_Rat_mul(v___x_160_, v___x_161_);
lean_dec_ref(v___x_160_);
v___x_163_ = l_Rat_mul(v___x_162_, v_brakeSystemEfficiency_158_);
lean_dec_ref(v___x_162_);
return v___x_163_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_physicalPressure(lean_object* v_train_164_, lean_object* v_independent_165_){
_start:
{
lean_object* v___x_166_; lean_object* v___y_168_; uint8_t v___x_170_; 
v___x_166_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
lean_inc_ref(v_independent_165_);
lean_inc_ref(v_train_164_);
v___x_170_ = l_Rat_instDecidableLe(v_train_164_, v_independent_165_);
if (v___x_170_ == 0)
{
lean_dec_ref(v_independent_165_);
v___y_168_ = v_train_164_;
goto v___jp_167_;
}
else
{
lean_dec_ref(v_train_164_);
v___y_168_ = v_independent_165_;
goto v___jp_167_;
}
v___jp_167_:
{
uint8_t v___x_169_; 
lean_inc_ref(v___y_168_);
v___x_169_ = l_Rat_instDecidableLe(v___x_166_, v___y_168_);
if (v___x_169_ == 0)
{
return v___y_168_;
}
else
{
lean_dec_ref(v___y_168_);
return v___x_166_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_fullServiceBrake(lean_object* v_s_171_){
_start:
{
lean_object* v_brakeMultiplier_172_; lean_object* v___x_173_; lean_object* v___x_174_; 
v_brakeMultiplier_172_ = lean_ctor_get(v_s_171_, 5);
lean_inc_ref(v_brakeMultiplier_172_);
v___x_173_ = lp_pid_x2dproof_PidProof_Stock_designAdhesion(v_s_171_);
v___x_174_ = l_Rat_mul(v_brakeMultiplier_172_, v___x_173_);
lean_dec_ref(v_brakeMultiplier_172_);
return v___x_174_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_wheelSlipBrake(lean_object* v_s_175_){
_start:
{
lean_object* v_massKg_176_; lean_object* v_brakeMultiplier_177_; lean_object* v___x_178_; lean_object* v___x_179_; lean_object* v___x_180_; 
v_massKg_176_ = lean_ctor_get(v_s_175_, 0);
v_brakeMultiplier_177_ = lean_ctor_get(v_s_175_, 5);
v___x_178_ = lp_pid_x2dproof_PidProof_steelKinetic;
v___x_179_ = l_Rat_mul(v_massKg_176_, v___x_178_);
v___x_180_ = l_Rat_mul(v_brakeMultiplier_177_, v___x_179_);
return v___x_180_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_wheelSlipBrake___boxed(lean_object* v_s_181_){
_start:
{
lean_object* v_res_182_; 
v_res_182_ = lp_pid_x2dproof_PidProof_wheelSlipBrake(v_s_181_);
lean_dec_ref(v_s_181_);
return v_res_182_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_uniformBrake(lean_object* v_s_183_){
_start:
{
lean_object* v___x_184_; lean_object* v___x_185_; uint8_t v___x_186_; 
lean_inc_ref(v_s_183_);
v___x_184_ = lp_pid_x2dproof_PidProof_fullServiceBrake(v_s_183_);
v___x_185_ = lp_pid_x2dproof_PidProof_wheelSlipBrake(v_s_183_);
lean_dec_ref(v_s_183_);
lean_inc_ref(v___x_185_);
lean_inc_ref(v___x_184_);
v___x_186_ = l_Rat_instDecidableLe(v___x_184_, v___x_185_);
if (v___x_186_ == 0)
{
lean_dec_ref(v___x_184_);
return v___x_185_;
}
else
{
lean_dec_ref(v___x_185_);
return v___x_184_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stockNonBrakeForce(lean_object* v_s_187_){
_start:
{
lean_object* v_rollingResistanceN_188_; lean_object* v_gradeForceN_189_; lean_object* v_directResistanceN_190_; lean_object* v_interferenceResistanceN_191_; lean_object* v_nearZeroResistanceN_192_; lean_object* v___x_193_; lean_object* v___x_194_; lean_object* v___x_195_; lean_object* v___x_196_; 
v_rollingResistanceN_188_ = lean_ctor_get(v_s_187_, 6);
lean_inc_ref(v_rollingResistanceN_188_);
v_gradeForceN_189_ = lean_ctor_get(v_s_187_, 7);
lean_inc_ref(v_gradeForceN_189_);
v_directResistanceN_190_ = lean_ctor_get(v_s_187_, 9);
lean_inc_ref(v_directResistanceN_190_);
v_interferenceResistanceN_191_ = lean_ctor_get(v_s_187_, 10);
lean_inc_ref(v_interferenceResistanceN_191_);
v_nearZeroResistanceN_192_ = lean_ctor_get(v_s_187_, 11);
lean_inc_ref(v_nearZeroResistanceN_192_);
lean_dec_ref(v_s_187_);
v___x_193_ = l_Rat_add(v_rollingResistanceN_188_, v_directResistanceN_190_);
v___x_194_ = l_Rat_add(v___x_193_, v_interferenceResistanceN_191_);
v___x_195_ = l_Rat_add(v___x_194_, v_nearZeroResistanceN_192_);
v___x_196_ = l_Rat_sub(v_gradeForceN_189_, v___x_195_);
return v___x_196_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Stock_fromJava8(lean_object* v_x_197_){
_start:
{
lean_object* v_massKg_198_; lean_object* v_designMassKg_199_; lean_object* v_pitchSine_200_; lean_object* v_slopeMultiplier_201_; lean_object* v_tractiveEffortN_202_; lean_object* v_rollingResistanceCoeff_203_; lean_object* v_interferingResistance_204_; lean_object* v_blockHardness_205_; lean_object* v_directResistanceN_206_; lean_object* v_nearZeroResistanceN_207_; lean_object* v_brakeShoeFriction_208_; lean_object* v_brakeAdhesionEfficiency_209_; lean_object* v_brakeMultiplier_210_; uint8_t v_cogging_211_; lean_object* v_adverseForceBoundN_212_; uint8_t v_hasPressureBrake_213_; uint8_t v_hasIndependentBrake_214_; lean_object* v___y_216_; lean_object* v___y_217_; lean_object* v___y_230_; 
v_massKg_198_ = lean_ctor_get(v_x_197_, 0);
lean_inc_ref(v_massKg_198_);
v_designMassKg_199_ = lean_ctor_get(v_x_197_, 1);
lean_inc_ref(v_designMassKg_199_);
v_pitchSine_200_ = lean_ctor_get(v_x_197_, 2);
lean_inc_ref(v_pitchSine_200_);
v_slopeMultiplier_201_ = lean_ctor_get(v_x_197_, 3);
lean_inc_ref(v_slopeMultiplier_201_);
v_tractiveEffortN_202_ = lean_ctor_get(v_x_197_, 4);
lean_inc_ref(v_tractiveEffortN_202_);
v_rollingResistanceCoeff_203_ = lean_ctor_get(v_x_197_, 5);
lean_inc_ref(v_rollingResistanceCoeff_203_);
v_interferingResistance_204_ = lean_ctor_get(v_x_197_, 6);
lean_inc_ref(v_interferingResistance_204_);
v_blockHardness_205_ = lean_ctor_get(v_x_197_, 7);
lean_inc_ref(v_blockHardness_205_);
v_directResistanceN_206_ = lean_ctor_get(v_x_197_, 8);
lean_inc_ref(v_directResistanceN_206_);
v_nearZeroResistanceN_207_ = lean_ctor_get(v_x_197_, 9);
lean_inc_ref(v_nearZeroResistanceN_207_);
v_brakeShoeFriction_208_ = lean_ctor_get(v_x_197_, 10);
lean_inc_ref(v_brakeShoeFriction_208_);
v_brakeAdhesionEfficiency_209_ = lean_ctor_get(v_x_197_, 12);
lean_inc_ref(v_brakeAdhesionEfficiency_209_);
v_brakeMultiplier_210_ = lean_ctor_get(v_x_197_, 13);
lean_inc_ref(v_brakeMultiplier_210_);
v_cogging_211_ = lean_ctor_get_uint8(v_x_197_, sizeof(void*)*15);
v_adverseForceBoundN_212_ = lean_ctor_get(v_x_197_, 14);
lean_inc_ref(v_adverseForceBoundN_212_);
v_hasPressureBrake_213_ = lean_ctor_get_uint8(v_x_197_, sizeof(void*)*15 + 1);
v_hasIndependentBrake_214_ = lean_ctor_get_uint8(v_x_197_, sizeof(void*)*15 + 2);
lean_dec_ref(v_x_197_);
if (v_cogging_211_ == 0)
{
lean_inc_ref(v_brakeShoeFriction_208_);
v___y_230_ = v_brakeShoeFriction_208_;
goto v___jp_229_;
}
else
{
lean_object* v___x_232_; 
v___x_232_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelStatic___closed__1, &lp_pid_x2dproof_PidProof_steelStatic___closed__1_once, _init_lp_pid_x2dproof_PidProof_steelStatic___closed__1);
v___y_230_ = v___x_232_;
goto v___jp_229_;
}
v___jp_215_:
{
lean_object* v___x_218_; lean_object* v___x_219_; lean_object* v___x_220_; lean_object* v___x_221_; lean_object* v___x_222_; lean_object* v___x_223_; lean_object* v___x_224_; lean_object* v___x_225_; lean_object* v___x_226_; lean_object* v___x_227_; lean_object* v___x_228_; 
lean_inc_ref(v_massKg_198_);
v___x_218_ = l_Rat_mul(v_rollingResistanceCoeff_203_, v_massKg_198_);
lean_dec_ref(v_rollingResistanceCoeff_203_);
v___x_219_ = lp_pid_x2dproof_PidProof_gravity;
v___x_220_ = l_Rat_mul(v___x_218_, v___x_219_);
lean_dec_ref(v___x_218_);
v___x_221_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0, &lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0_once, _init_lp_pid_x2dproof_PidProof_java8ForcesNewtons___closed__0);
v___x_222_ = l_Rat_mul(v_massKg_198_, v___x_221_);
v___x_223_ = l_Rat_mul(v___x_222_, v_pitchSine_200_);
lean_dec_ref(v___x_222_);
v___x_224_ = l_Rat_mul(v___x_223_, v_slopeMultiplier_201_);
lean_dec_ref(v___x_223_);
v___x_225_ = lean_obj_once(&lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0, &lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0_once, _init_lp_pid_x2dproof_PidProof_java8FrictionNewtons___closed__0);
v___x_226_ = l_Rat_mul(v_interferingResistance_204_, v___x_225_);
lean_dec_ref(v_interferingResistance_204_);
v___x_227_ = l_Rat_mul(v___x_226_, v_blockHardness_205_);
lean_dec_ref(v___x_226_);
v___x_228_ = lean_alloc_ctor(0, 13, 2);
lean_ctor_set(v___x_228_, 0, v_massKg_198_);
lean_ctor_set(v___x_228_, 1, v_designMassKg_199_);
lean_ctor_set(v___x_228_, 2, v_brakeShoeFriction_208_);
lean_ctor_set(v___x_228_, 3, v___y_216_);
lean_ctor_set(v___x_228_, 4, v___y_217_);
lean_ctor_set(v___x_228_, 5, v_brakeMultiplier_210_);
lean_ctor_set(v___x_228_, 6, v___x_220_);
lean_ctor_set(v___x_228_, 7, v___x_224_);
lean_ctor_set(v___x_228_, 8, v_tractiveEffortN_202_);
lean_ctor_set(v___x_228_, 9, v_directResistanceN_206_);
lean_ctor_set(v___x_228_, 10, v___x_227_);
lean_ctor_set(v___x_228_, 11, v_nearZeroResistanceN_207_);
lean_ctor_set(v___x_228_, 12, v_adverseForceBoundN_212_);
lean_ctor_set_uint8(v___x_228_, sizeof(void*)*13, v_hasPressureBrake_213_);
lean_ctor_set_uint8(v___x_228_, sizeof(void*)*13 + 1, v_hasIndependentBrake_214_);
return v___x_228_;
}
v___jp_229_:
{
if (v_cogging_211_ == 0)
{
v___y_216_ = v___y_230_;
v___y_217_ = v_brakeAdhesionEfficiency_209_;
goto v___jp_215_;
}
else
{
lean_object* v___x_231_; 
lean_dec_ref(v_brakeAdhesionEfficiency_209_);
v___x_231_ = lean_obj_once(&lp_pid_x2dproof_PidProof_steelStatic___closed__1, &lp_pid_x2dproof_PidProof_steelStatic___closed__1_once, _init_lp_pid_x2dproof_PidProof_steelStatic___closed__1);
v___y_216_ = v___y_230_;
v___y_217_ = v___x_231_;
goto v___jp_215_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sumBy(lean_object* v_f_233_, lean_object* v_x_234_){
_start:
{
if (lean_obj_tag(v_x_234_) == 0)
{
lean_object* v___x_235_; 
lean_dec_ref(v_f_233_);
v___x_235_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
return v___x_235_;
}
else
{
lean_object* v_head_236_; lean_object* v_tail_237_; lean_object* v___x_238_; lean_object* v___x_239_; lean_object* v___x_240_; 
v_head_236_ = lean_ctor_get(v_x_234_, 0);
lean_inc(v_head_236_);
v_tail_237_ = lean_ctor_get(v_x_234_, 1);
lean_inc(v_tail_237_);
lean_dec_ref_known(v_x_234_, 2);
lean_inc_ref(v_f_233_);
v___x_238_ = lean_apply_1(v_f_233_, v_head_236_);
v___x_239_ = lp_pid_x2dproof_PidProof_sumBy(v_f_233_, v_tail_237_);
v___x_240_ = l_Rat_add(v___x_238_, v___x_239_);
return v___x_240_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_mass___lam__0(lean_object* v_s_241_){
_start:
{
lean_object* v_massKg_242_; 
v_massKg_242_ = lean_ctor_get(v_s_241_, 0);
lean_inc_ref(v_massKg_242_);
return v_massKg_242_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_mass___lam__0___boxed(lean_object* v_s_243_){
_start:
{
lean_object* v_res_244_; 
v_res_244_ = lp_pid_x2dproof_PidProof_Consist_mass___lam__0(v_s_243_);
lean_dec_ref(v_s_243_);
return v_res_244_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_mass(lean_object* v_c_246_){
_start:
{
lean_object* v_stocks_247_; lean_object* v___f_248_; lean_object* v___x_249_; 
v_stocks_247_ = lean_ctor_get(v_c_246_, 0);
lean_inc(v_stocks_247_);
lean_dec_ref(v_c_246_);
v___f_248_ = ((lean_object*)(lp_pid_x2dproof_PidProof_Consist_mass___closed__0));
v___x_249_ = lp_pid_x2dproof_PidProof_sumBy(v___f_248_, v_stocks_247_);
return v___x_249_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_uniformBrake(lean_object* v_c_251_){
_start:
{
lean_object* v_stocks_252_; lean_object* v___f_253_; lean_object* v___x_254_; 
v_stocks_252_ = lean_ctor_get(v_c_251_, 0);
lean_inc(v_stocks_252_);
lean_dec_ref(v_c_251_);
v___f_253_ = ((lean_object*)(lp_pid_x2dproof_PidProof_Consist_uniformBrake___closed__0));
v___x_254_ = lp_pid_x2dproof_PidProof_sumBy(v___f_253_, v_stocks_252_);
return v___x_254_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_adverseBound___lam__0(lean_object* v_s_255_){
_start:
{
lean_object* v_adverseForceBoundN_256_; 
v_adverseForceBoundN_256_ = lean_ctor_get(v_s_255_, 12);
lean_inc_ref(v_adverseForceBoundN_256_);
return v_adverseForceBoundN_256_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_adverseBound___lam__0___boxed(lean_object* v_s_257_){
_start:
{
lean_object* v_res_258_; 
v_res_258_ = lp_pid_x2dproof_PidProof_Consist_adverseBound___lam__0(v_s_257_);
lean_dec_ref(v_s_257_);
return v_res_258_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_adverseBound(lean_object* v_c_260_){
_start:
{
lean_object* v_stocks_261_; lean_object* v_curvatureBoundN_262_; lean_object* v_slackBoundN_263_; lean_object* v_pushPullBoundN_264_; lean_object* v___f_265_; lean_object* v___x_266_; lean_object* v___x_267_; lean_object* v___x_268_; lean_object* v___x_269_; 
v_stocks_261_ = lean_ctor_get(v_c_260_, 0);
lean_inc(v_stocks_261_);
v_curvatureBoundN_262_ = lean_ctor_get(v_c_260_, 4);
lean_inc_ref(v_curvatureBoundN_262_);
v_slackBoundN_263_ = lean_ctor_get(v_c_260_, 5);
lean_inc_ref(v_slackBoundN_263_);
v_pushPullBoundN_264_ = lean_ctor_get(v_c_260_, 6);
lean_inc_ref(v_pushPullBoundN_264_);
lean_dec_ref(v_c_260_);
v___f_265_ = ((lean_object*)(lp_pid_x2dproof_PidProof_Consist_adverseBound___closed__0));
v___x_266_ = lp_pid_x2dproof_PidProof_sumBy(v___f_265_, v_stocks_261_);
v___x_267_ = l_Rat_add(v___x_266_, v_curvatureBoundN_262_);
v___x_268_ = l_Rat_add(v___x_267_, v_slackBoundN_263_);
v___x_269_ = l_Rat_add(v___x_268_, v_pushPullBoundN_264_);
return v___x_269_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_List_mapTR_loop___at___00PidProof_Consist_fromJava8_spec__0(lean_object* v_a_270_, lean_object* v_a_271_){
_start:
{
if (lean_obj_tag(v_a_270_) == 0)
{
lean_object* v___x_272_; 
v___x_272_ = l_List_reverse___redArg(v_a_271_);
return v___x_272_;
}
else
{
lean_object* v_head_273_; lean_object* v_tail_274_; lean_object* v___x_276_; uint8_t v_isShared_277_; uint8_t v_isSharedCheck_283_; 
v_head_273_ = lean_ctor_get(v_a_270_, 0);
v_tail_274_ = lean_ctor_get(v_a_270_, 1);
v_isSharedCheck_283_ = !lean_is_exclusive(v_a_270_);
if (v_isSharedCheck_283_ == 0)
{
v___x_276_ = v_a_270_;
v_isShared_277_ = v_isSharedCheck_283_;
goto v_resetjp_275_;
}
else
{
lean_inc(v_tail_274_);
lean_inc(v_head_273_);
lean_dec(v_a_270_);
v___x_276_ = lean_box(0);
v_isShared_277_ = v_isSharedCheck_283_;
goto v_resetjp_275_;
}
v_resetjp_275_:
{
lean_object* v___x_278_; lean_object* v___x_280_; 
v___x_278_ = lp_pid_x2dproof_PidProof_Stock_fromJava8(v_head_273_);
if (v_isShared_277_ == 0)
{
lean_ctor_set(v___x_276_, 1, v_a_271_);
lean_ctor_set(v___x_276_, 0, v___x_278_);
v___x_280_ = v___x_276_;
goto v_reusejp_279_;
}
else
{
lean_object* v_reuseFailAlloc_282_; 
v_reuseFailAlloc_282_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v_reuseFailAlloc_282_, 0, v___x_278_);
lean_ctor_set(v_reuseFailAlloc_282_, 1, v_a_271_);
v___x_280_ = v_reuseFailAlloc_282_;
goto v_reusejp_279_;
}
v_reusejp_279_:
{
v_a_270_ = v_tail_274_;
v_a_271_ = v___x_280_;
goto _start;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_fromJava8(lean_object* v_xs_284_, lean_object* v_curvature_285_, lean_object* v_slack_286_, lean_object* v_pushPull_287_, lean_object* v_curvatureBound_288_, lean_object* v_slackBound_289_, lean_object* v_pushPullBound_290_){
_start:
{
lean_object* v___x_291_; lean_object* v___x_292_; lean_object* v___x_293_; 
v___x_291_ = lean_box(0);
v___x_292_ = lp_pid_x2dproof_List_mapTR_loop___at___00PidProof_Consist_fromJava8_spec__0(v_xs_284_, v___x_291_);
v___x_293_ = lean_alloc_ctor(0, 7, 0);
lean_ctor_set(v___x_293_, 0, v___x_292_);
lean_ctor_set(v___x_293_, 1, v_curvature_285_);
lean_ctor_set(v___x_293_, 2, v_slack_286_);
lean_ctor_set(v___x_293_, 3, v_pushPull_287_);
lean_ctor_set(v___x_293_, 4, v_curvatureBound_288_);
lean_ctor_set(v___x_293_, 5, v_slackBound_289_);
lean_ctor_set(v___x_293_, 6, v_pushPullBound_290_);
return v___x_293_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sumJavaBy(lean_object* v_f_294_, lean_object* v_x_295_){
_start:
{
if (lean_obj_tag(v_x_295_) == 0)
{
lean_object* v___x_296_; 
lean_dec_ref(v_f_294_);
v___x_296_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
return v___x_296_;
}
else
{
lean_object* v_head_297_; lean_object* v_tail_298_; lean_object* v___x_299_; lean_object* v___x_300_; lean_object* v___x_301_; 
v_head_297_ = lean_ctor_get(v_x_295_, 0);
lean_inc(v_head_297_);
v_tail_298_ = lean_ctor_get(v_x_295_, 1);
lean_inc(v_tail_298_);
lean_dec_ref_known(v_x_295_, 2);
lean_inc_ref(v_f_294_);
v___x_299_ = lean_apply_1(v_f_294_, v_head_297_);
v___x_300_ = lp_pid_x2dproof_PidProof_sumJavaBy(v_f_294_, v_tail_298_);
v___x_301_ = l_Rat_add(v___x_299_, v___x_300_);
return v___x_301_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumBy_match__1_splitter___redArg(lean_object* v_x_302_, lean_object* v_h__1_303_, lean_object* v_h__2_304_){
_start:
{
if (lean_obj_tag(v_x_302_) == 0)
{
lean_object* v___x_305_; lean_object* v___x_306_; 
lean_dec(v_h__2_304_);
v___x_305_ = lean_box(0);
v___x_306_ = lean_apply_1(v_h__1_303_, v___x_305_);
return v___x_306_;
}
else
{
lean_object* v_head_307_; lean_object* v_tail_308_; lean_object* v___x_309_; 
lean_dec(v_h__1_303_);
v_head_307_ = lean_ctor_get(v_x_302_, 0);
lean_inc(v_head_307_);
v_tail_308_ = lean_ctor_get(v_x_302_, 1);
lean_inc(v_tail_308_);
lean_dec_ref_known(v_x_302_, 2);
v___x_309_ = lean_apply_2(v_h__2_304_, v_head_307_, v_tail_308_);
return v___x_309_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumBy_match__1_splitter(lean_object* v_motive_310_, lean_object* v_x_311_, lean_object* v_h__1_312_, lean_object* v_h__2_313_){
_start:
{
if (lean_obj_tag(v_x_311_) == 0)
{
lean_object* v___x_314_; lean_object* v___x_315_; 
lean_dec(v_h__2_313_);
v___x_314_ = lean_box(0);
v___x_315_ = lean_apply_1(v_h__1_312_, v___x_314_);
return v___x_315_;
}
else
{
lean_object* v_head_316_; lean_object* v_tail_317_; lean_object* v___x_318_; 
lean_dec(v_h__1_312_);
v_head_316_ = lean_ctor_get(v_x_311_, 0);
lean_inc(v_head_316_);
v_tail_317_ = lean_ctor_get(v_x_311_, 1);
lean_inc(v_tail_317_);
lean_dec_ref_known(v_x_311_, 2);
v___x_318_ = lean_apply_2(v_h__2_313_, v_head_316_, v_tail_317_);
return v___x_318_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumJavaBy_match__1_splitter___redArg(lean_object* v_x_319_, lean_object* v_h__1_320_, lean_object* v_h__2_321_){
_start:
{
if (lean_obj_tag(v_x_319_) == 0)
{
lean_object* v___x_322_; lean_object* v___x_323_; 
lean_dec(v_h__2_321_);
v___x_322_ = lean_box(0);
v___x_323_ = lean_apply_1(v_h__1_320_, v___x_322_);
return v___x_323_;
}
else
{
lean_object* v_head_324_; lean_object* v_tail_325_; lean_object* v___x_326_; 
lean_dec(v_h__1_320_);
v_head_324_ = lean_ctor_get(v_x_319_, 0);
lean_inc(v_head_324_);
v_tail_325_ = lean_ctor_get(v_x_319_, 1);
lean_inc(v_tail_325_);
lean_dec_ref_known(v_x_319_, 2);
v___x_326_ = lean_apply_2(v_h__2_321_, v_head_324_, v_tail_325_);
return v___x_326_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sumJavaBy_match__1_splitter(lean_object* v_motive_327_, lean_object* v_x_328_, lean_object* v_h__1_329_, lean_object* v_h__2_330_){
_start:
{
if (lean_obj_tag(v_x_328_) == 0)
{
lean_object* v___x_331_; lean_object* v___x_332_; 
lean_dec(v_h__2_330_);
v___x_331_ = lean_box(0);
v___x_332_ = lean_apply_1(v_h__1_329_, v___x_331_);
return v___x_332_;
}
else
{
lean_object* v_head_333_; lean_object* v_tail_334_; lean_object* v___x_335_; 
lean_dec(v_h__1_329_);
v_head_333_ = lean_ctor_get(v_x_328_, 0);
lean_inc(v_head_333_);
v_tail_334_ = lean_ctor_get(v_x_328_, 1);
lean_inc(v_tail_334_);
lean_dec_ref_known(v_x_328_, 2);
v___x_335_ = lean_apply_2(v_h__2_330_, v_head_333_, v_tail_334_);
return v___x_335_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_certifiedLowerBound(lean_object* v_mass_336_, lean_object* v_brake_337_, lean_object* v_adverse_338_){
_start:
{
lean_object* v___x_339_; lean_object* v_candidate_340_; lean_object* v___x_341_; uint8_t v___x_342_; 
v___x_339_ = l_Rat_sub(v_brake_337_, v_adverse_338_);
v_candidate_340_ = l_Rat_div(v___x_339_, v_mass_336_);
lean_dec_ref(v___x_339_);
v___x_341_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
lean_inc_ref(v_candidate_340_);
v___x_342_ = l_Rat_blt(v___x_341_, v_candidate_340_);
if (v___x_342_ == 0)
{
lean_object* v___x_343_; 
lean_dec_ref(v_candidate_340_);
v___x_343_ = lean_box(0);
return v___x_343_;
}
else
{
lean_object* v___x_344_; 
v___x_344_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_344_, 0, v_candidate_340_);
return v___x_344_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_Consist_certifiedAcceleration(lean_object* v_c_345_){
_start:
{
lean_object* v___x_346_; lean_object* v___x_347_; lean_object* v___x_348_; lean_object* v___x_349_; 
lean_inc_ref_n(v_c_345_, 2);
v___x_346_ = lp_pid_x2dproof_PidProof_Consist_mass(v_c_345_);
v___x_347_ = lp_pid_x2dproof_PidProof_Consist_uniformBrake(v_c_345_);
v___x_348_ = lp_pid_x2dproof_PidProof_Consist_adverseBound(v_c_345_);
v___x_349_ = lp_pid_x2dproof_PidProof_certifiedLowerBound(v___x_346_, v___x_347_, v___x_348_);
return v___x_349_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorIdx(uint8_t v_x_350_){
_start:
{
if (v_x_350_ == 0)
{
lean_object* v___x_351_; 
v___x_351_ = lean_unsigned_to_nat(0u);
return v___x_351_;
}
else
{
lean_object* v___x_352_; 
v___x_352_ = lean_unsigned_to_nat(1u);
return v___x_352_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorIdx___boxed(lean_object* v_x_353_){
_start:
{
uint8_t v_x_boxed_354_; lean_object* v_res_355_; 
v_x_boxed_354_ = lean_unbox(v_x_353_);
v_res_355_ = lp_pid_x2dproof_PidProof_RouteSide_ctorIdx(v_x_boxed_354_);
return v_res_355_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_toCtorIdx(uint8_t v_x_356_){
_start:
{
lean_object* v___x_357_; 
v___x_357_ = lp_pid_x2dproof_PidProof_RouteSide_ctorIdx(v_x_356_);
return v___x_357_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_toCtorIdx___boxed(lean_object* v_x_358_){
_start:
{
uint8_t v_x_4__boxed_359_; lean_object* v_res_360_; 
v_x_4__boxed_359_ = lean_unbox(v_x_358_);
v_res_360_ = lp_pid_x2dproof_PidProof_RouteSide_toCtorIdx(v_x_4__boxed_359_);
return v_res_360_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim___redArg(lean_object* v_k_361_){
_start:
{
lean_inc(v_k_361_);
return v_k_361_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim___redArg___boxed(lean_object* v_k_362_){
_start:
{
lean_object* v_res_363_; 
v_res_363_ = lp_pid_x2dproof_PidProof_RouteSide_ctorElim___redArg(v_k_362_);
lean_dec(v_k_362_);
return v_res_363_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim(lean_object* v_motive_364_, lean_object* v_ctorIdx_365_, uint8_t v_t_366_, lean_object* v_h_367_, lean_object* v_k_368_){
_start:
{
lean_inc(v_k_368_);
return v_k_368_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_ctorElim___boxed(lean_object* v_motive_369_, lean_object* v_ctorIdx_370_, lean_object* v_t_371_, lean_object* v_h_372_, lean_object* v_k_373_){
_start:
{
uint8_t v_t_boxed_374_; lean_object* v_res_375_; 
v_t_boxed_374_ = lean_unbox(v_t_371_);
v_res_375_ = lp_pid_x2dproof_PidProof_RouteSide_ctorElim(v_motive_369_, v_ctorIdx_370_, v_t_boxed_374_, v_h_372_, v_k_373_);
lean_dec(v_k_373_);
lean_dec(v_ctorIdx_370_);
return v_res_375_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim___redArg(lean_object* v_positive_376_){
_start:
{
lean_inc(v_positive_376_);
return v_positive_376_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim___redArg___boxed(lean_object* v_positive_377_){
_start:
{
lean_object* v_res_378_; 
v_res_378_ = lp_pid_x2dproof_PidProof_RouteSide_positive_elim___redArg(v_positive_377_);
lean_dec(v_positive_377_);
return v_res_378_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim(lean_object* v_motive_379_, uint8_t v_t_380_, lean_object* v_h_381_, lean_object* v_positive_382_){
_start:
{
lean_inc(v_positive_382_);
return v_positive_382_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_positive_elim___boxed(lean_object* v_motive_383_, lean_object* v_t_384_, lean_object* v_h_385_, lean_object* v_positive_386_){
_start:
{
uint8_t v_t_boxed_387_; lean_object* v_res_388_; 
v_t_boxed_387_ = lean_unbox(v_t_384_);
v_res_388_ = lp_pid_x2dproof_PidProof_RouteSide_positive_elim(v_motive_383_, v_t_boxed_387_, v_h_385_, v_positive_386_);
lean_dec(v_positive_386_);
return v_res_388_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim___redArg(lean_object* v_negative_389_){
_start:
{
lean_inc(v_negative_389_);
return v_negative_389_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim___redArg___boxed(lean_object* v_negative_390_){
_start:
{
lean_object* v_res_391_; 
v_res_391_ = lp_pid_x2dproof_PidProof_RouteSide_negative_elim___redArg(v_negative_390_);
lean_dec(v_negative_390_);
return v_res_391_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim(lean_object* v_motive_392_, uint8_t v_t_393_, lean_object* v_h_394_, lean_object* v_negative_395_){
_start:
{
lean_inc(v_negative_395_);
return v_negative_395_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_RouteSide_negative_elim___boxed(lean_object* v_motive_396_, lean_object* v_t_397_, lean_object* v_h_398_, lean_object* v_negative_399_){
_start:
{
uint8_t v_t_boxed_400_; lean_object* v_res_401_; 
v_t_boxed_400_ = lean_unbox(v_t_397_);
v_res_401_ = lp_pid_x2dproof_PidProof_RouteSide_negative_elim(v_motive_396_, v_t_boxed_400_, v_h_398_, v_negative_399_);
lean_dec(v_negative_399_);
return v_res_401_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_sideSign___closed__0(void){
_start:
{
lean_object* v___x_402_; lean_object* v___x_403_; 
v___x_402_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_403_ = l_Rat_neg(v___x_402_);
return v___x_403_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sideSign(uint8_t v_x_404_){
_start:
{
if (v_x_404_ == 0)
{
lean_object* v___x_405_; 
v___x_405_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
return v___x_405_;
}
else
{
lean_object* v___x_406_; 
v___x_406_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sideSign___closed__0, &lp_pid_x2dproof_PidProof_sideSign___closed__0_once, _init_lp_pid_x2dproof_PidProof_sideSign___closed__0);
return v___x_406_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_sideSign___boxed(lean_object* v_x_407_){
_start:
{
uint8_t v_x_46__boxed_408_; lean_object* v_res_409_; 
v_x_46__boxed_408_ = lean_unbox(v_x_407_);
v_res_409_ = lp_pid_x2dproof_PidProof_sideSign(v_x_46__boxed_408_);
return v_res_409_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_remainingDistance(uint8_t v_side_410_, lean_object* v_target_411_, lean_object* v_worldPosition_412_){
_start:
{
lean_object* v___x_413_; lean_object* v___x_414_; lean_object* v___x_415_; 
v___x_413_ = lp_pid_x2dproof_PidProof_sideSign(v_side_410_);
v___x_414_ = l_Rat_sub(v_target_411_, v_worldPosition_412_);
v___x_415_ = l_Rat_mul(v___x_413_, v___x_414_);
lean_dec_ref(v___x_413_);
return v___x_415_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_remainingDistance___boxed(lean_object* v_side_416_, lean_object* v_target_417_, lean_object* v_worldPosition_418_){
_start:
{
uint8_t v_side_boxed_419_; lean_object* v_res_420_; 
v_side_boxed_419_ = lean_unbox(v_side_416_);
v_res_420_ = lp_pid_x2dproof_PidProof_remainingDistance(v_side_boxed_419_, v_target_417_, v_worldPosition_418_);
return v_res_420_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedVelocity(uint8_t v_side_421_, lean_object* v_worldVelocity_422_){
_start:
{
lean_object* v___x_423_; lean_object* v___x_424_; 
v___x_423_ = lp_pid_x2dproof_PidProof_sideSign(v_side_421_);
v___x_424_ = l_Rat_mul(v___x_423_, v_worldVelocity_422_);
lean_dec_ref(v___x_423_);
return v___x_424_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedVelocity___boxed(lean_object* v_side_425_, lean_object* v_worldVelocity_426_){
_start:
{
uint8_t v_side_boxed_427_; lean_object* v_res_428_; 
v_side_boxed_427_ = lean_unbox(v_side_425_);
v_res_428_ = lp_pid_x2dproof_PidProof_targetDirectedVelocity(v_side_boxed_427_, v_worldVelocity_426_);
return v_res_428_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedSpeedError(lean_object* v_referenceVelocity_429_, lean_object* v_worldVelocity_430_, uint8_t v_side_431_){
_start:
{
lean_object* v___x_432_; lean_object* v___x_433_; 
v___x_432_ = lp_pid_x2dproof_PidProof_targetDirectedVelocity(v_side_431_, v_worldVelocity_430_);
v___x_433_ = l_Rat_sub(v_referenceVelocity_429_, v___x_432_);
return v___x_433_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_targetDirectedSpeedError___boxed(lean_object* v_referenceVelocity_434_, lean_object* v_worldVelocity_435_, lean_object* v_side_436_){
_start:
{
uint8_t v_side_boxed_437_; lean_object* v_res_438_; 
v_side_boxed_437_ = lean_unbox(v_side_436_);
v_res_438_ = lp_pid_x2dproof_PidProof_targetDirectedSpeedError(v_referenceVelocity_434_, v_worldVelocity_435_, v_side_boxed_437_);
return v_res_438_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter___redArg(uint8_t v_x_439_, lean_object* v_h__1_440_, lean_object* v_h__2_441_){
_start:
{
if (v_x_439_ == 0)
{
lean_object* v___x_442_; lean_object* v___x_443_; 
lean_dec(v_h__2_441_);
v___x_442_ = lean_box(0);
v___x_443_ = lean_apply_1(v_h__1_440_, v___x_442_);
return v___x_443_;
}
else
{
lean_object* v___x_444_; lean_object* v___x_445_; 
lean_dec(v_h__1_440_);
v___x_444_ = lean_box(0);
v___x_445_ = lean_apply_1(v_h__2_441_, v___x_444_);
return v___x_445_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter___redArg___boxed(lean_object* v_x_446_, lean_object* v_h__1_447_, lean_object* v_h__2_448_){
_start:
{
uint8_t v_x_24__boxed_449_; lean_object* v_res_450_; 
v_x_24__boxed_449_ = lean_unbox(v_x_446_);
v_res_450_ = lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter___redArg(v_x_24__boxed_449_, v_h__1_447_, v_h__2_448_);
return v_res_450_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter(lean_object* v_motive_451_, uint8_t v_x_452_, lean_object* v_h__1_453_, lean_object* v_h__2_454_){
_start:
{
if (v_x_452_ == 0)
{
lean_object* v___x_455_; lean_object* v___x_456_; 
lean_dec(v_h__2_454_);
v___x_455_ = lean_box(0);
v___x_456_ = lean_apply_1(v_h__1_453_, v___x_455_);
return v___x_456_;
}
else
{
lean_object* v___x_457_; lean_object* v___x_458_; 
lean_dec(v_h__1_453_);
v___x_457_ = lean_box(0);
v___x_458_ = lean_apply_1(v_h__2_454_, v___x_457_);
return v___x_458_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter___boxed(lean_object* v_motive_459_, lean_object* v_x_460_, lean_object* v_h__1_461_, lean_object* v_h__2_462_){
_start:
{
uint8_t v_x_35__boxed_463_; lean_object* v_res_464_; 
v_x_35__boxed_463_ = lean_unbox(v_x_460_);
v_res_464_ = lp_pid_x2dproof___private_PidProof_0__PidProof_sideSign_match__1_splitter(v_motive_459_, v_x_35__boxed_463_, v_h__1_461_, v_h__2_462_);
return v_res_464_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingEntry(uint8_t v_side_465_, lean_object* v_target_466_, lean_object* v_position_467_, lean_object* v_worldVelocity_468_, lean_object* v_guard_469_){
_start:
{
lean_object* v_d_470_; lean_object* v_v_471_; lean_object* v___x_472_; uint8_t v___x_473_; 
v_d_470_ = lp_pid_x2dproof_PidProof_remainingDistance(v_side_465_, v_target_466_, v_position_467_);
v_v_471_ = lp_pid_x2dproof_PidProof_targetDirectedVelocity(v_side_465_, v_worldVelocity_468_);
v___x_472_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
lean_inc_ref(v_v_471_);
v___x_473_ = l_Rat_blt(v___x_472_, v_v_471_);
if (v___x_473_ == 0)
{
lean_object* v___x_474_; 
lean_dec_ref(v_v_471_);
lean_dec_ref(v_d_470_);
lean_dec_ref(v_guard_469_);
v___x_474_ = lean_box(0);
return v___x_474_;
}
else
{
uint8_t v___x_475_; 
lean_inc_ref(v_d_470_);
v___x_475_ = l_Rat_instDecidableLe(v_guard_469_, v_d_470_);
if (v___x_475_ == 0)
{
lean_object* v___x_476_; 
lean_dec_ref(v_v_471_);
lean_dec_ref(v_d_470_);
v___x_476_ = lean_box(0);
return v___x_476_;
}
else
{
lean_object* v___x_477_; lean_object* v___x_478_; 
v___x_477_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v___x_477_, 0, v_d_470_);
lean_ctor_set(v___x_477_, 1, v_v_471_);
v___x_478_ = lean_alloc_ctor(1, 1, 0);
lean_ctor_set(v___x_478_, 0, v___x_477_);
return v___x_478_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingEntry___boxed(lean_object* v_side_479_, lean_object* v_target_480_, lean_object* v_position_481_, lean_object* v_worldVelocity_482_, lean_object* v_guard_483_){
_start:
{
uint8_t v_side_boxed_484_; lean_object* v_res_485_; 
v_side_boxed_484_ = lean_unbox(v_side_479_);
v_res_485_ = lp_pid_x2dproof_PidProof_stoppingEntry(v_side_boxed_484_, v_target_480_, v_position_481_, v_worldVelocity_482_, v_guard_483_);
return v_res_485_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayVelocity(lean_object* v_v_486_, lean_object* v_adverseAcceleration_487_, lean_object* v_tau_488_){
_start:
{
lean_object* v___x_489_; lean_object* v___x_490_; 
v___x_489_ = l_Rat_mul(v_adverseAcceleration_487_, v_tau_488_);
v___x_490_ = l_Rat_add(v_v_486_, v___x_489_);
return v___x_490_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayVelocity___boxed(lean_object* v_v_491_, lean_object* v_adverseAcceleration_492_, lean_object* v_tau_493_){
_start:
{
lean_object* v_res_494_; 
v_res_494_ = lp_pid_x2dproof_PidProof_delayVelocity(v_v_491_, v_adverseAcceleration_492_, v_tau_493_);
lean_dec_ref(v_adverseAcceleration_492_);
return v_res_494_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayTravel(lean_object* v_v_495_, lean_object* v_adverseAcceleration_496_, lean_object* v_tau_497_){
_start:
{
lean_object* v___x_498_; lean_object* v___x_499_; lean_object* v___x_500_; lean_object* v___x_501_; lean_object* v___x_502_; 
lean_inc_ref(v_tau_497_);
v___x_498_ = l_Rat_mul(v_v_495_, v_tau_497_);
v___x_499_ = lean_unsigned_to_nat(2u);
v___x_500_ = l_Rat_pow(v_tau_497_, v___x_499_);
v___x_501_ = l_Rat_mul(v_adverseAcceleration_496_, v___x_500_);
v___x_502_ = l_Rat_add(v___x_498_, v___x_501_);
return v___x_502_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_delayTravel___boxed(lean_object* v_v_503_, lean_object* v_adverseAcceleration_504_, lean_object* v_tau_505_){
_start:
{
lean_object* v_res_506_; 
v_res_506_ = lp_pid_x2dproof_PidProof_delayTravel(v_v_503_, v_adverseAcceleration_504_, v_tau_505_);
lean_dec_ref(v_adverseAcceleration_504_);
lean_dec_ref(v_v_503_);
return v_res_506_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_stoppingGuard___closed__0(void){
_start:
{
lean_object* v___x_507_; lean_object* v___x_508_; 
v___x_507_ = lean_unsigned_to_nat(2u);
v___x_508_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_507_);
return v___x_508_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingGuard(lean_object* v_v_509_, lean_object* v_lowerBrake_510_, lean_object* v_tau_511_, lean_object* v_adverseAcceleration_512_, lean_object* v_positionTolerance_513_, lean_object* v_computationTolerance_514_){
_start:
{
lean_object* v___x_515_; lean_object* v___x_516_; lean_object* v___x_517_; lean_object* v___x_518_; lean_object* v___x_519_; lean_object* v___x_520_; lean_object* v___x_521_; lean_object* v___x_522_; lean_object* v___x_523_; lean_object* v___x_524_; 
lean_inc_ref(v_tau_511_);
v___x_515_ = lp_pid_x2dproof_PidProof_delayTravel(v_v_509_, v_adverseAcceleration_512_, v_tau_511_);
v___x_516_ = lp_pid_x2dproof_PidProof_delayVelocity(v_v_509_, v_adverseAcceleration_512_, v_tau_511_);
v___x_517_ = lean_unsigned_to_nat(2u);
v___x_518_ = l_Rat_pow(v___x_516_, v___x_517_);
v___x_519_ = lean_obj_once(&lp_pid_x2dproof_PidProof_stoppingGuard___closed__0, &lp_pid_x2dproof_PidProof_stoppingGuard___closed__0_once, _init_lp_pid_x2dproof_PidProof_stoppingGuard___closed__0);
v___x_520_ = l_Rat_mul(v___x_519_, v_lowerBrake_510_);
v___x_521_ = l_Rat_div(v___x_518_, v___x_520_);
lean_dec_ref(v___x_518_);
v___x_522_ = l_Rat_add(v___x_515_, v___x_521_);
v___x_523_ = l_Rat_add(v___x_522_, v_positionTolerance_513_);
v___x_524_ = l_Rat_add(v___x_523_, v_computationTolerance_514_);
return v___x_524_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_stoppingGuard___boxed(lean_object* v_v_525_, lean_object* v_lowerBrake_526_, lean_object* v_tau_527_, lean_object* v_adverseAcceleration_528_, lean_object* v_positionTolerance_529_, lean_object* v_computationTolerance_530_){
_start:
{
lean_object* v_res_531_; 
v_res_531_ = lp_pid_x2dproof_PidProof_stoppingGuard(v_v_525_, v_lowerBrake_526_, v_tau_527_, v_adverseAcceleration_528_, v_positionTolerance_529_, v_computationTolerance_530_);
lean_dec_ref(v_adverseAcceleration_528_);
return v_res_531_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingVelocity(lean_object* v_a_532_, lean_object* v_h_533_, lean_object* v_v_534_){
_start:
{
lean_object* v___x_535_; lean_object* v___x_536_; lean_object* v___x_537_; uint8_t v___x_538_; 
v___x_535_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_536_ = l_Rat_mul(v_a_532_, v_h_533_);
v___x_537_ = l_Rat_sub(v_v_534_, v___x_536_);
lean_inc_ref(v___x_537_);
v___x_538_ = l_Rat_instDecidableLe(v___x_535_, v___x_537_);
if (v___x_538_ == 0)
{
lean_dec_ref(v___x_537_);
return v___x_535_;
}
else
{
return v___x_537_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingVelocity___boxed(lean_object* v_a_539_, lean_object* v_h_540_, lean_object* v_v_541_){
_start:
{
lean_object* v_res_542_; 
v_res_542_ = lp_pid_x2dproof_PidProof_brakingVelocity(v_a_539_, v_h_540_, v_v_541_);
lean_dec_ref(v_a_539_);
return v_res_542_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingStep(lean_object* v_a_543_, lean_object* v_h_544_, lean_object* v_s_545_){
_start:
{
lean_object* v_distance_546_; lean_object* v_velocity_547_; lean_object* v___x_549_; uint8_t v_isShared_550_; uint8_t v_isSharedCheck_557_; 
v_distance_546_ = lean_ctor_get(v_s_545_, 0);
v_velocity_547_ = lean_ctor_get(v_s_545_, 1);
v_isSharedCheck_557_ = !lean_is_exclusive(v_s_545_);
if (v_isSharedCheck_557_ == 0)
{
v___x_549_ = v_s_545_;
v_isShared_550_ = v_isSharedCheck_557_;
goto v_resetjp_548_;
}
else
{
lean_inc(v_velocity_547_);
lean_inc(v_distance_546_);
lean_dec(v_s_545_);
v___x_549_ = lean_box(0);
v_isShared_550_ = v_isSharedCheck_557_;
goto v_resetjp_548_;
}
v_resetjp_548_:
{
lean_object* v___x_551_; lean_object* v___x_552_; lean_object* v___x_553_; lean_object* v___x_555_; 
lean_inc_ref(v_h_544_);
v___x_551_ = lp_pid_x2dproof_PidProof_brakingVelocity(v_a_543_, v_h_544_, v_velocity_547_);
lean_inc_ref(v___x_551_);
v___x_552_ = l_Rat_mul(v_h_544_, v___x_551_);
lean_dec_ref(v_h_544_);
v___x_553_ = l_Rat_sub(v_distance_546_, v___x_552_);
if (v_isShared_550_ == 0)
{
lean_ctor_set(v___x_549_, 1, v___x_551_);
lean_ctor_set(v___x_549_, 0, v___x_553_);
v___x_555_ = v___x_549_;
goto v_reusejp_554_;
}
else
{
lean_object* v_reuseFailAlloc_556_; 
v_reuseFailAlloc_556_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v_reuseFailAlloc_556_, 0, v___x_553_);
lean_ctor_set(v_reuseFailAlloc_556_, 1, v___x_551_);
v___x_555_ = v_reuseFailAlloc_556_;
goto v_reusejp_554_;
}
v_reusejp_554_:
{
return v___x_555_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingStep___boxed(lean_object* v_a_558_, lean_object* v_h_559_, lean_object* v_s_560_){
_start:
{
lean_object* v_res_561_; 
v_res_561_ = lp_pid_x2dproof_PidProof_brakingStep(v_a_558_, v_h_559_, v_s_560_);
lean_dec_ref(v_a_558_);
return v_res_561_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_iterateBraking(lean_object* v_x_562_, lean_object* v_x_563_, lean_object* v_x_564_, lean_object* v_x_565_){
_start:
{
lean_object* v_zero_566_; uint8_t v_isZero_567_; 
v_zero_566_ = lean_unsigned_to_nat(0u);
v_isZero_567_ = lean_nat_dec_eq(v_x_562_, v_zero_566_);
if (v_isZero_567_ == 1)
{
lean_dec_ref(v_x_564_);
lean_dec(v_x_562_);
return v_x_565_;
}
else
{
lean_object* v_one_568_; lean_object* v_n_569_; lean_object* v___x_570_; 
v_one_568_ = lean_unsigned_to_nat(1u);
v_n_569_ = lean_nat_sub(v_x_562_, v_one_568_);
lean_dec(v_x_562_);
lean_inc_ref(v_x_564_);
v___x_570_ = lp_pid_x2dproof_PidProof_brakingStep(v_x_563_, v_x_564_, v_x_565_);
v_x_562_ = v_n_569_;
v_x_565_ = v___x_570_;
goto _start;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_iterateBraking___boxed(lean_object* v_x_572_, lean_object* v_x_573_, lean_object* v_x_574_, lean_object* v_x_575_){
_start:
{
lean_object* v_res_576_; 
v_res_576_ = lp_pid_x2dproof_PidProof_iterateBraking(v_x_572_, v_x_573_, v_x_574_, v_x_575_);
lean_dec_ref(v_x_573_);
return v_res_576_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingTravel(lean_object* v_x_577_, lean_object* v_x_578_, lean_object* v_x_579_, lean_object* v_x_580_){
_start:
{
lean_object* v_zero_581_; uint8_t v_isZero_582_; 
v_zero_581_ = lean_unsigned_to_nat(0u);
v_isZero_582_ = lean_nat_dec_eq(v_x_577_, v_zero_581_);
if (v_isZero_582_ == 1)
{
lean_object* v___x_583_; 
lean_dec_ref(v_x_580_);
lean_dec_ref(v_x_579_);
v___x_583_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
return v___x_583_;
}
else
{
lean_object* v_one_584_; lean_object* v_n_585_; lean_object* v___x_586_; lean_object* v___x_587_; lean_object* v___x_588_; lean_object* v___x_589_; 
v_one_584_ = lean_unsigned_to_nat(1u);
v_n_585_ = lean_nat_sub(v_x_577_, v_one_584_);
lean_inc_ref(v_x_579_);
v___x_586_ = lp_pid_x2dproof_PidProof_brakingVelocity(v_x_578_, v_x_579_, v_x_580_);
lean_inc_ref(v___x_586_);
v___x_587_ = l_Rat_mul(v_x_579_, v___x_586_);
v___x_588_ = lp_pid_x2dproof_PidProof_brakingTravel(v_n_585_, v_x_578_, v_x_579_, v___x_586_);
lean_dec(v_n_585_);
v___x_589_ = l_Rat_add(v___x_587_, v___x_588_);
return v___x_589_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_brakingTravel___boxed(lean_object* v_x_590_, lean_object* v_x_591_, lean_object* v_x_592_, lean_object* v_x_593_){
_start:
{
lean_object* v_res_594_; 
v_res_594_ = lp_pid_x2dproof_PidProof_brakingTravel(v_x_590_, v_x_591_, v_x_592_, v_x_593_);
lean_dec_ref(v_x_591_);
lean_dec(v_x_590_);
return v_res_594_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter___redArg(lean_object* v_x_595_, lean_object* v_x_596_, lean_object* v_x_597_, lean_object* v_x_598_, lean_object* v_h__1_599_, lean_object* v_h__2_600_){
_start:
{
lean_object* v_zero_601_; uint8_t v_isZero_602_; 
v_zero_601_ = lean_unsigned_to_nat(0u);
v_isZero_602_ = lean_nat_dec_eq(v_x_595_, v_zero_601_);
if (v_isZero_602_ == 1)
{
lean_object* v___x_603_; 
lean_dec(v_h__2_600_);
v___x_603_ = lean_apply_3(v_h__1_599_, v_x_596_, v_x_597_, v_x_598_);
return v___x_603_;
}
else
{
lean_object* v_one_604_; lean_object* v_n_605_; lean_object* v___x_606_; 
lean_dec(v_h__1_599_);
v_one_604_ = lean_unsigned_to_nat(1u);
v_n_605_ = lean_nat_sub(v_x_595_, v_one_604_);
v___x_606_ = lean_apply_4(v_h__2_600_, v_n_605_, v_x_596_, v_x_597_, v_x_598_);
return v___x_606_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter___redArg___boxed(lean_object* v_x_607_, lean_object* v_x_608_, lean_object* v_x_609_, lean_object* v_x_610_, lean_object* v_h__1_611_, lean_object* v_h__2_612_){
_start:
{
lean_object* v_res_613_; 
v_res_613_ = lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter___redArg(v_x_607_, v_x_608_, v_x_609_, v_x_610_, v_h__1_611_, v_h__2_612_);
lean_dec(v_x_607_);
return v_res_613_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter(lean_object* v_motive_614_, lean_object* v_x_615_, lean_object* v_x_616_, lean_object* v_x_617_, lean_object* v_x_618_, lean_object* v_h__1_619_, lean_object* v_h__2_620_){
_start:
{
lean_object* v_zero_621_; uint8_t v_isZero_622_; 
v_zero_621_ = lean_unsigned_to_nat(0u);
v_isZero_622_ = lean_nat_dec_eq(v_x_615_, v_zero_621_);
if (v_isZero_622_ == 1)
{
lean_object* v___x_623_; 
lean_dec(v_h__2_620_);
v___x_623_ = lean_apply_3(v_h__1_619_, v_x_616_, v_x_617_, v_x_618_);
return v___x_623_;
}
else
{
lean_object* v_one_624_; lean_object* v_n_625_; lean_object* v___x_626_; 
lean_dec(v_h__1_619_);
v_one_624_ = lean_unsigned_to_nat(1u);
v_n_625_ = lean_nat_sub(v_x_615_, v_one_624_);
v___x_626_ = lean_apply_4(v_h__2_620_, v_n_625_, v_x_616_, v_x_617_, v_x_618_);
return v___x_626_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter___boxed(lean_object* v_motive_627_, lean_object* v_x_628_, lean_object* v_x_629_, lean_object* v_x_630_, lean_object* v_x_631_, lean_object* v_h__1_632_, lean_object* v_h__2_633_){
_start:
{
lean_object* v_res_634_; 
v_res_634_ = lp_pid_x2dproof___private_PidProof_0__PidProof_iterateBraking_match__1_splitter(v_motive_627_, v_x_628_, v_x_629_, v_x_630_, v_x_631_, v_h__1_632_, v_h__2_633_);
lean_dec(v_x_628_);
return v_res_634_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter___redArg(lean_object* v_x_635_, lean_object* v_x_636_, lean_object* v_x_637_, lean_object* v_x_638_, lean_object* v_h__1_639_, lean_object* v_h__2_640_){
_start:
{
lean_object* v_zero_641_; uint8_t v_isZero_642_; 
v_zero_641_ = lean_unsigned_to_nat(0u);
v_isZero_642_ = lean_nat_dec_eq(v_x_635_, v_zero_641_);
if (v_isZero_642_ == 1)
{
lean_object* v___x_643_; 
lean_dec(v_h__2_640_);
v___x_643_ = lean_apply_3(v_h__1_639_, v_x_636_, v_x_637_, v_x_638_);
return v___x_643_;
}
else
{
lean_object* v_one_644_; lean_object* v_n_645_; lean_object* v___x_646_; 
lean_dec(v_h__1_639_);
v_one_644_ = lean_unsigned_to_nat(1u);
v_n_645_ = lean_nat_sub(v_x_635_, v_one_644_);
v___x_646_ = lean_apply_4(v_h__2_640_, v_n_645_, v_x_636_, v_x_637_, v_x_638_);
return v___x_646_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter___redArg___boxed(lean_object* v_x_647_, lean_object* v_x_648_, lean_object* v_x_649_, lean_object* v_x_650_, lean_object* v_h__1_651_, lean_object* v_h__2_652_){
_start:
{
lean_object* v_res_653_; 
v_res_653_ = lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter___redArg(v_x_647_, v_x_648_, v_x_649_, v_x_650_, v_h__1_651_, v_h__2_652_);
lean_dec(v_x_647_);
return v_res_653_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter(lean_object* v_motive_654_, lean_object* v_x_655_, lean_object* v_x_656_, lean_object* v_x_657_, lean_object* v_x_658_, lean_object* v_h__1_659_, lean_object* v_h__2_660_){
_start:
{
lean_object* v_zero_661_; uint8_t v_isZero_662_; 
v_zero_661_ = lean_unsigned_to_nat(0u);
v_isZero_662_ = lean_nat_dec_eq(v_x_655_, v_zero_661_);
if (v_isZero_662_ == 1)
{
lean_object* v___x_663_; 
lean_dec(v_h__2_660_);
v___x_663_ = lean_apply_3(v_h__1_659_, v_x_656_, v_x_657_, v_x_658_);
return v___x_663_;
}
else
{
lean_object* v_one_664_; lean_object* v_n_665_; lean_object* v___x_666_; 
lean_dec(v_h__1_659_);
v_one_664_ = lean_unsigned_to_nat(1u);
v_n_665_ = lean_nat_sub(v_x_655_, v_one_664_);
v___x_666_ = lean_apply_4(v_h__2_660_, v_n_665_, v_x_656_, v_x_657_, v_x_658_);
return v___x_666_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter___boxed(lean_object* v_motive_667_, lean_object* v_x_668_, lean_object* v_x_669_, lean_object* v_x_670_, lean_object* v_x_671_, lean_object* v_h__1_672_, lean_object* v_h__2_673_){
_start:
{
lean_object* v_res_674_; 
v_res_674_ = lp_pid_x2dproof___private_PidProof_0__PidProof_brakingTravel_match__1_splitter(v_motive_667_, v_x_668_, v_x_669_, v_x_670_, v_x_671_, v_h__1_672_, v_h__2_673_);
lean_dec(v_x_668_);
return v_res_674_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_det3(lean_object* v_m_675_){
_start:
{
lean_object* v_m11_676_; lean_object* v_m12_677_; lean_object* v_m13_678_; lean_object* v_m21_679_; lean_object* v_m22_680_; lean_object* v_m23_681_; lean_object* v_m31_682_; lean_object* v_m32_683_; lean_object* v_m33_684_; lean_object* v___x_685_; lean_object* v___x_686_; lean_object* v___x_687_; lean_object* v___x_688_; lean_object* v___x_689_; lean_object* v___x_690_; lean_object* v___x_691_; lean_object* v___x_692_; lean_object* v___x_693_; lean_object* v___x_694_; lean_object* v___x_695_; lean_object* v___x_696_; lean_object* v___x_697_; lean_object* v___x_698_; 
v_m11_676_ = lean_ctor_get(v_m_675_, 0);
lean_inc_ref(v_m11_676_);
v_m12_677_ = lean_ctor_get(v_m_675_, 1);
lean_inc_ref(v_m12_677_);
v_m13_678_ = lean_ctor_get(v_m_675_, 2);
lean_inc_ref(v_m13_678_);
v_m21_679_ = lean_ctor_get(v_m_675_, 3);
lean_inc_ref(v_m21_679_);
v_m22_680_ = lean_ctor_get(v_m_675_, 4);
lean_inc_ref(v_m22_680_);
v_m23_681_ = lean_ctor_get(v_m_675_, 5);
lean_inc_ref(v_m23_681_);
v_m31_682_ = lean_ctor_get(v_m_675_, 6);
lean_inc_ref_n(v_m31_682_, 2);
v_m32_683_ = lean_ctor_get(v_m_675_, 7);
lean_inc_ref_n(v_m32_683_, 2);
v_m33_684_ = lean_ctor_get(v_m_675_, 8);
lean_inc_ref_n(v_m33_684_, 2);
lean_dec_ref(v_m_675_);
v___x_685_ = l_Rat_mul(v_m22_680_, v_m33_684_);
v___x_686_ = l_Rat_mul(v_m23_681_, v_m32_683_);
v___x_687_ = l_Rat_sub(v___x_685_, v___x_686_);
v___x_688_ = l_Rat_mul(v_m11_676_, v___x_687_);
lean_dec_ref(v_m11_676_);
v___x_689_ = l_Rat_mul(v_m21_679_, v_m33_684_);
v___x_690_ = l_Rat_mul(v_m23_681_, v_m31_682_);
lean_dec_ref(v_m23_681_);
v___x_691_ = l_Rat_sub(v___x_689_, v___x_690_);
v___x_692_ = l_Rat_mul(v_m12_677_, v___x_691_);
lean_dec_ref(v_m12_677_);
v___x_693_ = l_Rat_sub(v___x_688_, v___x_692_);
v___x_694_ = l_Rat_mul(v_m21_679_, v_m32_683_);
lean_dec_ref(v_m21_679_);
v___x_695_ = l_Rat_mul(v_m22_680_, v_m31_682_);
lean_dec_ref(v_m22_680_);
v___x_696_ = l_Rat_sub(v___x_694_, v___x_695_);
v___x_697_ = l_Rat_mul(v_m13_678_, v___x_696_);
lean_dec_ref(v_m13_678_);
v___x_698_ = l_Rat_add(v___x_693_, v___x_697_);
return v___x_698_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_closedLoopMatrix(lean_object* v_h_699_, lean_object* v_a_700_, lean_object* v_kp_701_, lean_object* v_kv_702_, lean_object* v_ki_703_){
_start:
{
lean_object* v___x_704_; lean_object* v___x_705_; lean_object* v___x_706_; lean_object* v___x_707_; lean_object* v___x_708_; lean_object* v___x_709_; lean_object* v___x_710_; lean_object* v___x_711_; lean_object* v___x_712_; lean_object* v___x_713_; 
v___x_704_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_705_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_706_ = l_Rat_mul(v_h_699_, v_a_700_);
v___x_707_ = l_Rat_mul(v___x_706_, v_kp_701_);
v___x_708_ = l_Rat_neg(v___x_707_);
v___x_709_ = l_Rat_mul(v___x_706_, v_kv_702_);
v___x_710_ = l_Rat_sub(v___x_704_, v___x_709_);
v___x_711_ = l_Rat_mul(v___x_706_, v_ki_703_);
lean_dec_ref(v___x_706_);
v___x_712_ = l_Rat_neg(v___x_711_);
lean_inc_ref(v_h_699_);
v___x_713_ = lean_alloc_ctor(0, 9, 0);
lean_ctor_set(v___x_713_, 0, v___x_704_);
lean_ctor_set(v___x_713_, 1, v_h_699_);
lean_ctor_set(v___x_713_, 2, v___x_705_);
lean_ctor_set(v___x_713_, 3, v___x_708_);
lean_ctor_set(v___x_713_, 4, v___x_710_);
lean_ctor_set(v___x_713_, 5, v___x_712_);
lean_ctor_set(v___x_713_, 6, v_h_699_);
lean_ctor_set(v___x_713_, 7, v___x_705_);
lean_ctor_set(v___x_713_, 8, v___x_704_);
return v___x_713_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_matrixStep(lean_object* v_m_714_, lean_object* v_x_715_){
_start:
{
lean_object* v_m11_716_; lean_object* v_m12_717_; lean_object* v_m13_718_; lean_object* v_m21_719_; lean_object* v_m22_720_; lean_object* v_m23_721_; lean_object* v_m31_722_; lean_object* v_m32_723_; lean_object* v_m33_724_; lean_object* v_x1_725_; lean_object* v_x2_726_; lean_object* v_x3_727_; lean_object* v___x_729_; uint8_t v_isShared_730_; uint8_t v_isSharedCheck_749_; 
v_m11_716_ = lean_ctor_get(v_m_714_, 0);
v_m12_717_ = lean_ctor_get(v_m_714_, 1);
v_m13_718_ = lean_ctor_get(v_m_714_, 2);
v_m21_719_ = lean_ctor_get(v_m_714_, 3);
v_m22_720_ = lean_ctor_get(v_m_714_, 4);
v_m23_721_ = lean_ctor_get(v_m_714_, 5);
v_m31_722_ = lean_ctor_get(v_m_714_, 6);
v_m32_723_ = lean_ctor_get(v_m_714_, 7);
v_m33_724_ = lean_ctor_get(v_m_714_, 8);
v_x1_725_ = lean_ctor_get(v_x_715_, 0);
v_x2_726_ = lean_ctor_get(v_x_715_, 1);
v_x3_727_ = lean_ctor_get(v_x_715_, 2);
v_isSharedCheck_749_ = !lean_is_exclusive(v_x_715_);
if (v_isSharedCheck_749_ == 0)
{
v___x_729_ = v_x_715_;
v_isShared_730_ = v_isSharedCheck_749_;
goto v_resetjp_728_;
}
else
{
lean_inc(v_x3_727_);
lean_inc(v_x2_726_);
lean_inc(v_x1_725_);
lean_dec(v_x_715_);
v___x_729_ = lean_box(0);
v_isShared_730_ = v_isSharedCheck_749_;
goto v_resetjp_728_;
}
v_resetjp_728_:
{
lean_object* v___x_731_; lean_object* v___x_732_; lean_object* v___x_733_; lean_object* v___x_734_; lean_object* v___x_735_; lean_object* v___x_736_; lean_object* v___x_737_; lean_object* v___x_738_; lean_object* v___x_739_; lean_object* v___x_740_; lean_object* v___x_741_; lean_object* v___x_742_; lean_object* v___x_743_; lean_object* v___x_744_; lean_object* v___x_745_; lean_object* v___x_747_; 
lean_inc_ref_n(v_x1_725_, 2);
v___x_731_ = l_Rat_mul(v_m11_716_, v_x1_725_);
lean_inc_ref_n(v_x2_726_, 2);
v___x_732_ = l_Rat_mul(v_m12_717_, v_x2_726_);
v___x_733_ = l_Rat_add(v___x_731_, v___x_732_);
lean_inc_ref_n(v_x3_727_, 2);
v___x_734_ = l_Rat_mul(v_m13_718_, v_x3_727_);
v___x_735_ = l_Rat_add(v___x_733_, v___x_734_);
v___x_736_ = l_Rat_mul(v_m21_719_, v_x1_725_);
v___x_737_ = l_Rat_mul(v_m22_720_, v_x2_726_);
v___x_738_ = l_Rat_add(v___x_736_, v___x_737_);
v___x_739_ = l_Rat_mul(v_m23_721_, v_x3_727_);
v___x_740_ = l_Rat_add(v___x_738_, v___x_739_);
v___x_741_ = l_Rat_mul(v_m31_722_, v_x1_725_);
v___x_742_ = l_Rat_mul(v_m32_723_, v_x2_726_);
v___x_743_ = l_Rat_add(v___x_741_, v___x_742_);
v___x_744_ = l_Rat_mul(v_m33_724_, v_x3_727_);
v___x_745_ = l_Rat_add(v___x_743_, v___x_744_);
if (v_isShared_730_ == 0)
{
lean_ctor_set(v___x_729_, 2, v___x_745_);
lean_ctor_set(v___x_729_, 1, v___x_740_);
lean_ctor_set(v___x_729_, 0, v___x_735_);
v___x_747_ = v___x_729_;
goto v_reusejp_746_;
}
else
{
lean_object* v_reuseFailAlloc_748_; 
v_reuseFailAlloc_748_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_748_, 0, v___x_735_);
lean_ctor_set(v_reuseFailAlloc_748_, 1, v___x_740_);
lean_ctor_set(v_reuseFailAlloc_748_, 2, v___x_745_);
v___x_747_ = v_reuseFailAlloc_748_;
goto v_reusejp_746_;
}
v_reusejp_746_:
{
return v___x_747_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_matrixStep___boxed(lean_object* v_m_750_, lean_object* v_x_751_){
_start:
{
lean_object* v_res_752_; 
v_res_752_ = lp_pid_x2dproof_PidProof_matrixStep(v_m_750_, v_x_751_);
lean_dec_ref(v_m_750_);
return v_res_752_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_closedLoopStep(lean_object* v_h_753_, lean_object* v_a_754_, lean_object* v_kp_755_, lean_object* v_kv_756_, lean_object* v_ki_757_, lean_object* v_x_758_){
_start:
{
lean_object* v___x_759_; lean_object* v___x_760_; 
v___x_759_ = lp_pid_x2dproof_PidProof_closedLoopMatrix(v_h_753_, v_a_754_, v_kp_755_, v_kv_756_, v_ki_757_);
v___x_760_ = lp_pid_x2dproof_PidProof_matrixStep(v___x_759_, v_x_758_);
lean_dec_ref(v___x_759_);
return v___x_760_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_characteristic(lean_object* v_m_761_, lean_object* v_lambda_762_){
_start:
{
lean_object* v_m11_763_; lean_object* v_m12_764_; lean_object* v_m13_765_; lean_object* v_m21_766_; lean_object* v_m22_767_; lean_object* v_m23_768_; lean_object* v_m31_769_; lean_object* v_m32_770_; lean_object* v_m33_771_; lean_object* v___x_773_; uint8_t v_isShared_774_; uint8_t v_isSharedCheck_788_; 
v_m11_763_ = lean_ctor_get(v_m_761_, 0);
v_m12_764_ = lean_ctor_get(v_m_761_, 1);
v_m13_765_ = lean_ctor_get(v_m_761_, 2);
v_m21_766_ = lean_ctor_get(v_m_761_, 3);
v_m22_767_ = lean_ctor_get(v_m_761_, 4);
v_m23_768_ = lean_ctor_get(v_m_761_, 5);
v_m31_769_ = lean_ctor_get(v_m_761_, 6);
v_m32_770_ = lean_ctor_get(v_m_761_, 7);
v_m33_771_ = lean_ctor_get(v_m_761_, 8);
v_isSharedCheck_788_ = !lean_is_exclusive(v_m_761_);
if (v_isSharedCheck_788_ == 0)
{
v___x_773_ = v_m_761_;
v_isShared_774_ = v_isSharedCheck_788_;
goto v_resetjp_772_;
}
else
{
lean_inc(v_m33_771_);
lean_inc(v_m32_770_);
lean_inc(v_m31_769_);
lean_inc(v_m23_768_);
lean_inc(v_m22_767_);
lean_inc(v_m21_766_);
lean_inc(v_m13_765_);
lean_inc(v_m12_764_);
lean_inc(v_m11_763_);
lean_dec(v_m_761_);
v___x_773_ = lean_box(0);
v_isShared_774_ = v_isSharedCheck_788_;
goto v_resetjp_772_;
}
v_resetjp_772_:
{
lean_object* v___x_775_; lean_object* v___x_776_; lean_object* v___x_777_; lean_object* v___x_778_; lean_object* v___x_779_; lean_object* v___x_780_; lean_object* v___x_781_; lean_object* v___x_782_; lean_object* v___x_783_; lean_object* v___x_785_; 
lean_inc_ref_n(v_lambda_762_, 2);
v___x_775_ = l_Rat_sub(v_lambda_762_, v_m11_763_);
v___x_776_ = l_Rat_neg(v_m12_764_);
v___x_777_ = l_Rat_neg(v_m13_765_);
v___x_778_ = l_Rat_neg(v_m21_766_);
v___x_779_ = l_Rat_sub(v_lambda_762_, v_m22_767_);
v___x_780_ = l_Rat_neg(v_m23_768_);
v___x_781_ = l_Rat_neg(v_m31_769_);
v___x_782_ = l_Rat_neg(v_m32_770_);
v___x_783_ = l_Rat_sub(v_lambda_762_, v_m33_771_);
if (v_isShared_774_ == 0)
{
lean_ctor_set(v___x_773_, 8, v___x_783_);
lean_ctor_set(v___x_773_, 7, v___x_782_);
lean_ctor_set(v___x_773_, 6, v___x_781_);
lean_ctor_set(v___x_773_, 5, v___x_780_);
lean_ctor_set(v___x_773_, 4, v___x_779_);
lean_ctor_set(v___x_773_, 3, v___x_778_);
lean_ctor_set(v___x_773_, 2, v___x_777_);
lean_ctor_set(v___x_773_, 1, v___x_776_);
lean_ctor_set(v___x_773_, 0, v___x_775_);
v___x_785_ = v___x_773_;
goto v_reusejp_784_;
}
else
{
lean_object* v_reuseFailAlloc_787_; 
v_reuseFailAlloc_787_ = lean_alloc_ctor(0, 9, 0);
lean_ctor_set(v_reuseFailAlloc_787_, 0, v___x_775_);
lean_ctor_set(v_reuseFailAlloc_787_, 1, v___x_776_);
lean_ctor_set(v_reuseFailAlloc_787_, 2, v___x_777_);
lean_ctor_set(v_reuseFailAlloc_787_, 3, v___x_778_);
lean_ctor_set(v_reuseFailAlloc_787_, 4, v___x_779_);
lean_ctor_set(v_reuseFailAlloc_787_, 5, v___x_780_);
lean_ctor_set(v_reuseFailAlloc_787_, 6, v___x_781_);
lean_ctor_set(v_reuseFailAlloc_787_, 7, v___x_782_);
lean_ctor_set(v_reuseFailAlloc_787_, 8, v___x_783_);
v___x_785_ = v_reuseFailAlloc_787_;
goto v_reusejp_784_;
}
v_reusejp_784_:
{
lean_object* v___x_786_; 
v___x_786_ = lp_pid_x2dproof_PidProof_det3(v___x_785_);
return v___x_786_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_shiftedCharacteristic(lean_object* v_h_789_, lean_object* v_a_790_, lean_object* v_kp_791_, lean_object* v_kv_792_, lean_object* v_ki_793_, lean_object* v_z_794_){
_start:
{
lean_object* v___x_795_; lean_object* v___x_796_; lean_object* v___x_797_; lean_object* v___x_798_; 
v___x_795_ = lp_pid_x2dproof_PidProof_closedLoopMatrix(v_h_789_, v_a_790_, v_kp_791_, v_kv_792_, v_ki_793_);
v___x_796_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_797_ = l_Rat_add(v_z_794_, v___x_796_);
v___x_798_ = lp_pid_x2dproof_PidProof_characteristic(v___x_795_, v___x_797_);
return v___x_798_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_poleGains___closed__0(void){
_start:
{
lean_object* v___x_799_; lean_object* v___x_800_; 
v___x_799_ = lean_unsigned_to_nat(3u);
v___x_800_ = l_Nat_cast___at___00Lean_Server_Logging_LogConfig_ofLspLogConfig_spec__0(v___x_799_);
return v___x_800_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_poleGains(lean_object* v_h_801_, lean_object* v_a_802_, lean_object* v_rho_803_){
_start:
{
lean_object* v___x_804_; lean_object* v_delta_805_; lean_object* v_b_806_; lean_object* v___x_807_; lean_object* v___x_808_; lean_object* v___x_809_; lean_object* v___x_810_; lean_object* v___x_811_; lean_object* v___x_812_; lean_object* v___x_813_; lean_object* v___x_814_; lean_object* v___x_815_; lean_object* v___x_816_; lean_object* v___x_817_; lean_object* v___x_818_; lean_object* v___x_819_; lean_object* v___x_820_; lean_object* v___x_821_; 
v___x_804_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v_delta_805_ = l_Rat_sub(v___x_804_, v_rho_803_);
v_b_806_ = l_Rat_mul(v_h_801_, v_a_802_);
v___x_807_ = lean_unsigned_to_nat(3u);
v___x_808_ = lean_obj_once(&lp_pid_x2dproof_PidProof_poleGains___closed__0, &lp_pid_x2dproof_PidProof_poleGains___closed__0_once, _init_lp_pid_x2dproof_PidProof_poleGains___closed__0);
v___x_809_ = lean_unsigned_to_nat(2u);
lean_inc_ref_n(v_delta_805_, 2);
v___x_810_ = l_Rat_pow(v_delta_805_, v___x_809_);
v___x_811_ = l_Rat_mul(v___x_808_, v___x_810_);
lean_inc_ref_n(v_b_806_, 2);
v___x_812_ = l_Rat_mul(v_h_801_, v_b_806_);
v___x_813_ = l_Rat_div(v___x_811_, v___x_812_);
lean_dec_ref(v___x_811_);
v___x_814_ = l_Rat_mul(v___x_808_, v_delta_805_);
v___x_815_ = l_Rat_div(v___x_814_, v_b_806_);
lean_dec_ref(v___x_814_);
v___x_816_ = l_Rat_pow(v_delta_805_, v___x_807_);
v___x_817_ = l_Rat_pow(v_h_801_, v___x_809_);
v___x_818_ = l_Rat_mul(v___x_817_, v_b_806_);
lean_dec_ref(v___x_817_);
v___x_819_ = l_Rat_div(v___x_816_, v___x_818_);
lean_dec_ref(v___x_816_);
v___x_820_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v___x_820_, 0, v___x_815_);
lean_ctor_set(v___x_820_, 1, v___x_819_);
v___x_821_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v___x_821_, 0, v___x_813_);
lean_ctor_set(v___x_821_, 1, v___x_820_);
return v___x_821_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_speedError(lean_object* v_input_822_){
_start:
{
lean_object* v_referenceVelocity_823_; lean_object* v_measuredVelocity_824_; lean_object* v___x_825_; 
v_referenceVelocity_823_ = lean_ctor_get(v_input_822_, 0);
lean_inc_ref(v_referenceVelocity_823_);
v_measuredVelocity_824_ = lean_ctor_get(v_input_822_, 1);
lean_inc_ref(v_measuredVelocity_824_);
lean_dec_ref(v_input_822_);
v___x_825_ = l_Rat_sub(v_referenceVelocity_823_, v_measuredVelocity_824_);
return v___x_825_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_provisionalIntegral(lean_object* v_s_826_, lean_object* v_input_827_){
_start:
{
lean_object* v_h_828_; lean_object* v_integralLimit_829_; lean_object* v_integral_830_; lean_object* v___x_831_; lean_object* v___x_832_; lean_object* v___x_833_; lean_object* v___x_834_; 
v_h_828_ = lean_ctor_get(v_input_827_, 2);
lean_inc_ref(v_h_828_);
v_integralLimit_829_ = lean_ctor_get(v_input_827_, 3);
lean_inc_ref(v_integralLimit_829_);
v_integral_830_ = lean_ctor_get(v_s_826_, 0);
lean_inc_ref(v_integral_830_);
lean_dec_ref(v_s_826_);
v___x_831_ = lp_pid_x2dproof_PidProof_speedError(v_input_827_);
v___x_832_ = l_Rat_mul(v_h_828_, v___x_831_);
lean_dec_ref(v_h_828_);
v___x_833_ = l_Rat_add(v_integral_830_, v___x_832_);
v___x_834_ = lp_pid_x2dproof_PidProof_satSym(v_integralLimit_829_, v___x_833_);
return v___x_834_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_measuredDeceleration(lean_object* v_s_835_, lean_object* v_input_836_){
_start:
{
lean_object* v_measuredVelocity_837_; lean_object* v_h_838_; lean_object* v_previousVelocity_839_; lean_object* v___x_840_; lean_object* v___x_841_; lean_object* v___x_842_; 
v_measuredVelocity_837_ = lean_ctor_get(v_input_836_, 1);
lean_inc_ref(v_measuredVelocity_837_);
v_h_838_ = lean_ctor_get(v_input_836_, 2);
lean_inc_ref(v_h_838_);
lean_dec_ref(v_input_836_);
v_previousVelocity_839_ = lean_ctor_get(v_s_835_, 1);
lean_inc_ref(v_previousVelocity_839_);
lean_dec_ref(v_s_835_);
v___x_840_ = l_Rat_sub(v_measuredVelocity_837_, v_previousVelocity_839_);
v___x_841_ = l_Rat_neg(v___x_840_);
v___x_842_ = l_Rat_div(v___x_841_, v_h_838_);
lean_dec_ref(v___x_841_);
return v___x_842_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_rawEffort(lean_object* v_g_843_, lean_object* v_s_844_, lean_object* v_input_845_){
_start:
{
lean_object* v_kp_846_; lean_object* v_kv_847_; lean_object* v_ki_848_; lean_object* v___x_849_; lean_object* v___x_850_; lean_object* v___x_851_; lean_object* v___x_852_; lean_object* v___x_853_; lean_object* v___x_854_; lean_object* v___x_855_; lean_object* v___x_856_; 
v_kp_846_ = lean_ctor_get(v_g_843_, 0);
v_kv_847_ = lean_ctor_get(v_g_843_, 1);
v_ki_848_ = lean_ctor_get(v_g_843_, 2);
lean_inc_ref_n(v_input_845_, 2);
v___x_849_ = lp_pid_x2dproof_PidProof_speedError(v_input_845_);
v___x_850_ = l_Rat_mul(v_kp_846_, v___x_849_);
lean_inc_ref(v_s_844_);
v___x_851_ = lp_pid_x2dproof_PidProof_provisionalIntegral(v_s_844_, v_input_845_);
v___x_852_ = l_Rat_mul(v_ki_848_, v___x_851_);
v___x_853_ = l_Rat_add(v___x_850_, v___x_852_);
v___x_854_ = lp_pid_x2dproof_PidProof_measuredDeceleration(v_s_844_, v_input_845_);
v___x_855_ = l_Rat_mul(v_kv_847_, v___x_854_);
v___x_856_ = l_Rat_sub(v___x_853_, v___x_855_);
return v___x_856_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_rawEffort___boxed(lean_object* v_g_857_, lean_object* v_s_858_, lean_object* v_input_859_){
_start:
{
lean_object* v_res_860_; 
v_res_860_ = lp_pid_x2dproof_PidProof_rawEffort(v_g_857_, v_s_858_, v_input_859_);
lean_dec_ref(v_g_857_);
return v_res_860_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_effortSaturation(lean_object* v_x_861_){
_start:
{
lean_object* v___x_862_; lean_object* v___x_863_; 
v___x_862_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_863_ = lp_pid_x2dproof_PidProof_satSym(v___x_862_, v_x_861_);
return v___x_863_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_antiWindupIntegral(lean_object* v_g_864_, lean_object* v_s_865_, lean_object* v_input_866_){
_start:
{
lean_object* v_raw_867_; lean_object* v___x_877_; uint8_t v___x_878_; 
lean_inc_ref(v_input_866_);
lean_inc_ref(v_s_865_);
v_raw_867_ = lp_pid_x2dproof_PidProof_rawEffort(v_g_864_, v_s_865_, v_input_866_);
v___x_877_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
lean_inc_ref(v_raw_867_);
v___x_878_ = l_Rat_blt(v___x_877_, v_raw_867_);
if (v___x_878_ == 0)
{
goto v___jp_868_;
}
else
{
lean_object* v___x_879_; lean_object* v___x_880_; uint8_t v___x_881_; 
v___x_879_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
lean_inc_ref(v_input_866_);
v___x_880_ = lp_pid_x2dproof_PidProof_speedError(v_input_866_);
v___x_881_ = l_Rat_blt(v___x_879_, v___x_880_);
if (v___x_881_ == 0)
{
goto v___jp_868_;
}
else
{
lean_object* v_integral_882_; 
lean_dec_ref(v_raw_867_);
lean_dec_ref(v_input_866_);
v_integral_882_ = lean_ctor_get(v_s_865_, 0);
lean_inc_ref(v_integral_882_);
lean_dec_ref(v_s_865_);
return v_integral_882_;
}
}
v___jp_868_:
{
lean_object* v___x_869_; uint8_t v___x_870_; 
v___x_869_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sideSign___closed__0, &lp_pid_x2dproof_PidProof_sideSign___closed__0_once, _init_lp_pid_x2dproof_PidProof_sideSign___closed__0);
v___x_870_ = l_Rat_blt(v_raw_867_, v___x_869_);
if (v___x_870_ == 0)
{
lean_object* v___x_871_; 
v___x_871_ = lp_pid_x2dproof_PidProof_provisionalIntegral(v_s_865_, v_input_866_);
return v___x_871_;
}
else
{
lean_object* v___x_872_; lean_object* v___x_873_; uint8_t v___x_874_; 
lean_inc_ref(v_input_866_);
v___x_872_ = lp_pid_x2dproof_PidProof_speedError(v_input_866_);
v___x_873_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_874_ = l_Rat_blt(v___x_872_, v___x_873_);
if (v___x_874_ == 0)
{
lean_object* v___x_875_; 
v___x_875_ = lp_pid_x2dproof_PidProof_provisionalIntegral(v_s_865_, v_input_866_);
return v___x_875_;
}
else
{
lean_object* v_integral_876_; 
lean_dec_ref(v_input_866_);
v_integral_876_ = lean_ctor_get(v_s_865_, 0);
lean_inc_ref(v_integral_876_);
lean_dec_ref(v_s_865_);
return v_integral_876_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_antiWindupIntegral___boxed(lean_object* v_g_883_, lean_object* v_s_884_, lean_object* v_input_885_){
_start:
{
lean_object* v_res_886_; 
v_res_886_ = lp_pid_x2dproof_PidProof_antiWindupIntegral(v_g_883_, v_s_884_, v_input_885_);
lean_dec_ref(v_g_883_);
return v_res_886_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_slewLimit(lean_object* v_previous_887_, lean_object* v_target_888_, lean_object* v_h_889_, lean_object* v_rate_890_){
_start:
{
lean_object* v___x_891_; lean_object* v___x_892_; lean_object* v___x_893_; lean_object* v___x_894_; 
v___x_891_ = l_Rat_mul(v_rate_890_, v_h_889_);
lean_inc_ref(v___x_891_);
lean_inc_ref(v_previous_887_);
v___x_892_ = l_Rat_sub(v_previous_887_, v___x_891_);
v___x_893_ = l_Rat_add(v_previous_887_, v___x_891_);
v___x_894_ = lp_pid_x2dproof_PidProof_clamp(v___x_892_, v___x_893_, v_target_888_);
return v___x_894_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_slewLimit___boxed(lean_object* v_previous_895_, lean_object* v_target_896_, lean_object* v_h_897_, lean_object* v_rate_898_){
_start:
{
lean_object* v_res_899_; 
v_res_899_ = lp_pid_x2dproof_PidProof_slewLimit(v_previous_895_, v_target_896_, v_h_897_, v_rate_898_);
lean_dec_ref(v_rate_898_);
return v_res_899_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidEffort(lean_object* v_g_900_, lean_object* v_s_901_, lean_object* v_input_902_){
_start:
{
lean_object* v_previousEffort_903_; lean_object* v_h_904_; lean_object* v_slewRate_905_; lean_object* v___x_906_; lean_object* v___x_907_; lean_object* v___x_908_; 
v_previousEffort_903_ = lean_ctor_get(v_s_901_, 2);
lean_inc_ref(v_previousEffort_903_);
v_h_904_ = lean_ctor_get(v_input_902_, 2);
lean_inc_ref(v_h_904_);
v_slewRate_905_ = lean_ctor_get(v_input_902_, 4);
lean_inc_ref(v_slewRate_905_);
v___x_906_ = lp_pid_x2dproof_PidProof_rawEffort(v_g_900_, v_s_901_, v_input_902_);
v___x_907_ = lp_pid_x2dproof_PidProof_effortSaturation(v___x_906_);
v___x_908_ = lp_pid_x2dproof_PidProof_slewLimit(v_previousEffort_903_, v___x_907_, v_h_904_, v_slewRate_905_);
lean_dec_ref(v_slewRate_905_);
return v___x_908_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidEffort___boxed(lean_object* v_g_909_, lean_object* v_s_910_, lean_object* v_input_911_){
_start:
{
lean_object* v_res_912_; 
v_res_912_ = lp_pid_x2dproof_PidProof_pidEffort(v_g_909_, v_s_910_, v_input_911_);
lean_dec_ref(v_g_909_);
return v_res_912_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_normalAllocation(lean_object* v_effort_913_){
_start:
{
lean_object* v___x_914_; uint8_t v___x_915_; 
v___x_914_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
lean_inc_ref(v_effort_913_);
v___x_915_ = l_Rat_instDecidableLe(v___x_914_, v_effort_913_);
if (v___x_915_ == 0)
{
lean_object* v___x_916_; lean_object* v___x_917_; 
v___x_916_ = l_Rat_neg(v_effort_913_);
lean_inc_ref(v___x_916_);
v___x_917_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_917_, 0, v___x_914_);
lean_ctor_set(v___x_917_, 1, v___x_916_);
lean_ctor_set(v___x_917_, 2, v___x_916_);
return v___x_917_;
}
else
{
lean_object* v___x_918_; 
v___x_918_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_918_, 0, v_effort_913_);
lean_ctor_set(v___x_918_, 1, v___x_914_);
lean_ctor_set(v___x_918_, 2, v___x_914_);
return v___x_918_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_dynamicBrakeAllocation(lean_object* v_effort_919_, lean_object* v_trainCapacity_920_, lean_object* v_independentCapacity_921_){
_start:
{
lean_object* v___x_922_; uint8_t v___x_923_; 
v___x_922_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
lean_inc_ref(v_effort_919_);
v___x_923_ = l_Rat_instDecidableLe(v___x_922_, v_effort_919_);
if (v___x_923_ == 0)
{
lean_object* v___x_924_; lean_object* v_requested_925_; lean_object* v___y_927_; uint8_t v___x_931_; 
v___x_924_ = l_Rat_neg(v_effort_919_);
v_requested_925_ = lp_pid_x2dproof_PidProof_sat01(v___x_924_);
lean_inc_ref(v_trainCapacity_920_);
lean_inc_ref(v_requested_925_);
v___x_931_ = l_Rat_instDecidableLe(v_requested_925_, v_trainCapacity_920_);
if (v___x_931_ == 0)
{
v___y_927_ = v_trainCapacity_920_;
goto v___jp_926_;
}
else
{
lean_dec_ref(v_trainCapacity_920_);
lean_inc_ref(v_requested_925_);
v___y_927_ = v_requested_925_;
goto v___jp_926_;
}
v___jp_926_:
{
uint8_t v___x_928_; 
lean_inc_ref(v_independentCapacity_921_);
lean_inc_ref(v_requested_925_);
v___x_928_ = l_Rat_instDecidableLe(v_requested_925_, v_independentCapacity_921_);
if (v___x_928_ == 0)
{
lean_object* v___x_929_; 
lean_dec_ref(v_requested_925_);
v___x_929_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_929_, 0, v___x_922_);
lean_ctor_set(v___x_929_, 1, v___y_927_);
lean_ctor_set(v___x_929_, 2, v_independentCapacity_921_);
return v___x_929_;
}
else
{
lean_object* v___x_930_; 
lean_dec_ref(v_independentCapacity_921_);
v___x_930_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_930_, 0, v___x_922_);
lean_ctor_set(v___x_930_, 1, v___y_927_);
lean_ctor_set(v___x_930_, 2, v_requested_925_);
return v___x_930_;
}
}
}
else
{
lean_object* v___x_932_; 
lean_dec_ref(v_independentCapacity_921_);
lean_dec_ref(v_trainCapacity_920_);
v___x_932_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_932_, 0, v_effort_919_);
lean_ctor_set(v___x_932_, 1, v___x_922_);
lean_ctor_set(v___x_932_, 2, v___x_922_);
return v___x_932_;
}
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_emergencyControl___closed__0(void){
_start:
{
lean_object* v___x_933_; lean_object* v___x_934_; lean_object* v___x_935_; 
v___x_933_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_934_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_935_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_935_, 0, v___x_934_);
lean_ctor_set(v___x_935_, 1, v___x_933_);
lean_ctor_set(v___x_935_, 2, v___x_933_);
return v___x_935_;
}
}
static lean_object* _init_lp_pid_x2dproof_PidProof_emergencyControl(void){
_start:
{
lean_object* v___x_936_; 
v___x_936_ = lean_obj_once(&lp_pid_x2dproof_PidProof_emergencyControl___closed__0, &lp_pid_x2dproof_PidProof_emergencyControl___closed__0_once, _init_lp_pid_x2dproof_PidProof_emergencyControl___closed__0);
return v___x_936_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_zeroThrottleSupervisor(uint8_t v_brakingPhase_937_, lean_object* v_effort_938_){
_start:
{
if (v_brakingPhase_937_ == 0)
{
lean_object* v___x_939_; lean_object* v___x_940_; 
v___x_939_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_940_ = lp_pid_x2dproof_PidProof_dynamicBrakeAllocation(v_effort_938_, v___x_939_, v___x_939_);
return v___x_940_;
}
else
{
lean_object* v___x_941_; 
lean_dec_ref(v_effort_938_);
v___x_941_ = lp_pid_x2dproof_PidProof_emergencyControl;
return v___x_941_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_zeroThrottleSupervisor___boxed(lean_object* v_brakingPhase_942_, lean_object* v_effort_943_){
_start:
{
uint8_t v_brakingPhase_boxed_944_; lean_object* v_res_945_; 
v_brakingPhase_boxed_944_ = lean_unbox(v_brakingPhase_942_);
v_res_945_ = lp_pid_x2dproof_PidProof_zeroThrottleSupervisor(v_brakingPhase_boxed_944_, v_effort_943_);
return v_res_945_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_aggregateParticleStep(lean_object* v_p_946_, lean_object* v_dt_947_){
_start:
{
lean_object* v_massKg_948_; lean_object* v_forceN_949_; lean_object* v_distance_950_; lean_object* v_velocity_951_; lean_object* v___x_953_; uint8_t v_isShared_954_; uint8_t v_isSharedCheck_963_; 
v_massKg_948_ = lean_ctor_get(v_p_946_, 0);
v_forceN_949_ = lean_ctor_get(v_p_946_, 1);
v_distance_950_ = lean_ctor_get(v_p_946_, 2);
v_velocity_951_ = lean_ctor_get(v_p_946_, 3);
v_isSharedCheck_963_ = !lean_is_exclusive(v_p_946_);
if (v_isSharedCheck_963_ == 0)
{
v___x_953_ = v_p_946_;
v_isShared_954_ = v_isSharedCheck_963_;
goto v_resetjp_952_;
}
else
{
lean_inc(v_velocity_951_);
lean_inc(v_distance_950_);
lean_inc(v_forceN_949_);
lean_inc(v_massKg_948_);
lean_dec(v_p_946_);
v___x_953_ = lean_box(0);
v_isShared_954_ = v_isSharedCheck_963_;
goto v_resetjp_952_;
}
v_resetjp_952_:
{
lean_object* v___x_955_; lean_object* v___x_956_; lean_object* v___x_957_; lean_object* v___x_958_; lean_object* v___x_959_; lean_object* v___x_961_; 
lean_inc_ref(v_velocity_951_);
v___x_955_ = l_Rat_mul(v_dt_947_, v_velocity_951_);
v___x_956_ = l_Rat_sub(v_distance_950_, v___x_955_);
lean_inc_ref(v_massKg_948_);
v___x_957_ = l_Rat_div(v_forceN_949_, v_massKg_948_);
v___x_958_ = l_Rat_mul(v_dt_947_, v___x_957_);
v___x_959_ = l_Rat_add(v_velocity_951_, v___x_958_);
if (v_isShared_954_ == 0)
{
lean_ctor_set(v___x_953_, 3, v___x_959_);
lean_ctor_set(v___x_953_, 2, v___x_956_);
v___x_961_ = v___x_953_;
goto v_reusejp_960_;
}
else
{
lean_object* v_reuseFailAlloc_962_; 
v_reuseFailAlloc_962_ = lean_alloc_ctor(0, 4, 0);
lean_ctor_set(v_reuseFailAlloc_962_, 0, v_massKg_948_);
lean_ctor_set(v_reuseFailAlloc_962_, 1, v_forceN_949_);
lean_ctor_set(v_reuseFailAlloc_962_, 2, v___x_956_);
lean_ctor_set(v_reuseFailAlloc_962_, 3, v___x_959_);
v___x_961_ = v_reuseFailAlloc_962_;
goto v_reusejp_960_;
}
v_reusejp_960_:
{
return v___x_961_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_aggregateParticleStep___boxed(lean_object* v_p_964_, lean_object* v_dt_965_){
_start:
{
lean_object* v_res_966_; 
v_res_966_ = lp_pid_x2dproof_PidProof_aggregateParticleStep(v_p_964_, v_dt_965_);
lean_dec_ref(v_dt_965_);
return v_res_966_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidStateUpdate(lean_object* v_g_967_, lean_object* v_s_968_, lean_object* v_input_969_){
_start:
{
lean_object* v_measuredVelocity_970_; lean_object* v___x_971_; lean_object* v___x_972_; lean_object* v___x_973_; 
v_measuredVelocity_970_ = lean_ctor_get(v_input_969_, 1);
lean_inc_ref(v_measuredVelocity_970_);
lean_inc_ref(v_input_969_);
lean_inc_ref(v_s_968_);
v___x_971_ = lp_pid_x2dproof_PidProof_antiWindupIntegral(v_g_967_, v_s_968_, v_input_969_);
v___x_972_ = lp_pid_x2dproof_PidProof_pidEffort(v_g_967_, v_s_968_, v_input_969_);
v___x_973_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_973_, 0, v___x_971_);
lean_ctor_set(v___x_973_, 1, v_measuredVelocity_970_);
lean_ctor_set(v___x_973_, 2, v___x_972_);
return v___x_973_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_pidStateUpdate___boxed(lean_object* v_g_974_, lean_object* v_s_975_, lean_object* v_input_976_){
_start:
{
lean_object* v_res_977_; 
v_res_977_ = lp_pid_x2dproof_PidProof_pidStateUpdate(v_g_974_, v_s_975_, v_input_976_);
lean_dec_ref(v_g_974_);
return v_res_977_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_commandNormalize(lean_object* v_raw_978_){
_start:
{
if (lean_obj_tag(v_raw_978_) == 0)
{
lean_object* v___x_979_; 
v___x_979_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
return v___x_979_;
}
else
{
lean_object* v_val_980_; lean_object* v___x_981_; lean_object* v___x_982_; lean_object* v___x_983_; 
v_val_980_ = lean_ctor_get(v_raw_978_, 0);
lean_inc(v_val_980_);
lean_dec_ref_known(v_raw_978_, 1);
v___x_981_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_982_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sideSign___closed__0, &lp_pid_x2dproof_PidProof_sideSign___closed__0_once, _init_lp_pid_x2dproof_PidProof_sideSign___closed__0);
v___x_983_ = lp_pid_x2dproof_PidProof_clamp(v___x_982_, v___x_981_, v_val_980_);
return v___x_983_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorIdx(uint8_t v_x_984_){
_start:
{
switch(v_x_984_)
{
case 0:
{
lean_object* v___x_985_; 
v___x_985_ = lean_unsigned_to_nat(0u);
return v___x_985_;
}
case 1:
{
lean_object* v___x_986_; 
v___x_986_ = lean_unsigned_to_nat(1u);
return v___x_986_;
}
default: 
{
lean_object* v___x_987_; 
v___x_987_ = lean_unsigned_to_nat(2u);
return v___x_987_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorIdx___boxed(lean_object* v_x_988_){
_start:
{
uint8_t v_x_boxed_989_; lean_object* v_res_990_; 
v_x_boxed_989_ = lean_unbox(v_x_988_);
v_res_990_ = lp_pid_x2dproof_PidProof_ApiMethod_ctorIdx(v_x_boxed_989_);
return v_res_990_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_toCtorIdx(uint8_t v_x_991_){
_start:
{
lean_object* v___x_992_; 
v___x_992_ = lp_pid_x2dproof_PidProof_ApiMethod_ctorIdx(v_x_991_);
return v___x_992_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_toCtorIdx___boxed(lean_object* v_x_993_){
_start:
{
uint8_t v_x_4__boxed_994_; lean_object* v_res_995_; 
v_x_4__boxed_994_ = lean_unbox(v_x_993_);
v_res_995_ = lp_pid_x2dproof_PidProof_ApiMethod_toCtorIdx(v_x_4__boxed_994_);
return v_res_995_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim___redArg(lean_object* v_k_996_){
_start:
{
lean_inc(v_k_996_);
return v_k_996_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim___redArg___boxed(lean_object* v_k_997_){
_start:
{
lean_object* v_res_998_; 
v_res_998_ = lp_pid_x2dproof_PidProof_ApiMethod_ctorElim___redArg(v_k_997_);
lean_dec(v_k_997_);
return v_res_998_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim(lean_object* v_motive_999_, lean_object* v_ctorIdx_1000_, uint8_t v_t_1001_, lean_object* v_h_1002_, lean_object* v_k_1003_){
_start:
{
lean_inc(v_k_1003_);
return v_k_1003_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_ctorElim___boxed(lean_object* v_motive_1004_, lean_object* v_ctorIdx_1005_, lean_object* v_t_1006_, lean_object* v_h_1007_, lean_object* v_k_1008_){
_start:
{
uint8_t v_t_boxed_1009_; lean_object* v_res_1010_; 
v_t_boxed_1009_ = lean_unbox(v_t_1006_);
v_res_1010_ = lp_pid_x2dproof_PidProof_ApiMethod_ctorElim(v_motive_1004_, v_ctorIdx_1005_, v_t_boxed_1009_, v_h_1007_, v_k_1008_);
lean_dec(v_k_1008_);
lean_dec(v_ctorIdx_1005_);
return v_res_1010_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim___redArg(lean_object* v_legacySetBrake_1011_){
_start:
{
lean_inc(v_legacySetBrake_1011_);
return v_legacySetBrake_1011_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim___redArg___boxed(lean_object* v_legacySetBrake_1012_){
_start:
{
lean_object* v_res_1013_; 
v_res_1013_ = lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim___redArg(v_legacySetBrake_1012_);
lean_dec(v_legacySetBrake_1012_);
return v_res_1013_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim(lean_object* v_motive_1014_, uint8_t v_t_1015_, lean_object* v_h_1016_, lean_object* v_legacySetBrake_1017_){
_start:
{
lean_inc(v_legacySetBrake_1017_);
return v_legacySetBrake_1017_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim___boxed(lean_object* v_motive_1018_, lean_object* v_t_1019_, lean_object* v_h_1020_, lean_object* v_legacySetBrake_1021_){
_start:
{
uint8_t v_t_boxed_1022_; lean_object* v_res_1023_; 
v_t_boxed_1022_ = lean_unbox(v_t_1019_);
v_res_1023_ = lp_pid_x2dproof_PidProof_ApiMethod_legacySetBrake_elim(v_motive_1018_, v_t_boxed_1022_, v_h_1020_, v_legacySetBrake_1021_);
lean_dec(v_legacySetBrake_1021_);
return v_res_1023_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim___redArg(lean_object* v_trainBrake_1024_){
_start:
{
lean_inc(v_trainBrake_1024_);
return v_trainBrake_1024_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim___redArg___boxed(lean_object* v_trainBrake_1025_){
_start:
{
lean_object* v_res_1026_; 
v_res_1026_ = lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim___redArg(v_trainBrake_1025_);
lean_dec(v_trainBrake_1025_);
return v_res_1026_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim(lean_object* v_motive_1027_, uint8_t v_t_1028_, lean_object* v_h_1029_, lean_object* v_trainBrake_1030_){
_start:
{
lean_inc(v_trainBrake_1030_);
return v_trainBrake_1030_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim___boxed(lean_object* v_motive_1031_, lean_object* v_t_1032_, lean_object* v_h_1033_, lean_object* v_trainBrake_1034_){
_start:
{
uint8_t v_t_boxed_1035_; lean_object* v_res_1036_; 
v_t_boxed_1035_ = lean_unbox(v_t_1032_);
v_res_1036_ = lp_pid_x2dproof_PidProof_ApiMethod_trainBrake_elim(v_motive_1031_, v_t_boxed_1035_, v_h_1033_, v_trainBrake_1034_);
lean_dec(v_trainBrake_1034_);
return v_res_1036_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim___redArg(lean_object* v_independentBrake_1037_){
_start:
{
lean_inc(v_independentBrake_1037_);
return v_independentBrake_1037_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim___redArg___boxed(lean_object* v_independentBrake_1038_){
_start:
{
lean_object* v_res_1039_; 
v_res_1039_ = lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim___redArg(v_independentBrake_1038_);
lean_dec(v_independentBrake_1038_);
return v_res_1039_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim(lean_object* v_motive_1040_, uint8_t v_t_1041_, lean_object* v_h_1042_, lean_object* v_independentBrake_1043_){
_start:
{
lean_inc(v_independentBrake_1043_);
return v_independentBrake_1043_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim___boxed(lean_object* v_motive_1044_, lean_object* v_t_1045_, lean_object* v_h_1046_, lean_object* v_independentBrake_1047_){
_start:
{
uint8_t v_t_boxed_1048_; lean_object* v_res_1049_; 
v_t_boxed_1048_ = lean_unbox(v_t_1045_);
v_res_1049_ = lp_pid_x2dproof_PidProof_ApiMethod_independentBrake_elim(v_motive_1044_, v_t_boxed_1048_, v_h_1046_, v_independentBrake_1047_);
lean_dec(v_independentBrake_1047_);
return v_res_1049_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_apiDispatch(uint8_t v_method_1050_, lean_object* v_raw_1051_){
_start:
{
if (v_method_1050_ == 2)
{
lean_object* v___x_1052_; lean_object* v___x_1053_; lean_object* v___x_1054_; lean_object* v___x_1055_; 
v___x_1052_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_1053_ = lp_pid_x2dproof_PidProof_commandNormalize(v_raw_1051_);
v___x_1054_ = lp_pid_x2dproof_PidProof_sat01(v___x_1053_);
v___x_1055_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_1055_, 0, v___x_1052_);
lean_ctor_set(v___x_1055_, 1, v___x_1052_);
lean_ctor_set(v___x_1055_, 2, v___x_1054_);
return v___x_1055_;
}
else
{
lean_object* v___x_1056_; lean_object* v___x_1057_; lean_object* v___x_1058_; lean_object* v___x_1059_; 
v___x_1056_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_1057_ = lp_pid_x2dproof_PidProof_commandNormalize(v_raw_1051_);
v___x_1058_ = lp_pid_x2dproof_PidProof_sat01(v___x_1057_);
v___x_1059_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_1059_, 0, v___x_1056_);
lean_ctor_set(v___x_1059_, 1, v___x_1058_);
lean_ctor_set(v___x_1059_, 2, v___x_1056_);
return v___x_1059_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_apiDispatch___boxed(lean_object* v_method_1060_, lean_object* v_raw_1061_){
_start:
{
uint8_t v_method_boxed_1062_; lean_object* v_res_1063_; 
v_method_boxed_1062_ = lean_unbox(v_method_1060_);
v_res_1063_ = lp_pid_x2dproof_PidProof_apiDispatch(v_method_boxed_1062_, v_raw_1061_);
return v_res_1063_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_commonApiNormalize(lean_object* v_raw_1064_){
_start:
{
if (lean_obj_tag(v_raw_1064_) == 0)
{
lean_object* v___x_1065_; 
v___x_1065_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
return v___x_1065_;
}
else
{
lean_object* v_val_1066_; lean_object* v___x_1067_; lean_object* v___x_1068_; lean_object* v___x_1069_; 
v_val_1066_ = lean_ctor_get(v_raw_1064_, 0);
lean_inc(v_val_1066_);
lean_dec_ref_known(v_raw_1064_, 1);
v___x_1067_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_1068_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sideSign___closed__0, &lp_pid_x2dproof_PidProof_sideSign___closed__0_once, _init_lp_pid_x2dproof_PidProof_sideSign___closed__0);
v___x_1069_ = lp_pid_x2dproof_PidProof_clamp(v___x_1068_, v___x_1067_, v_val_1066_);
return v___x_1069_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_radioSetBrake(lean_object* v_raw_1070_){
_start:
{
lean_object* v___x_1071_; lean_object* v___x_1072_; lean_object* v___x_1073_; lean_object* v___x_1074_; 
v___x_1071_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_1072_ = lp_pid_x2dproof_PidProof_commandNormalize(v_raw_1070_);
v___x_1073_ = lp_pid_x2dproof_PidProof_sat01(v___x_1072_);
v___x_1074_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_1074_, 0, v___x_1071_);
lean_ctor_set(v___x_1074_, 1, v___x_1073_);
lean_ctor_set(v___x_1074_, 2, v___x_1071_);
return v___x_1074_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_commonApiSetTrainBrake(lean_object* v_raw_1075_){
_start:
{
lean_object* v___x_1076_; lean_object* v___x_1077_; lean_object* v___x_1078_; lean_object* v___x_1079_; 
v___x_1076_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__0, &lp_pid_x2dproof_PidProof_sat01___closed__0_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__0);
v___x_1077_ = lp_pid_x2dproof_PidProof_commonApiNormalize(v_raw_1075_);
v___x_1078_ = lp_pid_x2dproof_PidProof_sat01(v___x_1077_);
v___x_1079_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v___x_1079_, 0, v___x_1076_);
lean_ctor_set(v___x_1079_, 1, v___x_1078_);
lean_ctor_set(v___x_1079_, 2, v___x_1076_);
return v___x_1079_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_radioSetTrainBrake(lean_object* v_raw_1080_){
_start:
{
lean_object* v___x_1081_; 
v___x_1081_ = lp_pid_x2dproof_PidProof_commonApiSetTrainBrake(v_raw_1080_);
return v___x_1081_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter___redArg(uint8_t v_method_1082_, lean_object* v_h__1_1083_, lean_object* v_h__2_1084_, lean_object* v_h__3_1085_){
_start:
{
switch(v_method_1082_)
{
case 0:
{
lean_object* v___x_1086_; lean_object* v___x_1087_; 
lean_dec(v_h__3_1085_);
lean_dec(v_h__2_1084_);
v___x_1086_ = lean_box(0);
v___x_1087_ = lean_apply_1(v_h__1_1083_, v___x_1086_);
return v___x_1087_;
}
case 1:
{
lean_object* v___x_1088_; lean_object* v___x_1089_; 
lean_dec(v_h__3_1085_);
lean_dec(v_h__1_1083_);
v___x_1088_ = lean_box(0);
v___x_1089_ = lean_apply_1(v_h__2_1084_, v___x_1088_);
return v___x_1089_;
}
default: 
{
lean_object* v___x_1090_; lean_object* v___x_1091_; 
lean_dec(v_h__2_1084_);
lean_dec(v_h__1_1083_);
v___x_1090_ = lean_box(0);
v___x_1091_ = lean_apply_1(v_h__3_1085_, v___x_1090_);
return v___x_1091_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter___redArg___boxed(lean_object* v_method_1092_, lean_object* v_h__1_1093_, lean_object* v_h__2_1094_, lean_object* v_h__3_1095_){
_start:
{
uint8_t v_method_33__boxed_1096_; lean_object* v_res_1097_; 
v_method_33__boxed_1096_ = lean_unbox(v_method_1092_);
v_res_1097_ = lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter___redArg(v_method_33__boxed_1096_, v_h__1_1093_, v_h__2_1094_, v_h__3_1095_);
return v_res_1097_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter(lean_object* v_motive_1098_, uint8_t v_method_1099_, lean_object* v_h__1_1100_, lean_object* v_h__2_1101_, lean_object* v_h__3_1102_){
_start:
{
switch(v_method_1099_)
{
case 0:
{
lean_object* v___x_1103_; lean_object* v___x_1104_; 
lean_dec(v_h__3_1102_);
lean_dec(v_h__2_1101_);
v___x_1103_ = lean_box(0);
v___x_1104_ = lean_apply_1(v_h__1_1100_, v___x_1103_);
return v___x_1104_;
}
case 1:
{
lean_object* v___x_1105_; lean_object* v___x_1106_; 
lean_dec(v_h__3_1102_);
lean_dec(v_h__1_1100_);
v___x_1105_ = lean_box(0);
v___x_1106_ = lean_apply_1(v_h__2_1101_, v___x_1105_);
return v___x_1106_;
}
default: 
{
lean_object* v___x_1107_; lean_object* v___x_1108_; 
lean_dec(v_h__2_1101_);
lean_dec(v_h__1_1100_);
v___x_1107_ = lean_box(0);
v___x_1108_ = lean_apply_1(v_h__3_1102_, v___x_1107_);
return v___x_1108_;
}
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter___boxed(lean_object* v_motive_1109_, lean_object* v_method_1110_, lean_object* v_h__1_1111_, lean_object* v_h__2_1112_, lean_object* v_h__3_1113_){
_start:
{
uint8_t v_method_48__boxed_1114_; lean_object* v_res_1115_; 
v_method_48__boxed_1114_ = lean_unbox(v_method_1110_);
v_res_1115_ = lp_pid_x2dproof___private_PidProof_0__PidProof_apiDispatch_match__1_splitter(v_motive_1109_, v_method_48__boxed_1114_, v_h__1_1111_, v_h__2_1112_, v_h__3_1113_);
return v_res_1115_;
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_commandNormalize_match__1_splitter___redArg(lean_object* v_raw_1116_, lean_object* v_h__1_1117_, lean_object* v_h__2_1118_){
_start:
{
if (lean_obj_tag(v_raw_1116_) == 0)
{
lean_object* v___x_1119_; lean_object* v___x_1120_; 
lean_dec(v_h__2_1118_);
v___x_1119_ = lean_box(0);
v___x_1120_ = lean_apply_1(v_h__1_1117_, v___x_1119_);
return v___x_1120_;
}
else
{
lean_object* v_val_1121_; lean_object* v___x_1122_; 
lean_dec(v_h__1_1117_);
v_val_1121_ = lean_ctor_get(v_raw_1116_, 0);
lean_inc(v_val_1121_);
lean_dec_ref_known(v_raw_1116_, 1);
v___x_1122_ = lean_apply_1(v_h__2_1118_, v_val_1121_);
return v___x_1122_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof___private_PidProof_0__PidProof_commandNormalize_match__1_splitter(lean_object* v_motive_1123_, lean_object* v_raw_1124_, lean_object* v_h__1_1125_, lean_object* v_h__2_1126_){
_start:
{
if (lean_obj_tag(v_raw_1124_) == 0)
{
lean_object* v___x_1127_; lean_object* v___x_1128_; 
lean_dec(v_h__2_1126_);
v___x_1127_ = lean_box(0);
v___x_1128_ = lean_apply_1(v_h__1_1125_, v___x_1127_);
return v___x_1128_;
}
else
{
lean_object* v_val_1129_; lean_object* v___x_1130_; 
lean_dec(v_h__1_1125_);
v_val_1129_ = lean_ctor_get(v_raw_1124_, 0);
lean_inc(v_val_1129_);
lean_dec_ref_known(v_raw_1124_, 1);
v___x_1130_ = lean_apply_1(v_h__2_1126_, v_val_1129_);
return v___x_1130_;
}
}
}
LEAN_EXPORT lean_object* lp_pid_x2dproof_PidProof_ema(lean_object* v_alpha_1131_, lean_object* v_previous_1132_, lean_object* v_sample_1133_){
_start:
{
lean_object* v___x_1134_; lean_object* v___x_1135_; lean_object* v___x_1136_; lean_object* v___x_1137_; lean_object* v___x_1138_; 
v___x_1134_ = l_Rat_mul(v_alpha_1131_, v_previous_1132_);
v___x_1135_ = lean_obj_once(&lp_pid_x2dproof_PidProof_sat01___closed__1, &lp_pid_x2dproof_PidProof_sat01___closed__1_once, _init_lp_pid_x2dproof_PidProof_sat01___closed__1);
v___x_1136_ = l_Rat_sub(v___x_1135_, v_alpha_1131_);
v___x_1137_ = l_Rat_mul(v___x_1136_, v_sample_1133_);
lean_dec_ref(v___x_1136_);
v___x_1138_ = l_Rat_add(v___x_1134_, v___x_1137_);
return v___x_1138_;
}
}
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Lean(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_pid_x2dproof_PidProof(uint8_t builtin) {
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
lp_pid_x2dproof_PidProof_steelStatic = _init_lp_pid_x2dproof_PidProof_steelStatic();
lean_mark_persistent(lp_pid_x2dproof_PidProof_steelStatic);
lp_pid_x2dproof_PidProof_steelKinetic = _init_lp_pid_x2dproof_PidProof_steelKinetic();
lean_mark_persistent(lp_pid_x2dproof_PidProof_steelKinetic);
lp_pid_x2dproof_PidProof_steelCastIronKinetic = _init_lp_pid_x2dproof_PidProof_steelCastIronKinetic();
lean_mark_persistent(lp_pid_x2dproof_PidProof_steelCastIronKinetic);
lp_pid_x2dproof_PidProof_gravity = _init_lp_pid_x2dproof_PidProof_gravity();
lean_mark_persistent(lp_pid_x2dproof_PidProof_gravity);
lp_pid_x2dproof_PidProof_defaultBrakeMultiplier = _init_lp_pid_x2dproof_PidProof_defaultBrakeMultiplier();
lean_mark_persistent(lp_pid_x2dproof_PidProof_defaultBrakeMultiplier);
lp_pid_x2dproof_PidProof_emergencyControl = _init_lp_pid_x2dproof_PidProof_emergencyControl();
lean_mark_persistent(lp_pid_x2dproof_PidProof_emergencyControl);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif
