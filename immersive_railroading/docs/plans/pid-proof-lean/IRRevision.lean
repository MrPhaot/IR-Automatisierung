import IRProof

namespace IRRevision

open IRProof
open Classical

abbrev Q := Rat

/-! A source-connected revision model.

    The older files remain available as migration references, but this module
    does not treat a caller-supplied proposition as evidence that its own
    certificate is valid.  Producers below return `Option` values after
    checking their input records.  Consumers require those produced values.
    Missing physical, timing, or source data is represented by `none`, never
    by a zero-valued default. -/

structure SourceRef where
  className : String
  method : String
  branch : String
  classHash : String
  variant : String
deriving DecidableEq, Repr

def rootJava8 : SourceRef :=
  { className := "root Java-8 class"
    method := "verified root bytecode"
    branch := "root"
    classHash := "recorded in pid-jar-manifest.md"
    variant := "root-java8" }

def sourceSimulationForces : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.entity.physics.SimulationState"
    method := "forcesNewtons()"
    branch := "bytecode 0..44" }

def sourceSimulationFriction : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.entity.physics.SimulationState"
    method := "frictionNewtons()"
    branch := "bytecode 0..177" }

def sourceSimulationNext : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.entity.physics.SimulationState"
    method := "next(double,List)"
    branch := "bytecode 0..188" }

def sourceParticleVelocity : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.entity.physics.Consist$Particle"
    method := "computeVelocity(double)"
    branch := "bytecode 0..297" }

def sourceParticlePosition : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.entity.physics.Consist$Particle"
    method := "computePosition(double)"
    branch := "bytecode 0..29" }

def sourceCurvePosition : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.track.CubicCurve"
    method := "position(double)"
    branch := "Bernstein cubic" }

def sourceCurveLength : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.track.CubicCurve"
    method := "lengthWithCache(int)"
    branch := "trapezoidal derivative samples" }

def sourceDetectorInfo : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.thirdparty.opencomputers.AugmentDriver$DetectorAugment"
    method := "info()"
    branch := "delegates CommonAPI.info" }

def sourceDetectorEvent : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.thirdparty.opencomputers.AugmentDriver$AugmentManagerBase"
    method := "update()"
    branch := "ir_train_overhead" }

theorem rootJava8_variant : rootJava8.variant = "root-java8" := by
  rfl

inductive Orientation
  | forward
  | reverse
deriving DecidableEq, Repr

def opposite : Orientation → Orientation
  | .forward => .reverse
  | .reverse => .forward

/-! Geometry source and producer.  The offset is the compact tracer's stock
    reference correction, not the front coupler. -/

structure TraceObservation where
  tick : Nat
  rawPosition : Vec3
  stockUuid : String
  definitionId : String
  bogeyReferenceOffset : Vec3
  sampleAge : Q
  samplingSpacing : Q
  curvatureBound : Q
  floatingError : Q
  missingObservationBound : Q
  measuredResidual : Vec3

def zeroVec : Vec3 := ⟨0, 0, 0⟩

def traceCentre (o : TraceObservation) : Vec3 :=
  Vec3.add o.rawPosition o.bogeyReferenceOffset

def traceResidualBound (o : TraceObservation) : Q :=
  o.samplingSpacing * o.curvatureBound + o.floatingError +
    o.missingObservationBound

def traceObservationValid (o : TraceObservation) : Bool :=
  o.stockUuid != "" && o.definitionId != "" &&
    decide (0 ≤ o.sampleAge) && decide (0 ≤ o.samplingSpacing) &&
    decide (0 ≤ o.curvatureBound) && decide (0 ≤ o.floatingError) &&
    decide (0 ≤ o.missingObservationBound) &&
    decide (distance3L1 o.measuredResidual zeroVec ≤ traceResidualBound o)

def allTraceObservationsValid : List TraceObservation → Bool
  | [] => false
  | x :: xs => traceObservationValid x &&
      match xs with
      | [] => true
      | _ => allTraceObservationsValid xs

def maximumTraceBound : List TraceObservation → Option Q
  | [] => none
  | x :: xs =>
      match maximumTraceBound xs with
      | none => some (traceResidualBound x)
      | some tailBound => some (max (traceResidualBound x) tailBound)

structure SplineCandidate where
  stableId : String
  curve : Cubic
  arcMarks : List ArcMark
  totalLength : Q
  tangentSamples : List Vec3
  gradeSamples : List Q
  curvatureSamples : List Q
  fittingError : Q
  sourceTraceIds : List String
  observations : List TraceObservation
  traceParameters : List Q
  builderSource : Option SourceRef

def traceFitRowValid (curve : Cubic) (fittingError : Q)
    (o : TraceObservation) (t : Q) : Bool :=
  decide (0 ≤ t) && decide (t ≤ 1) &&
    decide (distance3L1 (traceCentre o) (cubicPosition curve t) ≤
      fittingError + traceResidualBound o)

def traceFitRowsValid (curve : Cubic) (fittingError : Q) :
    List TraceObservation → List Q → Bool
  | [], [] => true
  | o :: os, t :: ts =>
      traceFitRowValid curve fittingError o t &&
        traceFitRowsValid curve fittingError os ts
  | _, _ => false

def splineCandidateValid (c : SplineCandidate) : Bool :=
  c.stableId != "" && decide (0 < c.totalLength) &&
    decide (0 ≤ c.fittingError) && c.sourceTraceIds != [] &&
    allTraceObservationsValid c.observations &&
    traceFitRowsValid c.curve c.fittingError c.observations c.traceParameters &&
    match maximumTraceBound c.observations with
    | none => false
    | some _ => true

structure ValidatedSpline where
  candidate : SplineCandidate
  localizationError : Q
  source : SourceRef
def validatedSplineProducer (c : SplineCandidate) : Option ValidatedSpline :=
  if splineCandidateValid c then
    match maximumTraceBound c.observations with
    | none => none
    | some b =>
        some
          { candidate := c
            localizationError := c.fittingError + b
            source := sourceCurvePosition }
  else none

theorem validatedSplineProducer_candidate
    (c : SplineCandidate) (v : ValidatedSpline)
    (h : validatedSplineProducer c = some v) : v.candidate = c := by
  by_cases hv : splineCandidateValid c
  · simp [validatedSplineProducer, hv] at h
    cases hm : maximumTraceBound c.observations with
    | none => simp [hm] at h
    | some b =>
        simp [hm] at h
        cases h
        rfl
  · simp [validatedSplineProducer, hv] at h

theorem validatedSplineProducer_error
    (c : SplineCandidate) (v : ValidatedSpline)
    (h : validatedSplineProducer c = some v) :
    v.localizationError = c.fittingError +
      (match maximumTraceBound c.observations with
       | some b => b
        | none => c.fittingError) := by
  by_cases hv : splineCandidateValid c
  · simp [validatedSplineProducer, hv] at h
    cases hm : maximumTraceBound c.observations with
    | none => simp [hm] at h
    | some b =>
        simp [hm] at h
        cases h
        rfl
  · simp [validatedSplineProducer, hv] at h

theorem validated_spline_trace_fit_is_checked
    (c : SplineCandidate) (v : ValidatedSpline)
    (hsource : validatedSplineProducer c = some v) :
    traceFitRowsValid c.curve c.fittingError c.observations c.traceParameters = true := by
  have hv : splineCandidateValid c = true := by
    by_cases hvalid : splineCandidateValid c
    · exact hvalid
    · simp [validatedSplineProducer, hvalid] at hsource
  simp [splineCandidateValid] at hv
  grind

def orientedCurve (v : ValidatedSpline) : Orientation → Cubic
  | .forward => v.candidate.curve
  | .reverse => cubicReverse v.candidate.curve

def orientedLength (v : ValidatedSpline) : Orientation → Q
  | .forward => v.candidate.totalLength
  | .reverse => v.candidate.totalLength

def orientedStartS (v : ValidatedSpline) : Orientation → Q
  | .forward => 0
  | .reverse => v.candidate.totalLength

def orientedEndS (v : ValidatedSpline) : Orientation → Q
  | .forward => v.candidate.totalLength
  | .reverse => 0

def orientedStartPoint (v : ValidatedSpline) : Orientation → Vec3
  | .forward => (orientedCurve v .forward).p1
  | .reverse => (orientedCurve v .reverse).p1

def orientedEndPoint (v : ValidatedSpline) : Orientation → Vec3
  | .forward => (orientedCurve v .forward).p2
  | .reverse => (orientedCurve v .reverse).p2

def edgeCoordinate (v : ValidatedSpline) (o : Orientation) (u : Q) : Q :=
  match o with
  | .forward => u
  | .reverse => v.candidate.totalLength - u

def directedCoordinateOfParameter (v : ValidatedSpline) (o : Orientation)
    (t : Q) : Q :=
  match o with
  | .forward => t * v.candidate.totalLength
  | .reverse => (1 - t) * v.candidate.totalLength

def edgePointAt (v : ValidatedSpline) (o : Orientation) (u : Q) : Vec3 :=
  match o with
  | .forward => cubicPosition v.candidate.curve
      (u / v.candidate.totalLength)
  | .reverse => cubicPosition (cubicReverse v.candidate.curve)
      (u / v.candidate.totalLength)

theorem vec3_eq (a b : Vec3)
    (hx : a.x = b.x) (hy : a.y = b.y) (hz : a.z = b.z) : a = b := by
  cases a
  cases b
  simp_all

theorem cubic_reverse_position (c : Cubic) (t : Q) :
    cubicPosition (cubicReverse c) t = cubicPosition c (1 - t) := by
  apply vec3_eq
  · simp [cubicPosition, cubicReverse] <;> grind
  · simp [cubicPosition, cubicReverse] <;> grind
  · simp [cubicPosition, cubicReverse] <;> grind

theorem edge_point_at_parameter
    (c : SplineCandidate) (v : ValidatedSpline)
    (hsource : validatedSplineProducer c = some v)
    (o : Orientation) (t : Q) :
    edgePointAt v o (directedCoordinateOfParameter v o t) =
      cubicPosition c.curve t := by
  have hc : v.candidate = c := validatedSplineProducer_candidate c v hsource
  have hv : splineCandidateValid c = true := by
    by_cases hvalid : splineCandidateValid c
    · exact hvalid
    · simp [validatedSplineProducer, hvalid] at hsource
  have hlength : 0 < c.totalLength := by
    by_cases hlength : 0 < c.totalLength
    · exact hlength
    · have hfalse : splineCandidateValid c = false := by
        simp [splineCandidateValid, hlength]
      simp [hfalse] at hv
  have hne : c.totalLength ≠ 0 := Rat.ne_of_gt hlength
  cases o with
  | forward =>
      have hparam : t * c.totalLength / c.totalLength = t := by
        rw [Rat.div_def]
        grind [Rat.mul_inv_cancel c.totalLength hne]
      simp [edgePointAt, directedCoordinateOfParameter, hc, hparam]
  | reverse =>
      have hparam : (1 - t) * c.totalLength / c.totalLength = 1 - t := by
        rw [Rat.div_def]
        grind [Rat.mul_inv_cancel c.totalLength hne]
      simp [edgePointAt, directedCoordinateOfParameter, hc, hparam]
      rw [cubic_reverse_position]
      have hdouble : 1 - (1 - t) = t := by grind
      rw [hdouble]

structure DirectedEdge where
  edgeId : String
  splineId : String
  orientation : Orientation
  startS : Q
  endS : Q
  startPoint : Vec3
  endPoint : Vec3
  localizationError : Q
  sourceTraceIds : List String
def directedEdge (v : ValidatedSpline) (o : Orientation) : DirectedEdge :=
  { edgeId := v.candidate.stableId ++
      match o with | .forward => ":forward" | .reverse => ":reverse"
    splineId := v.candidate.stableId
    orientation := o
    startS := orientedStartS v o
    endS := orientedEndS v o
    startPoint := orientedStartPoint v o
    endPoint := orientedEndPoint v o
    localizationError := v.localizationError
    sourceTraceIds := v.candidate.sourceTraceIds }

def directedEdges (v : ValidatedSpline) : List DirectedEdge :=
  [directedEdge v .forward, directedEdge v .reverse]

def edgeIsProduced (v : ValidatedSpline) (e : DirectedEdge) : Prop :=
  e = directedEdge v .forward ∨ e = directedEdge v .reverse

/- The required nontrivial funnel theorem.  Its producer premise is an
  equality to the checked `Option` output, rather than an arbitrary validity
  proposition supplied alongside the result. -/
theorem validated_spline_to_directed_routing_edge
    (c : SplineCandidate) (v : ValidatedSpline)
    (hsource : validatedSplineProducer c = some v) (o : Orientation)
    (t eps : Q) (q : Vec3) (_hinterval : 0 ≤ t ∧ t ≤ 1)
    (hprojection : distance3L1 q (cubicPosition c.curve t) ≤ eps) :
    let e := directedEdge v o
    e.splineId = c.stableId ∧
      e.orientation = o ∧
      e.startS = orientedStartS v o ∧
      e.endS = orientedEndS v o ∧
      e.startPoint = (match o with
        | .forward => c.curve.p1
        | .reverse => c.curve.p2) ∧
      e.endPoint = (match o with
        | .forward => c.curve.p2
        | .reverse => c.curve.p1) ∧
      e.sourceTraceIds = c.sourceTraceIds ∧
      e.localizationError = c.fittingError +
        (match maximumTraceBound c.observations with
         | some b => b
         | none => c.fittingError) ∧
      edgeCoordinate v o (directedCoordinateOfParameter v o t) =
        (match o with
         | .forward => t * c.totalLength
         | .reverse => c.totalLength - ((1 - t) * c.totalLength)) ∧
      edgePointAt v o (directedCoordinateOfParameter v o t) =
        cubicPosition c.curve t ∧
      distance3L1 q (edgePointAt v o (directedCoordinateOfParameter v o t)) ≤ eps := by
  have hc : v.candidate = c := validatedSplineProducer_candidate c v hsource
  have he := validatedSplineProducer_error c v hsource
  have hp := edge_point_at_parameter c v hsource o t
  rw [hp]
  cases o <;> simp [directedEdge, orientedStartS, orientedEndS,
    orientedStartPoint, orientedEndPoint, orientedCurve, hc, he,
    edgeCoordinate, directedCoordinateOfParameter, cubicReverse]
  · exact hprojection
  · exact hprojection

theorem directed_edge_preserves_localization_error
    (c : SplineCandidate) (v : ValidatedSpline)
    (hsource : validatedSplineProducer c = some v) (o : Orientation)
    (t eps : Q) (q : Vec3) (hinterval : 0 ≤ t ∧ t ≤ 1)
    (hprojection : distance3L1 q (cubicPosition c.curve t) ≤ eps) :
    (directedEdge v o).localizationError =
      c.fittingError +
        (match maximumTraceBound c.observations with
         | some b => b
         | none => c.fittingError) := by
  have h := validated_spline_to_directed_routing_edge c v hsource o t eps q
    hinterval hprojection
  exact h.2.2.2.2.2.2.2.1

structure GraphVertex where
  vertexId : String
  splineId : String
  coordinate : Q
deriving DecidableEq, Repr

structure RoutingGraph where
  revision : Nat
  vertices : List GraphVertex
  edges : List DirectedEdge

def endpointVertices (v : ValidatedSpline) : List GraphVertex :=
  [{ vertexId := v.candidate.stableId ++ ":start"
     splineId := v.candidate.stableId
     coordinate := orientedStartS v .forward },
   { vertexId := v.candidate.stableId ++ ":end"
     splineId := v.candidate.stableId
     coordinate := orientedEndS v .forward }]

def validatedSplineIdPresent (id : String) : List ValidatedSpline → Bool
  | [] => false
  | v :: vs => v.candidate.stableId = id || validatedSplineIdPresent id vs

def routingGraphProducer (revision : Nat) (v : ValidatedSpline) : RoutingGraph :=
  { revision := revision
    vertices := endpointVertices v
    edges := directedEdges v }

def networkSplineIdPresent (id : String) : List DirectedEdge → Bool
  | [] => false
  | e :: es => e.splineId = id || networkSplineIdPresent id es

def graphNetworkProducer (revision : Nat) : List SplineCandidate →
    Option RoutingGraph
  | [] => some { revision := revision, vertices := [], edges := [] }
  | c :: cs =>
      match validatedSplineProducer c with
      | none => none
      | some v =>
          match graphNetworkProducer revision cs with
          | none => none
          | some tail =>
              if c.stableId = "" || networkSplineIdPresent c.stableId tail.edges
              then none
              else some { revision := revision, vertices := endpointVertices v ++ tail.vertices, edges := directedEdges v ++ tail.edges }

def networkEdgeProduced (cs : List SplineCandidate) (e : DirectedEdge) : Prop :=
  ∃ c v, c ∈ cs ∧ validatedSplineProducer c = some v ∧ edgeIsProduced v e

theorem graph_network_consumes_only_source_validated_splines
    (revision : Nat) :
    ∀ (cs : List SplineCandidate) (g : RoutingGraph),
      graphNetworkProducer revision cs = some g →
        ∀ e ∈ g.edges, networkEdgeProduced cs e := by
  intro cs
  induction cs with
  | nil =>
      intro g hsource e he
      simp [graphNetworkProducer] at hsource
      subst g
      simp at he
  | cons c cs ih =>
      intro g hsource e he
      cases hvalidated : validatedSplineProducer c with
      | none =>
          simp [graphNetworkProducer, hvalidated] at hsource
      | some v =>
          cases htail : graphNetworkProducer revision cs with
          | none =>
              simp [graphNetworkProducer, hvalidated, htail] at hsource
          | some tail =>
              by_cases hbad : c.stableId = "" ||
                  networkSplineIdPresent c.stableId tail.edges
              · simp [graphNetworkProducer, hvalidated, htail, hbad] at hsource
              · simp [graphNetworkProducer, hvalidated, htail, hbad] at hsource
                subst g
                simp only [List.mem_append] at he
                rcases he with he | he
                · simp [directedEdges] at he
                  rcases he with rfl | rfl
                  · exact ⟨c, v, by simp, hvalidated, Or.inl rfl⟩
                  · exact ⟨c, v, by simp, hvalidated, Or.inr rfl⟩
                · have htailEdge := ih tail htail e he
                  rcases htailEdge with ⟨d, w, hd, hsourceTail, hproduced⟩
                  exact ⟨d, w, by simp [hd], hsourceTail, hproduced⟩

theorem routing_graph_consumes_only_validated_spline
    (revision : Nat) (c : SplineCandidate) (v : ValidatedSpline)
    (hsource : validatedSplineProducer c = some v) :
    ∀ e ∈ (routingGraphProducer revision v).edges,
      edgeIsProduced v e ∧ e.splineId = c.stableId := by
  have hc : v.candidate = c := validatedSplineProducer_candidate c v hsource
  intro e he
  simp [routingGraphProducer, directedEdges] at he
  rcases he with rfl | rfl
  · exact ⟨Or.inl rfl, by simp [directedEdge, hc]⟩
  · exact ⟨Or.inr rfl, by simp [directedEdge, hc]⟩

/-! Incremental topology is computed from 3-D observations.  Projection-only
    intersection never appears in the connection predicate. -/

structure TopologyObservation where
  threeDistance : Q
  tangentDistance : Q
  curvatureDistance : Q
  arcDistance : Q
  heightSeparation : Q
  tolerance : Q
  sameLevel : Bool
  bothContinue : Bool
  knownConnection : Bool
  extendsInterval : Bool
  splitRequired : Bool
  overlapObserved : Bool
deriving DecidableEq, Repr

inductive TopologyClass
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

def topologyMatch (o : TopologyObservation) : Bool :=
  decide (o.threeDistance ≤ o.tolerance) &&
    decide (o.tangentDistance ≤ o.tolerance) &&
    decide (o.curvatureDistance ≤ o.tolerance) &&
    decide (o.arcDistance ≤ o.tolerance)

def classifyTopology (o : TopologyObservation) : TopologyClass :=
  if !topologyMatch o then .unresolved
  else if !o.sameLevel then
    if decide (o.tolerance < o.heightSeparation) then .overpass else .unresolved
  else if o.bothContinue && !o.knownConnection then .isolatedCrossing
  else if o.splitRequired then .split
  else if o.overlapObserved then .overlap
  else if o.knownConnection then .sharedConnection
  else if o.extendsInterval then .extension
  else if topologyMatch o then .continuation
  else .newGeometry

def topologyRoutable : TopologyClass → Bool
  | .isolatedCrossing => false
  | .overpass => false
  | .unresolved => false
  | _ => true

structure IncrementalStore where
  revision : Nat
  splines : List ValidatedSpline

def hasSplineId (id : String) : List ValidatedSpline → Bool
  | [] => false
  | x :: xs => x.candidate.stableId = id || hasSplineId id xs

def reconstructionCommit (store : IncrementalStore)
    (candidate : ValidatedSpline) (kind : TopologyClass) : IncrementalStore :=
  if topologyRoutable kind then
    if hasSplineId candidate.candidate.stableId store.splines then store
    else { revision := store.revision + 1
           splines := store.splines ++ [candidate] }
  else store

theorem unresolved_reconstruction_is_unavailable
    (store : IncrementalStore) (candidate : ValidatedSpline) :
    (reconstructionCommit store candidate .unresolved).splines = store.splines := by
  simp [reconstructionCommit, topologyRoutable]

theorem crossing_reconstruction_is_unavailable
    (store : IncrementalStore) (candidate : ValidatedSpline) :
    (reconstructionCommit store candidate .isolatedCrossing).splines = store.splines := by
  simp [reconstructionCommit, topologyRoutable]

structure MarkerObservation where
  markerId : String
  kind : String
  coordinate : Q
  distance : Q
  tolerance : Q
  approach : Orientation
  source : SourceRef

structure DirectedMarker where
  marker : MarkerObservation
  splineId : String
  coordinate : Q
  permittedApproach : Orientation

def directedMarkerProducer (v : ValidatedSpline) (m : MarkerObservation) :
    Option DirectedMarker :=
  if m.markerId = "" || m.coordinate < 0 ||
      v.candidate.totalLength < m.coordinate || m.distance < 0 ||
      m.tolerance < m.distance then none
  else some
    { marker := m
      splineId := v.candidate.stableId
      coordinate := m.coordinate
      permittedApproach := m.approach }

theorem marker_wrong_orientation_is_not_permitted
    (v : ValidatedSpline) (m : MarkerObservation)
    (x : DirectedMarker) (h : directedMarkerProducer v m = some x) :
    x.permittedApproach = m.approach := by
  by_cases hv : m.markerId = "" || m.coordinate < 0 ||
      v.candidate.totalLength < m.coordinate || m.distance < 0 ||
      m.tolerance < m.distance
  · simp [directedMarkerProducer, hv] at h
  · simp [directedMarkerProducer, hv] at h
    cases h
    rfl

theorem marker_maps_to_valid_spline_interval
    (v : ValidatedSpline) (m : MarkerObservation) (x : DirectedMarker)
    (h : directedMarkerProducer v m = some x) :
    x.splineId = v.candidate.stableId ∧
      0 ≤ x.coordinate ∧ x.coordinate ≤ v.candidate.totalLength ∧
      x.permittedApproach = m.approach := by
  by_cases hv : m.markerId = "" || m.coordinate < 0 ||
      v.candidate.totalLength < m.coordinate || m.distance < 0 ||
      m.tolerance < m.distance
  · simp [directedMarkerProducer, hv] at h
  · simp [directedMarkerProducer, hv] at h
    cases h
    exact ⟨rfl, by grind, by grind, rfl⟩

theorem crossing_is_separate (o : TopologyObservation)
    (h : classifyTopology o = .isolatedCrossing) :
    topologyRoutable (classifyTopology o) = false := by
  simp [h, topologyRoutable]

theorem overpass_is_separate (o : TopologyObservation)
    (h : classifyTopology o = .overpass) :
    topologyRoutable (classifyTopology o) = false := by
  simp [h, topologyRoutable]

/-! Profile boundary: dynamic `info()`, static definition/addon data, global
    configuration, and the frozen runtime profile remain separate records. -/

inductive Direction
  | forward
  | reverse
deriving DecidableEq, Repr

structure DynamicInfo where
  stockUuid : String
  definitionId : Option String
  weightKg : Option Q
  speedMps : Option Q
  direction : Option Direction
  trainBrakePosition : Option Q
  independentBrakePosition : Option Q
  tractionN : Option Q
  cogging : Option Bool
  source : SourceRef
deriving DecidableEq, Repr

structure StaticDefinition where
  definitionId : String
  designMassKg : Option Q
  brakeShoeFriction : Option Q
  brakeSystemEfficiency : Option Q
  brakeAdhesionEfficiency : Option Q
  source : SourceRef
deriving DecidableEq, Repr

structure GlobalConfiguration where
  brakeMultiplier : Option Q
  slopeMultiplier : Option Q
  rollingCoefficient : Option Q
  blockHardness : Option Q
  source : SourceRef
deriving DecidableEq, Repr

structure StockRecord where
  stockUuid : String
  definitionId : String
  weightKg : Q
  speedMps : Q
  direction : Direction
  trainBrakePosition : Q
  independentBrakePosition : Q
  tractionN : Q
  cogging : Bool
  brakeShoeFriction : Q
  brakeSystemEfficiency : Q
  brakeAdhesionEfficiency : Q
  sourceInfo : SourceRef
  sourceDefinition : SourceRef
deriving DecidableEq, Repr

def staticFor (definitionId : String) : List StaticDefinition → Option StaticDefinition
  | [] => none
  | x :: xs => if x.definitionId = definitionId then some x else staticFor definitionId xs

def stockAdapter (d : DynamicInfo) (s : StaticDefinition) : Option StockRecord :=
  match d.weightKg, d.speedMps, d.direction, d.trainBrakePosition,
    d.independentBrakePosition, d.tractionN, d.cogging,
    s.brakeShoeFriction, s.brakeSystemEfficiency, s.brakeAdhesionEfficiency with
  | some weight, some speed, some direction, some trainBrake, some independent,
      some traction, some cogging, some shoe, some efficiency, some adhesion =>
      if d.stockUuid = "" || s.definitionId = "" then none
      else some
        { stockUuid := d.stockUuid
          definitionId := s.definitionId
          weightKg := weight
          speedMps := speed
          direction := direction
          trainBrakePosition := trainBrake
          independentBrakePosition := independent
          tractionN := traction
          cogging := cogging
          brakeShoeFriction := shoe
          brakeSystemEfficiency := efficiency
          brakeAdhesionEfficiency := adhesion
          sourceInfo := d.source
          sourceDefinition := s.source }
  | _, _, _, _, _, _, _, _, _, _ => none

structure DetectorEvent where
  eventName : String
  stockUuid : String
  infoResult : Option DynamicInfo
  consistResult : Option (List StockRecord)
  source : SourceRef
deriving DecidableEq, Repr

def overheadEventName : String := "ir_train_overhead"

def consumeDetectorEvent (definitions : List StaticDefinition)
    (e : DetectorEvent) : Option StockRecord :=
  if e.eventName != overheadEventName then none
  else
    match e.infoResult with
    | none => none
    | some info =>
        match info.definitionId with
        | none => none
        | some definitionId =>
            match staticFor definitionId definitions with
            | some definition => stockAdapter info definition
            | none => none

def catalogueProducer (definitions : List StaticDefinition) :
    List DetectorEvent → Option (List StockRecord)
  | [] => some []
  | e :: es =>
      match consumeDetectorEvent definitions e, catalogueProducer definitions es with
      | some stock, some tail => some (stock :: tail)
      | _, _ => none

structure StockFingerprint where
  stockUuid : String
  definitionId : String
  weightKg : Q
  speedMps : Q
  trainBrakePosition : Q
  independentBrakePosition : Q
  tractionN : Q
  cogging : Bool
  brakeShoeFriction : Q
  brakeSystemEfficiency : Q
  brakeAdhesionEfficiency : Q
deriving DecidableEq, Repr

def profileFingerprint : List StockRecord → List StockFingerprint
  | [] => []
  | x :: xs =>
      { stockUuid := x.stockUuid
        definitionId := x.definitionId
        weightKg := x.weightKg
        speedMps := x.speedMps
        trainBrakePosition := x.trainBrakePosition
        independentBrakePosition := x.independentBrakePosition
        tractionN := x.tractionN
        cogging := x.cogging
        brakeShoeFriction := x.brakeShoeFriction
        brakeSystemEfficiency := x.brakeSystemEfficiency
        brakeAdhesionEfficiency := x.brakeAdhesionEfficiency } ::
      profileFingerprint xs

structure FrozenProfile where
  orderedStocks : List StockRecord
  fingerprint : List StockFingerprint
deriving DecidableEq, Repr

def freezeCatalogue (stocks : List StockRecord) : FrozenProfile :=
  { orderedStocks := stocks, fingerprint := profileFingerprint stocks }

def frozenProfileMatches (f : FrozenProfile) (actual : List StockRecord) : Bool :=
  f.fingerprint = profileFingerprint actual

theorem catalogue_preserves_order
    (definitions : List StaticDefinition) (event : DetectorEvent)
    (events : List DetectorEvent) (stock : StockRecord) (tail : List StockRecord)
    (hhead : consumeDetectorEvent definitions event = some stock)
    (htail : catalogueProducer definitions events = some tail) :
    catalogueProducer definitions (event :: events) = some (stock :: tail) := by
  simp [catalogueProducer, hhead, htail]

theorem invalid_profile_is_not_accepted
    (f : FrozenProfile) (actual : List StockRecord)
    (h : frozenProfileMatches f actual = false) :
    frozenProfileMatches f actual ≠ true := by
  intro htrue
  simp [h] at htrue

/-! Physics source adapter and line-by-line force ledger. -/

def steelStatic : Q := 7 / 10
def steelKinetic : Q := 21 / 50
def steelCastIronKinetic : Q := 1 / 4

structure PhysicsObservation where
  massKg : Option Q
  pitchDegrees : Option Q
  slopeMultiplier : Option Q
  tractionN : Option Q
  rollingResistanceN : Option Q
  directResistanceN : Option Q
  interferenceResistanceN : Option Q
  brakePressure : Option Q
  independentBrakePosition : Option Q
  designAdhesionN : Option Q
  maximumAdhesionN : Option Q
  brakeMultiplier : Option Q
  blockHardness : Option Q
  velocityMps : Option Q
  brakeShoeFriction : Option Q
  source : SourceRef
deriving DecidableEq, Repr

structure RuntimePhysicsInputs where
  pitchDegrees : Option Q
  designAdhesionN : Option Q
  maximumAdhesionN : Option Q
  directResistanceN : Option Q
  interferenceResistanceN : Option Q
deriving DecidableEq, Repr

def physicsObservationFromProfile (stock : StockRecord)
    (configuration : GlobalConfiguration) (runtime : RuntimePhysicsInputs) :
    Option PhysicsObservation :=
  match configuration.brakeMultiplier, configuration.slopeMultiplier,
    configuration.rollingCoefficient, configuration.blockHardness,
    runtime.pitchDegrees, runtime.designAdhesionN, runtime.maximumAdhesionN,
    runtime.directResistanceN, runtime.interferenceResistanceN with
  | some multiplier, some slope, some rolling, some hardness, some pitch,
      some designAdhesion, some maximumAdhesion, some direct, some interference =>
      some
        { massKg := some stock.weightKg
          pitchDegrees := some pitch
          slopeMultiplier := some slope
          tractionN := some stock.tractionN
          rollingResistanceN := some rolling
          directResistanceN := some direct
          interferenceResistanceN := some interference
          brakePressure := some stock.trainBrakePosition
          independentBrakePosition := some stock.independentBrakePosition
          designAdhesionN := some designAdhesion
          maximumAdhesionN := some maximumAdhesion
          brakeMultiplier := some multiplier
          blockHardness := some hardness
          velocityMps := some stock.speedMps
          brakeShoeFriction := some stock.brakeShoeFriction
          source := stock.sourceInfo }
  | _, _, _, _, _, _, _, _, _ => none

theorem missing_profile_physics_configuration_fails_closed
    (stock : StockRecord) (configuration : GlobalConfiguration)
    (runtime : RuntimePhysicsInputs)
    (h : configuration.brakeMultiplier = none ∨
      configuration.slopeMultiplier = none ∨
      configuration.rollingCoefficient = none ∨
      configuration.blockHardness = none) :
    physicsObservationFromProfile stock configuration runtime = none := by
  rcases h with h | h | h | h <;>
    simp [physicsObservationFromProfile, h]

structure PhysicsInput where
  massKg : Q
  pitchDegrees : Q
  slopeMultiplier : Q
  tractionN : Q
  rollingResistanceN : Q
  directResistanceN : Q
  interferenceResistanceN : Q
  brakePressure : Q
  independentBrakePosition : Q
  designAdhesionN : Q
  maximumAdhesionN : Q
  brakeMultiplier : Q
  blockHardness : Q
  velocityMps : Q
  brakeShoeFriction : Q
  source : SourceRef
deriving DecidableEq, Repr

def physicsAdapter (o : PhysicsObservation) : Option PhysicsInput :=
  match o.massKg, o.pitchDegrees, o.slopeMultiplier, o.tractionN,
    o.rollingResistanceN, o.directResistanceN, o.interferenceResistanceN,
    o.brakePressure, o.independentBrakePosition, o.designAdhesionN,
    o.maximumAdhesionN, o.brakeMultiplier, o.blockHardness, o.velocityMps,
    o.brakeShoeFriction with
  | some mass, some pitch, some slope, some traction, some rolling, some direct,
      some interference, some pressure, some independent, some designAdhesion,
      some maximumAdhesion, some multiplier, some hardness, some velocity,
      some shoe =>
      if mass ≤ 0 || multiplier < 0 || designAdhesion < 0 ||
          maximumAdhesion < 0 then none
      else some
        { massKg := mass
          pitchDegrees := pitch
          slopeMultiplier := slope
          tractionN := traction
          rollingResistanceN := rolling
          directResistanceN := direct
          interferenceResistanceN := interference
          brakePressure := pressure
          independentBrakePosition := independent
          designAdhesionN := designAdhesion
          maximumAdhesionN := maximumAdhesion
          brakeMultiplier := multiplier
          blockHardness := hardness
          velocityMps := velocity
          brakeShoeFriction := shoe
          source := o.source }
  | _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ => none

def physicalPressure (p : PhysicsInput) : Q :=
  min 1 (max 0 (max p.brakePressure p.independentBrakePosition))

def brakeCandidate (p : PhysicsInput) : Q :=
  p.designAdhesionN * physicalPressure p

def wheelSlipBranch (p : PhysicsInput) : Bool :=
  p.maximumAdhesionN < brakeCandidate p && 1 / 100 < absQ p.velocityMps

def brakeMaterialForce (p : PhysicsInput) : Q :=
  if wheelSlipBranch p then p.massKg * steelKinetic
  else brakeCandidate p

def gradeForce (p : PhysicsInput) : Q :=
  p.massKg * (-98 / 10) * (p.pitchDegrees / 180) * p.slopeMultiplier

def rollingForce (p : PhysicsInput) : Q :=
  p.rollingResistanceN

def interferenceForce (p : PhysicsInput) : Q :=
  p.interferenceResistanceN * 1000 * p.blockHardness

def brakeForce (p : PhysicsInput) : Q :=
  brakeMaterialForce p * p.brakeMultiplier

structure ForceLedger where
  gradeN : Q
  tractionN : Q
  rollingN : Q
  directN : Q
  interferenceN : Q
  brakeShoeCoefficient : Q
  brakeN : Q
  netN : Q
  sourceForces : SourceRef
  sourceFriction : SourceRef
deriving DecidableEq, Repr

def forceLedger (p : PhysicsInput) : ForceLedger :=
  { gradeN := gradeForce p
    tractionN := p.tractionN
    rollingN := rollingForce p
    directN := p.directResistanceN
    interferenceN := interferenceForce p
    brakeShoeCoefficient := p.brakeShoeFriction
    brakeN := brakeForce p
    netN := gradeForce p + p.tractionN -
      (rollingForce p + p.directResistanceN + interferenceForce p + brakeForce p)
    sourceForces := sourceSimulationForces
    sourceFriction := sourceSimulationFriction }

theorem force_ledger_signed_equation (p : PhysicsInput) :
    (forceLedger p).netN = gradeForce p + p.tractionN -
      ((forceLedger p).rollingN + (forceLedger p).directN +
       (forceLedger p).interferenceN + (forceLedger p).brakeN) := by
  rfl

theorem force_ledger_has_both_brake_channels (p : PhysicsInput) :
    physicalPressure p = min 1 (max 0 (max p.brakePressure p.independentBrakePosition)) := by
  rfl

theorem wheel_slip_changes_branch (p : PhysicsInput)
    (h : wheelSlipBranch p = true) :
    brakeMaterialForce p = p.massKg * steelKinetic := by
  simp [brakeMaterialForce, h]

/-! The following adapter is the normative source-shaped physics boundary.
    Its inputs are not a caller's claimed certificate: every optional field is
    populated by the detector/static definition/configuration/runtime adapter,
    and absence rejects the observation.  The field `pitchSine` is kept
    separately from the displayed pitch because the root bytecode evaluates
    `sin(toRadians(pitch))`, not the angle itself. -/

def sourceSimulationConfiguration : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.entity.physics.SimulationState$Configuration"
    method := "constructor"
    branch := "mass/adhesion/resistance/coupler configuration" }

def sourceLocomotiveBrakeEfficiency : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.entity.Locomotive"
    method := "getBrakeSystemEfficiency/getBrakeAdhesionEfficiency"
    branch := "base and cogging override" }

structure PhysicsSourceRecord where
  currentMassKg : Option Q
  designMassKg : Option Q
  pitchDegrees : Option Q
  pitchSine : Option Q
  slopeMultiplier : Option Q
  tractiveEffortN : Option Q
  rollingCoefficient : Option Q
  speedRetarderResistanceN : Option Q
  directFrictionCoefficient : Option Q
  interferenceResistance : Option Q
  blockHardness : Option Q
  brakePressure : Option Q
  independentBrakePosition : Option Q
  brakeSystemEfficiency : Option Q
  brakeAdhesionEfficiency : Option Q
  brakeMultiplier : Option Q
  velocityMps : Option Q
  brakeShoeFriction : Option Q
  cogging : Option Bool
  sourceConfiguration : SourceRef
  sourceBrakeEfficiency : SourceRef
deriving DecidableEq, Repr

structure ExactPhysicsInput where
  currentMassKg : Q
  designMassKg : Q
  pitchDegrees : Q
  pitchSine : Q
  slopeMultiplier : Q
  tractiveEffortN : Q
  rollingCoefficient : Q
  speedRetarderResistanceN : Q
  directFrictionCoefficient : Q
  interferenceResistance : Q
  blockHardness : Q
  brakePressure : Q
  independentBrakePosition : Q
  designAdhesionN : Q
  maximumAdhesionN : Q
  brakeSystemEfficiency : Q
  brakeAdhesionEfficiency : Q
  brakeMultiplier : Q
  velocityMps : Q
  brakeShoeFriction : Q
  cogging : Bool
  sourceConfiguration : SourceRef
  sourceBrakeEfficiency : SourceRef
deriving DecidableEq, Repr

structure RuntimeExactPhysicsInputs where
  pitchDegrees : Option Q
  pitchSine : Option Q
  speedRetarderResistanceN : Option Q
  directFrictionCoefficient : Option Q
  interferenceResistance : Option Q
deriving DecidableEq, Repr

def sourcePhysicsRecordFromProfile (stock : StockRecord)
    (definition : StaticDefinition) (configuration : GlobalConfiguration)
    (runtime : RuntimeExactPhysicsInputs) : Option PhysicsSourceRecord :=
  if stock.definitionId != definition.definitionId then none
  else
    match definition.designMassKg, configuration.brakeMultiplier,
      configuration.slopeMultiplier, configuration.rollingCoefficient,
      configuration.blockHardness, runtime.pitchDegrees, runtime.pitchSine,
      runtime.speedRetarderResistanceN, runtime.directFrictionCoefficient,
      runtime.interferenceResistance with
    | some designMass, some multiplier, some slope, some rolling, some hardness,
        some pitch, some pitchSine, some retarder, some directCoeff,
        some interference =>
        some
          { currentMassKg := some stock.weightKg
            designMassKg := some designMass
            pitchDegrees := some pitch
            pitchSine := some pitchSine
            slopeMultiplier := some slope
            tractiveEffortN := some stock.tractionN
            rollingCoefficient := some rolling
            speedRetarderResistanceN := some retarder
            directFrictionCoefficient := some directCoeff
            interferenceResistance := some interference
            blockHardness := some hardness
            brakePressure := some stock.trainBrakePosition
            independentBrakePosition := some stock.independentBrakePosition
            brakeSystemEfficiency := some stock.brakeSystemEfficiency
            brakeAdhesionEfficiency := some stock.brakeAdhesionEfficiency
            brakeMultiplier := some multiplier
            velocityMps := some stock.speedMps
            brakeShoeFriction := some stock.brakeShoeFriction
            cogging := some stock.cogging
            sourceConfiguration := configuration.source
            sourceBrakeEfficiency := stock.sourceDefinition }
    | _, _, _, _, _, _, _, _, _, _ => none

theorem source_profile_physics_requires_definition_match
    (stock : StockRecord) (definition : StaticDefinition)
    (configuration : GlobalConfiguration) (runtime : RuntimeExactPhysicsInputs)
    (h : stock.definitionId ≠ definition.definitionId) :
    sourcePhysicsRecordFromProfile stock definition configuration runtime = none := by
  simp [sourcePhysicsRecordFromProfile, h]

theorem source_profile_physics_preserves_mass_and_channels
    (stock : StockRecord) (definition : StaticDefinition)
    (configuration : GlobalConfiguration) (runtime : RuntimeExactPhysicsInputs)
    (r : PhysicsSourceRecord)
    (h : sourcePhysicsRecordFromProfile stock definition configuration runtime = some r) :
    r.currentMassKg = some stock.weightKg ∧
      r.tractiveEffortN = some stock.tractionN ∧
      r.brakePressure = some stock.trainBrakePosition ∧
      r.independentBrakePosition = some stock.independentBrakePosition := by
  by_cases hmatch : stock.definitionId = definition.definitionId
  · simp [sourcePhysicsRecordFromProfile, hmatch] at h
    split at h <;> simp_all
    cases h
    exact ⟨rfl, rfl, rfl, rfl⟩
  · simp [sourcePhysicsRecordFromProfile, hmatch] at h

def sourcePhysicsAdapter (r : PhysicsSourceRecord) : Option ExactPhysicsInput :=
  match r.currentMassKg, r.designMassKg, r.pitchDegrees, r.pitchSine,
    r.slopeMultiplier, r.tractiveEffortN, r.rollingCoefficient,
    r.speedRetarderResistanceN, r.directFrictionCoefficient,
    r.interferenceResistance, r.blockHardness, r.brakePressure,
    r.independentBrakePosition, r.brakeSystemEfficiency,
    r.brakeAdhesionEfficiency, r.brakeMultiplier, r.velocityMps,
    r.brakeShoeFriction, r.cogging with
  | some currentMass, some designMass, some pitch, some pitchSine,
      some slope, some traction, some rolling, some retarder, some directCoeff,
      some interference, some hardness, some pressure, some independent,
      some brakeEfficiency, some adhesionEfficiency, some multiplier,
      some velocity, some shoe, some cogging =>
      if currentMass ≤ 0 || designMass ≤ 0 || rolling < 0 || retarder < 0 ||
          directCoeff < 0 || interference < 0 || hardness < 0 ||
          brakeEfficiency < 0 || adhesionEfficiency < 0 || multiplier < 0 ||
          shoe < 0 then none
      else some
        { currentMassKg := currentMass
          designMassKg := designMass
          pitchDegrees := pitch
          pitchSine := pitchSine
          slopeMultiplier := slope
          tractiveEffortN := traction
          rollingCoefficient := rolling
          speedRetarderResistanceN := retarder
          directFrictionCoefficient := directCoeff
          interferenceResistance := interference
          blockHardness := hardness
          brakePressure := pressure
          independentBrakePosition := independent
          designAdhesionN := designMass * steelStatic * (98 / 10) * brakeEfficiency
          maximumAdhesionN := currentMass * steelStatic * (98 / 10) * adhesionEfficiency
          brakeSystemEfficiency := brakeEfficiency
          brakeAdhesionEfficiency := adhesionEfficiency
          brakeMultiplier := multiplier
          velocityMps := velocity
          brakeShoeFriction := shoe
          cogging := cogging
          sourceConfiguration := r.sourceConfiguration
          sourceBrakeEfficiency := r.sourceBrakeEfficiency }
  | _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ => none

def exactPressure (p : ExactPhysicsInput) : Q :=
  min 1 (max p.brakePressure p.independentBrakePosition)

def exactBrakeCandidate (p : ExactPhysicsInput) : Q :=
  exactPressure p * p.designAdhesionN

def exactWheelSlip (p : ExactPhysicsInput) : Bool :=
  p.maximumAdhesionN < exactBrakeCandidate p && 1 / 100 < absQ p.velocityMps

def exactBrakeMaterial (p : ExactPhysicsInput) : Q :=
  if exactWheelSlip p then p.currentMassKg * steelKinetic
  else exactBrakeCandidate p

def exactRollingResistance (p : ExactPhysicsInput) : Q :=
  p.rollingCoefficient * p.currentMassKg * (98 / 10)

def exactNearZeroResistance (p : ExactPhysicsInput) : Q :=
  if p.velocityMps = 0 then (1 / 1000) * p.currentMassKg * (98 / 10) else 0

def exactDirectResistance (p : ExactPhysicsInput) : Q :=
  p.speedRetarderResistanceN +
    p.directFrictionCoefficient * p.independentBrakePosition *
      p.currentMassKg * (98 / 10) +
    p.directFrictionCoefficient * p.brakePressure *
      p.currentMassKg * (98 / 10)

def exactInterferenceResistance (p : ExactPhysicsInput) : Q :=
  p.interferenceResistance * 1000 * p.blockHardness

def exactGradeForce (p : ExactPhysicsInput) : Q :=
  p.currentMassKg * (-98 / 10) * p.pitchSine * p.slopeMultiplier

def exactBrakeForce (p : ExactPhysicsInput) : Q :=
  p.brakeMultiplier * exactBrakeMaterial p

structure ExactForceLedger where
  gradeN : Q
  tractionN : Q
  rollingN : Q
  nearZeroN : Q
  directN : Q
  interferenceN : Q
  brakeCandidateN : Q
  brakeN : Q
  netN : Q
  sourceForces : SourceRef
  sourceFriction : SourceRef
  sourceParticle : SourceRef
deriving DecidableEq, Repr

def exactForceLedger (p : ExactPhysicsInput) : ExactForceLedger :=
  { gradeN := exactGradeForce p
    tractionN := p.tractiveEffortN
    rollingN := exactRollingResistance p
    nearZeroN := exactNearZeroResistance p
    directN := exactDirectResistance p
    interferenceN := exactInterferenceResistance p
    brakeCandidateN := exactBrakeCandidate p
    brakeN := exactBrakeForce p
    netN := exactGradeForce p + p.tractiveEffortN -
      (exactRollingResistance p + exactNearZeroResistance p +
       exactDirectResistance p + exactInterferenceResistance p +
       exactBrakeForce p)
    sourceForces := sourceSimulationForces
    sourceFriction := sourceSimulationFriction
    sourceParticle := sourceParticleVelocity }

theorem source_physics_adapter_requires_runtime_fields
    (r : PhysicsSourceRecord)
    (h : r.currentMassKg = none ∨ r.pitchSine = none ∨
      r.rollingCoefficient = none ∨ r.directFrictionCoefficient = none ∨
      r.brakeMultiplier = none ∨ r.velocityMps = none) :
    sourcePhysicsAdapter r = none := by
  rcases h with h | h | h | h | h | h <;>
    simp [sourcePhysicsAdapter, h]

theorem source_force_ledger_equation (p : ExactPhysicsInput) :
    (exactForceLedger p).netN = exactGradeForce p + p.tractiveEffortN -
      ((exactForceLedger p).rollingN + (exactForceLedger p).nearZeroN +
       (exactForceLedger p).directN + (exactForceLedger p).interferenceN +
       (exactForceLedger p).brakeN) := by
  rfl

theorem source_wheel_slip_changes_branch (p : ExactPhysicsInput)
    (h : exactWheelSlip p = true) :
    exactBrakeMaterial p = p.currentMassKg * steelKinetic := by
  simp [exactBrakeMaterial, h]

/-! Front-coupler localization is downstream of the stock definition and
    selected orientation; raw entity position is never used as the target. -/

structure CouplerGeometry where
  stockPosition : Vec3
  frontOffsetForward : Vec3
  frontOffsetReverse : Vec3
  orientation : Orientation
  source : SourceRef
def frontCouplerPosition (g : CouplerGeometry) : Vec3 :=
  match g.orientation with
  | .forward => Vec3.add g.stockPosition g.frontOffsetForward
  | .reverse => Vec3.add g.stockPosition g.frontOffsetReverse

structure DirectedLocalization where
  splineId : String
  frontCouplerS : Q
  errorBound : Q
  orientation : Orientation
  source : SourceRef
deriving DecidableEq, Repr

def frontCouplerError (targetS : Q) (l : DirectedLocalization) : Q :=
  targetS - l.frontCouplerS

def directedVelocity (l : DirectedLocalization) (velocity : Q) : Q :=
  match l.orientation with
  | .forward => velocity
  | .reverse => -velocity

theorem target_uses_front_coupler (targetS : Q) (l : DirectedLocalization) :
    frontCouplerError targetS l = targetS - l.frontCouplerS := by
  rfl

theorem reverse_velocity_is_reversed (l : DirectedLocalization) (v : Q) :
    l.orientation = .reverse → directedVelocity l v = -v := by
  intro h
  cases l.orientation <;> simp_all [directedVelocity]

structure CouplerDefinition where
  frontOffsetForwardS : Option Q
  frontOffsetReverseS : Option Q
  rearOffsetForwardS : Option Q
  rearOffsetReverseS : Option Q
  slackForwardS : Option Q
  slackReverseS : Option Q
  source : SourceRef
deriving DecidableEq, Repr

def couplerGeometryProducer (d : CouplerDefinition) (o : Orientation) :
    Option (Q × Q) :=
  match o, d.frontOffsetForwardS, d.frontOffsetReverseS,
    d.rearOffsetForwardS, d.rearOffsetReverseS, d.slackForwardS,
    d.slackReverseS with
  | .forward, some front, some _, some rear, some _, some slack, some _ =>
      if 0 ≤ slack then some (front, rear) else none
  | .reverse, some _, some front, some _, some rear, some _, some slack =>
      if 0 ≤ slack then some (front, rear) else none
  | _, _, _, _, _, _, _ => none

def frontCouplerLocalizationProducer (v : ValidatedSpline)
    (d : CouplerDefinition) (centreS centreError : Q) (o : Orientation) :
    Option DirectedLocalization :=
  if centreS < 0 || v.candidate.totalLength < centreS || centreError < 0 then none
  else
    match couplerGeometryProducer d o with
    | none => none
    | some (front, _) =>
        some
          { splineId := v.candidate.stableId
            frontCouplerS := edgeCoordinate v o centreS + front
            errorBound := v.localizationError + centreError
            orientation := o
            source := d.source }

theorem coupler_localization_consumes_validated_spline
    (c : SplineCandidate) (v : ValidatedSpline)
    (hsource : validatedSplineProducer c = some v)
    (d : CouplerDefinition) (centreS centreError : Q) (o : Orientation)
    (l : DirectedLocalization)
    (h : frontCouplerLocalizationProducer v d centreS centreError o = some l) :
    l.splineId = c.stableId ∧ l.orientation = o ∧
      l.errorBound = v.localizationError + centreError := by
  have hc : v.candidate = c := validatedSplineProducer_candidate c v hsource
  by_cases hbad : centreS < 0 || v.candidate.totalLength < centreS || centreError < 0
  · simp [frontCouplerLocalizationProducer, hbad] at h
  · cases ho : couplerGeometryProducer d o with
    | none => simp [frontCouplerLocalizationProducer, hbad, ho] at h
    | some pair =>
        simp [frontCouplerLocalizationProducer, hbad, ho] at h
        cases h
        exact ⟨by simp [hc], by rfl, by rfl⟩

/-! Controller and source-shaped plant transition. -/

structure ControllerCommand where
  throttle : Q
  trainBrake : Q
  independentBrake : Q
  emergency : Bool
  commandAge : Q
  pressureAge : Q
deriving DecidableEq, Repr

def commandValid (c : ControllerCommand) : Bool :=
  decide (0 ≤ c.throttle) && decide (c.throttle ≤ 1) &&
    decide (0 ≤ c.trainBrake) && decide (c.trainBrake ≤ 1) &&
    decide (0 ≤ c.independentBrake) && decide (c.independentBrake ≤ 1) &&
    decide (0 ≤ c.commandAge) && decide (0 ≤ c.pressureAge)

def combinedThrottle (c : ControllerCommand) (availableTractionN : Q) : Q :=
  c.throttle * availableTractionN

def combinedBrakePressure (c : ControllerCommand) : Q :=
  min 1 (max 0 (max c.trainBrake c.independentBrake))

def sourceCommandPath : SourceRef :=
  { rootJava8 with
    className := "cam72cam.immersiverailroading.thirdparty.CommonAPI"
    method := "setThrottle/setTrainBrake/setIndependentBrake"
    branch := "normalize then locomotive setter" }

def commandPhysics (p : PhysicsInput) (c : ControllerCommand) : Option ForceLedger :=
  if commandValid c then
    some (forceLedger
      { p with
        tractionN := combinedThrottle c p.tractionN
        brakePressure := c.trainBrake
        independentBrakePosition := c.independentBrake })
  else none

structure ParticleState where
  positionS : Q
  velocityMps : Q
  massKg : Q
  forceN : Q
  frictionN : Q
  direction : Direction
  slackBound : Q
  pushPullBound : Q
  source : SourceRef
deriving DecidableEq, Repr

def particleAcceleration (p : ParticleState) : Q :=
  (p.forceN - p.frictionN - p.slackBound - p.pushPullBound) / p.massKg

def particleStep (dt : Q) (p : ParticleState) : ParticleState :=
  let a := particleAcceleration p
  { p with
    positionS := p.positionS + (p.velocityMps + a * dt) * dt
    velocityMps := p.velocityMps + a * dt }

def rootNextBranch (before after : ParticleState) : ParticleState :=
  if after.positionS = before.positionS then { after with velocityMps := 0 } else after

def plantTransition (dt : Q) (p : ParticleState) (physics : PhysicsInput)
    (c : ControllerCommand) :
    Option ParticleState :=
  match commandPhysics physics c with
  | none => none
  | some ledger =>
      let commanded :=
        { p with
          forceN := ledger.netN
          frictionN := ledger.rollingN + ledger.directN +
            ledger.interferenceN + ledger.brakeN }
      some (rootNextBranch p (particleStep dt commanded))

def exactCommandPhysics (p : ExactPhysicsInput) (c : ControllerCommand) :
    Option ExactForceLedger :=
  if commandValid c then
    some (exactForceLedger
      { p with
        tractiveEffortN := combinedThrottle c p.tractiveEffortN
        brakePressure := c.trainBrake
        independentBrakePosition := c.independentBrake })
  else none

def exactPlantTransition (dt : Q) (p : ParticleState)
    (physics : ExactPhysicsInput) (c : ControllerCommand) :
    Option ParticleState :=
  if commandValid c then
    let ledger := exactForceLedger
      { physics with
        tractiveEffortN := combinedThrottle c physics.tractiveEffortN
        brakePressure := c.trainBrake
        independentBrakePosition := c.independentBrake }
    let commanded :=
      { p with
        forceN := ledger.netN
        frictionN := ledger.rollingN + ledger.nearZeroN + ledger.directN +
          ledger.interferenceN + ledger.brakeN }
    some (rootNextBranch p (particleStep dt commanded))
  else none

def exactPlantResult (dt : Q) (p : ParticleState)
    (physics : ExactPhysicsInput) (c : ControllerCommand) : Option ParticleState :=
  exactPlantTransition dt p physics c

theorem exact_plant_rejects_invalid_command
    (dt : Q) (p : ParticleState) (physics : ExactPhysicsInput)
    (c : ControllerCommand) (h : commandValid c = false) :
    exactPlantResult dt p physics c = (none : Option ParticleState) := by
  simp [exactPlantResult, exactPlantTransition, h]

theorem exact_plant_has_source_next_state
    (dt : Q) (p : ParticleState) (physics : ExactPhysicsInput)
    (c : ControllerCommand) (h : commandValid c = true) :
    ∃ next : ParticleState, exactPlantResult dt p physics c = some next := by
  simp [exactPlantResult, exactPlantTransition, h]

/-! Source-shaped consist state.  The list is deliberately explicit: no
    scalar mass replacement can erase the per-particle linkage decisions.
    `sourceParticleTransition` follows the source order: select an
    interaction summary, cap friction against force direction, update all
    selected particles by the common acceleration, then apply linkage
    correction.  The remaining collision/track result is retained as a
    runtime observation in the input rather than silently defaulted. -/

structure LinkageState where
  canPull : Bool
  canPush : Bool
  currentDistance : Q
  minimumDistance : Q
  slackPercent : Q
  collisionObserved : Bool
  source : SourceRef
deriving DecidableEq, Repr

structure SourceParticleInput where
  state : ParticleState
  interactingMassKg : Q
  interactingFrictionN : Q
  previousLink : Option LinkageState
  nextLink : Option LinkageState
  trackTransitionObserved : Bool
  source : SourceRef
deriving DecidableEq, Repr

def linkageUsable (l : LinkageState) : Bool :=
  decide (0 ≤ l.currentDistance) && decide (0 ≤ l.minimumDistance) &&
    decide (0 ≤ l.slackPercent)

def sourceInteractionEnabled (p : SourceParticleInput) : Bool :=
  match decide (p.state.forceN < 0), p.previousLink, p.nextLink with
  | true, some prev, some next => prev.canPull || next.canPull
  | true, some prev, none => prev.canPull
  | true, none, some next => next.canPull
  | true, none, none => true
  | false, some prev, some next => prev.canPush || next.canPush
  | false, some prev, none => prev.canPush
  | false, none, some next => next.canPush
  | false, none, none => true

def sourceFrictionApplied (p : SourceParticleInput) : Q :=
  if sourceInteractionEnabled p then
    min (absQ p.state.forceN) p.interactingFrictionN
  else 0

def linkageCorrectedPosition (position : Q) (link : Option LinkageState) : Q :=
  match link with
  | none => position
  | some l => if l.currentDistance < l.minimumDistance then
      position + (l.minimumDistance - l.currentDistance) else position

def sourceParticleTransition (dt : Q) (p : SourceParticleInput) :
    Option ParticleState :=
  if p.state.massKg ≤ 0 || p.interactingMassKg ≤ 0 ||
      (match p.previousLink with | some l => !linkageUsable l | none => false) ||
      (match p.nextLink with | some l => !linkageUsable l | none => false) then none
  else
    let friction := sourceFrictionApplied p
    let signedFriction :=
      if p.state.forceN < 0 then -friction else friction
    let acceleration := (p.state.forceN - signedFriction) / p.interactingMassKg
    let moved :=
      { p.state with
        positionS := p.state.positionS + p.state.velocityMps * dt
        velocityMps := p.state.velocityMps + acceleration * dt
        frictionN := friction }
    some { moved with
      positionS := linkageCorrectedPosition moved.positionS p.previousLink }

def sourceConsistTransition (dt : Q) : List SourceParticleInput →
    Option (List ParticleState)
  | [] => some []
  | p :: ps =>
      match sourceParticleTransition dt p, sourceConsistTransition dt ps with
      | some next, some tail => some (next :: tail)
      | _, _ => none

theorem source_particle_transition_rejects_bad_linkage
    (dt : Q) (p : SourceParticleInput)
    (h : (match p.previousLink with
      | some l => !linkageUsable l
      | none => false) = true) :
    sourceParticleTransition dt p = none := by
  simp [sourceParticleTransition, h]

theorem source_particle_transition_has_next_state
    (dt : Q) (p : SourceParticleInput)
    (hmass : 0 < p.state.massKg) (hinteraction : 0 < p.interactingMassKg)
    (hprev : ∀ l, p.previousLink = some l → linkageUsable l = true)
    (hnext : ∀ l, p.nextLink = some l → linkageUsable l = true) :
    ∃ next, sourceParticleTransition dt p = some next := by
  have hbadprev : (match p.previousLink with
      | some l => !linkageUsable l
      | none => false) = false := by
    cases hp : p.previousLink with
    | none => rfl
    | some l => simp [hprev l hp]
  have hbadnext : (match p.nextLink with
      | some l => !linkageUsable l
      | none => false) = false := by
    cases hp : p.nextLink with
    | none => rfl
    | some l => simp [hnext l hp]
  unfold sourceParticleTransition
  have hm : ¬ p.state.massKg ≤ 0 := Rat.not_le.mpr hmass
  have hi : ¬ p.interactingMassKg ≤ 0 := Rat.not_le.mpr hinteraction
  simp [hm, hi, hbadprev, hbadnext]

theorem plant_transition_rejects_invalid_command
    (dt : Q) (p : ParticleState) (physics : PhysicsInput)
    (c : ControllerCommand) (h : commandValid c = false) :
    plantTransition dt p physics c = none := by
  have hcp : commandPhysics physics c = none := by
    simp [commandPhysics, h]
  unfold plantTransition
  rw [hcp]

theorem plant_transition_has_actual_next_state
    (dt : Q) (p : ParticleState) (physics : PhysicsInput)
    (c : ControllerCommand) (h : commandValid c = true) :
    ∃ next, plantTransition dt p physics c = some next := by
  have hcp : commandPhysics physics c ≠ none := by
    simp [commandPhysics, h]
  unfold plantTransition
  cases hc : commandPhysics physics c with
  | none => exact False.elim (hcp hc)
  | some ledger => exact ⟨_, rfl⟩

/-! Runtime numeric and timing boundaries are explicit producers. -/

inductive RawNumber
  | finite (value : Q)
  | nan
  | positiveInfinity
  | negativeInfinity
deriving DecidableEq, Repr

structure NumericCertificate where
  raw : RawNumber
  normalized : Q
  lower : Q
  upper : Q
  enclosureError : Q
  source : SourceRef
deriving DecidableEq, Repr

def numericConvert (lower upper : Q) (raw : RawNumber) : Option NumericCertificate :=
  match raw with
  | .finite value =>
      if lower ≤ upper then
        let normalized := min upper (max lower value)
        some
          { raw := raw
            normalized := normalized
            lower := lower
            upper := upper
            enclosureError := absQ (normalized - value)
            source := sourceCommandPath }
      else none
  | .nan => none
  | .positiveInfinity => none
  | .negativeInfinity => none

theorem invalid_numeric_input_fails_closed (lo hi : Q) (raw : RawNumber)
    (h : raw = .nan ∨ raw = .positiveInfinity ∨ raw = .negativeInfinity) :
    numericConvert lo hi raw = none := by
  rcases h with rfl | rfl | rfl <;> rfl

structure RawControllerCommand where
  throttle : RawNumber
  trainBrake : RawNumber
  independentBrake : RawNumber
  commandAge : RawNumber
  pressureAge : RawNumber
deriving DecidableEq, Repr

def nonnegativeRaw (raw : RawNumber) : Option Q :=
  match raw with
  | .finite value => if 0 ≤ value then some value else none
  | .nan => none
  | .positiveInfinity => none
  | .negativeInfinity => none

def apiCommandProducer (raw : RawControllerCommand) :
    Option (ControllerCommand × SourceRef) :=
  match numericConvert 0 1 raw.throttle,
    numericConvert 0 1 raw.trainBrake,
    numericConvert 0 1 raw.independentBrake,
    nonnegativeRaw raw.commandAge, nonnegativeRaw raw.pressureAge with
  | some throttle, some trainBrake, some independent, some commandAge,
      some pressureAge =>
      let candidate : ControllerCommand :=
        { throttle := throttle.normalized
          trainBrake := trainBrake.normalized
          independentBrake := independent.normalized
          emergency := false
          commandAge := commandAge
          pressureAge := pressureAge }
      if commandValid candidate then some (candidate, sourceCommandPath) else none
  | _, _, _, _, _ => none

theorem invalid_api_command_fails_closed (raw : RawControllerCommand)
    (h : raw.throttle = .nan ∨ raw.trainBrake = .nan ∨
      raw.independentBrake = .nan ∨ raw.commandAge = .nan ∨
      raw.pressureAge = .nan) :
    apiCommandProducer raw = none := by
  rcases h with h | h | h | h | h <;>
    simp [apiCommandProducer, numericConvert, nonnegativeRaw, h]

theorem api_command_has_source_path (raw : RawControllerCommand)
    (c : ControllerCommand) (source : SourceRef)
    (h : apiCommandProducer raw = some (c, source)) :
    source = sourceCommandPath := by
  unfold apiCommandProducer at h
  split at h <;> simp_all

theorem api_command_produces_valid_command (raw : RawControllerCommand)
    (c : ControllerCommand) (source : SourceRef)
    (h : apiCommandProducer raw = some (c, source)) :
    commandValid c = true := by
  unfold apiCommandProducer at h
  split at h
  · simp_all [commandValid]
    rcases h with ⟨hgood, hc, hs⟩
    cases hc
    simpa [commandValid] using hgood
  · simp_all

theorem api_command_to_exact_plant
    (raw : RawControllerCommand) (c : ControllerCommand) (source : SourceRef)
    (dt : Q) (p : ParticleState) (physics : ExactPhysicsInput)
    (hapi : apiCommandProducer raw = some (c, source)) :
    ∃ next, exactPlantResult dt p physics c = some next := by
  have hvalid := api_command_produces_valid_command raw c source hapi
  exact exact_plant_has_source_next_state dt p physics c hvalid

structure JarTiming where
  tickPeriod : Q
  nextBranchBound : Q
  source : SourceRef
deriving DecidableEq, Repr

structure RuntimeTiming where
  sampleAge : Option Q
  commandDelay : Option Q
  pressureDelay : Option Q
  detectorInfoDelay : Option Q
  routeChangeLatency : Option Q
deriving DecidableEq, Repr

def runtimeTimingProducer (t : RuntimeTiming) : Option (Q × Q × Q × Q × Q) :=
  match t.sampleAge, t.commandDelay, t.pressureDelay, t.detectorInfoDelay,
    t.routeChangeLatency with
  | some age, some command, some pressure, some detector, some route =>
      if 0 ≤ age && 0 ≤ command && 0 ≤ pressure && 0 ≤ detector && 0 ≤ route then
        some (age, command, pressure, detector, route)
      else none
  | _, _, _, _, _ => none

theorem missing_runtime_timing_fails_closed (t : RuntimeTiming)
    (h : t.sampleAge = none ∨ t.commandDelay = none ∨
      t.pressureDelay = none ∨ t.detectorInfoDelay = none ∨
      t.routeChangeLatency = none) :
    runtimeTimingProducer t = none := by
  rcases h with h | h | h | h | h <;>
    simp [runtimeTimingProducer, h]

/-! Robust arrival model.  The bound explicitly includes positive traction,
    adverse motion, all measured delays, geometry error, and terminal error. -/

structure DelayBudget where
  observationAge : Q
  commandDelay : Q
  pressureDelay : Q
  detectorDelay : Q
  routeChangeDelay : Q
  source : SourceRef
deriving DecidableEq, Repr

def delayBudgetProducer (jar : JarTiming) (t : RuntimeTiming) :
    Option DelayBudget :=
  match runtimeTimingProducer t with
  | none => none
  | some (age, command, pressure, detector, route) =>
      if 0 ≤ jar.tickPeriod && 0 ≤ jar.nextBranchBound then
        some
          { observationAge := age
            commandDelay := command + jar.nextBranchBound
            pressureDelay := pressure
            detectorDelay := detector
            routeChangeDelay := route
            source := jar.source }
      else none

theorem missing_runtime_budget_fails_closed (jar : JarTiming) (t : RuntimeTiming)
    (h : runtimeTimingProducer t = none) :
    delayBudgetProducer jar t = none := by
  simp [delayBudgetProducer, h]

def totalDelay (d : DelayBudget) : Q :=
  d.observationAge + d.commandDelay + d.pressureDelay +
    d.detectorDelay + d.routeChangeDelay

structure BrakingBound where
  massKg : Q
  brakeLowerN : Q
  positiveTractionUpperN : Q
  adverseGradeUpperN : Q
  curvatureUpperN : Q
  slackUpperN : Q
  pushPullUpperN : Q
  localizationError : Q
  terminalTolerance : Q
  delay : DelayBudget
deriving DecidableEq, Repr

def lowerDeceleration (b : BrakingBound) : Q :=
  (b.brakeLowerN - b.positiveTractionUpperN - b.adverseGradeUpperN -
    b.curvatureUpperN - b.slackUpperN - b.pushPullUpperN) / b.massKg

def adverseMotion (b : BrakingBound) : Q :=
  (b.adverseGradeUpperN + b.curvatureUpperN + b.slackUpperN +
    b.pushPullUpperN) / b.massKg * totalDelay b.delay * totalDelay b.delay / 2

def stoppingDistance (v a : Q) : Q := v * v / (2 * a)

def guardDistance (b : BrakingBound) (v : Q) : Q :=
  v * totalDelay b.delay + adverseMotion b +
    stoppingDistance v (lowerDeceleration b) + b.localizationError +
    b.terminalTolerance

def terminalGuard (distance : Q) (b : BrakingBound) (v : Q) : Bool :=
  decide (0 < distance) && decide (0 < v) &&
    decide (0 < lowerDeceleration b) &&
    decide (guardDistance b v ≤ distance)

theorem guard_includes_positive_traction (b : BrakingBound) (v : Q) :
    guardDistance b v =
      v * totalDelay b.delay + adverseMotion b +
      stoppingDistance v (lowerDeceleration b) + b.localizationError +
      b.terminalTolerance := by
  rfl

theorem terminal_guard_rejects_nonpositive_deceleration
    (distance v : Q) (b : BrakingBound)
    (h : lowerDeceleration b ≤ 0) :
    terminalGuard distance b v = false := by
  simp [terminalGuard, Rat.not_lt.mpr h]

theorem terminal_guard_rejects_crossed_target
    (distance v : Q) (b : BrakingBound) (h : distance ≤ 0) :
    terminalGuard distance b v = false := by
  simp [terminalGuard, Rat.not_lt.mpr h]

theorem terminal_guard_rejects_wrong_way
    (distance v : Q) (b : BrakingBound) (h : v ≤ 0) :
    terminalGuard distance b v = false := by
  simp [terminalGuard, Rat.not_lt.mpr h]

theorem terminal_guard_has_remaining_distance
    (distance v : Q) (b : BrakingBound)
    (hguard : terminalGuard distance b v = true) :
    0 ≤ distance - guardDistance b v := by
  have hd : 0 ≤ distance - guardDistance b v := by
    have hle : guardDistance b v ≤ distance := by
      have hparts : ((0 < distance ∧ 0 < v) ∧ 0 < lowerDeceleration b) ∧
          guardDistance b v ≤ distance := by
        simpa [terminalGuard] using hguard
      exact hparts.2
    grind
  exact hd

structure ArrivalState where
  distanceToTarget : Q
  velocity : Q
deriving DecidableEq, Repr

def arrivalStep (a dt : Q) (s : ArrivalState) : ArrivalState :=
  { distanceToTarget := s.distanceToTarget - s.velocity * dt + a * dt * dt / 2
    velocity := max 0 (s.velocity - a * dt) }

theorem terminal_arrival_step
    (a v : Q) (ha : 0 < a) :
    (arrivalStep a (v / a)
      { distanceToTarget := stoppingDistance v a, velocity := v }).velocity = 0 := by
  unfold arrivalStep
  have ha0 : a ≠ 0 := Rat.ne_of_gt ha
  have hmul : a * (v / a) = v := by
    calc
      a * (v / a) = (v / a) * a := by rw [Rat.mul_comm]
      _ = v := Rat.div_mul_cancel ha0
  have hzero : v - a * (v / a) = 0 := by
    rw [hmul]
    exact Rat.sub_self
  simp [hzero, Rat.max_def]

theorem terminal_arrival_step_position
    (a v : Q) (ha : 0 < a) :
    (arrivalStep a (v / a)
      { distanceToTarget := stoppingDistance v a, velocity := v }).distanceToTarget = 0 := by
  unfold arrivalStep stoppingDistance
  have ha0 : a ≠ 0 := Rat.ne_of_gt ha
  rw [Rat.div_def]
  grind

def irRestCondition (velocity force friction : Q) : Prop :=
  velocity = 0 ∧ absQ force < friction

theorem holding_uses_ir_rest_condition (v f r : Q)
    (h : irRestCondition v f r) : v = 0 ∧ absQ f < r := by
  exact h

noncomputable def holdingTransition (position velocity force friction : Q) :
    Option (Q × Q) :=
  if _h : irRestCondition velocity force friction then some (position, 0) else none

theorem holding_preserves_ir_terminal_state
    (position velocity force friction : Q)
    (h : irRestCondition velocity force friction) :
    holdingTransition position velocity force friction = some (position, 0) := by
  simp [holdingTransition, h]

def revisionArrivalRun (a dt : Q) : Nat → ArrivalState → ArrivalState
  | 0, s => s
  | n + 1, s => revisionArrivalRun a dt n (arrivalStep a dt s)

theorem arrival_step_preserves_no_crossing
    (a dt : Q) (s : ArrivalState)
    (ha : 0 < a) (hdt : 0 ≤ dt) (hpos : s.velocity * dt ≤ s.distanceToTarget)
    (hvel : a * dt ≤ s.velocity) :
    0 ≤ (arrivalStep a dt s).distanceToTarget ∧
      0 ≤ (arrivalStep a dt s).velocity := by
  unfold arrivalStep
  constructor
  · have hacc : 0 ≤ a * dt * dt / 2 := by
      rw [Rat.div_def]
      exact Rat.mul_nonneg
        (Rat.mul_nonneg (Rat.mul_nonneg (Rat.le_of_lt ha) hdt) hdt)
        (Rat.le_of_lt (Rat.inv_pos.mpr (by decide)))
    grind
  · have hdiff : 0 ≤ s.velocity - a * dt := by grind
    rw [Rat.max_def, if_pos hdiff]
    exact hdiff

theorem arrival_run_velocity_nonincreasing
    (a dt : Q) (n : Nat) (s : ArrivalState)
    (ha : 0 ≤ a) (hdt : 0 ≤ dt) (hv : 0 ≤ s.velocity) :
    (revisionArrivalRun a dt n s).velocity ≤ s.velocity := by
  induction n generalizing s with
  | zero => exact Rat.le_refl
  | succ n ih =>
      rw [revisionArrivalRun]
      have hstep : (arrivalStep a dt s).velocity ≤ s.velocity := by
        unfold arrivalStep
        by_cases hnonneg : 0 ≤ s.velocity - a * dt
        · simp [Rat.max_def, hnonneg]
          have hprod : 0 ≤ a * dt := Rat.mul_nonneg ha hdt
          grind
        · simp [Rat.max_def, hnonneg]
          exact hv
      have hvstep : 0 ≤ (arrivalStep a dt s).velocity := by
        unfold arrivalStep
        by_cases hnonneg : 0 ≤ s.velocity - a * dt <;>
          simp [Rat.max_def, hnonneg]
      exact Rat.le_trans (ih (arrivalStep a dt s) hvstep) hstep

structure ArrivalObservation where
  frontCouplerError : Q
  directedSpeed : Q
  source : SourceRef
deriving DecidableEq, Repr

structure TerminalAcceptanceContract where
  positionTolerance : Q
  speedTolerance : Q
  requiredStableObservations : Nat
deriving DecidableEq, Repr

def stableObservationAccepted (c : TerminalAcceptanceContract)
    (observations : List ArrivalObservation) : Bool :=
  observations.length ≥ c.requiredStableObservations &&
    observations.all (fun o =>
      decide (absQ o.frontCouplerError ≤ c.positionTolerance) &&
      decide (absQ o.directedSpeed ≤ c.speedTolerance))

theorem stable_observation_window_rejects_short_list
    (c : TerminalAcceptanceContract) (observations : List ArrivalObservation)
    (h : observations.length < c.requiredStableObservations) :
    stableObservationAccepted c observations = false := by
  simp [stableObservationAccepted, Nat.not_le.mpr h]

structure ErrorBudget where
  traceError : Q
  fitError : Q
  couplerError : Q
  sampleAgeError : Q
  commandDelayError : Q
  numericError : Q
deriving DecidableEq, Repr

def derivedStopTolerance (e : ErrorBudget) : Q :=
  e.traceError + e.fitError + e.couplerError + e.sampleAgeError +
    e.commandDelayError + e.numericError

theorem derived_tolerance_contains_all_error_terms (e : ErrorBudget) :
    derivedStopTolerance e =
      e.traceError + e.fitError + e.couplerError + e.sampleAgeError +
        e.commandDelayError + e.numericError := by
  rfl

/-! Route-local fail-closed state. -/

structure ActiveRoute where
  graphRevision : Nat
  splineIds : List String
  vertexIds : List String
  edgeIds : List String
  orientations : List Orientation
deriving DecidableEq, Repr

def splineIdPresent (id : String) : List DirectedEdge → Bool
  | [] => false
  | e :: es => e.splineId = id || splineIdPresent id es

def vertexIdPresent (id : String) : List GraphVertex → Bool
  | [] => false
  | v :: vs => v.vertexId = id || vertexIdPresent id vs

def edgeWithSplinePresent (edgeId splineId : String) (o : Orientation) :
    List DirectedEdge → Bool
  | [] => false
  | e :: es =>
      (e.edgeId = edgeId && e.splineId = splineId && e.orientation = o) ||
        edgeWithSplinePresent edgeId splineId o es

def routeEdgeReferences : List String → List String → List Orientation →
    List DirectedEdge → Bool
  | [], [], [], _ => true
  | edgeId :: edgeIds, splineId :: splineIds, o :: os, edges =>
      edgeWithSplinePresent edgeId splineId o edges &&
        routeEdgeReferences edgeIds splineIds os edges
  | _, _, _, _ => false

def routeReferencesGraph (r : ActiveRoute) (g : RoutingGraph) : Bool :=
  r.graphRevision = g.revision &&
    r.splineIds.length = r.edgeIds.length &&
    (r.splineIds.all (fun id => splineIdPresent id g.edges)) &&
    (r.vertexIds.all (fun id => vertexIdPresent id g.vertices)) &&
    routeEdgeReferences r.edgeIds r.splineIds r.orientations g.edges

inductive RouteDecision
  | continue
  | replan
  | failClosed
deriving DecidableEq, Repr

def routeDecision (r : ActiveRoute) (g : RoutingGraph) (replanAvailable : Bool) :
    RouteDecision :=
  if routeReferencesGraph r g then .continue
  else if replanAvailable then .replan else .failClosed

theorem invalid_route_fails_closed_without_replan
    (r : ActiveRoute) (g : RoutingGraph)
    (h : routeReferencesGraph r g = false) :
    routeDecision r g false = .failClosed := by
  simp [routeDecision, h]

end IRRevision
