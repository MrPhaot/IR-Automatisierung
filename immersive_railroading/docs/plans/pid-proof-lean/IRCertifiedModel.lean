import IRProof

namespace IRProof

def qLeBool (a b : Q) : Bool :=
  @decide (a ≤ b) (Rat.instDecidableLe a b)

def qLtBool (a b : Q) : Bool :=
  @decide (a < b) (Rat.instDecidableLt a b)

/-! Connected construction and refinement model.

    This module makes the formerly prose-only network and controller contracts
    executable.  It deliberately accepts only certified spline candidates and
    explicit runtime certificates at the boundary; it never turns an
    unresolved observation into a routable object. -/

inductive ReconstructionKind
  | continuation
  | extension
  | split
  | overlap
  | sharedConnection
  | isolatedCrossing
  | overpass
  | newGeometry
  | unresolved
deriving DecidableEq, Repr

structure ReconstructionEvidence where
  candidate : Spline
  candidateCertificate : SplineCertificate candidate
  existingSplineId : Option String
  matchEvidence : MatchEvidence
  topologyEvidence : TopologyEvidence
  fitBound : Q
  traceId : String
  fitCertified : Bool
  splitRequired : Bool
  overlapObserved : Bool

def matchWithinBool (m : MatchEvidence) : Bool :=
  qLeBool m.distanceSq m.distanceToleranceSq &&
  qLeBool m.tangentDistanceSq m.tangentToleranceSq &&
  qLeBool m.curvatureDistance m.curvatureTolerance &&
  qLeBool m.arcDistance m.arcTolerance

def reconstructionKind (e : ReconstructionEvidence) : ReconstructionKind :=
  if e.fitCertified = false then .unresolved
  else if matchWithinBool e.matchEvidence = false then .unresolved
  else if qLtBool e.fitBound e.candidate.fittingError then .unresolved
  else if e.topologyEvidence.unresolvedObservation then .unresolved
  else if qLtBool e.topologyEvidence.certifiedToleranceSq
      e.topologyEvidence.heightSeparationSq then .overpass
  else if e.topologyEvidence.bothContinue && e.topologyEvidence.sameLevel &&
      !e.topologyEvidence.knownConnection then .isolatedCrossing
  else if e.splitRequired then .split
  else if e.overlapObserved then .overlap
  else if e.topologyEvidence.knownConnection then .sharedConnection
  else if e.topologyEvidence.extendsInterval then .extension
  else if e.topologyEvidence.sameInterval then .continuation
  else .newGeometry

def reconstructionRoutable : ReconstructionKind → Bool
  | .continuation => true
  | .extension => true
  | .split => true
  | .overlap => true
  | .sharedConnection => true
  | .isolatedCrossing => false
  | .overpass => false
  | .newGeometry => true
  | .unresolved => false

theorem unresolved_reconstruction_is_unavailable (e : ReconstructionEvidence)
    (h : reconstructionKind e = .unresolved) :
    reconstructionRoutable (reconstructionKind e) = false := by
  simp [h, reconstructionRoutable]

theorem crossing_reconstruction_preserves_separation (e : ReconstructionEvidence)
    (h : reconstructionKind e = .isolatedCrossing) :
    reconstructionRoutable (reconstructionKind e) = false := by
  simp [h, reconstructionRoutable]

structure SplineStore where
  revision : Nat
  splines : List Spline
  sourceTraceIds : List String

def splineIdPresent (id : String) : List Spline → Bool
  | [] => false
  | s :: rest => if s.stableId = id then true else splineIdPresent id rest

def appendSplineIfNew (s : Spline) (xs : List Spline) : List Spline :=
  if splineIdPresent s.stableId xs then xs else xs ++ [s]

def addTraceId (id : String) (xs : List String) : List String :=
  if containsString id xs then xs else xs ++ [id]

def commitReconstruction (store : SplineStore) (e : ReconstructionEvidence) : SplineStore :=
  let kind := reconstructionKind e
  let splines :=
    match kind with
    | .continuation => store.splines
    | .extension => appendSplineIfNew e.candidate store.splines
    | .split => appendSplineIfNew e.candidate store.splines
    | .overlap => appendSplineIfNew e.candidate store.splines
    | .sharedConnection => appendSplineIfNew e.candidate store.splines
    | .isolatedCrossing => appendSplineIfNew e.candidate store.splines
    | .overpass => appendSplineIfNew e.candidate store.splines
    | .newGeometry => appendSplineIfNew e.candidate store.splines
    | .unresolved => store.splines
  { revision := store.revision + 1
    splines := splines
    sourceTraceIds := addTraceId e.traceId store.sourceTraceIds }

theorem unresolved_commit_does_not_add_geometry
    (store : SplineStore) (e : ReconstructionEvidence)
    (h : reconstructionKind e = .unresolved) :
    (commitReconstruction store e).splines = store.splines := by
  simp [commitReconstruction, h]

theorem continuation_commit_does_not_add_geometry
    (store : SplineStore) (e : ReconstructionEvidence)
    (h : reconstructionKind e = .continuation) :
    (commitReconstruction store e).splines = store.splines := by
  simp [commitReconstruction, h]

theorem crossing_commit_keeps_candidate_separate
    (store : SplineStore) (e : ReconstructionEvidence)
    (hkind : reconstructionKind e = .isolatedCrossing)
    (hnew : ¬ splineIdPresent e.candidate.stableId store.splines = true) :
    (commitReconstruction store e).splines = store.splines ++ [e.candidate] := by
  simp [commitReconstruction, hkind, appendSplineIfNew, hnew]

structure SharedConnection where
  connectionId : String
  leftSplineId : String
  leftAtStart : Bool
  leftS : Q
  rightSplineId : String
  rightAtStart : Bool
  rightS : Q

structure SplineNetwork where
  revision : Nat
  splines : List Spline
  connections : List SharedConnection

def endpointName (splineId : String) (atStart : Bool) : String :=
  splineId ++ if atStart then ":start" else ":end"

def connectionMatches (c : SharedConnection) (sid : String) (atStart : Bool) : Bool :=
  (c.leftSplineId = sid && c.leftAtStart = atStart) ||
  (c.rightSplineId = sid && c.rightAtStart = atStart)

def resolvedEndpoint (connections : List SharedConnection)
    (sid : String) (atStart : Bool) : String :=
  match connections.find? (fun c => connectionMatches c sid atStart) with
  | some c => c.connectionId
  | none => endpointName sid atStart

def splineForwardEdge (connections : List SharedConnection) (s : Spline) : GraphEdge :=
  { edgeId := s.stableId ++ ":forward"
    splineId := s.stableId
    startS := 0
    endS := s.totalLength
    forward := true
    startVertexId := resolvedEndpoint connections s.stableId true
    endVertexId := resolvedEndpoint connections s.stableId false }

def splineReverseEdge (connections : List SharedConnection) (s : Spline) : GraphEdge :=
  { edgeId := s.stableId ++ ":reverse"
    splineId := s.stableId
    startS := s.totalLength
    endS := 0
    forward := false
    startVertexId := resolvedEndpoint connections s.stableId false
    endVertexId := resolvedEndpoint connections s.stableId true }

def splineEndpointVertices (s : Spline) : List GraphVertex :=
  [ { vertexId := endpointName s.stableId true, splineId := s.stableId, s := 0 }
  , { vertexId := endpointName s.stableId false, splineId := s.stableId,
      s := s.totalLength } ]

def connectionVertices (connections : List SharedConnection) : List GraphVertex :=
  connections.flatMap (fun c =>
    [ { vertexId := c.connectionId, splineId := c.leftSplineId, s := c.leftS }
    , { vertexId := c.connectionId, splineId := c.rightSplineId, s := c.rightS } ])

def buildRoutingGraph (network : SplineNetwork) : RoutingGraph :=
  { revision := network.revision
    splines := network.splines
    vertices := network.splines.flatMap splineEndpointVertices ++
      connectionVertices network.connections
    edges := network.splines.flatMap (fun s =>
      [ splineForwardEdge network.connections s
      , splineReverseEdge network.connections s ]) }

theorem graph_builder_preserves_spline_source (network : SplineNetwork) :
    (buildRoutingGraph network).splines = network.splines := by
  rfl

theorem graph_builder_has_two_oriented_edges (network : SplineNetwork) (s : Spline) :
    splineForwardEdge network.connections s ≠ splineReverseEdge network.connections s := by
  intro heq
  have hf : (true : Bool) = false := by
    simpa [splineForwardEdge, splineReverseEdge] using congrArg GraphEdge.forward heq
  cases hf

def closestCandidate (xs : List (String × Q × Q)) : Option (String × Q × Q) :=
  match xs with
  | [] => none
  | first :: rest =>
      match closestCandidate rest with
      | none => some first
      | some candidate =>
          if candidate.2.2 ≤ first.2.2 then some candidate else some first

def mapClosestMarker (m : Marker) (candidates : List (String × Q × Q)) :
    Option MarkerMapping :=
  match closestCandidate candidates with
  | none => none
  | some (sid, s, distanceSq) => mapMarker m sid s distanceSq

theorem closest_marker_singleton (m : Marker) (sid : String) (s distanceSq : Q) :
    mapClosestMarker m [(sid, s, distanceSq)] = mapMarker m sid s distanceSq := by
  rfl

noncomputable def mapMarkerOnSpline (m : Marker) (spline : Spline)
    (s distanceSq : Q) : Option MarkerMapping :=
  by
    classical
    exact if h : distanceSq ≤ m.toleranceSq ∧ 0 ≤ s ∧ s ≤ spline.totalLength then
      some ⟨m, spline.stableId, s, distanceSq⟩
    else none

theorem marker_mapping_rejects_out_of_interval
    (m : Marker) (spline : Spline) (s distanceSq : Q)
    (h : s < 0 ∨ spline.totalLength < s) :
    mapMarkerOnSpline m spline s distanceSq = none := by
  unfold mapMarkerOnSpline
  split
  · rename_i hg
    rcases h with hneg | hhigh
    · exact False.elim (by grind)
    · exact False.elim (by grind)
  · rfl

inductive RouteAction
  | continue
  | replan
  | failClosed
deriving DecidableEq, Repr

def routeAction (route : ActiveRoute) (graph : RoutingGraph)
    (latestRevision : Nat) (routeFound : Bool) : RouteAction :=
  if route.graphRevision = latestRevision &&
      routeEdgeSetValid route graph then .continue
  else if routeFound then .replan
  else .failClosed

theorem invalid_route_does_not_continue
    (route : ActiveRoute) (graph : RoutingGraph) (latestRevision : Nat)
    (routeFound : Bool)
    (h : ¬ (route.graphRevision = latestRevision ∧
      routeEdgeSetValid route graph = true)) :
    routeAction route graph latestRevision routeFound ≠ .continue := by
  unfold routeAction
  by_cases hrev : route.graphRevision = latestRevision
  · have hroute : routeEdgeSetValid route graph ≠ true := by
      intro hr
      exact h ⟨hrev, hr⟩
    simp [hrev, hroute]
    cases routeFound <;> simp
  · simp [hrev]
    cases routeFound <;> simp

theorem invalid_route_without_replacement_fails_closed
    (route : ActiveRoute) (graph : RoutingGraph) (latestRevision : Nat)
    (h : ¬ (route.graphRevision = latestRevision ∧
      routeEdgeSetValid route graph = true)) :
    routeAction route graph latestRevision false = .failClosed := by
  unfold routeAction
  by_cases hrev : route.graphRevision = latestRevision
  · have hroute : routeEdgeSetValid route graph ≠ true := by
      intro hr
      exact h ⟨hrev, hr⟩
    simp [hrev, hroute]
  · simp [hrev]

structure DirectedRouteMarker where
  mapping : MarkerMapping
  routeDirection : Approach

def directedMarkerValid (m : DirectedRouteMarker) : Prop :=
  approachMatches m.mapping m.routeDirection

theorem directed_marker_requires_configured_approach
    (m : DirectedRouteMarker) (h : directedMarkerValid m) :
    m.mapping.marker.configuredApproach = m.routeDirection := by
  exact h

structure FrozenProfile where
  observations : List StockObservation
  fingerprint : List ProfileFingerprint

def freezeProfile (xs : List StockObservation) : FrozenProfile :=
  { observations := xs, fingerprint := profileFingerprints xs }

def frozenProfileMatches (f : FrozenProfile) (actual : List StockObservation) : Bool :=
  f.fingerprint = profileFingerprints actual

theorem frozen_profile_detects_mutation (f : FrozenProfile) (actual : List StockObservation)
    (h : frozenProfileMatches f actual = false) :
    f.fingerprint ≠ profileFingerprints actual := by
  intro heq
  simp [frozenProfileMatches, heq] at h

def optionQOrZero : Option Q → Q
  | none => 0
  | some x => x

def physicsFromObservation (s : StockObservation) : PhysicsInput :=
  { massKg := s.weightKg
    designMassKg := s.weightKg
    velocityMps := s.speedMps
    slopeSine := 0
    slopeMultiplier := 1
    throttle := 0
    availableTractionN := optionQOrZero s.tractiveEffortN
    rollingResistanceN := 0
    directResistanceN := 0
    interferenceResistanceN := 0
    nearZeroResistanceN := 0
    trainBrake := 0
    independentBrake := 0
    trainBrakeAvailable := s.hasTrainBrake
    independentBrakeAvailable := s.hasIndependentBrake
    brakeShoeFriction := s.brakeSystemEfficiency
    configuredBrakeAdhesionEfficiency := s.brakeAdhesionEfficiency
    configuredBrakeMultiplier := s.brakeMultiplier
    cogging := s.cogging
    wheelSlip := false
    curvatureBoundN := 0
    slackBoundN := 0
    pushPullBoundN := 0 }

def profilePhysics (xs : List StockObservation) : List PhysicsInput :=
  xs.map physicsFromObservation

theorem profile_physics_preserves_order (xs : List StockObservation) :
    (profilePhysics xs).map (fun p => p.massKg) = xs.map (fun s => s.weightKg) := by
  simp [profilePhysics, physicsFromObservation]

theorem detector_profile_feeds_brake_parameters (s : StockObservation) :
    (physicsFromObservation s).brakeShoeFriction = s.brakeSystemEfficiency ∧
    (physicsFromObservation s).configuredBrakeAdhesionEfficiency =
      s.brakeAdhesionEfficiency ∧
    (physicsFromObservation s).configuredBrakeMultiplier = s.brakeMultiplier ∧
    (physicsFromObservation s).trainBrakeAvailable = s.hasTrainBrake ∧
    (physicsFromObservation s).independentBrakeAvailable = s.hasIndependentBrake := by
  exact ⟨rfl, rfl, rfl, rfl, rfl⟩

def commandConsistStep (dt : Q) (c : ConsistState)
    (cmd : ControllerCommand) : ConsistState :=
  { c with particles := c.particles.map (fun p => plantTransition dt p cmd) }

theorem command_consist_step_connects_each_particle
    (dt : Q) (c : ConsistState) (cmd : ControllerCommand) :
    (commandConsistStep dt c cmd).particles =
      c.particles.map (fun p => plantTransition dt p cmd) := by
  rfl

structure SupervisorInput where
  controller : ControllerInput
  route : ActiveRoute
  graph : RoutingGraph
  expectedProfile : FrozenProfile
  actualProfile : List StockObservation
  marker : DirectedRouteMarker
  numericBoundary : NumericBoundary
  physics : PhysicsInput
  throttleCap : Q

def supervisorGuard (i : SupervisorInput) : Prop :=
  terminalGuard (stoppingError i.controller.target)
    (directedVelocity i.controller.target) i.controller.brakeLower
    i.controller.tractiveUpper i.controller.adverseUpper i.controller.mass
    (i.controller.contract.maxSampleAge + i.controller.contract.maxCommandDelay +
      i.controller.contract.maxPressureDelay)
    i.controller.geometryError i.controller.terminalTolerance

def supervisorValid (i : SupervisorInput) : Prop :=
  routeEdgeSetValid i.route i.graph = true ∧
  frozenProfileMatches i.expectedProfile i.actualProfile = true ∧
  directedMarkerValid i.marker ∧
  numericBoundaryValid i.numericBoundary ∧
  dataContractValid i.controller ∧
  stoppingPremise i.controller.target ∧
  0 < i.throttleCap

noncomputable def supervisorCommand (i : SupervisorInput) : Option ControllerCommand :=
  by
    classical
    exact if h : supervisorValid i ∧ supervisorGuard i then
      some (stoppingCommand i.throttleCap i.controller.throttleRequest)
    else none

theorem supervisor_command_is_guarded (i : SupervisorInput) (cmd : ControllerCommand)
    (h : supervisorCommand i = some cmd) :
    ∃ _hvalid : supervisorValid i,
      terminalGuard (stoppingError i.controller.target)
        (directedVelocity i.controller.target) i.controller.brakeLower
        i.controller.tractiveUpper i.controller.adverseUpper i.controller.mass
        (i.controller.contract.maxSampleAge + i.controller.contract.maxCommandDelay +
          i.controller.contract.maxPressureDelay)
        i.controller.geometryError i.controller.terminalTolerance ∧
      cmd = stoppingCommand i.throttleCap i.controller.throttleRequest := by
  unfold supervisorCommand at h
  split at h
  · simp_all [supervisorGuard]
  · contradiction

theorem supervisor_valid_implies_controller_can_enter_stopping
    (i : SupervisorInput) (hvalid : supervisorValid i) (hguard : supervisorGuard i) :
    controllerCanEnterStopping i.controller := by
  rcases hvalid with ⟨_, _, _, _, hdata, _, _⟩
  exact ⟨hdata, hguard⟩

theorem supervisor_invalid_fails_closed (i : SupervisorInput)
    (h : ¬ supervisorValid i) : supervisorCommand i = none := by
  unfold supervisorCommand
  split
  · rename_i hg
    exact False.elim (h hg.1)
  · rfl

noncomputable def supervisorStateTransition (s : ControllerState) (i : SupervisorInput)
    (newRevision : Nat) (profileHash : String) : ControllerState :=
  by
    classical
    exact if h : newRevision ≠ s.graphRevision ∨ profileHash ≠ s.profileHash then
      { s with mode := .failClosed, graphRevision := newRevision, profileHash := profileHash }
    else if h : supervisorValid i ∧ supervisorGuard i then
      { s with mode := .stopping }
    else
      { s with mode := .failClosed }

theorem supervisor_state_refines_controller
    (s : ControllerState) (i : SupervisorInput)
    (hvalid : supervisorValid i) (hguard : supervisorGuard i) :
    (supervisorStateTransition s i s.graphRevision s.profileHash).mode = .stopping ∧
    (controllerTransition s i.controller s.graphRevision s.profileHash).mode = .stopping := by
  have hcontroller := supervisor_valid_implies_controller_can_enter_stopping i hvalid hguard
  constructor
  · simp [supervisorStateTransition, hvalid, hguard]
  · simp [controllerTransition, hcontroller]

structure CertifiedForceStep where
  before : ParticleState
  command : ControllerCommand
  dt : Q
  lowerAcceleration : Q
  massPositive : 0 < before.physics.massKg
  dtNonnegative : 0 ≤ dt
  forceBound : signedNetForceN (commandPhysics before.physics command) /
      before.physics.massKg ≤ -lowerAcceleration
  next : ParticleState
  nextIsPlant : next = plantTransition dt before command

theorem certified_force_step_velocity_bound (s : CertifiedForceStep) :
    s.next.velocityMps ≤ s.before.velocityMps - s.lowerAcceleration * s.dt := by
  have hnext : s.next = plantTransition s.dt s.before s.command := by
    exact s.nextIsPlant
  rw [hnext]
  exact plant_braking_upper s.massPositive s.dtNonnegative s.forceBound

theorem certified_force_step_refines_arrival_step (s : CertifiedForceStep) :
    s.before.positionS - s.before.velocityMps * s.dt =
      (certifiedBrakeStep s.lowerAcceleration s.dt
      ⟨s.before.positionS, s.before.velocityMps⟩).distance ∧
    s.next.velocityMps ≤
      (certifiedBrakeStep s.lowerAcceleration s.dt
        ⟨s.before.positionS, s.before.velocityMps⟩).velocity := by
  have hbound := certified_force_step_velocity_bound s
  constructor
  · rfl
  · unfold certifiedBrakeStep
    grind

def arrivalStep (a dt : Q) (s : BrakeState) : BrakeState :=
  certifiedBrakeStep a dt s

def arrivalRun (a dt : Q) : Nat → BrakeState → BrakeState
  | 0, s => s
  | n + 1, s => arrivalRun a dt n (arrivalStep a dt s)

def runCertificate (a dt : Q) : Nat → BrakeState → Prop
  | 0, s => envelope a s
  | n + 1, s =>
      envelope a s ∧
      s.velocity * dt ≤ s.distance ∧
      square (a * dt) ≤ 2 * a * s.distance - square s.velocity ∧
      runCertificate a dt n (arrivalStep a dt s)

theorem certified_run_preserves_envelope
    {a dt : Q} (ha : 0 < a) (hdt : 0 ≤ dt)
    {n : Nat} {s : BrakeState}
    (hcert : runCertificate a dt n s) :
    envelope a (arrivalRun a dt n s) := by
  induction n generalizing s with
  | zero => exact hcert
  | succ n ih =>
      have hstep := stopping_envelope_preservation ha hdt hcert.1 hcert.2.1 hcert.2.2.1
      exact ih hcert.2.2.2

theorem arrivalRun_velocity
    (a dt : Q) (n : Nat) (s : BrakeState)
    (ha : 0 ≤ a) (hdt : 0 ≤ dt) (hv : 0 ≤ s.velocity) :
    (arrivalRun a dt n s).velocity = brakeVelocity a dt n s.velocity := by
  induction n generalizing s with
  | zero =>
      grind [arrivalRun, brakeVelocity]
  | succ n ih =>
      rw [arrivalRun]
      have hvstep : 0 ≤ (arrivalStep a dt s).velocity := by
        unfold arrivalStep certifiedBrakeStep
        grind
      rw [ih (arrivalStep a dt s) hvstep]
      change max 0 (max 0 (s.velocity - a * dt) - (n : Q) * (a * dt)) =
        max 0 (s.velocity - (n.succ : Q) * (a * dt))
      by_cases hstep : 0 ≤ s.velocity - a * dt
      · have hinner : max 0 (s.velocity - a * dt) = s.velocity - a * dt := by
          simp [Rat.max_def, hstep]
        rw [hinner]
        have harg : s.velocity - a * dt - (n : Q) * (a * dt) =
            s.velocity - ((n : Q) + 1) * (a * dt) := by
          grind [Nat.succ_eq_add_one, Rat.natCast_add]
        rw [harg]
        simp [Nat.succ_eq_add_one, Rat.natCast_add]
      · have hinner : max 0 (s.velocity - a * dt) = 0 := by
          simp [Rat.max_def, hstep]
        rw [hinner]
        have hnonneg : 0 ≤ (n : Q) * (a * dt) := by
          exact Rat.mul_nonneg (by grind) (Rat.mul_nonneg ha hdt)
        have hleft : max 0 (0 - (n : Q) * (a * dt)) = 0 := by
          by_cases hz : 0 ≤ 0 - (n : Q) * (a * dt)
          · have hz0 : 0 - (n : Q) * (a * dt) = 0 := by grind
            simp [Rat.max_def, hz0]
          · simp [Rat.max_def, hz]
        rw [hleft]
        have hright : s.velocity - ((n : Q) + 1) * (a * dt) < 0 := by
          have hstep' : s.velocity < a * dt := by grind
          have hone : 0 < ((n : Q) + 1) := by grind
          have hmul : a * dt ≤ ((n : Q) + 1) * (a * dt) := by
            have hk : 0 ≤ a * dt := Rat.mul_nonneg ha hdt
            grind
          grind
        simp [Rat.max_def, Rat.not_le.mpr hright]

theorem arrival_run_reaches_zero
    {a dt v : Q} {d : Q} (ha : 0 < a) (hdt : 0 < dt) (hv : 0 ≤ v)
    {n : Nat} (hn : v ≤ n * (a * dt)) :
    (arrivalRun a dt n ⟨d, v⟩).velocity = 0 := by
  rw [arrivalRun_velocity a dt n ⟨d, v⟩ (Rat.le_of_lt ha) (Rat.le_of_lt hdt) hv]
  exact brake_velocity_zero_after ha hdt hv hn

theorem certified_run_no_crossing
    {a dt : Q} (ha : 0 < a) (hdt : 0 ≤ dt)
    {n : Nat} {s : BrakeState}
    (hcert : runCertificate a dt n s) :
    0 ≤ (arrivalRun a dt n s).distance := by
  exact (certified_run_preserves_envelope ha hdt hcert).1

structure HoldingCertificate where
  particle : ParticleState
  command : ControllerCommand
  dt : Q
  dtNonnegative : 0 ≤ dt
  massPositive : 0 < particle.physics.massKg
  zeroVelocity : particle.velocityMps = 0
  zeroForce : signedNetForceN (commandPhysics particle.physics command) = 0

theorem holding_preserves_terminal_state (h : HoldingCertificate) :
    (plantTransition h.dt h.particle h.command).positionS = h.particle.positionS ∧
    (plantTransition h.dt h.particle h.command).velocityMps = 0 := by
  change
    (h.particle.positionS + h.particle.velocityMps * h.dt = h.particle.positionS) ∧
      (h.particle.velocityMps +
        signedNetForceN (commandPhysics h.particle.physics h.command) /
          (commandPhysics h.particle.physics h.command).massKg * h.dt = 0)
  rw [h.zeroVelocity, h.zeroForce]
  rw [Rat.div_def]
  grind

def terminalState (c : RuntimeContract) (_targetS : Q) (s : BrakeState) : Prop :=
  0 ≤ s.distance ∧ s.distance ≤ c.terminalPositionTolerance ∧ s.velocity = 0

structure StableArrivalCertificate where
  contract : RuntimeContract
  target : DirectedTarget
  observations : List DirectedTarget
  nonempty : observations ≠ []
  enoughObservations : contract.stableObservations ≤ observations.length
  eachAccepted : ∀ obs, obs ∈ observations →
    absQ obs.frontCouplerVelocity ≤ contract.terminalSpeedTolerance ∧
    absQ (stoppingError obs) ≤ contract.terminalPositionTolerance
  stableSpeed : ∀ obs, obs ∈ observations → obs.frontCouplerVelocity = 0 ∨
    absQ obs.frontCouplerVelocity ≤ contract.terminalSpeedTolerance

def stableArrivalAccepted (c : StableArrivalCertificate) : Prop :=
  (c.observations.length ≥ c.contract.stableObservations) ∧
    (c.observations ≠ [])

theorem stable_arrival_has_accepted_observation
    (c : StableArrivalCertificate) :
    ∃ observation, observation ∈ c.observations ∧
      terminalAccepted c.contract observation true := by
  have hex : ∃ observation, observation ∈ c.observations := by
    cases hobs : c.observations with
    | nil => exact False.elim (c.nonempty hobs)
    | cons first rest => exact ⟨first, by simp⟩
  rcases hex with ⟨observation, hmem⟩
  have hbounds := c.eachAccepted observation hmem
  exact ⟨observation, hmem, ⟨hbounds.1, hbounds.2, rfl⟩⟩

theorem stable_arrival_certificate_is_accepted
    (c : StableArrivalCertificate) : stableArrivalAccepted c := by
  exact ⟨c.enoughObservations, c.nonempty⟩

noncomputable def supervisorPlantStep (dt : Q) (p : ParticleState)
    (i : SupervisorInput) : Option ParticleState :=
  match supervisorCommand i with
  | none => none
  | some cmd => some (plantTransition dt p cmd)

theorem supervisor_command_refines_plant
    (i : SupervisorInput) (p : ParticleState) (dt : Q) (cmd : ControllerCommand)
    (hcmd : supervisorCommand i = some cmd) :
    ∃ _hvalid : supervisorValid i,
      cmd = stoppingCommand i.throttleCap i.controller.throttleRequest ∧
      supervisorPlantStep dt p i =
        some (plantTransition dt p
          (stoppingCommand i.throttleCap i.controller.throttleRequest)) := by
  obtain ⟨hvalid, hguard, hcmd'⟩ := supervisor_command_is_guarded i cmd hcmd
  refine ⟨hvalid, hcmd', ?_⟩
  simp [supervisorPlantStep, hcmd, hcmd']

end IRProof
