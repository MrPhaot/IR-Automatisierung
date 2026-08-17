import IRRevision

namespace IRRevision

open IRProof

def v (x y z : Q) : Vec3 := ⟨x, y, z⟩

def traceVector : TraceObservation :=
  { tick := 1
    rawPosition := v 0 0 0
    stockUuid := "compact-tracer"
    definitionId := "compact-loco"
    bogeyReferenceOffset := v 1 0 0
    sampleAge := 1 / 20
    samplingSpacing := 1
    curvatureBound := 1
    floatingError := 1 / 10
    missingObservationBound := 1 / 10
    measuredResidual := v (1 / 10) 0 0 }

def splineVector : SplineCandidate :=
  { stableId := "spline-1"
    curve := degenerateStraight (v 0 0 0) (v 10 0 0)
    arcMarks := [{ t := 0, s := 0 }, { t := 1, s := 10 }]
    totalLength := 10
    tangentSamples := [v 10 0 0]
    gradeSamples := [0]
    curvatureSamples := [0]
    fittingError := 1 / 100
    sourceTraceIds := ["trace-1"]
    observations := [traceVector]
    traceParameters := [0]
    builderSource := some sourceCurvePosition }

def validatedVector : ValidatedSpline :=
  { candidate := splineVector
    localizationError := 121 / 100
    source := sourceCurvePosition }

example : traceObservationValid traceVector = true := by
  native_decide

example : splineCandidateValid splineVector = true := by
  native_decide

example : (validatedSplineProducer splineVector).isSome = true := by
  native_decide

example :
    (directedEdge validatedVector .forward).startS = 0 ∧
      (directedEdge validatedVector .forward).endS = 10 ∧
      (directedEdge validatedVector .forward).startPoint = splineVector.curve.p1 ∧
      (directedEdge validatedVector .forward).endPoint = splineVector.curve.p2 := by
  native_decide

example :
    (directedEdge validatedVector .reverse).startS = 10 ∧
      (directedEdge validatedVector .reverse).endS = 0 ∧
      (directedEdge validatedVector .reverse).startPoint = splineVector.curve.p2 ∧
      (directedEdge validatedVector .reverse).endPoint = splineVector.curve.p1 := by
  native_decide

example :
    (directedEdge validatedVector .forward).localizationError = 121 / 100 := by
  native_decide

example :
    edgeCoordinate validatedVector .reverse
        (directedCoordinateOfParameter validatedVector .reverse (1 / 4)) =
      1 / 4 * splineVector.totalLength := by
  native_decide

example :
    edgePointAt validatedVector .reverse
        (directedCoordinateOfParameter validatedVector .reverse (1 / 4)) =
      cubicPosition splineVector.curve (1 / 4) := by
  native_decide

example (c : SplineCandidate) (v : ValidatedSpline)
    (hsource : validatedSplineProducer c = some v) (o : Orientation)
    (t eps : Q) (q : Vec3) (hinterval : 0 ≤ t ∧ t ≤ 1)
    (hprojection : distance3L1 q (cubicPosition c.curve t) ≤ eps) :
    traceFitRowsValid c.curve c.fittingError c.observations c.traceParameters = true ∧
      (directedEdge v o).splineId = c.stableId := by
  have hfit := validated_spline_trace_fit_is_checked c v hsource
  have hedge := validated_spline_to_directed_routing_edge c v hsource o t eps q
    hinterval hprojection
  exact ⟨hfit, hedge.1⟩

def invalidSplineVector : SplineCandidate :=
  { splineVector with fittingError := -1 }

example : validatedSplineProducer invalidSplineVector = none := by
  native_decide

def crossingVector : TopologyObservation :=
  { threeDistance := 0
    tangentDistance := 0
    curvatureDistance := 0
    arcDistance := 0
    heightSeparation := 0
    tolerance := 1
    sameLevel := true
    bothContinue := true
    knownConnection := false
    extendsInterval := false
    splitRequired := false
    overlapObserved := false }

def overpassVector : TopologyObservation :=
  { crossingVector with sameLevel := false, heightSeparation := 4 }

example : classifyTopology crossingVector = .isolatedCrossing := by
  native_decide

example : topologyRoutable (classifyTopology crossingVector) = false := by
  native_decide

example : classifyTopology overpassVector = .overpass := by
  native_decide

def markerVector : MarkerObservation :=
  { markerId := "station-a"
    kind := "station"
    coordinate := 5
    distance := 1 / 2
    tolerance := 1
    approach := .forward
    source := sourceCurvePosition }

example : (directedMarkerProducer validatedVector markerVector).isSome = true := by
  native_decide

example (m : MarkerObservation) (v : ValidatedSpline) (x : DirectedMarker)
    (h : directedMarkerProducer v m = some x) :
    x.permittedApproach = m.approach := by
  exact marker_wrong_orientation_is_not_permitted v m x h

def routeGraphVector : RoutingGraph := routingGraphProducer 3 validatedVector

def emptyIdCandidateVector : SplineCandidate :=
  { splineVector with stableId := "" }

example : (graphNetworkProducer 3 [splineVector]).isSome = true := by
  native_decide

example : graphNetworkProducer 3 [splineVector, splineVector] = none := by
  native_decide

example : graphNetworkProducer 3 [emptyIdCandidateVector] = none := by
  native_decide

example : ∀ (g : RoutingGraph),
    graphNetworkProducer 3 [splineVector] = some g →
      ∀ e ∈ g.edges, networkEdgeProduced [splineVector] e := by
  intro g hsource e he
  exact graph_network_consumes_only_source_validated_splines
    3 [splineVector] g hsource e he

def forwardRouteVector : ActiveRoute :=
  { graphRevision := 3
    splineIds := ["spline-1"]
    vertexIds := ["spline-1:start", "spline-1:end"]
    edgeIds := ["spline-1:forward"]
    orientations := [.forward] }

def reverseRouteVector : ActiveRoute :=
  { forwardRouteVector with
    edgeIds := ["spline-1:reverse"]
    orientations := [.reverse] }

def wrongOrientationRouteVector : ActiveRoute :=
  { forwardRouteVector with orientations := [.reverse] }

def missingSplineRouteVector : ActiveRoute :=
  { forwardRouteVector with splineIds := ["missing-spline"] }

def missingVertexRouteVector : ActiveRoute :=
  { forwardRouteVector with vertexIds := ["missing-vertex"] }

example : routeReferencesGraph forwardRouteVector routeGraphVector = true := by
  native_decide

example : routeReferencesGraph reverseRouteVector routeGraphVector = true := by
  native_decide

example : routeReferencesGraph wrongOrientationRouteVector routeGraphVector = false := by
  native_decide

example : routeReferencesGraph missingSplineRouteVector routeGraphVector = false := by
  native_decide

example : routeReferencesGraph missingVertexRouteVector routeGraphVector = false := by
  native_decide

def staticVector : StaticDefinition :=
  { definitionId := "compact-loco"
    designMassKg := some 1000
    brakeShoeFriction := some steelCastIronKinetic
    brakeSystemEfficiency := some 1
    brakeAdhesionEfficiency := some 1
    source := sourceCurvePosition }

def dynamicVector : DynamicInfo :=
  { stockUuid := "stock-1"
    definitionId := some "compact-loco"
    weightKg := some 1000
    speedMps := some 10
    direction := some .forward
    trainBrakePosition := some 1
    independentBrakePosition := some 1
    tractionN := some 1000
    cogging := some false
    source := sourceDetectorInfo }

def detectorVector : DetectorEvent :=
  { eventName := overheadEventName
    stockUuid := "stock-1"
    infoResult := some dynamicVector
    consistResult := none
    source := sourceDetectorEvent }

example :
    (consumeDetectorEvent [staticVector] detectorVector).isSome = true := by
  native_decide

def missingInfoVector : DetectorEvent :=
  { detectorVector with infoResult := none }

example : consumeDetectorEvent [staticVector] missingInfoVector = none := by
  native_decide

def physicsVector : PhysicsObservation :=
  { massKg := some 1000
    pitchDegrees := some 0
    slopeMultiplier := some 1
    tractionN := some 1000
    rollingResistanceN := some 10
    directResistanceN := some 5
    interferenceResistanceN := some 0
    brakePressure := some 1
    independentBrakePosition := some 1
    designAdhesionN := some 2000
    maximumAdhesionN := some 10000
    brakeMultiplier := some 1
    blockHardness := some 1
    velocityMps := some 10
    brakeShoeFriction := some steelCastIronKinetic
    source := sourceSimulationFriction }

example : (physicsAdapter physicsVector).isSome = true := by
  native_decide

def missingPhysicsVector : PhysicsObservation :=
  { physicsVector with massKg := none }

example : physicsAdapter missingPhysicsVector = none := by
  native_decide

example : steelStatic = 7 / 10 ∧ steelKinetic = 21 / 50 ∧
    steelCastIronKinetic = 1 / 4 := by
  native_decide

def exactSourceVector : PhysicsSourceRecord :=
  { currentMassKg := some 1000
    designMassKg := some 1000
    pitchDegrees := some 0
    pitchSine := some 0
    slopeMultiplier := some 1
    tractiveEffortN := some 100
    rollingCoefficient := some (1 / 100)
    speedRetarderResistanceN := some 5
    directFrictionCoefficient := some (1 / 10)
    interferenceResistance := some 1
    blockHardness := some 2
    brakePressure := some 1
    independentBrakePosition := some 1
    brakeSystemEfficiency := some 1
    brakeAdhesionEfficiency := some 1
    brakeMultiplier := some 1
    velocityMps := some 10
    brakeShoeFriction := some steelCastIronKinetic
    cogging := some false
    sourceConfiguration := sourceSimulationConfiguration
    sourceBrakeEfficiency := sourceLocomotiveBrakeEfficiency }

def exactPhysicsVector : ExactPhysicsInput :=
  { currentMassKg := 1000
    designMassKg := 1000
    pitchDegrees := 0
    pitchSine := 0
    slopeMultiplier := 1
    tractiveEffortN := 100
    rollingCoefficient := 1 / 100
    speedRetarderResistanceN := 5
    directFrictionCoefficient := 1 / 10
    interferenceResistance := 1
    blockHardness := 2
    brakePressure := 1
    independentBrakePosition := 1
    designAdhesionN := 6860
    maximumAdhesionN := 6860
    brakeSystemEfficiency := 1
    brakeAdhesionEfficiency := 1
    brakeMultiplier := 1
    velocityMps := 10
    brakeShoeFriction := steelCastIronKinetic
    cogging := false
    sourceConfiguration := sourceSimulationConfiguration
    sourceBrakeEfficiency := sourceLocomotiveBrakeEfficiency }

example : (sourcePhysicsAdapter exactSourceVector).isSome = true := by
  native_decide

def missingSineSourceVector : PhysicsSourceRecord :=
  { exactSourceVector with pitchSine := none }

example : sourcePhysicsAdapter missingSineSourceVector = none := by
  native_decide

example : (exactForceLedger exactPhysicsVector).netN = -10823 := by
  native_decide

example :
    (exactForceLedger { exactPhysicsVector with brakeMultiplier := 0 }).netN ≠
      (exactForceLedger exactPhysicsVector).netN := by
  native_decide

def stockVector : StockRecord :=
  { stockUuid := "stock-1"
    definitionId := "compact-loco"
    weightKg := 1000
    speedMps := 10
    direction := .forward
    trainBrakePosition := 1
    independentBrakePosition := 1
    tractionN := 1000
    cogging := false
    brakeShoeFriction := steelCastIronKinetic
    brakeSystemEfficiency := 1
    brakeAdhesionEfficiency := 1
    sourceInfo := sourceDetectorInfo
    sourceDefinition := sourceCurvePosition }

def globalPhysicsVector : GlobalConfiguration :=
  { brakeMultiplier := some 1
    slopeMultiplier := some 1
    rollingCoefficient := some 10
    blockHardness := some 1
    source := sourceSimulationFriction }

def runtimePhysicsVector : RuntimePhysicsInputs :=
  { pitchDegrees := some 0
    designAdhesionN := some 2000
    maximumAdhesionN := some 10000
    directResistanceN := some 5
    interferenceResistanceN := some 0 }

example :
    (physicsObservationFromProfile stockVector globalPhysicsVector
      runtimePhysicsVector).isSome = true := by
  native_decide

def missingGlobalPhysicsVector : GlobalConfiguration :=
  { globalPhysicsVector with brakeMultiplier := none }

example : physicsObservationFromProfile stockVector missingGlobalPhysicsVector
    runtimePhysicsVector = none := by
  native_decide

def runtimeExactPhysicsVector : RuntimeExactPhysicsInputs :=
  { pitchDegrees := some 0
    pitchSine := some 0
    speedRetarderResistanceN := some 5
    directFrictionCoefficient := some (1 / 10)
    interferenceResistance := some 1 }

example :
    (sourcePhysicsRecordFromProfile stockVector staticVector
      globalPhysicsVector runtimeExactPhysicsVector).isSome = true := by
  native_decide

def wrongDefinitionVector : StaticDefinition :=
  { staticVector with definitionId := "other-definition" }

example :
    sourcePhysicsRecordFromProfile stockVector wrongDefinitionVector
      globalPhysicsVector runtimeExactPhysicsVector = none := by
  native_decide

def mutatedProfileStockVector : StockRecord :=
  { stockVector with brakeSystemEfficiency := 2 }

example : frozenProfileMatches (freezeCatalogue [stockVector])
    [mutatedProfileStockVector] = false := by
  native_decide

def couplerDefinitionVector : CouplerDefinition :=
  { frontOffsetForwardS := some 1
    frontOffsetReverseS := some (-1)
    rearOffsetForwardS := some (-2)
    rearOffsetReverseS := some 2
    slackForwardS := some (1 / 10)
    slackReverseS := some (1 / 10)
    source := sourceSimulationConfiguration }

example :
    (frontCouplerLocalizationProducer validatedVector couplerDefinitionVector
      5 (1 / 10) .forward).isSome = true := by
  native_decide

def couplerLocalizationVector : DirectedLocalization :=
  { splineId := "spline-1"
    frontCouplerS := 6
    errorBound := 131 / 100
    orientation := .forward
    source := sourceSimulationConfiguration }

example :
    frontCouplerLocalizationProducer validatedVector couplerDefinitionVector
      5 (1 / 10) .forward = some couplerLocalizationVector := by
  native_decide

def validCommandVector : ControllerCommand :=
  { throttle := 1 / 20
    trainBrake := 1
    independentBrake := 1
    emergency := true
    commandAge := 1 / 10
    pressureAge := 1 / 10 }

def invalidCommandVector : ControllerCommand :=
  { validCommandVector with throttle := 2 }

example : commandValid validCommandVector = true := by
  native_decide

example : commandValid invalidCommandVector = false := by
  native_decide

def physicsInputVector : PhysicsInput :=
  { massKg := 1000
    pitchDegrees := 0
    slopeMultiplier := 1
    tractionN := 1000
    rollingResistanceN := 10
    directResistanceN := 5
    interferenceResistanceN := 0
    brakePressure := 1
    independentBrakePosition := 1
    designAdhesionN := 2000
    maximumAdhesionN := 10000
    brakeMultiplier := 1
    blockHardness := 1
    velocityMps := 10
    brakeShoeFriction := steelCastIronKinetic
    source := sourceSimulationFriction }

example : (plantTransition 1
      { positionS := 0, velocityMps := 1, massKg := 1000, forceN := 1000,
        frictionN := 10, direction := .forward, slackBound := 1,
        pushPullBound := 1, source := sourceParticleVelocity }
      physicsInputVector validCommandVector).isSome = true := by
  native_decide

example : (exactPlantTransition 1
      { positionS := 0, velocityMps := 1, massKg := 1000, forceN := 100,
        frictionN := 10, direction := .forward, slackBound := 1,
        pushPullBound := 1, source := sourceParticleVelocity }
      exactPhysicsVector validCommandVector).isSome = true := by
  native_decide

def linkageVector : LinkageState :=
  { canPull := true
    canPush := true
    currentDistance := 0
    minimumDistance := 1
    slackPercent := 0
    collisionObserved := false
    source := sourceParticleVelocity }

def sourceParticleVector : SourceParticleInput :=
  { state :=
      { positionS := 0, velocityMps := 1, massKg := 1000, forceN := 2,
        frictionN := 0, direction := .forward, slackBound := 0,
        pushPullBound := 0, source := sourceParticleVelocity }
    interactingMassKg := 1000
    interactingFrictionN := 1
    previousLink := some linkageVector
    nextLink := none
    trackTransitionObserved := true
    source := sourceParticleVelocity }

example : (sourceParticleTransition 1 sourceParticleVector).isSome = true := by
  native_decide

def sourceParticleExpected : ParticleState :=
  { positionS := 2
    velocityMps := 1001 / 1000
    massKg := 1000
    forceN := 2
    frictionN := 1
    direction := .forward
    slackBound := 0
    pushPullBound := 0
    source := sourceParticleVelocity }

example : sourceParticleTransition 1 sourceParticleVector =
    some sourceParticleExpected := by
  native_decide

def invalidLinkParticleVector : SourceParticleInput :=
  { sourceParticleVector with
    previousLink := some { linkageVector with currentDistance := -1 } }

example : sourceParticleTransition 1 invalidLinkParticleVector = none := by
  native_decide

def rawCommandVector : RawControllerCommand :=
  { throttle := .finite (1 / 20)
    trainBrake := .finite 1
    independentBrake := .finite 1
    commandAge := .finite (1 / 10)
    pressureAge := .finite (1 / 10) }

example : (apiCommandProducer rawCommandVector).isSome = true := by
  native_decide

def rawNaNCommandVector : RawControllerCommand :=
  { rawCommandVector with throttle := .nan }

example : apiCommandProducer rawNaNCommandVector = none := by
  native_decide

example : numericConvert 0 1 .nan = none := by
  native_decide

example : (runtimeTimingProducer
    { sampleAge := some (1 / 20)
      commandDelay := some (1 / 10)
      pressureDelay := some (1 / 10)
      detectorInfoDelay := some (1 / 10)
      routeChangeLatency := some (1 / 10) }).isSome = true := by
  native_decide

example : runtimeTimingProducer
    { sampleAge := none
      commandDelay := some 1
      pressureDelay := some 1
      detectorInfoDelay := some 1
      routeChangeLatency := some 1 } = none := by
  native_decide

def jarTimingVector : JarTiming :=
  { tickPeriod := 1 / 20
    nextBranchBound := 1 / 200
    source := sourceSimulationNext }

def runtimeTimingVector : RuntimeTiming :=
  { sampleAge := some (1 / 20)
    commandDelay := some (1 / 10)
    pressureDelay := some (1 / 10)
    detectorInfoDelay := some (1 / 10)
    routeChangeLatency := some (1 / 10) }

example : (delayBudgetProducer jarTimingVector runtimeTimingVector).isSome = true := by
  native_decide

example : delayBudgetProducer jarTimingVector
    { runtimeTimingVector with sampleAge := none } = none := by
  native_decide

example :
    (arrivalStep 2 (10 / 2)
      { distanceToTarget := stoppingDistance 10 2, velocity := 10 }).velocity = 0 := by
  native_decide

example : irRestCondition 0 3 4 := by
  constructor
  · rfl
  · unfold absQ
    split <;> native_decide

def delayVector : DelayBudget :=
  { observationAge := 0
    commandDelay := 0
    pressureDelay := 0
    detectorDelay := 0
    routeChangeDelay := 0
    source := sourceSimulationNext }

def brakingBoundVector : BrakingBound :=
  { massKg := 100
    brakeLowerN := 1000
    positiveTractionUpperN := 100
    adverseGradeUpperN := 100
    curvatureUpperN := 0
    slackUpperN := 0
    pushPullUpperN := 0
    localizationError := 1
    terminalTolerance := 1
    delay := delayVector }

example : terminalGuard 10 brakingBoundVector 2 = true := by
  native_decide

example : terminalGuard 10 brakingBoundVector (-1) = false := by
  native_decide

def nonpositiveBoundVector : BrakingBound :=
  { brakingBoundVector with brakeLowerN := 100 }

example : terminalGuard 10 nonpositiveBoundVector 2 = false := by
  native_decide

example :
    (arrivalStep 2 (10 / 2)
      { distanceToTarget := stoppingDistance 10 2, velocity := 10 }).distanceToTarget = 0 := by
  native_decide

example :
    0 ≤ (arrivalStep 2 1
      { distanceToTarget := 10, velocity := 3 }).distanceToTarget ∧
      0 ≤ (arrivalStep 2 1
        { distanceToTarget := 10, velocity := 3 }).velocity := by
  apply arrival_step_preserves_no_crossing
  · native_decide
  · native_decide
  · native_decide
  · native_decide

example :
    (revisionArrivalRun 2 1 3
      { distanceToTarget := 10, velocity := 3 }).velocity ≤ 3 := by
  apply arrival_run_velocity_nonincreasing
  · native_decide
  · native_decide
  · native_decide

def shortAcceptanceContract : TerminalAcceptanceContract :=
  { positionTolerance := 1
    speedTolerance := 1
    requiredStableObservations := 2 }

def acceptedObservation : ArrivalObservation :=
  { frontCouplerError := 1 / 2
    directedSpeed := 1 / 2
    source := sourceSimulationNext }

example : stableObservationAccepted shortAcceptanceContract
    [acceptedObservation] = false := by
  native_decide

example : derivedStopTolerance
    { traceError := 1, fitError := 2, couplerError := 3,
      sampleAgeError := 4, commandDelayError := 5, numericError := 6 } = 21 := by
  native_decide

example : holdingTransition 5 0 3 4 = some (5, 0) := by
  apply holding_preserves_ir_terminal_state
  exact ⟨rfl, by unfold absQ; split <;> native_decide⟩

end IRRevision
