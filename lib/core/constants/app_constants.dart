class AppConstants {
  AppConstants._();

  // API Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPage = 1;
  
  // Cache
  static const int cacheMaxAge = 3600;
  static const int cacheMaxCount = 100;
  
  // Local Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUsername = 'username';
  static const String keyUserEmail = 'user_email';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyRememberMe = 'remember_me';
  static const String keyOrganization = 'organization';
  static const String keyBranchPlant = 'branch_plant'; // Store organization/branch for submit API
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  
  // API Endpoints
  static const String endpointLogin = '/tokenrequest';
  static const String endpointLogout = '/tokenrequest/logout';
  static const String endpointRefreshToken = '/auth/refresh';
  static const String endpointSearchOrders = '/v3/orchestrator/ORCH_59_PurchaseOrderLineDetails';
  static const String endpointReceivePurchaseOrder = '/v3/orchestrator/ORCH_59_ReceivePurchaseOrder';
  static const String endpointPutawayTaskDetails = '/v3/orchestrator/ORCH_59_PutawayTaskDetails';
  static const String endpointConfirmPutaway = '/v3/orchestrator/ORCH_59_ConfirmPutawayRequest';
  static const String endpointRoutingOrderDetails =
      '/v3/orchestrator/ORCH_59_RoutingOrderdetails';
  static const String endpointConfirmRouting =
      '/v3/orchestrator/ORCH_59_ConfirmRouting';
  static const String endpointGetOrderDetails = '/orders/details';
  static const String endpointGetRecords = '/records';
  static const String endpointAddRecord = '/records/add';
  static const String endpointUpdateRecord = '/records/update';
  static const String endpointSubmitRecord = '/records/submit';
  static const String endpointGetLocations = '/locations';
  static const String endpointGetItems = '/items';

  /// Orchestrator `Version` for ORCH_59_PutawayTaskDetails / ORCH_59_ConfirmPutawayRequest
  static const String orchestratorVersionPutaway = 'ZJDE0001';
  static const String orchestratorVersionPicking = 'ZJDE0002';

  /// [OrderType] for picking flow task-details / refresh (ORCH_59_PutawayTaskDetails)
  static const String orderTypePickingTasks = 'SO';

  /// [OrderType] for receipt routing (ORCH_59_RoutingOrderdetails / ConfirmRouting)
  static const String orderTypeRouting = 'OP';
  
  // Device Name for API
  static const String deviceName = 'MOBILE_APP';
  
  // Regex Patterns
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String phonePattern = r'^\+?[\d\s\-()]+$';
  static const String alphanumericPattern = r'^[a-zA-Z0-9]+$';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minQuantity = 1;
  static const int maxQuantity = 999999;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;
  
  static const double defaultBorderRadius = 8.0;
  static const double smallBorderRadius = 4.0;
  static const double largeBorderRadius = 12.0;
  static const double extraLargeBorderRadius = 16.0;
  
  static const double defaultElevation = 2.0;
  static const double smallElevation = 1.0;
  static const double largeElevation = 4.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;
  
  // Animation Durations
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  
  // Order Types - API Values
  static const String orderTypePurchaseOrder = 'OP'; // Purchase Order
  static const String orderTypeTransferOrder = 'OT'; // Transfer Order
  static const String orderTypeRMA = 'RMA'; // RMA
  static const String orderTypeASN = 'ASN'; // ASN
  static const String orderTypeReceipt = 'RECEIPT'; // Receipt
  static const String orderTypeIntransitShipment = 'INTRANSIT'; // Intransit Shipment
  
  // Date Formats
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, hh:mm a';
  static const String dateTimeFormatApi = 'yyyy-MM-ddTHH:mm:ss.SSSZ';
  static const String timeFormatDisplay = 'hh:mm a';
}
