# 🔍 Search API Error - Diagnosis Guide

## Current Error

```
DioError ║ DioExceptionType.unknown ║ null
```

This error means the HTTP request couldn't complete. The request is being made correctly (token retrieved, body formatted properly), but something is preventing the response from being received.

---

## 🚨 Most Likely Causes

### 1. **Network/Connection Issue**
The emulator/device can't reach the API server.

**Test:**
```bash
# From your computer, test if the endpoint is reachable:
curl -X POST http://129.154.245.81:7070/jderest/searchpurchaseorder \
  -H "Content-Type: application/json" \
  -d '{
    "deviceName": "POSTMAN",
    "token": "YOUR_TOKEN_HERE",
    "OrderNumber": "1071",
    "OrderType": "OP",
    "BranchPlant": "AWH"
  }'
```

### 2. **Android Emulator Network Configuration**
The Android emulator might not be able to access the network properly.

**Fix:**
- Restart the emulator
- Make sure emulator has internet access
- Try on a physical device instead

### 3. **Cleartext Traffic (Android)**
Android blocks HTTP (non-HTTPS) traffic by default for security.

**Your API uses HTTP (not HTTPS):**
```
http://129.154.245.81:7070  ← HTTP, not HTTPS
```

---

## ✅ FIX: Allow Cleartext HTTP Traffic

Since your API uses HTTP (not HTTPS), you need to tell Android to allow cleartext traffic.

### **Option 1: Allow All Cleartext (Quick Test)**

Update `/Users/nvc/Documents/Sid/putaway/android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:label="putaway">
```

**Add this line:** `android:usesCleartextTraffic="true"`

### **Option 2: Allow Specific Domain (Recommended)**

1. Create file: `android/app/src/main/res/xml/network_security_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">129.154.245.81</domain>
    </domain-config>
</network-security-config>
```

2. Reference it in `AndroidManifest.xml`:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:label="putaway">
```

---

## 🧪 Testing Steps

### **Step 1: Apply the Fix**
Add `android:usesCleartextTraffic="true"` to AndroidManifest.xml

### **Step 2: Restart the App**
```bash
# Stop the app
# Then run again
flutter run
```

**Important:** Just hot restart won't work - you need to fully restart the app for AndroidManifest changes to take effect.

### **Step 3: Test Search Again**
1. Login
2. Try search with order 1071
3. Check logs

---

## 📋 Expected Logs After Fix

You should see:

```
OrderRemoteDataSource: Calling API...
OrderRemoteDataSource: Response received successfully
OrderRemoteDataSource: Response status: 200
OrderRemoteDataSource: Response data: {PurchaseLineDetails: [...]}
OrderRemoteDataSource: Parsing response...
OrderRemoteDataSource: Found 2 line items
```

---

## 🔍 If Still Not Working

### **Check 1: Internet Permission**

Make sure `AndroidManifest.xml` has internet permission:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

This should be at the top level, outside `<application>`.

### **Check 2: Test on Physical Device**

If emulator has issues, try on a real Android device.

### **Check 3: Verify API is Running**

Use Postman to test the exact same request:
```
POST http://129.154.245.81:7070/jderest/searchpurchaseorder

Body (JSON):
{
  "deviceName": "POSTMAN",
  "token": "044sA3pb99C3GXKnyK/LVphSZuVxm3sAHsA9UwpnQALr1A=...",
  "OrderNumber": "1071",
  "OrderType": "OP",
  "BranchPlant": "AWH"
}
```

If Postman works but app doesn't, it's definitely an Android configuration issue.

---

## 🚀 Quick Fix Summary

1. **Add to AndroidManifest.xml:**
   ```xml
   android:usesCleartextTraffic="true"
   ```

2. **Fully restart the app** (not just hot reload)

3. **Test search again**

---

## 📱 Full AndroidManifest.xml Example

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <application
        android:usesCleartextTraffic="true"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:label="putaway">
        
        <activity
            android:name=".MainActivity"
            ...>
        </activity>
    </application>
</manifest>
```

---

## ❓ Why This Happens

**Android 9+ (API 28+)** blocks HTTP traffic by default for security. Since your API uses:
```
http://129.154.245.81:7070  ← HTTP (not secure)
```

You need to explicitly allow cleartext traffic.

**This is the #1 cause of "DioExceptionType.unknown" with null response when calling HTTP APIs from Android apps.**

---

Try the fix and let me know if it works! 🎯
