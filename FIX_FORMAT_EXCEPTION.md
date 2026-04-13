# 🔍 Search API - FormatException Fix

## Current Error

```
FormatException: Filter error, bad data
```

**Good News:** The cleartext traffic fix worked! The app is now reaching the API.

**The Problem:** The response from the API is causing a parsing error. This typically happens when:
1. The API returns HTML instead of JSON (error page)
2. Response encoding/compression issues
3. Response format doesn't match expectations

---

## 🚀 Quick Fix: Change Response Type

The issue is likely that Dio is trying to automatically decode the response and failing. Let's handle the raw response first, then parse it manually.

### **Update DioClient Configuration**

Find this line in `/Users/nvc/Documents/Sid/putaway/lib/core/network/dio_client.dart` around line 28:

**Current:**
```dart
void _configureDio() {
  _dio.options = BaseOptions(
    baseUrl: AppConfig.instance.fullBaseUrl,
    connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
    receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
    sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    // Add this line:
    responseType: ResponseType.plain,  // ← ADD THIS
  );
```

**Add:** `responseType: ResponseType.plain,` after the headers section.

---

## ✅ Alternative: Test with Postman First

Before modifying code, let's verify the API is working:

### **1. Use the exact token from your app:**

From your logs:
```
token: 044M0RPr7iXHi54dUpWnEgnxwJvL+X50boUbfqv95lDeIA=MDE5MDEwMjY5NzQ2OTgwNTQ3NTcxMzg1N01PQklMRV9BUFAxNzc2MDUwOTE2NDE2
```

### **2. Make the request in Postman:**

```
POST http://129.154.245.81:7070/jderest/searchpurchaseorder

Headers:
- Content-Type: application/json

Body (JSON):
{
  "deviceName": "MOBILE_APP",
  "token": "044M0RPr7iXHi54dUpWnEgnxwJvL+X50boUbfqv95lDeIA=MDE5MDEwMjY5NzQ2OTgwNTQ3NTcxMzg1N01PQklMRV9BUFAxNzc2MDUwOTE2NDE2",
  "OrderNumber": "1071",
  "OrderType": "OP",
  "BranchPlant": "AWH"
}
```

### **3. Check the response:**

- Does it return JSON?
- What's the status code?
- Is there any HTML in the response?

---

## 🔧 If Postman Works

If Postman returns valid JSON but the app doesn't, the issue is with how Dio is handling the response. 

### **Option 1: Disable Response Transformer (Quick Test)**

Add to `_configureDio()`:

```dart
_dio.options = BaseOptions(
  // ... existing options ...
  responseType: ResponseType.plain,
);

// Add transformer to handle response manually
_dio.transformer = BackgroundTransformer();
```

### **Option 2: Add Custom Response Interceptor**

Create a new file: `lib/core/network/interceptors/response_interceptor.dart`

```dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ResponseInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('ResponseInterceptor: Status ${response.statusCode}');
    _logger.d('ResponseInterceptor: Data type: ${response.data.runtimeType}');
    _logger.d('ResponseInterceptor: Raw data: ${response.data}');

    // If response is string, try to parse as JSON
    if (response.data is String) {
      try {
        final jsonData = jsonDecode(response.data as String);
        response.data = jsonData;
        _logger.i('ResponseInterceptor: Successfully parsed JSON');
      } catch (e) {
        _logger.e('ResponseInterceptor: Failed to parse JSON: $e');
        _logger.e('ResponseInterceptor: Raw response was: ${response.data}');
      }
    }

    handler.next(response);
  }
}
```

Then add it to Dio client in `_configureDio()`:

```dart
_dio.interceptors.add(ResponseInterceptor());
```

---

## 🔍 Debug: Check What the API Actually Returns

Add this temporary logging to `order_remote_data_source.dart` after the API call:

```dart
final response = await dioClient.post(
  AppConstants.endpointSearchOrders,
  data: requestBody,
);

// Add these debug logs:
_logger.i('=== RESPONSE DEBUG ===');
_logger.i('Status Code: ${response.statusCode}');
_logger.i('Response Headers: ${response.headers}');
_logger.i('Response Data Type: ${response.data.runtimeType}');
_logger.i('Response Data Length: ${response.data.toString().length}');
_logger.i('First 500 chars of response: ${response.data.toString().substring(0, min(500, response.data.toString().length))}');
_logger.i('=== END DEBUG ===');
```

This will show us exactly what the API is returning.

---

## 🎯 Most Likely Issue

The "Filter error, bad data" typically means:

1. **GZIP Compression Issue**: The response is compressed but Dio can't decompress it properly
2. **Encoding Issue**: The response uses a different character encoding
3. **Malformed JSON**: The JSON has special characters or is malformed

### **Try This Fix:**

In `_configureDio()`, add:

```dart
_dio.options = BaseOptions(
  // ... existing options ...
  responseDecoder: (responseBytes, options, responseBody) {
    // Log raw bytes
    print('Raw response bytes length: ${responseBytes.length}');
    
    // Try to decode as UTF-8
    try {
      final decoded = utf8.decode(responseBytes);
      print('Decoded response: $decoded');
      return decoded;
    } catch (e) {
      print('Failed to decode: $e');
      rethrow;
    }
  },
);
```

---

## 📋 Action Plan

**Step 1:** Test in Postman with the exact same token
- If fails → API issue, check with backend team
- If works → Continue to Step 2

**Step 2:** Add `responseType: ResponseType.plain` to DioClient

**Step 3:** Add response logging to see raw response

**Step 4:** Based on what you see, we'll adjust the parsing

---

Try Postman first and let me know what you get! That will tell us if it's an API issue or a parsing issue in the app.
