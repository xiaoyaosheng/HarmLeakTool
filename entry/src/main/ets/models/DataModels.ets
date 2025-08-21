/**
 * 额外数据项接口
 */
export interface ExtraDataItem {
  id: number;
  value: string;
  timestamp: number;
}

/**
 * 大数据对象元数据接口
 */
export interface LargeDataMetadata {
  componentId?: string;
  index?: number;
  description?: string;
  createdAt?: string;
  extraData?: ExtraDataItem[];
  type?: string;
  createdBy?: string;
  lastAccessed?: string;
}

/**
 * 大数据对象接口
 * 用于模拟内存占用较大的数据结构
 */
export interface LargeDataObject {
  id: string;
  data: ArrayBuffer;  // 大数据块
  metadata: LargeDataMetadata;
  timestamp: number;
}

/**
 * 内存统计信息
 * 用于跟踪和显示内存使用情况
 */
export interface MemoryStats {
  totalAllocated: number;    // 总分配内存
  currentUsage: number;      // 当前使用内存
  leakedMemory: number;      // 泄露的内存
  componentCount: number;    // 组件数量
}

/**
 * 组件实例跟踪信息
 * 用于记录组件的创建和销毁状态
 */
export interface ComponentInstance {
  id: string;
  type: 'leaky' | 'proper';
  createdAt: number;
  memorySize: number;
  isDestroyed: boolean;
}

/**
 * 组件数量统计
 * 用于跟踪不同类型组件的数量
 */
export interface ComponentCounts {
  leaky: number;
  proper: number;
}