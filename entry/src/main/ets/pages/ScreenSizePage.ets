import { router, display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

/** 表格行数据模型：单位 + 宽 + 高 */
interface SizeRow {
  unit: string;
  width: string;
  height: string;
}

@Entry
@Component
struct ScreenSizePage {
  // 表格数据，点击按钮前显示占位符
  @State rows: SizeRow[] = [
    { unit: 'px', width: '—', height: '—' },
    { unit: 'vp', width: '—', height: '—' },
    { unit: '英寸', width: '—', height: '—' }
  ];

  /** 数字格式化：保留指定小数位并去掉末尾多余的 0 */
  private fmt(n: number, digits: number): string {
    if (!Number.isFinite(n)) {
      return '—';
    }
    let s = n.toFixed(digits);
    s = s.replace(/(\.\d*?)0+$/, '$1');
    if (s.endsWith('.')) {
      s = s.slice(0, s.length - 1);
    }
    return s;
  }

  /** 获取屏幕宽高并刷新表格 */
  private fetchScreenSize(): void {
    let d: display.Display;
    try {
      d = display.getDefaultDisplaySync();
      console.log(`dyh1 details about d:${JSON.stringify(d)}`)
    } catch (err) {
      const e = err as BusinessError;
      console.error(`get display failed, code: ${e.code}, message: ${e.message}`);
      return;
    }
    const ui = this.getUIContext();
    this.rows = [
      {
        unit: 'px',
        width: this.fmt(d.width, 0),
        height: this.fmt(d.height, 0)
      },
      {
        unit: 'vp',
        width: this.fmt(ui.px2vp(d.width), 2),
        height: this.fmt(ui.px2vp(d.height), 2)
      },
      {
        unit: '英寸',
        width: this.fmt(d.width / d.xDPI, 2),
        height: this.fmt(d.height / d.yDPI, 2)
      }
    ];
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([$r('sys.color.font_primary')])
        }
        .width(40)
        .height(40)
        .onClick(() => {
          router.back();
        })

        Text('屏幕宽高')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位，保证标题居中
        Row().width(40).height(40)
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8 })

      // 获取屏幕宽高按钮
      Button('获取屏幕宽高')
        .width('100%')
        .height(44)
        .margin({ top: 16 })
        .fontSize(16)
        .backgroundColor($r('sys.color.comp_background_emphasize'))
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(() => {
          this.fetchScreenSize();
        })

      // 屏幕尺寸表格：第一列为单位，第一行为宽、高
      Column() {
        // 表头
        Row() {
          Text('单位')
            .width(72)
            .fontSize(13)
            .fontColor($r('sys.color.font_secondary'))
          Text('宽')
            .layoutWeight(1)
            .fontSize(13)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
          Text('高')
            .layoutWeight(1)
            .fontSize(13)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(44)
        .padding({ left: 16, right: 16 })

        Divider()
          .strokeWidth(0.5)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ left: 16, right: 16 })

        // 数据行
        ForEach(this.rows, (row: SizeRow, index: number) => {
          Row() {
            Text(row.unit)
              .width(72)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text(row.width)
              .layoutWeight(1)
              .fontSize(15)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Center)
            Text(row.height)
              .layoutWeight(1)
              .fontSize(15)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .height(48)
          .padding({ left: 16, right: 16 })

          if (index < this.rows.length - 1) {
            Divider()
              .strokeWidth(0.5)
              .color($r('sys.color.ohos_id_color_list_separator'))
              .margin({ left: 16, right: 16 })
          }
        }, (row: SizeRow) => `${row.unit}_${row.width}_${row.height}`)
      }
      .width('100%')
      .margin({ top: 16 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .clip(true)

      Text('px 为物理像素，vp 按屏幕密度换算，英寸为物理尺寸；旋转屏幕后可再次点击刷新')
        .fontSize(11)
        .fontColor($r('sys.color.font_tertiary'))
        .width('100%')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}
