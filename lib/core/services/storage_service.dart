/// 存储服务接口
/// 
/// 定义本地存储的抽象接口，支持不同存储实现

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// 存储服务单例
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  bool _initialized = false;

  /// 初始化存储服务
  Future<void> initialize() async {
    if (_initialized) return;

    // 获取应用文档目录
    final appDocDir = await getApplicationDocumentsDirectory();
    
    // 初始化 Hive，使用应用文档目录
    await Hive.initFlutter('${appDocDir.path}/wripal_data');
    
    _initialized = true;
  }

  /// 打开指定名称的 Box
  Future<Box<T>> openBox<T>(String name) async {
    if (!_initialized) {
      await initialize();
    }
    return await Hive.openBox<T>(name);
  }

  /// 获取已打开的 Box
  Box<T>? getBox<T>(String name) {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }
    return null;
  }

  /// 关闭所有 Box
  Future<void> closeAll() async {
    await Hive.close();
  }

  /// 删除指定 Box
  Future<void> deleteBox(String name) async {
    await Hive.deleteBoxFromDisk(name);
  }
}
