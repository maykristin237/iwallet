import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:iwallet/common/localization/default_localizations.dart';
import 'package:iwallet/common/style/def_style.dart';
import 'package:iwallet/widget/w_card_item.dart';
import 'package:iwallet/widget/w_input_widget.dart';

/// issue 编辑输入框
/// on 2022/7/21.
class IssueEditDialog extends StatefulWidget {
  final String dialogTitle;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String> onContentChanged;
  final Function(Iterable<ImageFile>?) onPressed;
  final TextEditingController? titleController;
  final TextEditingController? valueController;
  final MultiImagePickerController imgPickerController = MultiImagePickerController(maxImages: 6, allowedImageTypes: const ['jpg', 'jpeg', 'png']);
  final bool needTitle;

  IssueEditDialog(this.dialogTitle, this.onTitleChanged, this.onContentChanged, this.onPressed,
      {super.key, this.titleController, this.valueController, this.needTitle = true});

  @override
  State<IssueEditDialog> createState() => _IssueEditDialogState();
}

class _IssueEditDialogState extends State<IssueEditDialog> {

  final TextEditingController tCtr1 = TextEditingController();
  List feedbackValues = ["account", "trade", "soft", "other"];
  int _selected_value = 0;
  late var _info_values = [0, 1, 2, 3];
  late var _info = [Locals.i18n(context)!.account_q, Locals.i18n(context)!.trans_q, Locals.i18n(context)!.soft_q, Locals.i18n(context)!.other_q];  //Locals.i18n(context)!.enable

  ///标题输入框
  renderTitleInput() {
    return (widget.needTitle)
        ? Padding(
        padding: const EdgeInsets.all(5.0),
        child: WInputWidget(
          onChanged: widget.onTitleChanged,
          controller: widget.titleController,
          hintText: Locals.i18n(context)!.issue_edit_issue_title_tip,
          obscureText: false,
        ))
        : Container();
  }

  ///快速输入框
  _renderFastInputContainer() {
    return Container(
      height: 30.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return RawMaterialButton(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 5.0, bottom: 5.0),
              constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
              child: Icon(FAST_INPUT_LIST[index].iconData, size: 16.0, color: Colors.grey,),
              onPressed: () {
                String text = FAST_INPUT_LIST[index].content;
                String newText = "";
                if (widget.valueController?.value != null) {
                  newText = widget.valueController!.value.text;
                }
                newText = newText + text;
                setState(() {
                  widget.valueController!.value = TextEditingValue(text: newText);
                });
                widget.onContentChanged.call(newText);
              });
        },
        itemCount: FAST_INPUT_LIST.length,
      ),
    );
  }

  ///输入框
  Widget _textInput(String hintText, final TextEditingController controller) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: WInputWidget(
          textStyle: const TextStyle(fontSize: 16, color: DefColors.textTitleYellow),
          controller: controller,
          hintText: hintText,
          obscureText: false,
        ));
  }

  ///下拉框
  Widget renderDropdownBtn(List<String> info, List<int> values, int value, String hintText, Function onChan) {
    List<DropdownMenuItem<int>> _buildItems(List<String> info, List<int> colors) {
      return colors.map((e) => DropdownMenuItem<int>(
              value: e,
              child: Text(info[colors.indexOf(e)], style: const TextStyle(color: DefColors.textMainColor)),
            ),
          ).toList();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 30.0),
      child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          elevation: 1,
          dropdownColor: DefColors.primaryColor,
          icon: Icon(Icons.expand_more, size: 20, color: DefColors.toggleBtnColor),
          items: _buildItems(info, values),
          onChanged: (v) => onChan(v)), //(v) => setState(() => value = v!))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Center(
                child: WCardItem(
                  color: DefColors.primaryValue.withAlpha(236),
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ///dialog标题
                        Padding(
                            padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                            child: Center(
                              child: Text(widget.dialogTitle, style: DefConstant.normalTextBold),
                            )),

                        ///标题输入框
                        renderTitleInput(),

                        ///内容输入框
                        Container(
                          height: MediaQuery.of(context).size.height * 2 / 3,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                            color: DefColors.primaryValue,
                            border: Border.all(color: Colors.grey, width: 0.5),
                          ),
                          padding: const EdgeInsets.only(left: 20.0, top: 12.0, right: 20.0, bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ///意见类型
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(Locals.i18n(context)!.business_type, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 16, color: DefColors.textMainColor)),
                                  Expanded(child: renderDropdownBtn(_info, _info_values, _selected_value, "", (v) => setState(() => _selected_value = v!))),
                                ],
                              ),

                              Expanded(
                                child: TextField(
                                  autofocus: false,
                                  maxLines: 999,
                                  onChanged: widget.onContentChanged,
                                  controller: widget.valueController,
                                  decoration: InputDecoration(
                                    hintText: Locals.i18n(context)!.issue_edit_issue_content_tip,
                                    hintStyle: DefConstant.middleSubText,
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  style: DefConstant.middleText,
                                ),
                              ),

                              const Divider(color: Colors.grey, indent:5, endIndent: 5*2, height: 10, thickness: 0.5),
                              ///图片选择
                              _imgPickerView(),
                              const Divider(color: Colors.grey, indent:5, endIndent: 5*2, height: 10, thickness: 0.5),
                              ///电话
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(Locals.i18n(context)!.contact_number, style: const TextStyle(fontWeight: FontWeight.normal,fontSize: 16, color: Colors.grey)),
                              ),
                              _textInput(Locals.i18n(context)!.contact_info, tCtr1),

                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ///取消
                            Expanded(
                              child: RawMaterialButton(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.all(4.0),
                                constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                                child: Text(Locals.i18n(context)!.app_cancel, style: TextStyle(color: DefColors.textMainColor)),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Container(width: 0.3, height: 25.0, color: DefColors.subTextColor),

                            ///确定
                            Expanded(
                              child: RawMaterialButton(
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.all(4.0),
                                constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
                                child: Text(Locals.i18n(context)!.app_ok, style: TextStyle(color: DefColors.textTitleYellow, fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  //String url = "http://18.162.110.76:9199/base/image_upload";
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Iterable<ImageFile>? images;
  Widget _imgPickerView() {
    pickerView() => MultiImagePickerView(
          draggable: false,
          controller: widget.imgPickerController,
          padding: const EdgeInsets.all(5),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 90, childAspectRatio: 1, crossAxisSpacing: 0, mainAxisSpacing: 0),
          initialContainerBuilder: (context, pickerCallback) {
            return SizedBox(
              height: 90,
              //width: double.infinity,
              child: Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: ButtonStyleButton.allOrNull<Color>(DefColors.textTitleYellow),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  ),
                  child: Text(Locals.i18n(context)!.add_img, style: TextStyle(color: DefColors.subTextColor)),
                  onPressed: () {
                    pickerCallback();
                  },
                ),
              ),
            );
          },
          itemBuilder: (context, file, deleteCallback) {
            return ImageCard(file: file, deleteCallback: deleteCallback);
          },
          addMoreBuilder: (context, pickerCallback) {
            return SizedBox(
              height: 88,
              //width: double.infinity,
              child: Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    shape: const CircleBorder(),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add, color: Colors.blue, size: 30),
                  ),
                  onPressed: () {
                    pickerCallback();
                  },
                ),
              ),
            );
          },
          onChange: (list) {
            images = list;
          },
        );

    return SizedBox(
      height: 92,
      child: Column(
        children: [
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad}),
              child: pickerView(),
            ),
          ),
        ],
      ),
    );
  }

}

var FAST_INPUT_LIST = [
  FastInputIconModel(DefICons.ISSUE_EDIT_H1, "\n# "),
  FastInputIconModel(DefICons.ISSUE_EDIT_H2, "\n## "),
  FastInputIconModel(DefICons.ISSUE_EDIT_H3, "\n### "),
  FastInputIconModel(DefICons.ISSUE_EDIT_BOLD, "****"),
  FastInputIconModel(DefICons.ISSUE_EDIT_ITALIC, "__"),
  FastInputIconModel(DefICons.ISSUE_EDIT_QUOTE, "` `"),
  FastInputIconModel(DefICons.ISSUE_EDIT_CODE, " \n``` \n\n``` \n"),
  FastInputIconModel(DefICons.ISSUE_EDIT_LINK, "[](url)"),
];

class FastInputIconModel {
  final IconData iconData;
  final String content;

  FastInputIconModel(this.iconData, this.content);
}

class ImageCard extends StatelessWidget {
  const ImageCard({Key? key, required this.file, required this.deleteCallback}) : super(key: key);

  final ImageFile file;
  final Function(ImageFile file) deleteCallback;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      children: [
        Positioned.fill(
          child: !file.hasPath
              ? Image.memory(
            file.bytes!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('No Preview'));
            },
          )
              : Image.file(
            File(file.path!),
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            excludeFromSemantics: true,
            onLongPress: () {},
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 18),
            ),
            onTap: () {
              deleteCallback(file);
            },
          ),
        ),
      ],
    );
  }
}
