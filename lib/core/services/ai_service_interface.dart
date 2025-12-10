/// AI 服务接口定义
/// 
/// 预留 AI 功能接口，后续集成本地模型或云端 API
/// 当前为接口定义，具体实现留待 Phase 2+

/// AI 分析结果类型
enum AIAnalysisType {
  /// 手写文字识别 (OCR)
  handwritingRecognition,
  
  /// 内容分类
  contentClassification,
  
  /// 文本摘要
  textSummarization,
  
  /// 智能标签
  smartTagging,
}

/// AI 分析结果
class AIAnalysisResult {
  final AIAnalysisType type;
  final String content;
  final double confidence;
  final Map<String, dynamic>? metadata;

  AIAnalysisResult({
    required this.type,
    required this.content,
    required this.confidence,
    this.metadata,
  });
}

/// AI 服务抽象接口
abstract class AIServiceInterface {
  /// 初始化 AI 服务
  Future<void> initialize();

  /// 释放资源
  Future<void> dispose();

  /// 是否可用
  bool get isAvailable;

  /// 手写识别
  Future<AIAnalysisResult> recognizeHandwriting(List<int> imageBytes);

  /// 内容分类
  Future<AIAnalysisResult> classifyContent(String text);

  /// 文本摘要
  Future<AIAnalysisResult> summarizeText(String text, {int maxLength = 100});

  /// 智能标签生成
  Future<List<String>> generateTags(String content);
}

/// Mock AI 服务实现（测试用）
class MockAIService implements AIServiceInterface {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  bool get isAvailable => _initialized;

  @override
  Future<AIAnalysisResult> recognizeHandwriting(List<int> imageBytes) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return AIAnalysisResult(
      type: AIAnalysisType.handwritingRecognition,
      content: '[Mock] 手写内容识别结果',
      confidence: 0.85,
    );
  }

  @override
  Future<AIAnalysisResult> classifyContent(String text) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AIAnalysisResult(
      type: AIAnalysisType.contentClassification,
      content: 'note',
      confidence: 0.9,
      metadata: {'categories': ['笔记', '学习']},
    );
  }

  @override
  Future<AIAnalysisResult> summarizeText(String text, {int maxLength = 100}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final summary = text.length > maxLength 
        ? '${text.substring(0, maxLength)}...' 
        : text;
    return AIAnalysisResult(
      type: AIAnalysisType.textSummarization,
      content: summary,
      confidence: 0.88,
    );
  }

  @override
  Future<List<String>> generateTags(String content) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ['笔记', '手写', '学习'];
  }
}
