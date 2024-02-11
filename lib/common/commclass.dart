import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

/////
/////定义一些通用类
/////
//日志打印类
class CustomPrint{
  late final StackTrace _st;
  late String fileName;
  late int lineNumber;

  CustomPrint(this._st){
      _parseTrace();
  }

  void _parseTrace(){
    var traceString = _st.toString().split("\n")[0];
    var index0fFileName = traceString.indexOf(RegExp(r'[A-Za-z_]+.dart'));
    var fileInfo = traceString.substring(index0fFileName);
    var listOfInfos = fileInfo.split(":");
    fileName = listOfInfos[0];
    lineNumber = int.parse(listOfInfos[1].replaceAll(RegExp(r'[^0-9]'),''));  //release模式下若是非纯数字（字符串中包含字母）会报错
    var columnStr = "";
    if(listOfInfos.length > 2){
      columnStr = listOfInfos[2];
      columnStr = columnStr.replaceFirst(")","");
    }
  }
}

class DeviceInfoApi {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static final NetworkInfo _networkInfo = NetworkInfo();

  static String? _lanIPv4 = "";

  static Future<Map<String, dynamic>> getDeviceInfo() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};
    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData = _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
    return deviceData;
  }

  //Android 10使用NetworkInterface无法获取ipv4地址?！ 使用network_info_plus则可以获取ipv4地址
  static Future getDeviceLocalIP() async {
    RegExp ipv4Exp = RegExp(r"((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}"); //正则匹配ipv4地址
    await NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any).then((List<NetworkInterface> interfaces) {
        for (NetworkInterface interface in interfaces) {
          //print(interface); //过滤网桥ip
          if (!interface.name.toLowerCase().contains("lxdbr") && !interface.name.toLowerCase().contains("docker") && !interface.name.toLowerCase().contains("lo")) {
          for (InternetAddress addresses in interface.addresses) {
            if (ipv4Exp.hasMatch(addresses.address)) {
              _lanIPv4 = addresses.address;
              break;
            }
            //print(addresses.address);
          }
          }
        }
      }
    );
    if (_lanIPv4!.isEmpty) {
      _lanIPv4 = await _networkInfo.getWifiIP();
    }
    return _lanIPv4;
  }

  // ignore: slash_for_doc_comments
  /**
   *  获取network 信息
   */
  static Future getNetworkInfo(Function func) async {
    //判断网络类型
    final Connectivity connectivity = Connectivity();
    ConnectivityResult result = await connectivity.checkConnectivity();
    //StreamSubscription<ConnectivityResult> connectivitySubscription =
    connectivity.onConnectivityChanged.listen(func as void Function(ConnectivityResult event)?);
    //print(result.toString());
    return parseNetworkInfoResult(result);
  }

  static Future<Map> parseNetworkInfoResult(ConnectivityResult result) async {
    if (result == ConnectivityResult.ethernet) {
      //print(result);
      //未连接wifi
      return {'type': 'ethernet', 'wifiName': "以太网"};
    } else if (result == ConnectivityResult.wifi) {
      //已连接wifi
      String? wifiName = "已接入WiFi";
      try {
        //判断是否获取 location 权限
        // PermissionStatus permission = await Permission.location.status;
        // if(permission == PermissionStatus.denied){
        //   //await Permission.location.request();
        //   //wifiName = '点击定位授权';
        // } else {
        //   wifiName = await _networkInfo.getWifiName();
        // }
        //print('permission request');
        // ignore: unused_catch_clause
      } on PlatformException catch (e) {
        wifiName = '无法获取wifiName';
      }
      return {'type': 'wifi', 'wifiName': wifiName};
    } else if(result == ConnectivityResult.mobile){
      return {'type': 'mobile', 'wifiName': "移动网络"};
    } else {
      return {'type': 'nowifi'};
    }
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
          ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
      'serialNumber': build.serialNumber,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  static Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  static Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  static Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
      'model': data.productName,
    };
  }
}
