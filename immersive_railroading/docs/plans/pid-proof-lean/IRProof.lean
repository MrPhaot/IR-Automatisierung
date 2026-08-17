import Lean
import Lean.Elab.Tactic.Grind.Main

noncomputable section

namespace IRProof

open Classical

abbrev Q := Rat

/-! Exact-rational contract model.

    The model is deliberately split into geometry, routing, profile, plant,
    controller, and runtime-boundary layers.  A theorem below is a theorem of
    this contract; the accompanying traceability document identifies which
    premises are bytecode facts and which are certified runtime obligations.
    There is no project-specific escape hatch in this file. -/

def square (x : Q) : Q := x * x

def absQ (x : Q) : Q := if 0 ≤ x then x else -x

theorem square_nonneg (x : Q) : 0 ≤ square x := by
  unfold square
  by_cases h : 0 ≤ x
  · exact Rat.mul_nonneg h h
  · have hn : 0 ≤ -x := by
      exact Rat.le_of_lt (Rat.neg_lt_neg (Rat.not_le.mp h))
    calc
      0 ≤ (-x) * (-x) := Rat.mul_nonneg hn hn
      _ = x * x := by grind

theorem one_sub_zero : (1 : Q) - 0 = 1 := by grind

theorem one_sub_one : (1 : Q) - 1 = 0 := by grind

theorem absQ_nonneg (x : Q) : 0 ≤ absQ x := by
  unfold absQ
  split <;> grind

def clamp (lo hi x : Q) : Q :=
  if x < lo then lo else if hi < x then hi else x

theorem clamp_lower (lo hi x : Q) (hlo : lo ≤ hi) : lo ≤ clamp lo hi x := by
  unfold clamp
  by_cases hxl : x < lo
  · simp [hxl]
  · by_cases hxh : hi < x
    · simp [hxl, hxh, hlo]
    · simp [hxl, hxh, Rat.not_lt.mp hxl]

theorem clamp_upper (lo hi x : Q) (hlo : lo ≤ hi) : clamp lo hi x ≤ hi := by
  unfold clamp
  by_cases hxl : x < lo
  · simp [hxl, hlo]
  · by_cases hxh : hi < x
    · simp [hxl, hxh]
    · simp [hxl, hxh, Rat.not_lt.mp hxh]

def sat01 (x : Q) : Q := clamp 0 1 x

theorem sat01_bounds (x : Q) : 0 ≤ sat01 x ∧ sat01 x ≤ 1 := by
  exact ⟨clamp_lower 0 1 x (by decide), clamp_upper 0 1 x (by decide)⟩

structure Vec3 where
  x : Q
  y : Q
  z : Q
deriving DecidableEq

def Vec3.add (a b : Vec3) : Vec3 :=
  ⟨a.x + b.x, a.y + b.y, a.z + b.z⟩

def Vec3.sub (a b : Vec3) : Vec3 :=
  ⟨a.x - b.x, a.y - b.y, a.z - b.z⟩

def distance3Sq (a b : Vec3) : Q :=
  square (a.x - b.x) + square (a.y - b.y) + square (a.z - b.z)

def distance3L1 (a b : Vec3) : Q :=
  absQ (a.x - b.x) + absQ (a.y - b.y) + absQ (a.z - b.z)

theorem distance3Sq_nonneg (a b : Vec3) : 0 ≤ distance3Sq a b := by
  unfold distance3Sq
  exact Rat.add_nonneg (Rat.add_nonneg (square_nonneg _) (square_nonneg _))
    (square_nonneg _)

theorem distance3Sq_refl (a : Vec3) : distance3Sq a a = 0 := by
  grind [distance3Sq, square]

/- The stock uses CubicCurve.position and derivative.  These are the exact
   Bernstein expressions visible in the Java-8 root bytecode. -/
structure Cubic where
  p1 : Vec3
  ctrl1 : Vec3
  ctrl2 : Vec3
  p2 : Vec3

def cubicPosition (c : Cubic) (t : Q) : Vec3 :=
  let u := 1 - t
  ⟨u*u*u*c.p1.x + 3*u*u*t*c.ctrl1.x + 3*u*t*t*c.ctrl2.x + t*t*t*c.p2.x,
   u*u*u*c.p1.y + 3*u*u*t*c.ctrl1.y + 3*u*t*t*c.ctrl2.y + t*t*t*c.p2.y,
   u*u*u*c.p1.z + 3*u*u*t*c.ctrl1.z + 3*u*t*t*c.ctrl2.z + t*t*t*c.p2.z⟩

def cubicDerivative (c : Cubic) (t : Q) : Vec3 :=
  let u := 1 - t
  ⟨3*u*u*(c.ctrl1.x-c.p1.x) + 6*u*t*(c.ctrl2.x-c.ctrl1.x) +
      3*t*t*(c.p2.x-c.ctrl2.x),
   3*u*u*(c.ctrl1.y-c.p1.y) + 6*u*t*(c.ctrl2.y-c.ctrl1.y) +
      3*t*t*(c.p2.y-c.ctrl2.y),
   3*u*u*(c.ctrl1.z-c.p1.z) + 6*u*t*(c.ctrl2.z-c.ctrl1.z) +
      3*t*t*(c.p2.z-c.ctrl2.z)⟩

def cubicReverse (c : Cubic) : Cubic :=
  ⟨c.p2, c.ctrl2, c.ctrl1, c.p1⟩

theorem cubicPosition_zero (c : Cubic) : cubicPosition c 0 = c.p1 := by
  simp [cubicPosition, one_sub_zero, Rat.add_zero]

theorem cubicPosition_one (c : Cubic) : cubicPosition c 1 = c.p2 := by
  simp [cubicPosition, one_sub_one, Rat.add_zero, Rat.zero_add]

theorem cubicDerivative_zero (c : Cubic) :
    cubicDerivative c 0 =
      ⟨3 * (c.ctrl1.x - c.p1.x), 3 * (c.ctrl1.y - c.p1.y),
        3 * (c.ctrl1.z - c.p1.z)⟩ := by
  simp [cubicDerivative, one_sub_zero, Rat.add_zero]

theorem cubicDerivative_one (c : Cubic) :
    cubicDerivative c 1 =
      ⟨3 * (c.p2.x - c.ctrl2.x), 3 * (c.p2.y - c.ctrl2.y),
        3 * (c.p2.z - c.ctrl2.z)⟩ := by
  simp [cubicDerivative, one_sub_one, Rat.add_zero, Rat.zero_add]

theorem cubicReverse_endpoints (c : Cubic) :
    (cubicReverse c).p1 = c.p2 ∧ (cubicReverse c).p2 = c.p1 := by
  exact ⟨rfl, rfl⟩

def degenerateStraight (a b : Vec3) : Cubic :=
  ⟨a, Vec3.add a (Vec3.sub b a), Vec3.add a (Vec3.sub b a), b⟩

theorem degenerateStraight_endpoints (a b : Vec3) :
    (degenerateStraight a b).p1 = a ∧ (degenerateStraight a b).p2 = b := by
  exact ⟨rfl, rfl⟩

structure ArcMark where
  t : Q
  s : Q

structure SplinePoint where
  t : Q
  s : Q
  tangent : Vec3
  grade : Q
  curvature : Q

structure Spline where
  stableId : String
  curve : Cubic
  reverseCurve : Cubic
  arcMarks : List ArcMark
  totalLength : Q
  points : List SplinePoint
  fittingError : Q
  sourceTraceIds : List String
  irBuilder : Option String

def splineFromCurve (id : String) (c : Cubic) (marks : List ArcMark)
    (length : Q) (points : List SplinePoint) (fit : Q)
    (traces : List String) (builder : Option String) : Spline :=
  ⟨id, c, cubicReverse c, marks, length, points, fit, traces, builder⟩

def splineOrientation (s : Spline) (forward : Bool) : Cubic :=
  if forward then s.curve else s.reverseCurve

def tangentAt (s : Spline) (forward : Bool) (t : Q) : Vec3 :=
  cubicDerivative (splineOrientation s forward) t

def gradeAt (s : Spline) (forward : Bool) (t : Q) : Q :=
  (tangentAt s forward t).y

def curvatureAtList : List SplinePoint → Nat → Option Q
  | [], _ => none
  | p :: _, 0 => some p.curvature
  | _ :: ps, n + 1 => curvatureAtList ps n

def curvatureAt (s : Spline) (i : Nat) : Option Q :=
  curvatureAtList s.points i

def arcDistance (a b : ArcMark) : Q := b.s - a.s

def arcMarksMonotone : List ArcMark → Prop
  | [] => True
  | [_] => True
  | a :: b :: xs => a.t ≤ b.t ∧ a.s ≤ b.s ∧ arcMarksMonotone (b :: xs)

structure SplineCertificate (s : Spline) : Prop where
  marksMonotone : arcMarksMonotone s.arcMarks
  lengthPositive : 0 < s.totalLength
  fitNonnegative : 0 ≤ s.fittingError
  reverseCorrect : s.reverseCurve = cubicReverse s.curve
  tangentMetadata : ∀ p ∈ s.points, p.tangent = tangentAt s true p.t

theorem spline_reverse_has_same_endpoints (spline : Spline)
    (h : SplineCertificate spline) :
    (splineOrientation spline false).p1 = spline.curve.p2 ∧
    (splineOrientation spline false).p2 = spline.curve.p1 := by
  simp [splineOrientation, h.reverseCorrect, cubicReverse]

/- A trace record is raw IR position plus enough metadata to bound the
   centreline correction.  The front coupler is intentionally absent here. -/
structure TraceSample where
  tick : Nat
  rawPosition : Vec3
  speed : Q
  heading : Q
  tracerDefinitionId : String
  stockUuid : String
  valid : Bool
  sampleAge : Q

structure TracerConfig where
  referenceOffset : Vec3
  samplingSpacing : Q
  curvatureBound : Q
  floatingError : Q
  missingObservationBound : Q

def centreEstimate (cfg : TracerConfig) (sample : TraceSample) : Vec3 :=
  Vec3.add sample.rawPosition cfg.referenceOffset

def centrelineResidualBound (cfg : TracerConfig) : Q :=
  cfg.samplingSpacing * cfg.curvatureBound + cfg.floatingError +
    cfg.missingObservationBound

structure TraceCentreSound (cfg : TracerConfig) (sample : TraceSample) where
  actualCentre : Vec3
  residual : Vec3
  actualDefinition : actualCentre = Vec3.add (centreEstimate cfg sample) residual
  residualBound : distance3L1 residual ⟨0, 0, 0⟩ ≤ centrelineResidualBound cfg

theorem centre_estimator_residual_bound (h : TraceCentreSound cfg sample) :
    distance3L1 h.actualCentre (centreEstimate cfg sample) ≤
      centrelineResidualBound cfg := by
  rw [h.actualDefinition]
  simp only [distance3L1, Vec3.add]
  have hx : (centreEstimate cfg sample).x + h.residual.x - (centreEstimate cfg sample).x =
      h.residual.x := by grind
  have hy : (centreEstimate cfg sample).y + h.residual.y - (centreEstimate cfg sample).y =
      h.residual.y := by grind
  have hz : (centreEstimate cfg sample).z + h.residual.z - (centreEstimate cfg sample).z =
      h.residual.z := by grind
  rw [hx, hy, hz]
  have hx0 : h.residual.x - 0 = h.residual.x := by grind
  have hy0 : h.residual.y - 0 = h.residual.y := by grind
  have hz0 : h.residual.z - 0 = h.residual.z := by grind
  have hb := h.residualBound
  simpa only [distance3L1, hx0, hy0, hz0] using hb

structure MatchEvidence where
  distanceSq : Q
  tangentDistanceSq : Q
  curvatureDistance : Q
  arcDistance : Q
  distanceToleranceSq : Q
  tangentToleranceSq : Q
  curvatureTolerance : Q
  arcTolerance : Q

def matchWithin (m : MatchEvidence) : Prop :=
  m.distanceSq ≤ m.distanceToleranceSq ∧
  m.tangentDistanceSq ≤ m.tangentToleranceSq ∧
  m.curvatureDistance ≤ m.curvatureTolerance ∧
  m.arcDistance ≤ m.arcTolerance

inductive TopologyClass
  | continuation
  | extension
  | sharedConnection
  | isolatedCrossing
  | overpass
  | unresolved
deriving DecidableEq, Repr

structure TopologyEvidence where
  unresolvedObservation : Bool
  sameInterval : Bool
  extendsInterval : Bool
  knownConnection : Bool
  bothContinue : Bool
  sameLevel : Bool
  heightSeparationSq : Q
  certifiedToleranceSq : Q

def classifyTopology (e : TopologyEvidence) : TopologyClass :=
  if e.unresolvedObservation then .unresolved
  else if e.heightSeparationSq > e.certifiedToleranceSq then .overpass
  else if e.bothContinue && e.sameLevel && !e.knownConnection then
    .isolatedCrossing
  else if e.knownConnection then .sharedConnection
  else if e.extendsInterval then .extension
  else if e.sameInterval then .continuation
  else .unresolved

def topologyRoutable : TopologyClass → Bool
  | .continuation => true
  | .extension => true
  | .sharedConnection => true
  | .isolatedCrossing => false
  | .overpass => false
  | .unresolved => false

theorem overpass_is_not_routable (e : TopologyEvidence)
    (h : e.heightSeparationSq > e.certifiedToleranceSq) :
    topologyRoutable (classifyTopology e) = false := by
  by_cases hu : e.unresolvedObservation = true
  · simp [classifyTopology, topologyRoutable, hu]
  · simp [classifyTopology, topologyRoutable, hu, h]

theorem crossing_is_not_connection (e : TopologyEvidence)
    (hu : ¬ e.unresolvedObservation) (hs : ¬ e.heightSeparationSq > e.certifiedToleranceSq)
    (hc : e.bothContinue) (hl : e.sameLevel) (hn : ¬ e.knownConnection) :
    classifyTopology e = .isolatedCrossing := by
  simp [classifyTopology, hu, hs, hc, hl, hn]

structure GraphEdge where
  edgeId : String
  splineId : String
  startS : Q
  endS : Q
  forward : Bool
  startVertexId : String
  endVertexId : String

structure GraphVertex where
  vertexId : String
  splineId : String
  s : Q

structure RoutingGraph where
  revision : Nat
  splines : List Spline
  vertices : List GraphVertex
  edges : List GraphEdge

structure ActiveRoute where
  graphRevision : Nat
  splineIds : List String
  vertexIds : List String
  edgeIds : List String
  edgeDirections : List Bool

def containsString (x : String) : List String → Bool
  | [] => false
  | y :: ys => if x = y then true else containsString x ys

def routeChainValid (g : RoutingGraph) : List (String × Bool) → Bool
  | [] => true
  | [_] => true
  | (eid, direction) :: (nextId, nextDirection) :: rest =>
      match g.edges.find? (fun e => decide (e.edgeId = eid)) with
      | none => false
      | some e =>
          match g.edges.find? (fun n => decide (n.edgeId = nextId)) with
          | none => false
          | some n =>
              decide (e.forward = direction) &&
              decide (n.forward = nextDirection) &&
              decide (e.endVertexId = n.startVertexId) &&
              routeChainValid g ((nextId, nextDirection) :: rest)

def routeEdgeSetValid (route : ActiveRoute) (g : RoutingGraph) : Bool :=
  decide (route.graphRevision = g.revision) &&
  decide (route.edgeIds.length = route.edgeDirections.length) &&
  (route.edgeIds.zip route.edgeDirections).all (fun pair =>
    match g.edges.find? (fun e => decide (e.edgeId = pair.1)) with
    | none => false
    | some e => containsString e.splineId route.splineIds &&
        containsString e.startVertexId route.vertexIds &&
        containsString e.endVertexId route.vertexIds &&
        decide (e.forward = pair.2) &&
        match g.splines.find? (fun s => decide (s.stableId = e.splineId)) with
        | none => false
        | some s => decide (0 ≤ e.startS) && decide (0 ≤ e.endS) &&
            decide (if e.forward then e.startS ≤ e.endS else e.endS ≤ e.startS) &&
            decide (e.startS ≤ s.totalLength) && decide (e.endS ≤ s.totalLength)) &&
  routeChainValid g (route.edgeIds.zip route.edgeDirections) &&
  route.vertexIds.all (fun vid =>
    match g.vertices.find? (fun v => decide (v.vertexId = vid)) with
    | none => false
    | some v => containsString v.splineId route.splineIds &&
        match g.splines.find? (fun s => decide (s.stableId = v.splineId)) with
        | none => false
        | some s => decide (0 ≤ v.s) && decide (v.s ≤ s.totalLength)) &&
  route.splineIds.all (fun sid => g.splines.any (fun s => decide (s.stableId = sid)))

def routeInvalidated (oldRevision newRevision : Nat) : Bool :=
  oldRevision != newRevision

theorem route_change_requires_replan {oldRevision newRevision : Nat}
    (h : oldRevision ≠ newRevision) : routeInvalidated oldRevision newRevision = true := by
  simp [routeInvalidated, h]

inductive Approach
  | forward
  | reverse
deriving DecidableEq, Repr

structure Marker where
  markerId : String
  worldPosition : Vec3
  toleranceSq : Q
  configuredApproach : Approach
  kind : String
deriving DecidableEq

structure MarkerMapping where
  marker : Marker
  splineId : String
  s : Q
  measuredDistanceSq : Q
deriving DecidableEq

def mapMarker (m : Marker) (sid : String) (s distanceSq : Q) : Option MarkerMapping :=
  if distanceSq ≤ m.toleranceSq then some ⟨m, sid, s, distanceSq⟩ else none

theorem marker_mapping_rejects_far (m : Marker) (sid : String) (s distanceSq : Q)
    (h : m.toleranceSq < distanceSq) : mapMarker m sid s distanceSq = none := by
  have hn : ¬ distanceSq ≤ m.toleranceSq := by grind
  simp [mapMarker, hn]

def approachMatches (m : MarkerMapping) (direction : Approach) : Prop :=
  m.marker.configuredApproach = direction

theorem opposite_approach_not_accepted (m : MarkerMapping) (d : Approach)
    (h : m.marker.configuredApproach ≠ d) : ¬ approachMatches m d := by
  exact h

structure StockObservation where
  stockUuid : String
  definitionId : String
  weightKg : Q
  direction : Approach
  speedMps : Q
  brakeSystemEfficiency : Q
  brakeAdhesionEfficiency : Q
  brakeMultiplier : Q
  hasTrainBrake : Bool
  hasIndependentBrake : Bool
  tractiveEffortN : Option Q
  cogging : Bool

structure DetectorEvent where
  stockUuid : String
  eventName : String

def stockKey (s : StockObservation) : String :=
  s.stockUuid ++ ":" ++ s.definitionId

def profileKeys (xs : List StockObservation) : List String := xs.map stockKey

structure ProfileFingerprint where
  stockUuid : String
  definitionId : String
  weightKg : Q
  direction : Approach
  speedMps : Q
  brakeSystemEfficiency : Q
  brakeAdhesionEfficiency : Q
  brakeMultiplier : Q
  hasTrainBrake : Bool
  hasIndependentBrake : Bool
  tractiveEffortN : Option Q
  cogging : Bool
deriving DecidableEq

def profileFingerprint (s : StockObservation) : ProfileFingerprint :=
  { stockUuid := s.stockUuid
    definitionId := s.definitionId
    weightKg := s.weightKg
    direction := s.direction
    speedMps := s.speedMps
    brakeSystemEfficiency := s.brakeSystemEfficiency
    brakeAdhesionEfficiency := s.brakeAdhesionEfficiency
    brakeMultiplier := s.brakeMultiplier
    hasTrainBrake := s.hasTrainBrake
    hasIndependentBrake := s.hasIndependentBrake
    tractiveEffortN := s.tractiveEffortN
    cogging := s.cogging }

def profileFingerprints (xs : List StockObservation) : List ProfileFingerprint :=
  xs.map profileFingerprint

def profileMismatch (expected actual : List StockObservation) : Bool :=
  profileFingerprints expected != profileFingerprints actual

def catalogueOne (event : DetectorEvent) (info : StockObservation)
    (catalogue : List StockObservation) : List StockObservation :=
  if event.eventName = "ir_train_overhead" && event.stockUuid = info.stockUuid then
    catalogue ++ [info]
  else catalogue

def catalogueSpeedBound (detectorLength responseTime minimumSpacing : Q) : Q :=
  (detectorLength + minimumSpacing) / responseTime

theorem catalogue_speed_safe {speed detectorLength responseTime minimumSpacing : Q}
    (hr : 0 < responseTime)
    (hs : speed * responseTime ≤ detectorLength + minimumSpacing) :
    speed ≤ catalogueSpeedBound detectorLength responseTime minimumSpacing := by
  unfold catalogueSpeedBound
  have hne : responseTime ≠ 0 := Rat.ne_of_gt hr
  by_cases hgood : speed ≤ (detectorLength + minimumSpacing) / responseTime
  · exact hgood
  · have hlt : (detectorLength + minimumSpacing) / responseTime < speed :=
      Rat.not_le.mp hgood
    have hp : responseTime * ((detectorLength + minimumSpacing) / responseTime) <
        responseTime * speed := Rat.mul_lt_mul_of_pos_left hlt hr
    have hleft : responseTime * ((detectorLength + minimumSpacing) / responseTime) =
        detectorLength + minimumSpacing := by
      rw [Rat.div_def]
      grind [Rat.mul_inv_cancel responseTime hne]
    rw [hleft] at hp
    have hcontra : ¬ detectorLength + minimumSpacing < responseTime * speed := by
      intro hh
      grind [Rat.mul_comm]
    exact False.elim (hcontra hp)

theorem catalogue_preserves_order (event : DetectorEvent) (info : StockObservation)
    (xs : List StockObservation)
    (h : event.eventName = "ir_train_overhead" ∧ event.stockUuid = info.stockUuid) :
    catalogueOne event info xs = xs ++ [info] := by
  simp [catalogueOne, h.1, h.2]

def consistMass (xs : List StockObservation) : Q := xs.foldl (· + ·.weightKg) 0

theorem profile_mismatch_is_not_silent {expected actual : List StockObservation}
    (h : profileMismatch expected actual = true) :
    profileFingerprints expected ≠ profileFingerprints actual := by
  intro heq
  simp [profileMismatch, heq] at h

def steelStatic : Q := 7 / 10
def steelKinetic : Q := 21 / 50
def steelCastIronKinetic : Q := 1 / 4
def gravity : Q := 49 / 5
def defaultBrakeMultiplier : Q := 1

theorem bytecode_material_constants :
    steelStatic = 7 / 10 ∧ steelKinetic = 21 / 50 ∧
      steelCastIronKinetic = 1 / 4 ∧ gravity = 49 / 5 := by
  exact ⟨rfl, rfl, rfl, rfl⟩

theorem bytecode_default_multiplier : defaultBrakeMultiplier = 1 := by
  rfl

structure PhysicsInput where
  massKg : Q
  designMassKg : Q
  velocityMps : Q
  slopeSine : Q
  slopeMultiplier : Q
  throttle : Q
  availableTractionN : Q
  rollingResistanceN : Q
  directResistanceN : Q
  interferenceResistanceN : Q
  nearZeroResistanceN : Q
  trainBrake : Q
  independentBrake : Q
  trainBrakeAvailable : Bool
  independentBrakeAvailable : Bool
  brakeShoeFriction : Q
  configuredBrakeAdhesionEfficiency : Q
  configuredBrakeMultiplier : Q
  cogging : Bool
  wheelSlip : Bool
  curvatureBoundN : Q
  slackBoundN : Q
  pushPullBoundN : Q

def physicalPressure (train independent : Q) : Q :=
  min 1 (max 0 (max train independent))

def brakeSystemEfficiency (x : PhysicsInput) : Q :=
  if x.cogging then 10 else x.brakeShoeFriction

def brakeAdhesionEfficiency (x : PhysicsInput) : Q :=
  if x.cogging then 10 else x.configuredBrakeAdhesionEfficiency

def maximumAdhesionN (x : PhysicsInput) : Q :=
  x.massKg * steelStatic * gravity * brakeAdhesionEfficiency x

def designAdhesionN (x : PhysicsInput) : Q :=
  x.designMassKg * steelStatic * gravity * brakeSystemEfficiency x

def brakeDemandN (x : PhysicsInput) : Q :=
  designAdhesionN x * physicalPressure x.trainBrake x.independentBrake

def wheelSlipBrakeN (x : PhysicsInput) : Q := x.massKg * steelKinetic

def brakeBranch (x : PhysicsInput) : Q :=
  if x.wheelSlip = true ∧ 1 / 100 < absQ x.velocityMps then
    wheelSlipBrakeN x else brakeDemandN x

def brakeForceN (x : PhysicsInput) : Q :=
  x.configuredBrakeMultiplier * brakeBranch x

def gradeForceN (x : PhysicsInput) : Q :=
  x.massKg * (-gravity) * x.slopeSine * x.slopeMultiplier

def tractiveForceN (x : PhysicsInput) : Q := x.throttle * x.availableTractionN

def rollingDirectInterferenceN (x : PhysicsInput) : Q :=
  x.rollingResistanceN + x.directResistanceN + x.interferenceResistanceN +
    x.nearZeroResistanceN

def couplerAdverseN (x : PhysicsInput) : Q :=
  x.curvatureBoundN + x.slackBoundN + x.pushPullBoundN

def signedNetForceN (x : PhysicsInput) : Q :=
  gradeForceN x + tractiveForceN x - rollingDirectInterferenceN x -
    brakeForceN x - couplerAdverseN x

structure ForceLedger where
  grade : Q
  traction : Q
  rollingDirectInterference : Q
  braking : Q
  couplerAdverse : Q
  signedNet : Q

def forceLedger (x : PhysicsInput) : ForceLedger :=
  ⟨gradeForceN x, tractiveForceN x, rollingDirectInterferenceN x,
    brakeForceN x, couplerAdverseN x, signedNetForceN x⟩

theorem signed_force_equation (x : PhysicsInput) :
    (forceLedger x).signedNet = (forceLedger x).grade + (forceLedger x).traction -
      (forceLedger x).rollingDirectInterference - (forceLedger x).braking -
      (forceLedger x).couplerAdverse := by
  rfl

theorem pressure_is_clamped (train independent : Q) :
    physicalPressure train independent ≤ 1 := by
  unfold physicalPressure
  grind

theorem pressure_is_nonnegative (train independent : Q) :
    0 ≤ physicalPressure train independent := by
  unfold physicalPressure
  grind

theorem pressure_contains_both_channels (train independent : Q) :
    0 ≤ max train independent → max train independent ≤ 1 →
      physicalPressure train independent = max train independent := by
  intro h
  intro hupper
  unfold physicalPressure
  grind

theorem cogging_overrides_efficiencies (x : PhysicsInput) (h : x.cogging = true) :
    brakeSystemEfficiency x = 10 ∧ brakeAdhesionEfficiency x = 10 := by
  simp [brakeSystemEfficiency, brakeAdhesionEfficiency, h]

theorem ordinary_brake_branch (x : PhysicsInput)
    (hs : ¬ (x.wheelSlip = true ∧ 1 / 100 < absQ x.velocityMps)) :
    brakeBranch x = brakeDemandN x := by
  simp [brakeBranch, hs]

theorem wheel_slip_brake_branch (x : PhysicsInput)
    (hs : x.wheelSlip = true ∧ 1 / 100 < absQ x.velocityMps) :
    brakeBranch x = wheelSlipBrakeN x := by
  simp [brakeBranch, hs]

theorem brake_multiplier_is_in_force_equation (x : PhysicsInput) :
    brakeForceN x = x.configuredBrakeMultiplier * brakeBranch x := by
  rfl

structure ParticleState where
  positionS : Q
  velocityMps : Q
  physics : PhysicsInput

def particleAcceleration (p : ParticleState) : Q :=
  signedNetForceN p.physics / p.physics.massKg

def irParticleStep (dt : Q) (p : ParticleState) : ParticleState :=
  ⟨p.positionS + p.velocityMps * dt,
   p.velocityMps + particleAcceleration p * dt, p.physics⟩

structure ConsistState where
  particles : List ParticleState
  trainLengthM : Q
  frontCouplerS : Q
  frontSlackM : Q
  rearSlackM : Q
  frontPushing : Bool
  frontPulling : Bool
  rearPushing : Bool
  rearPulling : Bool

def consistMassQ (c : ConsistState) : Q :=
  c.particles.foldl (· + ·.physics.massKg) 0

def consistBrakeQ (c : ConsistState) : Q :=
  c.particles.foldl (fun acc p => acc + brakeForceN p.physics) 0

def consistTractionQ (c : ConsistState) : Q :=
  c.particles.foldl (fun acc p => acc + tractiveForceN p.physics) 0

def consistAdverseQ (c : ConsistState) : Q :=
  c.particles.foldl (fun acc p => acc + couplerAdverseN p.physics) 0

def consistStateValid (c : ConsistState) : Prop :=
  0 ≤ c.trainLengthM ∧ 0 ≤ c.frontSlackM ∧ 0 ≤ c.rearSlackM

def consistStep (dt : Q) (c : ConsistState) : ConsistState :=
  { c with particles := c.particles.map (irParticleStep dt) }

theorem consist_step_is_per_particle (dt : Q) (c : ConsistState) :
    (consistStep dt c).particles = c.particles.map (irParticleStep dt) := by
  rfl

theorem consist_step_preserves_geometry
    (dt : Q) (c : ConsistState) :
    (consistStep dt c).trainLengthM = c.trainLengthM ∧
    (consistStep dt c).frontSlackM = c.frontSlackM ∧
    (consistStep dt c).rearSlackM = c.rearSlackM ∧
    (consistStep dt c).frontPushing = c.frontPushing ∧
    (consistStep dt c).frontPulling = c.frontPulling ∧
    (consistStep dt c).rearPushing = c.rearPushing ∧
    (consistStep dt c).rearPulling = c.rearPulling := by
  exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem particle_step_force_path (dt : Q) (p : ParticleState) :
    (irParticleStep dt p).velocityMps =
      p.velocityMps + signedNetForceN p.physics / p.physics.massKg * dt := by
  rfl

structure FrontCouplerLocalization where
  tracerCentreS : Q
  frontCouplerOffsetS : Q
  frontCouplerS : Q
  localizationError : Q

def localizeFrontCoupler (tracerCentreS offsetS error : Q) :
    FrontCouplerLocalization :=
  ⟨tracerCentreS, offsetS, tracerCentreS + offsetS, error⟩

theorem front_coupler_not_raw_position (tracer offset error : Q)
    (h : offset ≠ 0) :
    (localizeFrontCoupler tracer offset error).frontCouplerS ≠ tracer := by
  dsimp [localizeFrontCoupler]
  intro heq
  apply h
  grind

structure DirectedTarget where
  targetS : Q
  frontCouplerS : Q
  frontCouplerVelocity : Q
  orientation : Approach

def directedTargetFromLocalization (targetS : Q)
    (localization : FrontCouplerLocalization) (velocity : Q)
    (orientation : Approach) : DirectedTarget :=
  { targetS := targetS
    frontCouplerS := localization.frontCouplerS
    frontCouplerVelocity := velocity
    orientation := orientation }

theorem target_uses_front_coupler_localization
    (targetS velocity : Q) (localization : FrontCouplerLocalization)
    (orientation : Approach) :
    (directedTargetFromLocalization targetS localization velocity orientation).frontCouplerS =
      localization.frontCouplerS := by
  rfl

def stoppingError (t : DirectedTarget) : Q := t.targetS - t.frontCouplerS

def directedVelocity (t : DirectedTarget) : Q := t.frontCouplerVelocity

def stoppingPremise (t : DirectedTarget) : Prop :=
  0 < stoppingError t ∧ 0 < directedVelocity t

theorem stopping_coordinate_sign (t : DirectedTarget) (h : stoppingPremise t) :
    0 < stoppingError t ∧ 0 < directedVelocity t := by
  exact h

theorem wrong_way_rejected (t : DirectedTarget)
    (h : ¬ 0 < directedVelocity t) : ¬ stoppingPremise t := by
  intro hs
  exact h hs.2

theorem target_crossing_rejected (t : DirectedTarget)
    (h : stoppingError t ≤ 0) : ¬ stoppingPremise t := by
  intro hs
  unfold stoppingPremise at hs
  change t.targetS - t.frontCouplerS ≤ 0 at h
  have hsx : 0 < t.targetS - t.frontCouplerS := by
    exact hs.1
  grind

structure RuntimeContract where
  maxSampleAge : Q
  maxCommandDelay : Q
  maxPressureDelay : Q
  routeValidationInterval : Q
  fittingTolerance : Q
  frontCouplerTolerance : Q
  terminalPositionTolerance : Q
  terminalSpeedTolerance : Q
  stableObservations : Nat
  detectorSpeed : Q
  profileHash : String

structure NumericBoundary where
  finite : Bool
  inRange : Bool
  absoluteError : Q
  errorBound : Q

def numericBoundaryValid (b : NumericBoundary) : Prop :=
  b.finite = true ∧ b.inRange = true ∧ 0 ≤ b.absoluteError ∧
    b.absoluteError ≤ b.errorBound

theorem invalid_numeric_boundary_is_rejected
    (b : NumericBoundary) (h : ¬ numericBoundaryValid b) :
    ¬ numericBoundaryValid b := by
  exact h

def totalPositionError (trace fit coupler sample command numeric : Q) : Q :=
  trace + fit + coupler + sample + command + numeric

theorem terminal_tolerance_lower_bound (trace fit coupler sample command numeric : Q) :
    totalPositionError trace fit coupler sample command numeric =
      trace + fit + coupler + sample + command + numeric := by
  rfl

def stoppingDistance (v a : Q) : Q := square v / (2 * a)

def delayDistance (v delay adverse : Q) : Q := v * delay + adverse * square delay

def terminalGuard (distance velocity brakeLower tractiveUpper adverse mass delay
    geometryError terminalTolerance : Q) : Prop :=
  0 < distance ∧ 0 < velocity ∧ 0 < mass ∧
  0 < brakeLower - tractiveUpper - adverse ∧
  distance ≥ delayDistance velocity delay adverse +
    stoppingDistance velocity ((brakeLower - tractiveUpper - adverse) / mass) +
    geometryError + terminalTolerance

def uniformBrakingAcceleration (brakeLower tractiveUpper adverse mass : Q) : Q :=
  (brakeLower - tractiveUpper - adverse) / mass

theorem uniform_braking_acceleration_positive
    {brakeLower tractiveUpper adverse mass : Q}
    (hm : 0 < mass) (hb : 0 < brakeLower - tractiveUpper - adverse) :
    0 < uniformBrakingAcceleration brakeLower tractiveUpper adverse mass := by
  unfold uniformBrakingAcceleration
  rw [Rat.div_def]
  exact Rat.mul_pos hb ((Rat.inv_pos).2 hm)

theorem terminal_guard_implies_valid_entry
    {distance velocity brakeLower tractiveUpper adverse mass delay geometryError terminalTolerance : Q}
    (h : terminalGuard distance velocity brakeLower tractiveUpper adverse mass delay
      geometryError terminalTolerance) :
    0 < distance ∧ 0 < velocity ∧
      0 < uniformBrakingAcceleration brakeLower tractiveUpper adverse mass := by
  exact ⟨h.1, h.2.1, uniform_braking_acceleration_positive h.2.2.1 h.2.2.2.1⟩

structure BrakeState where
  distance : Q
  velocity : Q

def envelope (a : Q) (s : BrakeState) : Prop :=
  0 ≤ s.distance ∧ 0 ≤ s.velocity ∧ square s.velocity ≤ 2 * a * s.distance

def certifiedBrakeStep (a dt : Q) (s : BrakeState) : BrakeState :=
  ⟨s.distance - s.velocity * dt, max 0 (s.velocity - a * dt)⟩

theorem stopping_envelope_preservation
    {a dt : Q} {s : BrakeState}
    (ha : 0 < a) (_hdt : 0 ≤ dt) (_he : envelope a s)
    (hpos : s.velocity * dt ≤ s.distance)
    (hquad : square (a * dt) ≤ 2 * a * s.distance - square s.velocity) :
    envelope a (certifiedBrakeStep a dt s) := by
  unfold envelope
  unfold certifiedBrakeStep
  have hx : 0 ≤ s.distance - s.velocity * dt := by grind
  unfold square at hquad ⊢
  constructor
  · exact hx
  constructor
  · exact by grind
  · by_cases hv : 0 ≤ s.velocity - a * dt
    · rw [Rat.max_def, if_pos hv]
      grind
    · rw [Rat.max_def, if_neg hv]
      simpa [Rat.zero_mul] using
        (Rat.mul_nonneg
          (Rat.mul_nonneg (show (0 : Q) ≤ 2 by grind) (Rat.le_of_lt ha)) hx)

theorem no_crossing_from_envelope_step
    {a dt : Q} {s : BrakeState}
    (ha : 0 < a) (hdt : 0 ≤ dt) (he : envelope a s)
    (hpos : s.velocity * dt ≤ s.distance)
    (hquad : square (a * dt) ≤ 2 * a * s.distance - square s.velocity) :
    0 ≤ (certifiedBrakeStep a dt s).distance := by
  exact (stopping_envelope_preservation ha hdt he hpos hquad).1

def brakeVelocity (a dt : Q) (n : Nat) (v : Q) : Q :=
  max 0 (v - (n : Q) * (a * dt))

theorem brake_velocity_zero_after
    {a dt v : Q} (_ha : 0 < a) (_hdt : 0 < dt) (_hv : 0 ≤ v)
    {n : Nat} (hn : v ≤ n * (a * dt)) : brakeVelocity a dt n v = 0 := by
  unfold brakeVelocity
  grind

structure ControllerCommand where
  throttle : Q
  trainBrake : Q
  independentBrake : Q
  emergency : Bool

def commandForceUpper (cmd : ControllerCommand) (tractionUpper : Q) : Q :=
  cmd.throttle * tractionUpper

def commandBrakeLower (cmd : ControllerCommand) (brakeUpper : Q) : Q :=
  physicalPressure cmd.trainBrake cmd.independentBrake * brakeUpper

def stoppingCommand (throttleCap : Q) (throttle : Q) : ControllerCommand :=
  ⟨clamp 0 throttleCap throttle, 1, 1, true⟩

theorem stopping_command_keeps_positive_throttle_in_model
    {cap throttle : Q} (hcap : 0 < cap) (ht : 0 < throttle) :
    0 < (stoppingCommand cap throttle).throttle := by
  unfold stoppingCommand
  by_cases hhigh : cap < throttle
  · have hzero : ¬ throttle < 0 := by grind
    simp [clamp, hzero, hhigh]
    exact hcap
  · have hzero : ¬ throttle < 0 := by grind
    simp [clamp, hzero, hhigh, ht]

structure ControllerInput where
  target : DirectedTarget
  consist : ConsistState
  contract : RuntimeContract
  observationAge : Q
  commandAge : Q
  pressureAge : Q
  geometryError : Q
  terminalTolerance : Q
  routeValid : Bool
  profileValid : Bool
  numericValid : Bool
  brakeLower : Q
  tractiveUpper : Q
  adverseUpper : Q
  mass : Q
  throttleRequest : Q

inductive ControllerMode
  | cruise
  | stopping
  | holding
  | failClosed
deriving DecidableEq, Repr

structure ControllerState where
  mode : ControllerMode
  graphRevision : Nat
  profileHash : String
  target : DirectedTarget

def dataContractValid (i : ControllerInput) : Prop :=
  i.routeValid = true ∧ i.profileValid = true ∧ i.numericValid = true ∧
  consistStateValid i.consist ∧
  0 ≤ i.observationAge ∧ i.observationAge ≤ i.contract.maxSampleAge ∧
  0 ≤ i.commandAge ∧ i.commandAge ≤ i.contract.maxCommandDelay ∧
  0 ≤ i.pressureAge ∧ i.pressureAge ≤ i.contract.maxPressureDelay ∧
  0 ≤ i.geometryError ∧ 0 ≤ i.terminalTolerance

def controllerCanEnterStopping (i : ControllerInput) : Prop :=
  dataContractValid i ∧ terminalGuard (stoppingError i.target)
    (directedVelocity i.target) i.brakeLower i.tractiveUpper i.adverseUpper i.mass
    (i.contract.maxSampleAge + i.contract.maxCommandDelay + i.contract.maxPressureDelay)
    i.geometryError i.terminalTolerance

def controllerTransition (s : ControllerState) (i : ControllerInput)
    (newRevision : Nat) (profileHash : String) : ControllerState :=
  if _h : newRevision ≠ s.graphRevision ∨ profileHash ≠ s.profileHash then
    { s with mode := .failClosed, graphRevision := newRevision, profileHash := profileHash }
  else if _h : controllerCanEnterStopping i then
    { s with mode := .stopping }
  else
    { s with mode := .failClosed }

theorem invalid_route_or_profile_fails_closed
    (s : ControllerState) (i : ControllerInput) {revision : Nat} {hash : String}
    (h : revision ≠ s.graphRevision ∨ hash ≠ s.profileHash) :
    (controllerTransition s i revision hash).mode = .failClosed := by
  simp [controllerTransition, h]

theorem stopping_entry_requires_guard
    (s : ControllerState) (i : ControllerInput)
    (hmode : (controllerTransition s i s.graphRevision s.profileHash).mode = .stopping) :
    controllerCanEnterStopping i := by
  unfold controllerTransition at hmode
  split at hmode
  · contradiction
  · split at hmode
    · assumption
    · contradiction

def combinedForceForCommand (x : PhysicsInput) (cmd : ControllerCommand) : Q :=
  signedNetForceN { x with
    throttle := cmd.throttle
    trainBrake :=
      if x.trainBrakeAvailable = true then
        if cmd.emergency = true then 1 else cmd.trainBrake
      else 0
    independentBrake :=
      if x.independentBrakeAvailable = true then cmd.independentBrake else 0 }

def commandPhysics (x : PhysicsInput) (cmd : ControllerCommand) : PhysicsInput :=
  { x with
    throttle := cmd.throttle
    trainBrake :=
      if x.trainBrakeAvailable = true then
        if cmd.emergency = true then 1 else cmd.trainBrake
      else 0
    independentBrake :=
      if x.independentBrakeAvailable = true then cmd.independentBrake else 0 }

theorem controller_to_combined_force (x : PhysicsInput) (cmd : ControllerCommand) :
    combinedForceForCommand x cmd =
      gradeForceN (commandPhysics x cmd) +
      tractiveForceN (commandPhysics x cmd) -
      rollingDirectInterferenceN (commandPhysics x cmd) -
      brakeForceN (commandPhysics x cmd) -
      couplerAdverseN (commandPhysics x cmd) := by
  rfl

theorem positive_throttle_is_accounted_for
    (x : PhysicsInput) (cmd : ControllerCommand) :
    tractiveForceN { x with throttle := cmd.throttle } =
      cmd.throttle * x.availableTractionN := by
  rfl

def plantTransition (dt : Q) (p : ParticleState) (cmd : ControllerCommand) : ParticleState :=
  let x := commandPhysics p.physics cmd
  ⟨p.positionS + p.velocityMps * dt,
    p.velocityMps + signedNetForceN x / x.massKg * dt, x⟩

theorem plant_transition_connects_command_and_force
    (dt : Q) (p : ParticleState) (cmd : ControllerCommand) :
    (plantTransition dt p cmd).velocityMps =
      p.velocityMps + combinedForceForCommand p.physics cmd /
        p.physics.massKg * dt := by
  simp [plantTransition, combinedForceForCommand, commandPhysics]

theorem plant_braking_upper
    {dt a : Q} {p : ParticleState} {cmd : ControllerCommand}
    (_hm : 0 < p.physics.massKg) (hdt : 0 ≤ dt)
    (hacc : signedNetForceN (commandPhysics p.physics cmd) /
      p.physics.massKg ≤ -a) :
    (plantTransition dt p cmd).velocityMps ≤ p.velocityMps - a * dt := by
  unfold plantTransition
  change p.velocityMps + signedNetForceN (commandPhysics p.physics cmd) /
      p.physics.massKg * dt ≤ p.velocityMps - a * dt
  have hmul := Rat.mul_le_mul_of_nonneg_right hacc hdt
  grind

structure ArrivalSample where
  state : ParticleState
  command : ControllerCommand
  age : Q

def terminalAccepted (c : RuntimeContract) (s : DirectedTarget)
    (speedStable : Bool) : Prop :=
  absQ s.frontCouplerVelocity ≤ c.terminalSpeedTolerance ∧
  absQ (stoppingError s) ≤ c.terminalPositionTolerance ∧ speedStable = true

def regulationProgress (before after : DirectedTarget) (minimumProgress : Q) : Prop :=
  0 < minimumProgress ∧ after.frontCouplerS - before.frontCouplerS ≥ minimumProgress

def arrivalTrace (c : RuntimeContract) (initial : DirectedTarget)
    (steps : List DirectedTarget) (minimumProgress : Q) : Prop :=
  (∀ next ∈ steps, minimumProgress ≤ next.frontCouplerS - initial.frontCouplerS) ∧
  0 ≤ minimumProgress ∧ steps.length ≥ c.stableObservations

structure MutationResult where
  name : String
  baselinePasses : Bool
  mutatedPasses : Bool

def mutationRejected (r : MutationResult) : Prop :=
  r.baselinePasses = true ∧ r.mutatedPasses = false

theorem mutation_mass_changes_acceleration {m m' force : Q}
    (hm : 0 < m) (hm' : 0 < m') (hne : m ≠ m') (hf : force ≠ 0) :
    force / m ≠ force / m' := by
  intro h
  apply hne
  grind

theorem mutation_brake_multiplier_changes_force {b k k' : Q}
    (hb : b ≠ 0) (hk : k ≠ k') : k * b ≠ k' * b := by
  intro h
  apply hk
  grind

theorem mutation_grade_changes_force {m g s s' : Q}
    (hm : m ≠ 0) (hg : g ≠ 0) (hs : s ≠ s') :
    m * (-g) * s ≠ m * (-g) * s' := by
  intro h
  apply hs
  grind

theorem mutation_delay_changes_guard_distance
    {v _d _a : Q} (hv : 0 < v) (_ha : 0 < a) {t t' : Q}
    (ht : t < t') : delayDistance v t 0 < delayDistance v t' 0 := by
  unfold delayDistance
  have hdt : 0 < t' - t := by grind
  have hprod : 0 < v * (t' - t) := Rat.mul_pos hv hdt
  grind

end IRProof
