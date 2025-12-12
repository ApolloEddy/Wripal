/// 存储服务接口
///
/// 定义本地存储的抽象接口，支持不同存储实现
/// 在 Web 平台使用 IndexedDB，其他平台使用文件系统

import 'package:flutter/foundation.dart' show kIsWeb;
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

    if (kIsWeb) {
      // Web 平台：使用 IndexedDB（hive_flutter 自动处理）
      await Hive.initFlutter();
    } else {
      // 原生平台：使用应用文档目录
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter('${appDocDir.path}/wripal_data');
      } catch (e) {
        // 如果获取目录失败，使用默认初始化
        await Hive.initFlutter();
      }
    }

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
