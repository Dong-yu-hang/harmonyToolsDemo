import { router } from '@kit.ArkUI';
import { photoAccessHelper, PhotoPickerComponent, PickerController, PickerOptions } from '@kit.MediaLibraryKit';

/** 页面阶段：初始按钮页 / 全屏选图 / 结果查看 */
enum PickerStage {
  Idle = 0,
  Picking = 1,
  Result = 2
}

@Entry
@Component
struct PhotoPickerPage {
  @State stage: PickerStage = PickerStage.Idle;
  // picker 组件控制器，必须由本页面持有并传入组件
  @State pickerController: PickerController = new PickerController();
  // picker 组件配置项
  pickerOptions: PickerOptions = new PickerOptions();
  // 已选中的图片 URI
  @State selectedUris: string[] = [];

  aboutToAppear(): void {
    this.pickerOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
    this.pickerOptions.maxSelectNumber = 9;
  }

  /** 点击按钮：拉起全屏 picker */
  private openPicker(): void {
    this.selectedUris = [];
    this.stage = PickerStage.Picking;
  }

  /** 完成：查看已选结果 */
  private finishPicking(): void {
    this.stage = PickerStage.Result;
  }

  /** 收起全屏 picker，回到按钮页（未点完成视为取消） */
  private closePicker(): void {
    this.selectedUris = [];
    this.stage = PickerStage.Idle;
  }

  /** 返回行为：选图中返回=收起 picker；其余=退出页面 */
  private onBack(): void {
    if (this.stage === PickerStage.Picking) {
      this.closePicker();
    } else {
      router.back();
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
          this.onBack();
        })

        if (this.stage === PickerStage.Picking) {
          Text('图库选择器')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 8 })

          Button(this.selectedUris.length > 0 ? `完成(${this.selectedUris.length})` : '完成')
            .width(88)
            .height(34)
            .fontSize(14)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .fontColor($r('sys.color.font_on_primary'))
            .enabled(this.selectedUris.length > 0)
            .opacity(this.selectedUris.length > 0 ? 1 : 0.4)
            .onClick(() => {
              this.finishPicking();
            })
        } else {
          Text(this.stage === PickerStage.Result ? '已选图片' : '图库选择器')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .layoutWeight(1)
            .margin({ left: 8 })

          // 占位，与选图模式右侧按钮宽度对齐
          Row().width(88).height(34)
        }
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8 })

      if (this.stage === PickerStage.Picking) {
        // 全屏嵌入系统图库 picker 组件
        PhotoPickerComponent({
          pickerOptions: this.pickerOptions,
          onSelect: (uri: string) => {
            if (!this.selectedUris.includes(uri)) {
              this.selectedUris = [...this.selectedUris, uri];
            }
          },
          onDeselect: (uri: string) => {
            this.selectedUris = this.selectedUris.filter((u: string) => u !== uri);
          },
          pickerController: this.pickerController
        })
          .width('100%')
          .layoutWeight(1)
      } else {
        // 按钮页 / 结果页：内容区统一加左右边距
        Column() {
          if (this.stage === PickerStage.Idle) {
            // 点击按钮才拉起全屏 picker
            Button('选择图片')
              .width('100%')
              .height(44)
              .margin({ top: 16 })
              .fontSize(16)
              .backgroundColor($r('sys.color.comp_background_emphasize'))
              .fontColor($r('sys.color.font_on_primary'))
              .onClick(() => {
                this.openPicker();
              })

            // 空态：还未选择图片
            Column({ space: 12 }) {
              Text('🖼️')
                .fontSize(40)
              Text('点击上方按钮，拉起全屏图库选择图片')
                .fontSize(14)
                .fontColor($r('sys.color.font_secondary'))
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else {
            Text(`已选择 ${this.selectedUris.length} 张图片`)
              .fontSize(13)
              .fontColor($r('sys.color.font_secondary'))
              .width('100%')
              .margin({ top: 16, bottom: 8 })

            // 已选图片缩略图
            Grid() {
              ForEach(this.selectedUris, (uri: string) => {
                GridItem() {
                  Image(uri)
                    .width('100%')
                    .aspectRatio(1)
                    .borderRadius(12)
                    .objectFit(ImageFit.Cover)
                    .backgroundColor($r('sys.color.comp_background_tertiary'))
                }
              }, (uri: string) => uri)
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(8)
            .columnsGap(8)
            .layoutWeight(1)
            .scrollBar(BarState.Off)

            Button('重新选择')
              .width('100%')
              .height(44)
              .margin({ top: 12, bottom: 16 })
              .fontSize(16)
              .backgroundColor($r('sys.color.comp_background_tertiary'))
              .fontColor($r('sys.color.font_primary'))
              .onClick(() => {
                this.openPicker();
              })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}
