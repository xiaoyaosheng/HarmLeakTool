import { MemoryStats } from '../models/DataModels';

/**
 * 内存工具函数
 * 提供内存相关的辅助功能和格式化方法
 */
export class MemoryUtils {
  
  /**
   * 格式化字节数为可读的字符串
   * @param bytes 字节数
   * @returns string 格式化后的字符串
   */
  static formatBytes(bytes: number): string {
    if (bytes === 0) return '0 B';
    
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }

  /**
   * 计算内存使用百分比
   * @param used 已使用内存
   * @param total 总内存
   * @returns number 百分比 (0-100)
   */
  static calculateMemoryPercentage(used: number, total: number): number {
    if (total === 0) return 0;
    return Math.round((used / total) * 100);
  }

  /**
   * 检查是否存在内存泄露
   * @param stats 内存统计信息
   * @returns boolean 是否存在泄露
   */
  static hasMemoryLeak(stats: MemoryStats): boolean {
    return stats.leakedMemory > 0;
  }

  /**
   * 获取内存泄露严重程度
   * @param stats 内存统计信息
   * @returns string 严重程度描述
   */
  static getLeakSeverity(stats: MemoryStats): string {
    const leakPercentage = MemoryUtils.calculateMemoryPercentage(stats.leakedMemory, stats.totalAllocated);
    
    if (leakPercentage === 0) return '无泄露';
    if (leakPercentage < 10) return '轻微';
    if (leakPercentage < 30) return '中等';
    if (leakPercentage < 60) return '严重';
    return '极严重';
  }

  /**
   * 生成内存报告
   * @param stats 内存统计信息
   * @returns string 内存报告文本
   */
  static generateMemoryReport(stats: MemoryStats): string {
    const report = [
      `=== 内存使用报告 ===`,
      `总分配内存: ${MemoryUtils.formatBytes(stats.totalAllocated)}`,
      `当前使用: ${MemoryUtils.formatBytes(stats.currentUsage)}`,
      `泄露内存: ${MemoryUtils.formatBytes(stats.leakedMemory)}`,
      `活跃组件: ${stats.componentCount}个`,
      `泄露严重程度: ${MemoryUtils.getLeakSeverity(stats)}`,
      `==================`
    ];
    
    return report.join('\n');
  }

  /**
   * 生成唯一ID
   * @param prefix 前缀
   * @returns string 唯一ID
   */
  static generateUniqueId(prefix: string = 'component'): string {
    return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 模拟内存压力测试数据
   * @param componentCount 组件数量
   * @returns MemoryStats 模拟的内存统计
   */
  static simulateMemoryPressure(componentCount: number): MemoryStats {
    const baseMemoryPerComponent = 10 * 1024 * 1024; // 10MB per component
    const totalAllocated = componentCount * baseMemoryPerComponent;
    const leakRate = 0.3; // 30% 泄露率
    const leakedMemory = Math.floor(totalAllocated * leakRate);
    const currentUsage = totalAllocated - leakedMemory;

    return {
      totalAllocated,
      currentUsage,
      leakedMemory,
      componentCount
    };
  }

  /**
   * 检查内存使用是否超过阈值
   * @param stats 内存统计信息
   * @param thresholdMB 阈值（MB）
   * @returns boolean 是否超过阈值
   */
  static isMemoryUsageExcessive(stats: MemoryStats, thresholdMB: number = 100): boolean {
    const thresholdBytes = thresholdMB * 1024 * 1024;
    return stats.currentUsage > thresholdBytes;
  }

  /**
   * 获取内存使用建议
   * @param stats 内存统计信息
   * @returns string[] 建议列表
   */
  static getMemoryOptimizationSuggestions(stats: MemoryStats): string[] {
    const suggestions: string[] = [];
    
    if (MemoryUtils.hasMemoryLeak(stats)) {
      suggestions.push('检查组件的aboutToDisappear生命周期方法');
      suggestions.push('确保及时清理大数据对象的引用');
      suggestions.push('取消未完成的定时器和订阅');
    }
    
    if (MemoryUtils.isMemoryUsageExcessive(stats)) {
      suggestions.push('考虑减少同时存在的组件数量');
      suggestions.push('实现数据的懒加载和分页');
      suggestions.push('使用对象池复用大数据对象');
    }
    
    if (stats.componentCount > 10) {
      suggestions.push('考虑实现组件的虚拟化渲染');
      suggestions.push('优化组件的创建和销毁频率');
    }
    
    return suggestions;
  }
}