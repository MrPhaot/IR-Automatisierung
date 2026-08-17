# IR jar provenance and hashes

Captured 2026-08-16 from `immersive_railroading/.cache/jar/`.

## Version and class selection

| Item | Observed value | Classification |
|---|---|---|
| Minecraft | `1.7.10` in `mcmod.info` | derived from extracted metadata |
| Immersive Railroading | `1.11.0` in `mcmod.info` | derived from extracted metadata |
| manifest | `Manifest-Version: 1.0` | bytecode/package fact |
| multi-release | `Multi-Release: true` | bytecode/package fact |
| root class major | `52` | bytecode fact; Java 8 |
| `META-INF/versions/16` major | `60` | bytecode fact; Java 16 |
| `META-INF/versions/21` major | `65` | bytecode fact; Java 21 |
| target | root Java-8 classes | certified provenance choice |

The original archive was found at both
`/home/mrphaot/Dokumente/lua/ImmersiveRailroading-1.7.10-forge-1.11.0.jar` and
`/home/mrphaot/Downloads/ImmersiveRailroading-1.7.10-forge-1.11.0.jar`; both
copies have the same SHA-256:

```text
ef1b8b465ed511fefba9482e36ec7067ac8b854c3c510b62a8e4c1a91b8daec9  ImmersiveRailroading-1.7.10-forge-1.11.0.jar
```

The archive was extracted into a temporary directory and compared with
`.cache/jar/`. All 1,945 regular archive files matched byte-for-byte. The four
additional files in `.cache/jar/` are generated decompilation snapshots:
`Configuration_decompiled.txt`, `LocomotiveDefinition_decompiled.txt`,
`Particle_decompiled.txt`, and `SimulationState_decompiled.txt`.

All versioned classes were excluded from source evidence. The root Java-8
classes are the selected target; `META-INF/versions/16` and
`META-INF/versions/21` are variant-drift controls only. For example, root,
version-16, and version-21 physics/API classes have different hashes.

## Manifest and metadata hashes

```text
29d333b67b81058749ee6ac3f8dec628bb55616abb0f6517f7cdac792f7c0c6e  META-INF/MANIFEST.MF
c380f08cd58155f1cacb2c7d72231bdb9a140c9c4e5d4512dd4a76db2946bfb0  mcmod.info
```

## Relevant root Java-8 class hashes

```text
66ab2dc7dc4ca1f3845ac0c424db24360a2d143ebc1f769a2ac51c8f377414d6  cam72cam/immersiverailroading/thirdparty/CommonAPI.class
cd652442dc2feece119d8a83586f78425f8ec77dd77104b5691c94053778fc21  cam72cam/immersiverailroading/thirdparty/opencomputers/AugmentDriver.class
427c6b20c5cade7b98060a6b892d781dbe3cd16176164028188d71651cd4800f  cam72cam/immersiverailroading/thirdparty/opencomputers/AugmentDriver$AugmentManagerBase.class
64d104ec3f579076719ed700aecb47814a39eec908779c4578780e1acd630e7c  cam72cam/immersiverailroading/thirdparty/opencomputers/AugmentDriver$DetectorAugment.class
81723d0236a4725b497562ac1b6a40d0457f6abdfc473f7565de02001530232e  cam72cam/immersiverailroading/thirdparty/opencomputers/AugmentDriver$LocoControlAugment.class
963d07e117cc438552d44f41db912b1a37d41bb2e8eb394ab3bb532cb9e1b440  cam72cam/immersiverailroading/thirdparty/opencomputers/RadioCtrlCardDriver.class
9183995071e2a5d69f943f3d5a2df277ac2846bb8b3ee5424481474fa3126b24  cam72cam/immersiverailroading/thirdparty/opencomputers/RadioCtrlCardDriver$RadioCtrlCardManager.class
89c3c38e5fc9a3a236de8703f1b3f2222d8c9fa4a8e857a62122d3edd4013d27  cam72cam/immersiverailroading/entity/EntityRollingStock.class
7cd59459c7cb8fd18c3e2c44a1fb2f0e3ca9408a2c76d4fbde037dadd6465aa1  cam72cam/immersiverailroading/entity/EntityCoupleableRollingStock.class
c6e6c9e7f8ef5765f8f707b75a0ec0f9c54e6c7791f52f1deacdc918e3050a8a  cam72cam/immersiverailroading/entity/EntityMoveableRollingStock.class
559cfc0a9ccc31456ba1bbfe0a663030e9a773b2ba8f64e01ae90a006bf01a31  cam72cam/immersiverailroading/entity/Locomotive.class
6957e09922a2fecb0098252e951ba09b2364930209fab92613fbb7c7600456fc  cam72cam/immersiverailroading/registry/LocomotiveDefinition.class
ad8c9dc314c966c509d3646371508e4045281dd1fc5e436e4fa0371f0c367fcb  cam72cam/immersiverailroading/library/PhysicalMaterials.class
b29e258af54a62b618d8150843b659351c49b867b99f2ba2ab5a295127b54208  cam72cam/immersiverailroading/Config$ConfigBalance.class
53fbba66dd08db82d9651918f70b253f097c128435c30a1eaf452357f2f526d2  cam72cam/immersiverailroading/entity/physics/SimulationState.class
084ac91d5852415bacf219ea2500986d1640da0fef6aeb5b19684cb842773a8d  cam72cam/immersiverailroading/entity/physics/SimulationState$Configuration.class
927fa7a53c414025001487d6dc11cdaee25423eeb8ec0754d9666ba0309e7b48  cam72cam/immersiverailroading/entity/physics/Consist.class
4ded715f2f790fa00d9882c18f44d6027bcb4d1c6a1b7d4f07db0914dc1b469f  cam72cam/immersiverailroading/entity/physics/Consist$Particle.class
770a32040b7d7f2dfc96dab18763e8923a820c5d365e05beeb20dd61084e20e3  cam72cam/immersiverailroading/physics/MovementTrack.class
143e12a743a9a28db3f8e886377f35b7b49a960034ef2c72d8c271981d2f715c  cam72cam/immersiverailroading/thirdparty/trackapi/ITrack.class
6382ebcaa04730d2df5b8203078b174a9469b5023aa83aa13c446eff417d4860  cam72cam/immersiverailroading/track/CubicCurve.class
2b8253349bef8c24e510e4d3f6c069dcb934fb62cdb8613715a8aa0b00ecc069  cam72cam/immersiverailroading/track/BuilderStraight.class
e84e9e2f631620b926adcf4c646b2d5ea3ebbd23a47673efba18fbc798076f52  cam72cam/immersiverailroading/track/BuilderTurn.class
ba90bdc07403391269490a8cafcd5de02ed13bbc552a23f95351850a31522470  cam72cam/immersiverailroading/track/BuilderSlope.class
862c4c3e61eb2473cc54eba01bc8f546d5595037d57e46380dc51839146e9cdd  cam72cam/immersiverailroading/track/BuilderSwitch.class
f8466642228c38895c0dba4a9d91b1972031e78b00435f10ab0717c268832cd4  cam72cam/immersiverailroading/track/BuilderCrossing.class
1ac737fe978c9c5b8e7872b5f27b33cd2d9a35081cc20c3c20bf60acde6f8f03  cam72cam/immersiverailroading/util/RailInfo.class
f54c4e1a3aebb797a8b304ea80d8b25cfcca348ceea7d6f486945ad6d850a324  cam72cam/immersiverailroading/library/TrackItems.class
82b71e6bd5cbe6ab3cdfc5fe4fd0a4bf5a43f8a71a68902bd42a5310ef78d3c6  cam72cam/immersiverailroading/items/nbt/RailSettings.class
```

## Root versus multi-release drift checks

```text
b29e258af54a62b618d8150843b659351c49b867b99f2ba2ab5a295127b54208  root cam72cam/immersiverailroading/Config$ConfigBalance.class
eaeab313c066d2582c4f143fb8f9370f9aed07ec2717e71cf70b4e75936ddb41  META-INF/versions/16/.../Config$ConfigBalance.class
53fbba66dd08db82d9651918f70b253f097c128435c30a1eaf452357f2f526d2  root .../SimulationState.class
d124f5c56872003dfeb942ff3d0fa724422f626c9702111f44829343a02b617c  META-INF/versions/16/.../SimulationState.class
```

## Decompiled-input hashes

```text
def38a76699a6db00e36807e3fbd913c3578952a0891429feb7240364664fff3  SimulationState_decompiled.txt
84377d308e7cdcd29efafc7efeb3a4e4e5fc43f5b0cdbe7c398dcbbb3345bbe5  Configuration_decompiled.txt
a8f2f622a7f24e669e4f45553d188f26409303952bc3c21ec08511b93078fa2d  Particle_decompiled.txt
820047c214a2b94604a876dc5e51ed7c5dc6ac13290c34a936d0d6f6d2b7826f  LocomotiveDefinition_decompiled.txt
```
