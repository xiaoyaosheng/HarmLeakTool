import { ComponentCounts } from '../models/DataModels';

/**
 * 控制面板组件
 * 
 * 提供用户交互控制功能，包括：
 * 1. 组件创建和销毁控制
 * 2. 视图切换功能
 * 3. 内存清理和重置功能
 * 4. 批量操作功能
 * 
 * 满足需求: 3.1, 3.2, 3.3
 */
@Component
export struct ControlPanel {
  // 回调函数接口
  onCreateComponent?: (type: 'leaky' | 'proper') => void;
  onDestroyComponent?: (type: 'leaky' | 'proper') => void;
  onClearMemory?: () => void;
  onSwitchView?: (view: 'leaky' | 'proper' | 'comparison') => void;
  onBatchOperation?: (operation: 'create' | 'destroy', count: number, type: 'leaky' | 'proper') => void;
  onResetAll?: () => void;

  // 当前状态
  @Prop currentView: 'leaky' | 'proper' | 'comparison' = 'leaky';
  @Prop componentCounts: ComponentCounts = { leaky: 0, proper: 0 };
  @Prop memoryUsage: number = 0;
  @Prop isOperating: boolean = false;

  // 内部状态
  @State private batchCount: number = 5;
  @State private selectedBatchType: 'leaky' | 'proper' = 'leaky';
  @State private showBatchControls: boolean = false;

  build() {
    Column({ space: 16 }) {
      // 标题
      Text('控制面板')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      // 视图切换区域
      this.buildViewSwitcher()

      // 组件状态显示
      this.buildStatusDisplay()

      // 单个组件控制区域
      this.buildSingleComponentControls()

      // 批量操作区域
      this.buildBatchControls()

      // 内存管理区域
      this.buildMemoryControls()
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#F8F9FA')
    .borderRadius(12)
    .border({
      width: 1,
      color: '#E0E0E0',
      style: BorderStyle.Solid
    })
  }

  /**
   * 构建视图切换器
   * 需求 3.2: 实现视图切换功能
   */
  @Builder
  private buildViewSwitcher() {
    Column({ space: 12 }) {
      Text('视图模式')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#555555')

      Row({ space: 8 }) {
        // 泄露组件视图
        Button('泄露组件')
          .type(ButtonType.Normal)
          .backgroundColor(this.currentView === 'leaky' ? '#FF6B6B' : '#FFFFFF')
          .fontColor(this.currentView === 'leaky' ? '#FFFFFF' : '#FF6B6B')
          .border({
            width: 1,
            color: '#FF6B6B',
            style: BorderStyle.Solid
          })
          .borderRadius(6)
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onClick(() => {
            if (this.onSwitchView) {
              this.onSwitchView('leaky');
            }
          })

        // 正确组件视图
        Button('正确组件')
          .type(ButtonType.Normal)
          .backgroundColor(this.currentView === 'proper' ? '#4CAF50' : '#FFFFFF')
          .fontColor(this.currentView === 'proper' ? '#FFFFFF' : '#4CAF50')
          .border({
            width: 1,
            color: '#4CAF50',
            style: BorderStyle.Solid
          })
          .borderRadius(6)
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onClick(() => {
            if (this.onSwitchView) {
              this.onSwitchView('proper');
            }
          })

        // 对比视图
        Button('对比视图')
          .type(ButtonType.Normal)
          .backgroundColor(this.currentView === 'comparison' ? '#2196F3' : '#FFFFFF')
          .fontColor(this.currentView === 'comparison' ? '#FFFFFF' : '#2196F3')
          .border({
            width: 1,
            color: '#2196F3',
            style: BorderStyle.Solid
          })
          .borderRadius(6)
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .onClick(() => {
            if (this.onSwitchView) {
              this.onSwitchView('comparison');
            }
          })
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  /**
   * 构建状态显示区域
   */
  @Builder
  private buildStatusDisplay() {
    Column({ space: 8 }) {
      Text('组件状态')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#555555')

      Row({ space: 16 }) {
        // 泄露组件数量
        Column({ space: 4 }) {
          Text('泄露组件')
            .fontSize(12)
            .fontColor('#FF6B6B')
          Text(`${this.componentCounts.leaky}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')
        }

        // 正确组件数量
        Column({ space: 4 }) {
          Text('正确组件')
            .fontSize(12)
            .fontColor('#4CAF50')
          Text(`${this.componentCounts.proper}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
        }

        // 内存使用量
        Column({ space: 4 }) {
          Text('内存使用')
            .fontSize(12)
            .fontColor('#FF9800')
          Text(`${this.memoryUsage.toFixed(1)} MB`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
        }
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  /**
   * 构建单个组件控制区域
   * 需求 3.1: 创建组件创建和销毁的控制按钮
   */
  @Builder
  private buildSingleComponentControls() {
    Column({ space: 12 }) {
      Text('单个组件控制')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#555555')

      // 泄露组件控制
      Row({ space: 8 }) {
        Text('泄露组件:')
          .fontSize(14)
          .fontColor('#FF6B6B')
          .width(80)

        Button('创建')
          .type(ButtonType.Normal)
          .backgroundColor('#FF6B6B')
          .fontColor('#FFFFFF')
          .borderRadius(6)
          .fontSize(12)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .enabled(!this.isOperating)
          .onClick(() => {
            if (this.onCreateComponent) {
              this.onCreateComponent('leaky');
            }
          })

        Button('销毁')
          .type(ButtonType.Normal)
          .backgroundColor('#FFFFFF')
          .fontColor('#FF6B6B')
          .border({
            width: 1,
            color: '#FF6B6B',
            style: BorderStyle.Solid
          })
          .borderRadius(6)
          .fontSize(12)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .enabled(!this.isOperating && this.componentCounts.leaky > 0)
          .onClick(() => {
            if (this.onDestroyComponent) {
              this.onDestroyComponent('leaky');
            }
          })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')

      // 正确组件控制
      Row({ space: 8 }) {
        Text('正确组件:')
          .fontSize(14)
          .fontColor('#4CAF50')
          .width(80)

        Button('创建')
          .type(ButtonType.Normal)
          .backgroundColor('#4CAF50')
          .fontColor('#FFFFFF')
          .borderRadius(6)
          .fontSize(12)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .enabled(!this.isOperating)
          .onClick(() => {
            if (this.onCreateComponent) {
              this.onCreateComponent('proper');
            }
          })

        Button('销毁')
          .type(ButtonType.Normal)
          .backgroundColor('#FFFFFF')
          .fontColor('#4CAF50')
          .border({
            width: 1,
            color: '#4CAF50',
            style: BorderStyle.Solid
          })
          .borderRadius(6)
          .fontSize(12)
          .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          .enabled(!this.isOperating && this.componentCounts.proper > 0)
          .onClick(() => {
            if (this.onDestroyComponent) {
              this.onDestroyComponent('proper');
            }
          })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  /**
   * 构建批量操作控制区域
   * 需求 3.3: 实现批量操作功能以快速触发内存泄露
   */
  @Builder
  private buildBatchControls() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Text('批量操作')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#555555')

        Button(this.showBatchControls ? '收起' : '展开')
          .type(ButtonType.Normal)
          .backgroundColor('#FFFFFF')
          .fontColor('#2196F3')
          .border({
            width: 1,
            color: '#2196F3',
            style: BorderStyle.Solid
          })
          .borderRadius(4)
          .fontSize(10)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => {
            this.showBatchControls = !this.showBatchControls;
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')

      if (this.showBatchControls) {
        Column({ space: 12 }) {
          // 批量操作配置
          Row({ space: 12 }) {
            Text('数量:')
              .fontSize(14)
              .fontColor('#666666')

            Button('-')
              .type(ButtonType.Circle)
              .backgroundColor('#E0E0E0')
              .fontColor('#666666')
              .width(32)
              .height(32)
              .fontSize(16)
              .enabled(this.batchCount > 1)
              .onClick(() => {
                if (this.batchCount > 1) {
                  this.batchCount--;
                }
              })

            Text(`${this.batchCount}`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .width(40)
              .textAlign(TextAlign.Center)

            Button('+')
              .type(ButtonType.Circle)
              .backgroundColor('#E0E0E0')
              .fontColor('#666666')
              .width(32)
              .height(32)
              .fontSize(16)
              .enabled(this.batchCount < 20)
              .onClick(() => {
                if (this.batchCount < 20) {
                  this.batchCount++;
                }
              })
          }
          .alignItems(VerticalAlign.Center)

          // 组件类型选择
          Row({ space: 8 }) {
            Text('类型:')
              .fontSize(14)
              .fontColor('#666666')

            Button('泄露组件')
              .type(ButtonType.Normal)
              .backgroundColor(this.selectedBatchType === 'leaky' ? '#FF6B6B' : '#FFFFFF')
              .fontColor(this.selectedBatchType === 'leaky' ? '#FFFFFF' : '#FF6B6B')
              .border({
                width: 1,
                color: '#FF6B6B',
                style: BorderStyle.Solid
              })
              .borderRadius(4)
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => {
                this.selectedBatchType = 'leaky';
              })

            Button('正确组件')
              .type(ButtonType.Normal)
              .backgroundColor(this.selectedBatchType === 'proper' ? '#4CAF50' : '#FFFFFF')
              .fontColor(this.selectedBatchType === 'proper' ? '#FFFFFF' : '#4CAF50')
              .border({
                width: 1,
                color: '#4CAF50',
                style: BorderStyle.Solid
              })
              .borderRadius(4)
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .onClick(() => {
                this.selectedBatchType = 'proper';
              })
          }
          .alignItems(VerticalAlign.Center)

          // 批量操作按钮
          Row({ space: 12 }) {
            Button(`批量创建 ${this.batchCount} 个`)
              .type(ButtonType.Normal)
              .backgroundColor(this.selectedBatchType === 'leaky' ? '#FF6B6B' : '#4CAF50')
              .fontColor('#FFFFFF')
              .borderRadius(6)
              .fontSize(12)
              .layoutWeight(1)
              .enabled(!this.isOperating)
              .onClick(() => {
                if (this.onBatchOperation) {
                  this.onBatchOperation('create', this.batchCount, this.selectedBatchType);
                }
              })

            Button(`批量销毁 ${this.batchCount} 个`)
              .type(ButtonType.Normal)
              .backgroundColor('#FFFFFF')
              .fontColor(this.selectedBatchType === 'leaky' ? '#FF6B6B' : '#4CAF50')
              .border({
                width: 1,
                color: this.selectedBatchType === 'leaky' ? '#FF6B6B' : '#4CAF50',
                style: BorderStyle.Solid
              })
              .borderRadius(6)
              .fontSize(12)
              .layoutWeight(1)
              .enabled(!this.isOperating && 
                ((this.selectedBatchType === 'leaky' && this.componentCounts.leaky >= this.batchCount) ||
                 (this.selectedBatchType === 'proper' && this.componentCounts.proper >= this.batchCount)))
              .onClick(() => {
                if (this.onBatchOperation) {
                  this.onBatchOperation('destroy', this.batchCount, this.selectedBatchType);
                }
              })
          }
          .width('100%')

          // 快速触发内存泄露按钮
          Button('🚀 快速触发内存泄露 (创建10个泄露组件)')
            .type(ButtonType.Normal)
            .backgroundColor('#FF4444')
            .fontColor('#FFFFFF')
            .borderRadius(6)
            .fontSize(12)
            .width('100%')
            .enabled(!this.isOperating)
            .onClick(() => {
              if (this.onBatchOperation) {
                this.onBatchOperation('create', 10, 'leaky');
              }
            })
        }
        .width('100%')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  /**
   * 构建内存管理控制区域
   * 需求 3.2: 添加内存清理和重置功能
   */
  @Builder
  private buildMemoryControls() {
    Column({ space: 12 }) {
      Text('内存管理')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#555555')

      Row({ space: 8 }) {
        // 内存清理按钮
        Button('清理内存')
          .type(ButtonType.Normal)
          .backgroundColor('#FF9800')
          .fontColor('#FFFFFF')
          .borderRadius(6)
          .fontSize(12)
          .layoutWeight(1)
          .enabled(!this.isOperating)
          .onClick(() => {
            if (this.onClearMemory) {
              this.onClearMemory();
            }
          })

        // 重置所有按钮
        Button('重置所有')
          .type(ButtonType.Normal)
          .backgroundColor('#F44336')
          .fontColor('#FFFFFF')
          .borderRadius(6)
          .fontSize(12)
          .layoutWeight(1)
          .enabled(!this.isOperating)
          .onClick(() => {
            if (this.onResetAll) {
              this.onResetAll();
            }
          })
      }
      .width('100%')

      // 操作提示
      if (this.isOperating) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(16)
            .height(16)
            .color('#2196F3')

          Text('操作进行中...')
            .fontSize(12)
            .fontColor('#2196F3')
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .margin({ top: 8 })
      }

      // 使用说明
      Column({ space: 4 }) {
        Text('使用说明:')
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#666666')

        Text('• 创建泄露组件后不销毁可观察内存泄露')
          .fontSize(10)
          .fontColor('#999999')

        Text('• 使用批量操作可快速触发大量内存泄露')
          .fontSize(10)
          .fontColor('#999999')

        Text('• 对比视图可同时观察两种组件的差异')
          .fontSize(10)
          .fontColor('#999999')

        Text('• 清理内存可模拟垃圾回收效果')
          .fontSize(10)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ top: 8 })
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}