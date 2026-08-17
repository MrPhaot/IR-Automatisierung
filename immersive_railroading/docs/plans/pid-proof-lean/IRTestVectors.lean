import IRProof
import IRCertifiedModel

open IRProof

def v (x y z : Q) : Vec3 := ⟨x, y, z⟩

def straightVector : Cubic := degenerateStraight (v 0 0 0) (v 10 0 0)

example : cubicPosition straightVector 0 = straightVector.p1 :=
  cubicPosition_zero straightVector

example : cubicPosition straightVector 1 = straightVector.p2 :=
  cubicPosition_one straightVector

example : (cubicReverse straightVector).p1 = v 10 0 0 := by
  rfl

def sampleCubic : Cubic :=
  ⟨v 0 0 0, v 0 2 0, v 8 2 0, v 10 0 0⟩

example : (cubicPosition sampleCubic (1 / 2)).x = 17 / 4 := by
  unfold cubicPosition sampleCubic v
  grind

example : (cubicPosition sampleCubic (1 / 2)).y = 3 / 2 := by
  unfold cubicPosition sampleCubic v
  grind

def crossingEvidence : TopologyEvidence :=
  { unresolvedObservation := false
    sameInterval := false
    extendsInterval := false
    knownConnection := false
    bothContinue := true
    sameLevel := true
    heightSeparationSq := 0
    certifiedToleranceSq := 1 }

example : classifyTopology crossingEvidence = .isolatedCrossing := by
  have h : ¬ (1 : Q) < 0 := by grind
  simp [classifyTopology, crossingEvidence, h]

def overpassEvidence : TopologyEvidence :=
  { crossingEvidence with heightSeparationSq := 4 }

example : topologyRoutable (classifyTopology overpassEvidence) = false := by
  native_decide

def markerVector : Marker :=
  { markerId := "m"
    worldPosition := v 0 0 0
    toleranceSq := 1
    configuredApproach := .forward
    kind := "station" }

example : mapMarker markerVector "s" 10 4 = none := by
  apply marker_mapping_rejects_far
  change (1 : Q) < 4
  grind

def testSpline : Spline :=
  { stableId := "s"
    curve := straightVector
    reverseCurve := cubicReverse straightVector
    arcMarks := [{ t := 0, s := 0 }, { t := 1, s := 10 }]
    totalLength := 10
    points := []
    fittingError := 0
    sourceTraceIds := ["trace-1"]
    irBuilder := some "straight" }

def testGraph : RoutingGraph :=
  { revision := 7
    splines := [testSpline]
    vertices := [{ vertexId := "v0", splineId := "s", s := 0 },
      { vertexId := "v1", splineId := "s", s := 10 }]
    edges := [{ edgeId := "e", splineId := "s", startS := 0, endS := 10, forward := true, startVertexId := "v0", endVertexId := "v1" }] }

def validRoute : ActiveRoute :=
  { graphRevision := 7, splineIds := ["s"], vertexIds := ["v0", "v1"], edgeIds := ["e"],
    edgeDirections := [true] }

def invalidVertexRoute : ActiveRoute :=
  { validRoute with vertexIds := ["missing"] }

example : routeEdgeSetValid validRoute testGraph = true := by
  native_decide

example : routeEdgeSetValid invalidVertexRoute testGraph = false := by
  native_decide

theorem testSplineCertificate : SplineCertificate testSpline :=
  { marksMonotone := by
      simp [testSpline, arcMarksMonotone]
      constructor <;> native_decide
    lengthPositive := by
      native_decide
    fitNonnegative := by
      native_decide
    reverseCorrect := by
      rfl
    tangentMetadata := by
      intro p hp
      simp [testSpline] at hp }

def matchVector : MatchEvidence :=
  { distanceSq := 0
    tangentDistanceSq := 0
    curvatureDistance := 0
    arcDistance := 0
    distanceToleranceSq := 1
    tangentToleranceSq := 1
    curvatureTolerance := 1
    arcTolerance := 1 }

def newGeometryEvidence : ReconstructionEvidence :=
  { candidate := testSpline
    candidateCertificate := testSplineCertificate
    existingSplineId := none
    matchEvidence := matchVector
    topologyEvidence :=
      { unresolvedObservation := false
        sameInterval := false
        extendsInterval := false
        knownConnection := false
        bothContinue := false
        sameLevel := true
        heightSeparationSq := 0
        certifiedToleranceSq := 1 }
    fitBound := 1
    traceId := "trace-new"
    fitCertified := true
    splitRequired := false
    overlapObserved := false }

example : reconstructionKind newGeometryEvidence = .newGeometry := by
  native_decide

def unresolvedEvidence : ReconstructionEvidence :=
  { newGeometryEvidence with fitCertified := false }

example : reconstructionRoutable (reconstructionKind unresolvedEvidence) = false := by
  native_decide

def crossingReconstructionEvidence : ReconstructionEvidence :=
  { newGeometryEvidence with
    topologyEvidence := crossingEvidence
    traceId := "trace-crossing" }

def emptySplineStore : SplineStore :=
  { revision := 0, splines := [], sourceTraceIds := [] }

example : (commitReconstruction emptySplineStore crossingReconstructionEvidence).splines =
    [testSpline] := by
  apply crossing_commit_keeps_candidate_separate
  · native_decide
  · native_decide

def testNetwork : SplineNetwork :=
  { revision := 8, splines := [testSpline], connections := [] }

def builtGraph : RoutingGraph := buildRoutingGraph testNetwork

def builtForwardRoute : ActiveRoute :=
  { graphRevision := 8
    splineIds := ["s"]
    vertexIds := ["s:start", "s:end"]
    edgeIds := ["s:forward"]
    edgeDirections := [true] }

def builtReverseRoute : ActiveRoute :=
  { graphRevision := 8
    splineIds := ["s"]
    vertexIds := ["s:start", "s:end"]
    edgeIds := ["s:reverse"]
    edgeDirections := [false] }

example : routeEdgeSetValid builtForwardRoute builtGraph = true := by
  native_decide

example : routeEdgeSetValid builtReverseRoute builtGraph = true := by
  native_decide

example : mapClosestMarker markerVector
    [("s", 4, 4), ("s2", 6, 1)] = mapMarker markerVector "s2" 6 1 := by
  native_decide

def profileOne : StockObservation :=
  { stockUuid := "u1"
    definitionId := "freight"
    weightKg := 1000
    direction := .forward
    speedMps := 10
    brakeSystemEfficiency := 1 / 4
    brakeAdhesionEfficiency := 1
    brakeMultiplier := 1
    hasTrainBrake := true
    hasIndependentBrake := true
    tractiveEffortN := some 1000
    cogging := false }

def profileWeightMutation : StockObservation :=
  { profileOne with weightKg := 1001 }

def overheadEvent : DetectorEvent :=
  { stockUuid := "u1", eventName := "ir_train_overhead" }

example : catalogueOne overheadEvent profileOne [] = [profileOne] := by
  apply catalogue_preserves_order
  constructor <;> rfl

example : profileMismatch [profileOne] [profileWeightMutation] = true := by
  native_decide

def crossedTarget : DirectedTarget :=
  { targetS := 10, frontCouplerS := 11, frontCouplerVelocity := 1,
    orientation := .forward }

def awayMotion : DirectedTarget :=
  { targetS := 10, frontCouplerS := 5, frontCouplerVelocity := -1,
    orientation := .forward }

example : ¬ stoppingPremise crossedTarget := by
  apply target_crossing_rejected
  native_decide

example : ¬ stoppingPremise awayMotion := by
  apply wrong_way_rejected
  native_decide

def ordinaryPhysics : PhysicsInput :=
  { massKg := 1000
    designMassKg := 1000
    velocityMps := 10
    slopeSine := 0
    slopeMultiplier := 1
    throttle := 1 / 10
    availableTractionN := 1000
    rollingResistanceN := 10
    directResistanceN := 5
    interferenceResistanceN := 0
    nearZeroResistanceN := 0
    trainBrake := 1
    independentBrake := 1
    trainBrakeAvailable := true
    independentBrakeAvailable := true
    brakeShoeFriction := 1 / 4
    configuredBrakeAdhesionEfficiency := 1
    configuredBrakeMultiplier := 1
    cogging := false
    wheelSlip := false
    curvatureBoundN := 2
    slackBoundN := 3
    pushPullBoundN := 1 }

example : physicalPressure 0 (3 / 4) = 3 / 4 := by
  native_decide

example : physicalPressure (-1) (-2) = 0 := by
  native_decide

example : signedNetForceN ordinaryPhysics = -1636 := by
  native_decide

def slipPhysics : PhysicsInput := { ordinaryPhysics with wheelSlip := true }

example : brakeBranch slipPhysics = 420 := by
  native_decide

def ordinaryCommand : ControllerCommand :=
  stoppingCommand (1 / 10) (1 / 20)

example : ordinaryCommand.throttle = 1 / 20 := by
  native_decide

example : ordinaryCommand.trainBrake = 1 ∧ ordinaryCommand.independentBrake = 1 := by
  native_decide

example : (commandPhysics ordinaryPhysics
    { throttle := 1 / 20, trainBrake := 0, independentBrake := 0,
      emergency := true }).trainBrake = 1 := by
  native_decide

example : (commandPhysics
    { ordinaryPhysics with trainBrakeAvailable := false }
    { throttle := 0, trainBrake := 1, independentBrake := 1,
      emergency := true }).trainBrake = 0 := by
  native_decide

example : delayDistance 10 1 1 = 11 := by
  native_decide

example : delayDistance 10 2 1 = 24 := by
  native_decide

example :
    brakeVelocity 2 1 1 10 = 8 := by
  native_decide

def arrivalContract : RuntimeContract :=
  { maxSampleAge := 1
    maxCommandDelay := 1
    maxPressureDelay := 1
    routeValidationInterval := 1
    fittingTolerance := 1 / 10
    frontCouplerTolerance := 1 / 10
    terminalPositionTolerance := 1 / 2
    terminalSpeedTolerance := 1 / 10
    stableObservations := 3
    detectorSpeed := 10 / 36
    profileHash := "p" }

def terminalVector : DirectedTarget :=
  { targetS := 100, frontCouplerS := 499 / 5, frontCouplerVelocity := 1 / 100,
    orientation := .forward }

example : terminalAccepted arrivalContract terminalVector true := by
  constructor
  · native_decide
  constructor <;> native_decide

def testSpline2 : Spline :=
  { stableId := "t"
    curve := degenerateStraight (v 10 0 0) (v 20 0 0)
    reverseCurve := cubicReverse (degenerateStraight (v 10 0 0) (v 20 0 0))
    arcMarks := [{ t := 0, s := 0 }, { t := 1, s := 10 }]
    totalLength := 10
    points := []
    fittingError := 0
    sourceTraceIds := ["trace-2"]
    irBuilder := some "straight" }

def sharedJunction : SharedConnection :=
  { connectionId := "junction"
    leftSplineId := "s"
    leftAtStart := false
    leftS := 10
    rightSplineId := "t"
    rightAtStart := true
    rightS := 0 }

def connectedNetwork : SplineNetwork :=
  { revision := 9
    splines := [testSpline, testSpline2]
    connections := [sharedJunction] }

def connectedGraph : RoutingGraph := buildRoutingGraph connectedNetwork

def connectedRoute : ActiveRoute :=
  { graphRevision := 9
    splineIds := ["s", "t"]
    vertexIds := ["s:start", "junction", "t:end"]
    edgeIds := ["s:forward", "t:forward"]
    edgeDirections := [true, true] }

example : routeEdgeSetValid connectedRoute connectedGraph = true := by
  native_decide

def brokenConnectionRoute : ActiveRoute :=
  { connectedRoute with edgeIds := ["s:forward", "s:reverse"] }

example : routeEdgeSetValid brokenConnectionRoute connectedGraph = false := by
  native_decide

example : mapMarkerOnSpline markerVector testSpline (-1) 0 = none := by
  apply marker_mapping_rejects_out_of_interval
  left
  native_decide

def continuationEvidence : ReconstructionEvidence :=
  { newGeometryEvidence with
    existingSplineId := some "s"
    topologyEvidence :=
      { newGeometryEvidence.topologyEvidence with sameInterval := true }
    traceId := "trace-repeat" }

example : reconstructionKind continuationEvidence = .continuation := by
  native_decide

example : (commitReconstruction emptySplineStore continuationEvidence).splines = [] := by
  apply continuation_commit_does_not_add_geometry
  native_decide

def overpassReconstructionEvidence : ReconstructionEvidence :=
  { crossingReconstructionEvidence with
    topologyEvidence := overpassEvidence
    traceId := "trace-overpass" }

example : reconstructionKind overpassReconstructionEvidence = .overpass := by
  native_decide

example : reconstructionRoutable (reconstructionKind overpassReconstructionEvidence) = false := by
  native_decide

def mappedStation : DirectedRouteMarker :=
  { mapping :=
      { marker := markerVector, splineId := "s", s := 5, measuredDistanceSq := 0 }
    routeDirection := .forward }

example : directedMarkerValid mappedStation := by
  rfl

def expectedProfile : FrozenProfile := freezeProfile [profileOne]

def supervisorConsist : ConsistState :=
  { particles := []
    trainLengthM := 10
    frontCouplerS := 0
    frontSlackM := 0
    rearSlackM := 0
    frontPushing := false
    frontPulling := true
    rearPushing := false
    rearPulling := true }

def supervisorController : ControllerInput :=
  { target :=
      { targetS := 100, frontCouplerS := 0, frontCouplerVelocity := 1,
        orientation := .forward }
    consist := supervisorConsist
    contract := arrivalContract
    observationAge := 0
    commandAge := 0
    pressureAge := 0
    geometryError := 1
    terminalTolerance := 1
    routeValid := true
    profileValid := true
    numericValid := true
    brakeLower := 20000
    tractiveUpper := 100
    adverseUpper := 0
    mass := 1000
    throttleRequest := 1 / 20 }

def supervisorVector : SupervisorInput :=
  { controller := supervisorController
    route := builtForwardRoute
    graph := builtGraph
    expectedProfile := expectedProfile
    actualProfile := [profileOne]
    marker := mappedStation
    numericBoundary :=
      { finite := true, inRange := true, absoluteError := 0, errorBound := 1 / 100 }
    physics := ordinaryPhysics
    throttleCap := 1 / 10 }

theorem supervisor_vector_valid : supervisorValid supervisorVector := by
  have hroute : routeEdgeSetValid supervisorVector.route supervisorVector.graph = true := by
    native_decide
  have hprofile : frozenProfileMatches supervisorVector.expectedProfile
      supervisorVector.actualProfile = true := by
    native_decide
  have hnumeric : numericBoundaryValid supervisorVector.numericBoundary := by
    constructor
    · rfl
    constructor
    · rfl
    constructor <;> native_decide
  have hdata : dataContractValid supervisorController := by
    grind [dataContractValid, consistStateValid, supervisorController,
      supervisorConsist, arrivalContract]
  have hstop : stoppingPremise supervisorController.target := by
    grind [stoppingPremise, stoppingError, directedVelocity, supervisorController]
  have hcap : 0 < supervisorVector.throttleCap := by
    change (0 : Q) < 1 / 10
    native_decide
  exact ⟨hroute, hprofile, rfl, hnumeric, hdata, hstop, hcap⟩

theorem supervisor_vector_guard : supervisorGuard supervisorVector := by
  unfold supervisorGuard terminalGuard stoppingError directedVelocity
  dsimp [supervisorVector, supervisorController, arrivalContract]
  constructor
  · native_decide
  constructor
  · native_decide
  constructor
  · native_decide
  constructor
  · native_decide
  · native_decide

example : supervisorValid supervisorVector := supervisor_vector_valid

example : supervisorGuard supervisorVector := supervisor_vector_guard

example : (supervisorStateTransition
    { mode := .cruise, graphRevision := 8, profileHash := "p",
      target := supervisorController.target } supervisorVector 8 "p").mode = .stopping := by
  have hv : supervisorValid supervisorVector := supervisor_vector_valid
  have hg : supervisorGuard supervisorVector := supervisor_vector_guard
  simp [supervisorStateTransition, hv, hg]

example : supervisorCommand supervisorVector =
    some (stoppingCommand (1 / 10) (1 / 20)) := by
  have hv : supervisorValid supervisorVector := supervisor_vector_valid
  have hg : supervisorGuard supervisorVector := supervisor_vector_guard
  classical
  unfold supervisorCommand
  rw [dif_pos ⟨hv, hg⟩]
  rfl

example : supervisorCommand
    { supervisorVector with controller :=
        { supervisorController with observationAge := 2 } } = none := by
  apply supervisor_invalid_fails_closed
  intro h
  have hbad : ¬ dataContractValid
      { supervisorController with observationAge := 2 } := by
    grind [dataContractValid, supervisorController, supervisorConsist, arrivalContract,
      consistStateValid]
  exact hbad h.2.2.2.2.1

example : ¬ numericBoundaryValid
    { finite := false, inRange := true, absoluteError := 0, errorBound := 1 } := by
  intro h
  cases h.1

def massBaselineAcceleration : Q := 100 / 1000
def massMutatedAcceleration : Q := 100 / 2000

def massMutation : MutationResult :=
  { name := "mass"
    baselinePasses := true
    mutatedPasses := decide (massBaselineAcceleration = massMutatedAcceleration) }

example : mutationRejected massMutation := by
  change true = true ∧ massMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def brakeMultiplierMutation : MutationResult :=
  { name := "brakeMultiplier"
    baselinePasses := true
    mutatedPasses := decide
      (brakeForceN ordinaryPhysics =
        brakeForceN { ordinaryPhysics with configuredBrakeMultiplier := 2 }) }

example : mutationRejected brakeMultiplierMutation := by
  change true = true ∧ brakeMultiplierMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def gradeMutation : MutationResult :=
  { name := "grade"
    baselinePasses := true
    mutatedPasses := decide
      (gradeForceN ordinaryPhysics =
        gradeForceN { ordinaryPhysics with slopeSine := 1 / 100 }) }

example : mutationRejected gradeMutation := by
  change true = true ∧ gradeMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def throttleMutation : MutationResult :=
  { name := "throttle"
    baselinePasses := true
    mutatedPasses := decide
      (tractiveForceN ordinaryPhysics =
        tractiveForceN { ordinaryPhysics with throttle := 0 }) }

example : mutationRejected throttleMutation := by
  change true = true ∧ throttleMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def geometryMutation : MutationResult :=
  { name := "spline-geometry"
    baselinePasses := true
    mutatedPasses := decide
      (distance3Sq (cubicPosition sampleCubic 0) (cubicPosition sampleCubic 1) = 0) }

example : mutationRejected geometryMutation := by
  change true = true ∧ geometryMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def slackCurvatureMutation : MutationResult :=
  { name := "curvature-slack"
    baselinePasses := true
    mutatedPasses := decide
      (couplerAdverseN ordinaryPhysics =
        couplerAdverseN ({ ordinaryPhysics with slackBoundN := 0, curvatureBoundN := 0 })) }

example : mutationRejected slackCurvatureMutation := by
  change true = true ∧ slackCurvatureMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def delayMutation : MutationResult :=
  { name := "command-delay"
    baselinePasses := true
    mutatedPasses := decide (delayDistance 10 1 0 = delayDistance 10 2 0) }

example : mutationRejected delayMutation := by
  change true = true ∧ delayMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def profileMutation : MutationResult :=
  { name := "consist-profile"
    baselinePasses := true
    mutatedPasses := !(profileMismatch [profileOne] [profileWeightMutation]) }

example : mutationRejected profileMutation := by
  change true = true ∧ profileMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide

def directionMutation : MutationResult :=
  { name := "route-direction"
    baselinePasses := true
    mutatedPasses := routeEdgeSetValid
      { builtForwardRoute with edgeDirections := [false] } builtGraph }

example : mutationRejected directionMutation := by
  change true = true ∧ directionMutation.mutatedPasses = false
  constructor
  · rfl
  · native_decide
