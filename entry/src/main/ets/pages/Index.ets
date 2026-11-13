import { router } from '@kit.ArkUI';

/** 工具目录项：后续新增工具时在此数组中追加即可 */
interface ToolItem {
  name: string;
  desc: string;
  icon: string;
  pagePath: string;
}

@Entry
@Component
struct Index {
  @State tools: ToolItem[] = [
    {
      name: '像素单位转换',
      desc: 'px / vp / fp 互转',
      icon: '📐',
      pagePath: 'pages/PixelUnitPage'
    },
    {
      name: '图库选择器',
      desc: '拉起系统图库 Picker 选图',
      icon: '🖼️',
      pagePath: 'pages/PhotoPickerPage'
    },
    {
      name: '屏幕宽高',
      desc: '查看当前设备屏幕的宽高尺寸',
      icon: '📱',
      pagePath: 'pages/ScreenSizePage'
    },
    {
      name: '最简比例',
      desc: '把宽高比约分成最简整数比',
      icon: '🔢',
      pagePath: 'pages/RatioPage'
    }
  ];

  build() {
    Column() {
      Text('工具箱')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .margin({ top: 16, bottom: 12 })

      List({ space: 12 }) {
        ForEach(this.tools, (tool: ToolItem) => {
          ListItem() {
            Row() {
              Text(tool.icon)
                .fontSize(24)
                .width(44)
                .height(44)
                .textAlign(TextAlign.Center)
                .borderRadius(12)
                .backgroundColor($r('sys.color.comp_background_tertiary'))

              Column({ space: 2 }) {
                Text(tool.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
                Text(tool.desc)
                  .fontSize(12)
                  .fontColor($r('sys.color.font_secondary'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })

              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(16)
                .fontColor([$r('sys.color.icon_tertiary')])
            }
            .width('100%')
            .padding(12)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onClick(() => {
              router.pushUrl({ url: tool.pagePath });
            })
          }
        }, (tool: ToolItem) => tool.pagePath)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}
