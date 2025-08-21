import { MemoryStats, ComponentInstance, LargeDataObject } from '../models/DataModels';
import { DataGenerator } from './DataGenerator';

/**
 * 内存跟踪器
 * 用于跟踪和统计内存使用情况，模拟内存泄露检测
 */
export class MemoryTracker {
  private static instance: MemoryTracker;
  private componentInstances: Map<string, ComponentInstance> = new Map();
  private allocatedObjects: Map<string, LargeDataObject> = new Map();
  private memoryStats: MemoryStats = {
    totalAllocated: 0,
    currentUsage: 0,
    leakedMemory: 0,
    componentCount: 0
  };

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): MemoryTracker {
    if (!MemoryTracker.instance) {
      MemoryTracker.instance = new MemoryTracker();
    }
    return MemoryTracker.instance;
  }

  /**
   * 注册组件实例
   * @param id 组件ID
   * @param type 组件类型
   * @param memorySize 内存大小
   */
  registerComponent(id: string, type: 'leaky' | 'proper', memorySize: number): void {
    const instance: ComponentInstance = {
      id: id,
      type: type,
      createdAt: Date.now(),
      memorySize: memorySize,
      isDestroyed: false
    };
    
    this.componentInstances.set(id, instance);
    this.updateMemoryStats();
  }

  /**
   * 注销组件实例
   * @param id 组件ID
   * @param isProperCleanup 是否正确清理
   */
  unregisterComponent(id: string, isProperCleanup: boolean = false): void {
    const instance = this.componentInstances.get(id);
    if (instance) {
      instance.isDestroyed = true;
      
      if (!isProperCleanup && instance.type === 'leaky') {
        // 模拟内存泄露：组件被销毁但内存未释放
        this.memoryStats.leakedMemory += instance.memorySize;
      }
      
      this.updateMemoryStats();
    }
  }

  /**
   * 分配内存对象
   * @param obj 大数据对象
   */
  allocateObject(obj: LargeDataObject): void {
    this.allocatedObjects.set(obj.id, obj);
    this.memoryStats.totalAllocated += DataGenerator.getObjectMemorySize(obj);
    this.updateMemoryStats();
  }

  /**
   * 释放内存对象
   * @param objectId 对象ID
   */
  deallocateObject(objectId: string): void {
    const obj = this.allocatedObjects.get(objectId);
    if (obj) {
      this.allocatedObjects.delete(objectId);
      this.updateMemoryStats();
    }
  }

  /**
   * 获取当前内存统计
   */
  getMemoryStats(): MemoryStats {
    return {
      totalAllocated: this.memoryStats.totalAllocated,
      currentUsage: this.memoryStats.currentUsage,
      leakedMemory: this.memoryStats.leakedMemory,
      componentCount: this.memoryStats.componentCount
    };
  }

  /**
   * 获取活跃组件列表
   */
  getActiveComponents(): ComponentInstance[] {
    return Array.from(this.componentInstances.values())
      .filter(instance => !instance.isDestroyed);
  }

  /**
   * 获取泄露的组件列表
   */
  getLeakedComponents(): ComponentInstance[] {
    return Array.from(this.componentInstances.values())
      .filter(instance => instance.isDestroyed && instance.type === 'leaky');
  }

  /**
   * 清理所有内存（用于重置演示）
   */
  clearAllMemory(): void {
    this.componentInstances.clear();
    this.allocatedObjects.clear();
    this.memoryStats = {
      totalAllocated: 0,
      currentUsage: 0,
      leakedMemory: 0,
      componentCount: 0
    };
  }

  /**
   * 更新内存统计信息
   */
  private updateMemoryStats(): void {
    let currentUsage = 0;
    let componentCount = 0;

    // 计算当前使用的内存
    for (const obj of this.allocatedObjects.values()) {
      currentUsage += DataGenerator.getObjectMemorySize(obj);
    }

    // 计算活跃组件数量
    for (const instance of this.componentInstances.values()) {
      if (!instance.isDestroyed) {
        componentCount++;
      }
    }

    this.memoryStats.currentUsage = currentUsage;
    this.memoryStats.componentCount = componentCount;
  }

  /**
   * 模拟垃圾回收
   * 清理已标记为销毁且正确清理的组件
   */
  simulateGarbageCollection(): void {
    const toRemove: string[] = [];
    
    for (const [id, instance] of this.componentInstances.entries()) {
      if (instance.isDestroyed && instance.type === 'proper') {
        toRemove.push(id);
      }
    }
    
    toRemove.forEach(id => {
      this.componentInstances.delete(id);
    });
    
    this.updateMemoryStats();
  }
}