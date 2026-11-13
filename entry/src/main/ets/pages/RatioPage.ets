@Entry
@Component
struct RatioPage {
  @State wValue: string = '';
  @State hValue: string = '';
  // 约分结果，如 "16 : 9"；输入无效时为空串
  @State resultText: string = '';
  // 结果下方的说明文字，如"已约去公因数 80"；无结果时为空串
  @State hintText: string = '';

  /** 字符串转数字，空串或非法输入返回 null */
  private toNum(value: string): number | null {
    const s = value.trim();
    if (s.length === 0) {
      return null;
    }
    const n = Number(s);
    return Number.isNaN(n) ? null : n;
  }

  /** 统计小数位数，用于把小数放大成整数再约分 */
  private decimalsOf(s: string): number {
    const idx = s.indexOf('.');
    return idx < 0 ? 0 : (s.length - idx - 1);
  }

  /** 辗转相除求最大公因数（取绝对值） */
  private gcd(a: number, b: number): number {
    let x = Math.abs(Math.round(a));
    let y = Math.abs(Math.round(b));
    while (y > 0) {
      const t = x % y;
      x = y;
      y = t;
    }
    return x;
  }

  /**
   * 统一处理两个输入框的输入并重新约分
   * 任意一项变化时都从两项的原始输入重算，避免中间状态残留
   */
  private handleInput(field: string, value: string): void {
    if (field === 'w') {
      this.wValue = value;
    } else {
      this.hValue = value;
    }

    this.resultText = '';
    this.hintText = '';

    const w = this.toNum(this.wValue);
    const h = this.toNum(this.hValue);
    if (w === null || h === null) {
      return; // 任一项为空或非法时不展示结果
    }
    if (w <= 0 || h <= 0) {
      this.hintText = '请输入大于 0 的数值';
      return;
    }

    // 支持小数：按最长的小数位数放大成整数再约分
    // 如 12.8 : 7.2 → 128 : 72 → 16 : 9
    let k = Math.max(this.decimalsOf(this.wValue.trim()), this.decimalsOf(this.hValue.trim()));
    k = Math.min(k, 6);
    const scale = Math.pow(10, k);
    const wi = Math.round(w * scale);
    const hi = Math.round(h * scale);

    const g = this.gcd(wi, hi);
    this.resultText = `${wi / g} : ${hi / g}`;
    this.hintText = g > 1 ? `已约去公因数 ${g}` : '已是最简比例';
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
          this.getUIContext().getRouter().back();
        })

        Text('最简比例')
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

      // 输入卡片：两个输入框中间用冒号分隔
      Column() {
        Row() {
          TextInput({ text: this.wValue, placeholder: '宽度' })
            .type(InputType.NUMBER_DECIMAL)
            .layoutWeight(1)
            .height(44)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Center)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.handleInput('w', value);
            })

          Text(':')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ left: 12, right: 12 })

          TextInput({ text: this.hValue, placeholder: '高度' })
            .type(InputType.NUMBER_DECIMAL)
            .layoutWeight(1)
            .height(44)
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.Center)
            .backgroundColor(Color.Transparent)
            .onChange((value: string) => {
              this.handleInput('h', value);
            })
        }
        .width('100%')
        .height(72)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .margin({ top: 16 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .clip(true)

      // 结果卡片
      Column() {
        if (this.resultText.length > 0) {
          Text(this.resultText)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text(this.hintText)
            .fontSize(12)
            .fontColor($r('sys.color.font_tertiary'))
            .margin({ top: 8 })
        } else if (this.hintText.length > 0) {
          Text(this.hintText)
            .fontSize(14)
            .fontColor($r('sys.color.font_tertiary'))
        } else {
          Text('分别输入两个数值，自动约分为最简整数比')
            .fontSize(14)
            .fontColor($r('sys.color.font_tertiary'))
        }
      }
      .width('100%')
      .margin({ top: 16 })
      .padding({ top: 24, bottom: 24 })
      .borderRadius(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))

      Text('示例：输入 1280 和 720，得到 16 : 9')
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
