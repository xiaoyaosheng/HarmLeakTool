import { LargeDataObject, ComponentInstance, ExtraDataItem, LargeDataMetadata } from '../models/DataModels';
import { MemoryUtils } from '../utils/MemoryUtils';

/**
 * 订阅对象接口
 */
interface Subscription {
  id: string;
  callback: (() => void) | null;
  active: boolean;
}

/**
 * 内存泄露组件演示
 * 
 * 这个组件故意实现了错误的资源管理方式，用于演示内存泄露问题。
 * 主要问题：
 * 1. 缺少aboutToDisappear生命周期方法
 * 2. 未清理大数据对象的引用
 * 3. 未取消定时器和其他资源
 * 
 * ⚠️ 警告：这是一个反面教材，请勿在实际项目中使用此实现方式！
 */
@Component
export struct LeakyComponent {
  // 组件实例ID，用于跟踪
  private instanceId: string = MemoryUtils.generateUniqueId('leaky');
  
  // 大数据对象数组 - 这些数据在组件销毁时不会被清理，导致内存泄露
  private largeDataArray: LargeDataObject[] = [];
  
  // 定时器ID数组 - 这些定时器在组件销毁时不会被清除，导致内存泄露
  private timerIds: number[] = [];
  
  // 模拟的订阅对象 - 这些订阅在组件销毁时不会被取消，导致内存泄露
  private subscriptions: Subscription[] = [];
  
  // 组件状态
  @State private componentTitle: string = `泄露组件 #${this.instanceId.slice(-8)}`;
  @State private dataLoadStatus: string = '正在加载大数据...';
  @State private memoryUsage: string = '0 MB';
  @State private isDataLoaded: boolean = false;

  /**
   * 组件即将出现时的生命周期方法
   * 在这里加载大量数据，模拟内存占用
   */
  aboutToAppear() {
    console.info(`[LeakyComponent] 组件 ${this.instanceId} 开始创建`);
    // 加载大数据对象
    this.loadLargeData();
    
    // 启动定时器（这些定时器不会被清理）
    this.startTimers();
    
    // 模拟订阅（这些订阅不会被取消）
    this.createSubscriptions();
    
    console.info(`[LeakyComponent] 组件 ${this.instanceId} 创建完成，已分配内存`);
  }


  /**
   * 加载大数据对象
   * 创建多个大数据对象来模拟内存占用
   */
  private loadLargeData(): void {
    try {
      // 创建5个大数据对象，每个约2MB
      for (let i = 0; i < 5; i++) {
        const dataSize = 2 * 1024 * 1024; // 2MB
        const metadata: LargeDataMetadata = {
          componentId: this.instanceId,
          index: i,
          description: `这是第${i + 1}个大数据对象`,
          createdAt: new Date().toISOString(),
          // 添加更多元数据来增加内存占用
          extraData: new Array(1000).fill(0).map((value: number, idx): ExtraDataItem => ({
            id: idx,
            value: `数据项_${idx}`,
            timestamp: Date.now() + idx
          }))
        };

        const largeData: LargeDataObject = {
          id: `${this.instanceId}_data_${i}`,
          data: new ArrayBuffer(dataSize), // 分配2MB内存
          metadata: metadata,
          timestamp: Date.now()
        };
        
        // 将数据对象添加到数组中（这个引用不会被清理）
        this.largeDataArray.push(largeData);
      }
      
      // 计算总内存使用量
      const totalMemory = this.largeDataArray.length * 2; // 每个对象约2MB
      this.memoryUsage = `${totalMemory} MB`;
      this.dataLoadStatus = `已加载 ${this.largeDataArray.length} 个大数据对象`;
      this.isDataLoaded = true;
      
      console.info(`[LeakyComponent] ${this.instanceId} 加载了 ${this.largeDataArray.length} 个大数据对象`);
    } catch (error) {
      console.error(`[LeakyComponent] 加载数据时出错:`, error);
      this.dataLoadStatus = '数据加载失败';
    }
  }

  /**
   * 启动定时器
   * 这些定时器会持续运行，即使组件被销毁也不会停止
   */
  private startTimers(): void {
    // 定时器1：每秒更新时间戳
    const timer1 = setInterval(() => {
      // 更新大数据对象的时间戳（持续占用CPU和内存）
      this.largeDataArray?.forEach(data => {
        data.timestamp = Date.now();
      });
    }, 1000);
    this.timerIds.push(timer1);
    
    // 定时器2：每5秒添加更多数据
    const timer2 = setInterval(() => {
      // 持续添加更多数据，加剧内存泄露
      if (this.largeDataArray.length < 10) {
        const additionalMetadata: LargeDataMetadata = { 
          type: 'additional', 
          createdBy: 'timer',
          componentId: this.instanceId,
          index: this.largeDataArray.length,
          description: '定时器添加的额外数据',
          createdAt: new Date().toISOString()
        };
        const instanceId = this.instanceId;
        const additionalData: LargeDataObject = {
          id: `${instanceId}_additional_${Date.now()}`,
          data: new ArrayBuffer(1024 * 1024), // 1MB
          metadata: additionalMetadata,
          timestamp: Date.now()
        };
        this.largeDataArray.push(additionalData);
        console.info(`[LeakyComponent] 定时器添加了额外数据，当前数据量: ${this.largeDataArray.length}`);
      }
    }, 5000);
    this.timerIds.push(timer2);
    
    console.info(`[LeakyComponent] ${this.instanceId} 启动了 ${this.timerIds.length} 个定时器`);
  }

  /**
   * 创建模拟订阅
   * 这些订阅会持续存在，不会被取消
   */
  private createSubscriptions(): void {
    // 模拟事件订阅
    const subscription1: Subscription = {
      id: `sub_${this.instanceId}_1`,
      callback: () => {
        // 模拟订阅回调，持续引用组件数据
        console.debug(`[LeakyComponent] 订阅回调执行，数据量: ${this.largeDataArray.length}`);
      },
      active: true
    };
    
    const subscription2: Subscription = {
      id: `sub_${this.instanceId}_2`,
      callback: () => {
        // 另一个订阅回调
        this.largeDataArray.forEach(data => {
          data.metadata.lastAccessed = Date.now().toString();
        });
      },
      active: true
    };
    
    this.subscriptions.push(subscription1, subscription2);
    
    // 模拟定期触发订阅回调
    const subscriptionTimer = setInterval(() => {
      this.subscriptions.forEach(sub => {
        if (sub.active && sub.callback) {
          sub.callback();
        }
      });
    }, 3000);
    this.timerIds.push(subscriptionTimer);
    
    console.info(`[LeakyComponent] ${this.instanceId} 创建了 ${this.subscriptions.length} 个订阅`);
  }

  /**
   * 构建UI界面
   * 显示组件信息和内存使用情况
   */
  build() {
    Column({ space: 16 }) {
      // 组件标题
      Text(this.componentTitle)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF6B6B')
        .margin({ bottom: 8 })
      
      // 警告标识
      Row({ space: 8 }) {
        Text('⚠️')
          .fontSize(20)
        Text('内存泄露组件')
          .fontSize(14)
          .fontColor('#FF6B6B')
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Center)
      
      // 数据加载状态
      Text(this.dataLoadStatus)
        .fontSize(14)
        .fontColor(this.isDataLoaded ? '#4CAF50' : '#FF9800')
        .textAlign(TextAlign.Center)
      
      // 内存使用情况
      Row({ space: 8 }) {
        Text('内存占用:')
          .fontSize(12)
          .fontColor('#666666')
        Text(this.memoryUsage)
          .fontSize(12)
          .fontColor('#FF6B6B')
          .fontWeight(FontWeight.Bold)
      }
      .justifyContent(FlexAlign.Center)
      
      // 问题说明
      Column({ space: 8 }) {
        Text('存在的问题:')
          .fontSize(12)
          .fontColor('#333333')
          .fontWeight(FontWeight.Medium)
        
        Text('• 缺少 aboutToDisappear 方法')
          .fontSize(10)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
        
        Text('• 未清理大数据对象引用')
          .fontSize(10)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
        
        Text('• 未取消定时器和订阅')
          .fontSize(10)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: 16, right: 16 })
      
      // 组件ID显示
      Text(`ID: ${this.instanceId.slice(-12)}`)
        .fontSize(10)
        .fontColor('#999999')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFF5F5')
    .borderRadius(8)
    .border({
      width: 2,
      color: '#FF6B6B',
      style: BorderStyle.Dashed
    })
  }

  /**
   * ❌ 故意缺少的 aboutToDisappear 生命周期方法
   * 
   * 这是导致内存泄露的主要原因！
   * 
   * 正确的实现应该包含以下清理逻辑：
   * 
   * aboutToDisappear() {
   *   console.info(`[LeakyComponent] 组件 ${this.instanceId} 开始销毁`);
   *   
   *   // 清理大数据对象引用
   *   this.largeDataArray.forEach(data => {
   *     data.data = null;
   *     data.metadata = null;
   *   });
   *   this.largeDataArray = [];
   *   
   *   // 清除所有定时器
   *   this.timerIds.forEach(timerId => {
   *     clearInterval(timerId);
   *   });
   *   this.timerIds = [];
   *   
   *   // 取消所有订阅
   *   this.subscriptions.forEach(sub => {
   *     sub.active = false;
   *     sub.callback = null;
   *   });
   *   this.subscriptions = [];
   *   
   *   console.info(`[LeakyComponent] 组件 ${this.instanceId} 资源清理完成`);
   * }
   * 
   * 但是我们故意不实现这个方法，以演示内存泄露的后果！
   */
}