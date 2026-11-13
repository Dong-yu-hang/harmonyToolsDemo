import { router } from '@kit.ArkUI';

@Entry
@Component
struct PixelUnitPage {
  // 三个单位的值，默认为空；互相联动，任意一项输入后其余两项自动换算
  @State pxValue: string = '';
  @State vpValue: string = '';
  @State fpValue: string = '';

  /** 字符串转数字，空串或非法输入返回 null */
  private toNum(value: string): number | null {
    const s = value.trim();
    if (s.length === 0) {
      return null;
    }
    const n = Number(s);
    return Number.isNaN(n) ? null : n;
  }

  /** 保留 6 位小数并去掉末尾多余的 0 */
  private fmt(n: number): string {
    if (!Number.isFinite(n)) {
      return '';
    }
    let s = n.toFixed(6);
    s = s.replace(/(\.\d*?)0+$/, '$1');
    if (s.endsWith('.')) {
      s = s.slice(0, s.length - 1);
    }
    return s;
  }

  /**
   * 统一处理三个输入框的联动换算
   * 关键点：onChange 入口先过滤"与当前状态相同的事件"——
   * 程序把换算结果写入其它输入框时，框架同样会触发它们的 onChange，
   * 若不过滤，会反向重算正在编辑的输入框，浮点误差逐次累积，
   * 导致输入 5 变成 5.000001 这类一长串数字。
   */
  private handleUnitChange(field: string, value: string): void {
    const current = field === 'px' ? this.pxValue : (field === 'vp' ? this.vpValue : this.fpValue);
    if (value === current) {
      // 程序化写入的回显事件，直接忽略，切断联动循环
      return;
    }

    // 同步当前输入框自身的状态
    if (field === 'px') {
      this.pxValue = value;
    } else if (field === 'vp') {
      this.vpValue = value;
    } else {
      this.fpValue = value;
    }

    const n = this.toNum(value);
    const ui = this.getUIContext();
    if (n === null) {
      // 清空或非法输入：清空另外两项（当前项保留用户输入）
      if (field !== 'px') {
        this.pxValue = '';
      }
      if (field !== 'vp') {
        this.vpValue = '';
      }
      if (field !== 'fp') {
        this.fpValue = '';
      }
      return;
    }

    // 统一以 px 为中间基准，从用户输入的原始值直接换算，避免往返累积误差
    const px = field === 'px' ? n : (field === 'vp' ? ui.vp2px(n) : ui.fp2px(n));
    if (field !== 'px') {
      this.pxValue = this.fmt(px);
    }
    if (field !== 'vp') {
      this.vpValue = this.fmt(ui.px2vp(px));
    }
    if (field !== 'fp') {
      this.fpValue = this.fmt(ui.px2fp(px));
    }
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

        Text('像素单位转换')
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

      // 换算卡片：px / vp / fp 三行联动
      Column() {
        // px 行
        Row() {
          Column({ space: 2 }) {
            Text('px')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text('像素')
              .fontSize(11)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .alignItems(HorizontalAlign.Start)
          .width(72)

          TextInput({ text: this.pxValue })
            .type(InputType.NUMBER_DECIMAL)
            .layoutWeight(1)
            .height(44)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.End)
            .backgroundColor(Color.Transparent)
            .padding({ left: 8, right: 0 })
            .onChange((value: string) => {
              this.handleUnitChange('px', value);
            })
        }
        .width('100%')
        .height(64)
        .padding({ left: 16, right: 16 })

        Divider()
          .strokeWidth(0.5)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ left: 16, right: 16 })

        // vp 行
        Row() {
          Column({ space: 2 }) {
            Text('vp')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text('虚拟像素')
              .fontSize(11)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .alignItems(HorizontalAlign.Start)
          .width(72)

          TextInput({ text: this.vpValue })
            .type(InputType.NUMBER_DECIMAL)
            .layoutWeight(1)
            .height(44)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.End)
            .backgroundColor(Color.Transparent)
            .padding({ left: 8, right: 0 })
            .onChange((value: string) => {
              this.handleUnitChange('vp', value);
            })
        }
        .width('100%')
        .height(64)
        .padding({ left: 16, right: 16 })

        Divider()
          .strokeWidth(0.5)
          .color($r('sys.color.ohos_id_color_list_separator'))
          .margin({ left: 16, right: 16 })

        // fp 行
        Row() {
          Column({ space: 2 }) {
            Text('fp')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
            Text('字体像素')
              .fontSize(11)
              .fontColor($r('sys.color.font_tertiary'))
          }
          .alignItems(HorizontalAlign.Start)
          .width(72)

          TextInput({ text: this.fpValue })
            .type(InputType.NUMBER_DECIMAL)
            .layoutWeight(1)
            .height(44)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.End)
            .backgroundColor(Color.Transparent)
            .padding({ left: 8, right: 0 })
            .onChange((value: string) => {
              this.handleUnitChange('fp', value);
            })
        }
        .width('100%')
        .height(64)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .margin({ top: 16 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .clip(true)

      Text('换算基于当前设备的屏幕密度与系统字体缩放')
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
