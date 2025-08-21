/**
 * 数据模型和工具类的简单测试
 * 用于验证基础功能是否正常工作
 */

import { DataGenerator, MemoryTracker, MemoryUtils } from '../utils/index';
import { LargeDataObject, MemoryStats } from '../models/index';

/**
 * 测试数据生成器
 */
export function testDataGenerator(): boolean {
  try {
    console.info('=== 测试数据生成器 ===');
    
    // 测试创建单个大数据对象
    const largeObj = DataGenerator.createLargeDataObject(5);
    console.info(`创建对象ID: ${largeObj.id}`);
    console.info(`数据大小: ${largeObj.data.byteLength} 字节`);
    console.info(`元数据: ${JSON.stringify(largeObj.metadata)}`);
    
    // 测试创建多个对象
    const multipleObjs = DataGenerator.createMultipleLargeObjects(3, 2);
    console.info(`创建了 ${multipleObjs.length} 个对象`);
    
    // 测试内存大小计算
    const memorySize = DataGenerator.getObjectMemorySize(largeObj);
    console.info(`对象内存大小: ${MemoryUtils.formatBytes(memorySize)}`);
    
    return true;
  } catch (error) {
    console.error('数据生成器测试失败:', error);
    return false;
  }
}

/**
 * 测试内存跟踪器
 */
export function testMemoryTracker(): boolean {
  try {
    console.info('=== 测试内存跟踪器 ===');
    
    const tracker = MemoryTracker.getInstance();
    
    // 清理之前的数据
    tracker.clearAllMemory();
    
    // 注册组件
    tracker.registerComponent('comp1', 'leaky', 1024 * 1024); // 1MB
    tracker.registerComponent('comp2', 'proper', 2 * 1024 * 1024); // 2MB
    
    // 创建和分配对象
    const obj1 = DataGenerator.createLargeDataObject(3);
    const obj2 = DataGenerator.createLargeDataObject(4);
    tracker.allocateObject(obj1);
    tracker.allocateObject(obj2);
    
    // 获取统计信息
    let stats = tracker.getMemoryStats();
    console.info('初始统计:', JSON.stringify(stats));
    
    // 模拟组件销毁（泄露场景）
    tracker.unregisterComponent('comp1', false); // 不正确清理
    tracker.unregisterComponent('comp2', true);  // 正确清理
    
    stats = tracker.getMemoryStats();
    console.info('销毁后统计:', JSON.stringify(stats));
    
    // 检查活跃和泄露的组件
    const activeComponents = tracker.getActiveComponents();
    const leakedComponents = tracker.getLeakedComponents();
    console.info(`活跃组件数: ${activeComponents.length}`);
    console.info(`泄露组件数: ${leakedComponents.length}`);
    
    return true;
  } catch (error) {
    console.error('内存跟踪器测试失败:', error);
    return false;
  }
}

/**
 * 测试内存工具函数
 */
export function testMemoryUtils(): boolean {
  try {
    console.info('=== 测试内存工具函数 ===');
    
    // 测试字节格式化
    console.info(`1024 字节 = ${MemoryUtils.formatBytes(1024)}`);
    console.info(`1048576 字节 = ${MemoryUtils.formatBytes(1048576)}`);
    
    // 测试百分比计算
    const percentage = MemoryUtils.calculateMemoryPercentage(256, 1024);
    console.info(`256/1024 = ${percentage}%`);
    
    // 测试内存统计
    const mockStats: MemoryStats = {
      totalAllocated: 10 * 1024 * 1024,
      currentUsage: 7 * 1024 * 1024,
      leakedMemory: 3 * 1024 * 1024,
      componentCount: 5
    };
    
    console.info(`是否有内存泄露: ${MemoryUtils.hasMemoryLeak(mockStats)}`);
    console.info(`泄露严重程度: ${MemoryUtils.getLeakSeverity(mockStats)}`);
    
    // 测试内存报告
    const report = MemoryUtils.generateMemoryReport(mockStats);
    console.info('内存报告:\n' + report);
    
    // 测试优化建议
    const suggestions = MemoryUtils.getMemoryOptimizationSuggestions(mockStats);
    console.info('优化建议:', suggestions);
    
    return true;
  } catch (error) {
    console.error('内存工具函数测试失败:', error);
    return false;
  }
}

/**
 * 运行所有测试
 */
export function runAllTests(): void {
  console.info('开始运行数据模型和工具类测试...');
  
  const results = [
    testDataGenerator(),
    testMemoryTracker(),
    testMemoryUtils()
  ];
  
  const passedTests = results.filter(result => result).length;
  const totalTests = results.length;
  
  console.info(`测试完成: ${passedTests}/${totalTests} 通过`);
  
  if (passedTests === totalTests) {
    console.info('✅ 所有测试通过！基础数据模型和工具类实现正确。');
  } else {
    console.error('❌ 部分测试失败，请检查实现。');
  }
}