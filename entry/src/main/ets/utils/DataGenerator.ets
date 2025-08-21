import { LargeDataObject } from '../models/DataModels';

/**
 * 数据生成工具类
 * 提供创建大数据对象的方法，用于模拟内存占用
 */
export class DataGenerator {
  private static instanceCounter: number = 0;

  /**
   * 创建大数据对象
   * @param sizeInMB 数据大小（MB）
   * @returns LargeDataObject 大数据对象
   */
  static createLargeDataObject(sizeInMB: number = 10): LargeDataObject {
    const id = `data_${++this.instanceCounter}_${Date.now()}`;
    const sizeInBytes = sizeInMB * 1024 * 1024;
    
    // 创建指定大小的ArrayBuffer
    const buffer = new ArrayBuffer(sizeInBytes);
    const view = new Uint8Array(buffer);
    
    // 填充一些随机数据以确保内存真正被占用
    for (let i = 0; i < Math.min(sizeInBytes, 1000); i++) {
      view[i] = Math.floor(Math.random() * 256);
    }

    return {
      id: id,
      data: buffer,
      metadata: {
        size: sizeInMB,
        createdAt: new Date().toISOString(),
        description: `模拟大数据对象 - ${sizeInMB}MB`,
        randomValue: Math.random()
      },
      timestamp: Date.now()
    };
  }

  /**
   * 创建多个大数据对象
   * @param count 对象数量
   * @param sizePerObject 每个对象的大小（MB）
   * @returns LargeDataObject[] 大数据对象数组
   */
  static createMultipleLargeObjects(count: number, sizePerObject: number = 5): LargeDataObject[] {
    const objects: LargeDataObject[] = [];
    for (let i = 0; i < count; i++) {
      objects.push(this.createLargeDataObject(sizePerObject));
    }
    return objects;
  }

  /**
   * 获取对象的内存大小估算
   * @param obj LargeDataObject对象
   * @returns number 内存大小（字节）
   */
  static getObjectMemorySize(obj: LargeDataObject): number {
    let size = obj.data.byteLength;
    
    // 估算metadata的大小
    const metadataStr = JSON.stringify(obj.metadata);
    size += metadataStr.length * 2; // Unicode字符占用2字节
    
    // 加上其他属性的大小估算
    size += obj.id.length * 2;
    size += 8; // timestamp (number)
    
    return size;
  }
}