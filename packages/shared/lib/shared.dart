/// Shared package barrel export for StudyGuardian AI.
///
/// Import this single file to access all models, services, utilities,
/// constants, and theme definitions:
///
/// ```dart
/// import 'package:shared/shared.dart';
/// ```
library shared;

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

export 'models/app_category.dart';
export 'models/user_model.dart';
export 'models/device_model.dart';
export 'models/device_status_model.dart';
export 'models/app_usage_model.dart';
export 'models/daily_usage_model.dart';
export 'models/study_analytics_model.dart';
export 'models/report_model.dart';
export 'models/notification_model.dart';
export 'models/family_model.dart';

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

export 'services/firebase_service.dart';
export 'services/auth_service.dart';
export 'services/firestore_service.dart';
export 'services/fcm_service.dart';
export 'services/hive_service.dart';

// ---------------------------------------------------------------------------
// Utils
// ---------------------------------------------------------------------------

export 'utils/date_utils.dart';
export 'utils/duration_utils.dart';
export 'utils/app_classifier.dart';
export 'utils/study_score_calculator.dart';
export 'utils/summary_generator.dart';
export 'utils/logger.dart';
export 'utils/validators.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

export 'constants/app_constants.dart';
export 'constants/firebase_paths.dart';
export 'constants/category_mappings.dart';

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

export 'theme/app_colors.dart';
export 'theme/app_typography.dart';
export 'theme/glassmorphism.dart';
export 'theme/app_theme.dart';
