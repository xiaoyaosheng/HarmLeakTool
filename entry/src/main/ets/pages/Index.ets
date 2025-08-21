import { LeakyComponent } from '../components/LeakyComponent';
import { ControlPanel } from '../components/ControlPanel';
import { ComponentInstance, MemoryStats, ComponentCounts } from '../models/DataModels';
import { MemoryUtils } from '../utils/MemoryUtils';
import router from '@ohos.router';

/**
 * 内存泄露演示主页面
 *
 * 这是内存泄露演示功能的主容器组件，负责：
 * 1. 整合所有子组件 (LeakyComponent, ProperComponent, MemoryMonitor, ControlPanel)
 * 2. 管理组件实例的动态创建和销毁
 * 3. 协调各组件间的状态和交互
 * 4. 提供页面导航和布局管理
 *
 * 满足需求: 2.1, 3.1, 3.2
 */
@Entry
@Component
struct MemoryLeakDemo {
  // 当前视图模式
  @State private currentView: 'leaky' | 'proper' | 'comparison' = 'leaky';

  // 组件实例管理
  @State private leakyComponents: ComponentInstance[] = [];
  @State private properComponents: ComponentInstance[] = [];
  @State private componentIdCounter: number = 0;

  // 内存统计
  @State private memoryStats: MemoryStats = {
    totalAllocated: 0,
    currentUsage: 0,
    leakedMemory: 0,
    componentCount: 0
  };

  // 操作状态
  @State private isOperating: boolean = false;
  @State private operationMessage: string = '';

  // 页面状态
  @State private pageTitle: string = '鸿蒙内存泄露模拟';
  @State private showInstructions: boolean = true;

  /**
   * 页面即将出现时的生命周期方法
   */
  aboutToAppear() {
    console.info('[MemoryLeakDemo] 页面开始加载');
    this.initializePage();
  }

  /**
   * 页面即将消失时的生命周期方法
   * 确保清理所有资源
   */
  aboutToDisappear() {
    console.info('[MemoryLeakDemo] 页面开始销毁，清理所有资源');
    this.resetAllComponents();
  }

  /**
   * 初始化页面
   */
  private initializePage(): void {
    // 重置统计信息
    this.updateMemoryStats();
    console.info('[MemoryLeakDemo] 页面初始化完成');
  }

  /**
   * 创建组件实例
   * 需求 3.1: 实现组件创建功能
   */
  private createComponent = (type: 'leaky' | 'proper'): void => {
    if (this.isOperating) {
      return;
    }

    this.setOperating(true, `正在创建${type === 'leaky' ? '泄露' : '正确'}组件...`);

    try {
      const componentId = `${type}_${++this.componentIdCounter}_${Date.now()}`;
      const memorySize = this.calculateComponentMemorySize(type);

      const newComponent: ComponentInstance = {
        id: componentId,
        type: type,
        createdAt: Date.now(),
        memorySize: memorySize,
        isDestroyed: false
      };

      if (type === 'leaky') {
        this.leakyComponents.push(newComponent);
        console.info(`[MemoryLeakDemo] 创建泄露组件: ${componentId}`);
      } else {
        this.properComponents.push(newComponent);
        console.info(`[MemoryLeakDemo] 创建正确组件: ${componentId}`);
      }

      // 更新内存统计
      this.updateMemoryStats();

      setTimeout(() => {
        this.setOperating(false, '');
      }, 500);

    } catch (error) {
      console.error('[MemoryLeakDemo] 创建组件失败:', error);
      this.setOperating(false, '');
    }
  };

  /**
   * 销毁组件实例
   * 需求 3.1: 实现组件销毁功能
   */
  private destroyComponent = (type: 'leaky' | 'proper'): void => {
    if (this.isOperating) {
      return;
    }

    const components = type === 'leaky' ? this.leakyComponents : this.properComponents;
    if (components.length === 0) {
      return;
    }

    this.setOperating(true, `正在销毁${type === 'leaky' ? '泄露' : '正确'}组件...`);

    try {
      // 找到最后一个未销毁的组件
      const componentToDestroy = components.find(comp => !comp.isDestroyed);

      if (componentToDestroy) {
        componentToDestroy.isDestroyed = true;
        console.info(`[MemoryLeakDemo] 销毁组件: ${componentToDestroy.id}`);

        // 从数组中移除组件
        if (type === 'leaky') {
          this.leakyComponents = this.leakyComponents.filter(comp => comp.id !== componentToDestroy.id);
        } else {
          this.properComponents = this.properComponents.filter(comp => comp.id !== componentToDestroy.id);
        }

        // 更新内存统计
        this.updateMemoryStats();
      }

      setTimeout(() => {
        this.setOperating(false, '');
      }, 300);

    } catch (error) {
      console.error('[MemoryLeakDemo] 销毁组件失败:', error);
      this.setOperating(false, '');
    }
  };

  /**
   * 批量操作组件
   * 需求 3.3: 实现批量操作功能
   */
  private batchOperation = (operation: 'create' | 'destroy', count: number, type: 'leaky' | 'proper'): void => {
    if (this.isOperating) {
      return;
    }

    const operationName = operation === 'create' ? '创建' : '销毁';
    const componentName = type === 'leaky' ? '泄露' : '正确';

    this.setOperating(true, `正在批量${operationName} ${count} 个${componentName}组件...`);

    // 使用异步操作来避免阻塞UI
    setTimeout(() => {
      try {
        for (let i = 0; i < count; i++) {
          if (operation === 'create') {
            this.createComponentSync(type);
          } else {
            this.destroyComponentSync(type);
          }
        }

        this.updateMemoryStats();
        console.info(`[MemoryLeakDemo] 批量${operationName}完成: ${count} 个${componentName}组件`);

      } catch (error) {
        console.error(`[MemoryLeakDemo] 批量${operationName}失败:`, error);
      } finally {
        this.setOperating(false, '');
      }
    }, 100);
  };

  /**
   * 同步创建组件（用于批量操作）
   */
  private createComponentSync(type: 'leaky' | 'proper'): void {
    const componentId = `${type}_${++this.componentIdCounter}_${Date.now()}`;
    const memorySize = this.calculateComponentMemorySize(type);

    const newComponent: ComponentInstance = {
      id: componentId,
      type: type,
      createdAt: Date.now(),
      memorySize: memorySize,
      isDestroyed: false
    };

    if (type === 'leaky') {
      this.leakyComponents.push(newComponent);
    } else {
      this.properComponents.push(newComponent);
    }
  }

  /**
   * 同步销毁组件（用于批量操作）
   */
  private destroyComponentSync(type: 'leaky' | 'proper'): void {
    const components = type === 'leaky' ? this.leakyComponents : this.properComponents;
    const componentToDestroy = components.find(comp => !comp.isDestroyed);

    if (componentToDestroy) {
      if (type === 'leaky') {
        this.leakyComponents = this.leakyComponents.filter(comp => comp.id !== componentToDestroy.id);
      } else {
        this.properComponents = this.properComponents.filter(comp => comp.id !== componentToDestroy.id);
      }
    }
  }

  /**
   * 切换视图模式
   * 需求 3.2: 实现视图切换功能
   */
  private switchView = (view: 'leaky' | 'proper' | 'comparison'): void => {
    if (this.currentView !== view) {
      this.currentView = view;
      console.info(`[MemoryLeakDemo] 切换到视图: ${view}`);
    }
  };

  /**
   * 清理内存
   * 需求 3.2: 实现内存清理功能
   */
  private clearMemory = (): void => {
    if (this.isOperating) {
      return;
    }

    this.setOperating(true, '正在清理内存...');

    setTimeout(() => {
      try {
        // 模拟内存清理：重新计算内存统计
        this.updateMemoryStats();
        console.info('[MemoryLeakDemo] 内存清理完成');

      } catch (error) {
        console.error('[MemoryLeakDemo] 内存清理失败:', error);
      } finally {
        this.setOperating(false, '');
      }
    }, 1000);
  };

  /**
   * 重置所有组件
   * 需求 3.2: 实现重置功能
   */
  private resetAllComponents = (): void => {
    if (this.isOperating) {
      return;
    }

    this.setOperating(true, '正在重置所有组件...');

    setTimeout(() => {
      try {
        // 清空所有组件
        this.leakyComponents = [];
        this.properComponents = [];
        this.componentIdCounter = 0;

        // 重置内存统计
        this.updateMemoryStats();

        console.info('[MemoryLeakDemo] 重置完成');

      } catch (error) {
        console.error('[MemoryLeakDemo] 重置失败:', error);
      } finally {
        this.setOperating(false, '');
      }
    }, 800);
  };

  /**
   * 更新内存统计信息
   */
  private updateMemoryStats(): void {
    const leakyMemory = this.leakyComponents.reduce((total, comp) => total + comp.memorySize, 0);
    const properMemory = this.properComponents.reduce((total, comp) => total + comp.memorySize, 0);

    this.memoryStats = {
      totalAllocated: leakyMemory + properMemory,
      currentUsage: properMemory, // 正确组件的内存会被正确释放
      leakedMemory: leakyMemory,  // 泄露组件的内存不会被释放
      componentCount: this.leakyComponents.length + this.properComponents.length
    };
  }

  /**
   * 计算组件内存大小
   */
  private calculateComponentMemorySize(type: 'leaky' | 'proper'): number {
    // 每个泄露组件约占用10MB内存（5个2MB的数据对象）
    // 正确组件在销毁时会释放内存
    return type === 'leaky' ? 10 : 10;
  }

  /**
   * 设置操作状态
   */
  private setOperating(operating: boolean, message: string): void {
    this.isOperating = operating;
    this.operationMessage = message;
  }

  /**
   * 返回主页
   */
  private goBack = (): void => {
    router.back();
  };

  /**
   * 构建页面UI
   */
  build() {
    Column({ space: 0 }) {
      // 页面标题栏
      this.buildTitleBar()

      // 页面内容
      Scroll() {
        Column({ space: 16 }) {
          // 使用说明
          if (this.showInstructions) {
            this.buildInstructions()
          }

          // 控制面板
          ControlPanel({
            currentView: this.currentView,
            componentCounts: {
              leaky: this.leakyComponents.length,
              proper: this.properComponents.length
            } as ComponentCounts,
            memoryUsage: this.memoryStats.totalAllocated,
            isOperating: this.isOperating,
            onCreateComponent: this.createComponent,
            onDestroyComponent: this.destroyComponent,
            onClearMemory: this.clearMemory,
            onSwitchView: this.switchView,
            onBatchOperation: this.batchOperation,
            onResetAll: this.resetAllComponents
          })

          // 内存监控面板（临时实现，等待MemoryMonitor组件）
          this.buildMemoryMonitorPlaceholder()

          // 组件展示区域
          this.buildComponentDisplay()
        }
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 构建标题栏
   */
  @Builder
  private buildTitleBar() {
    Row({ space: 12 }) {
      // 返回按钮
      Button('← 返回')
        .type(ButtonType.Normal)
        .backgroundColor('#FFFFFF')
        .fontColor('#2196F3')
        .border({
          width: 1,
          color: '#2196F3',
          style: BorderStyle.Solid
        })
        .borderRadius(6)
        .fontSize(14)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .onClick(this.goBack)

      // 页面标题
      Text(this.pageTitle)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      // 说明开关
      Button(this.showInstructions ? '隐藏说明' : '显示说明')
        .type(ButtonType.Normal)
        .backgroundColor('#FFFFFF')
        .fontColor('#666666')
        .border({
          width: 1,
          color: '#E0E0E0',
          style: BorderStyle.Solid
        })
        .borderRadius(6)
        .fontSize(12)
        .padding({ left: 8, right: 8, top: 6, bottom: 6 })
        .onClick(() => {
          this.showInstructions = !this.showInstructions;
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .border({
      width: { bottom: 1 },
      color: '#E0E0E0',
      style: BorderStyle.Solid
    })
  }

  /**
   * 构建使用说明
   */
  @Builder
  private buildInstructions() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('📖')
          .fontSize(18)
        Text('使用说明')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .alignItems(VerticalAlign.Center)

      Column({ space: 8 }) {
        Text('1. 使用控制面板创建和销毁组件，观察内存使用变化')
          .fontSize(12)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
          .width('100%')

        Text('2. 泄露组件在销毁后不会释放内存，正确组件会正确清理')
          .fontSize(12)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
          .width('100%')

        Text('3. 使用批量操作可以快速创建多个组件观察内存泄露效果')
          .fontSize(12)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
          .width('100%')

        Text('4. 切换不同视图模式可以对比两种组件的实现差异')
          .fontSize(12)
          .fontColor('#666666')
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#E3F2FD')
    .borderRadius(8)
    .border({
      width: 1,
      color: '#2196F3',
      style: BorderStyle.Solid
    })
  }

  /**
   * 构建内存监控占位符（等待MemoryMonitor组件实现）
   */
  @Builder
  private buildMemoryMonitorPlaceholder() {
    Column({ space: 12 }) {
      Text('📊 内存监控')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Row({ space: 16 }) {
        // 总内存
        Column({ space: 4 }) {
          Text('总分配')
            .fontSize(12)
            .fontColor('#666666')
          Text(`${this.memoryStats.totalAllocated.toFixed(1)} MB`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#2196F3')
        }

        // 当前使用
        Column({ space: 4 }) {
          Text('当前使用')
            .fontSize(12)
            .fontColor('#666666')
          Text(`${this.memoryStats.currentUsage.toFixed(1)} MB`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
        }

        // 泄露内存
        Column({ space: 4 }) {
          Text('泄露内存')
            .fontSize(12)
            .fontColor('#666666')
          Text(`${this.memoryStats.leakedMemory.toFixed(1)} MB`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')
        }

        // 组件数量
        Column({ space: 4 }) {
          Text('组件数量')
            .fontSize(12)
            .fontColor('#666666')
          Text(`${this.memoryStats.componentCount}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
        }
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')

      // 操作状态显示
      if (this.isOperating && this.operationMessage) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(16)
            .height(16)
            .color('#2196F3')
          Text(this.operationMessage)
            .fontSize(12)
            .fontColor('#2196F3')
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({
      width: 1,
      color: '#E0E0E0',
      style: BorderStyle.Solid
    })
  }

  /**
   * 构建组件展示区域
   * 需求 2.1: 同时展示有问题的组件和正确实现的组件
   */
  @Builder
  private buildComponentDisplay() {
    Column({ space: 16 }) {
      Text('🧩 组件展示区域')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      if (this.currentView === 'leaky') {
        // 只显示泄露组件
        this.buildLeakyComponentsView()
      } else if (this.currentView === 'proper') {
        // 只显示正确组件（占位符）
        this.buildProperComponentsView()
      } else if (this.currentView === 'comparison') {
        // 对比视图
        this.buildComparisonView()
      }
    }
    .width('100%')
  }

  /**
   * 构建泄露组件视图
   */
  @Builder
  private buildLeakyComponentsView() {
    Column({ space: 12 }) {
      Text(`泄露组件 (${this.leakyComponents.length} 个)`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FF6B6B')
        .alignSelf(ItemAlign.Start)

      if (this.leakyComponents.length === 0) {
        Text('暂无泄露组件，请使用控制面板创建')
          .fontSize(12)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding(32)
          .backgroundColor('#F9F9F9')
          .borderRadius(8)
      } else {
        // 显示前3个泄露组件作为示例
        ForEach(this.leakyComponents.slice(0, 3), (component: ComponentInstance) => {
          LeakyComponent()
            .margin({ bottom: 8 })
        })

        if (this.leakyComponents.length > 3) {
          Text(`... 还有 ${this.leakyComponents.length - 3} 个泄露组件`)
            .fontSize(12)
            .fontColor('#999999')
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding(16)
            .backgroundColor('#F9F9F9')
            .borderRadius(8)
        }
      }
    }
    .width('100%')
  }

  /**
   * 构建正确组件视图（占位符）
   */
  @Builder
  private buildProperComponentsView() {
    Column({ space: 12 }) {
      Text(`正确组件 (${this.properComponents.length} 个)`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#4CAF50')
        .alignSelf(ItemAlign.Start)

      // 占位符，等待ProperComponent组件实现
      Column({ space: 8 }) {
        Text('🚧 正确组件开发中')
          .fontSize(16)
          .fontColor('#FF9800')
        Text('ProperComponent 组件尚未实现')
          .fontSize(12)
          .fontColor('#666666')
        Text('请先完成任务3的实现')
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('100%')
      .padding(32)
      .backgroundColor('#FFF3E0')
      .borderRadius(8)
      .border({
        width: 1,
        color: '#FF9800',
        style: BorderStyle.Dashed
      })
    }
    .width('100%')
  }

  /**
   * 构建对比视图
   */
  @Builder
  private buildComparisonView() {
    Row({ space: 16 }) {
      // 左侧：泄露组件
      Column({ space: 12 }) {
        Text('❌ 泄露组件')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FF6B6B')

        if (this.leakyComponents.length > 0) {
          LeakyComponent()
        } else {
          Text('暂无泄露组件')
            .fontSize(12)
            .fontColor('#999999')
            .padding(16)
            .backgroundColor('#FFF5F5')
            .borderRadius(8)
        }
      }
      .layoutWeight(1)

      // 右侧：正确组件（占位符）
      Column({ space: 12 }) {
        Text('✅ 正确组件')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#4CAF50')

        // 占位符
        Column({ space: 4 }) {
          Text('🚧 开发中')
            .fontSize(12)
            .fontColor('#FF9800')
          Text('ProperComponent')
            .fontSize(10)
            .fontColor('#666666')
          Text('尚未实现')
            .fontSize(10)
            .fontColor('#666666')
        }
        .padding(16)
        .backgroundColor('#FFF3E0')
        .borderRadius(8)
        .border({
          width: 1,
          color: '#FF9800',
          style: BorderStyle.Dashed
        })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }
}