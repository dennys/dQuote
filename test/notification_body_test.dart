import 'package:dquote/platform/awesome_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('多行內文轉成 <br> 斷行，而不是留下會被 HTML 折成空白的 \\n', () {
    expect(notificationBodyToHtml('台積電 215.0（1.23%）\n dQuote 提醒 above 210'),
        '台積電 215.0（1.23%）<br> dQuote 提醒 above 210');
  });

  test('每行的 HTML 特殊字元會被 escape', () {
    expect(notificationBodyToHtml('A&B <C>\nD'), 'A&amp;B &lt;C&gt;<br>D');
  });

  test('單行內文不加 <br>', () {
    expect(notificationBodyToHtml('只有一行'), '只有一行');
  });
}
