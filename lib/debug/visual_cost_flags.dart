const bool kDisableGrainPainter = bool.fromEnvironment(
  'DISABLE_GRAIN_PAINTER',
  defaultValue: false,
);

const bool kDisablePatternLayers = bool.fromEnvironment(
  'DISABLE_PATTERN_LAYERS',
  defaultValue: false,
);

const bool kDisableShaderMask = bool.fromEnvironment(
  'DISABLE_SHADER_MASK',
  defaultValue: false,
);

const bool kDisableCardShadow = bool.fromEnvironment(
  'DISABLE_CARD_SHADOW',
  defaultValue: false,
);

const bool kShowCardSnapshotDebug = bool.fromEnvironment(
  'SHOW_CARD_SNAPSHOT_DEBUG',
  defaultValue: false,
);

const String kVisualCostExperimentName = String.fromEnvironment(
  'VISUAL_COST_EXPERIMENT',
  defaultValue: 'baseline',
);
