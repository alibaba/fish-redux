import 'package:flutter/material.dart' hide Action, Page;
import 'package:test_widgets/adapter/page.dart';
import 'package:test_widgets/component/page.dart';
import 'package:test_widgets/dynamic_flow_adapter/page.dart';
import 'package:test_widgets/page/page.dart';
import 'package:test_widgets/static_flow_adapter/page.dart';

import 'test_base.dart';

final Map<String, WidgetBuilder> cases = <String, WidgetBuilder>{
  'buildPage': createPageWidget,
  'buildComponent': createComponentWidget,
  'buildAdapter': createAdapterWidget,
  'buildStaticAdapter': createStaticAdapterWidget,
  'buildDynamicAdapter': createDynamicAdapterWidget
};

void main() {
  runApp(TestStub(ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        final String name = cases.keys.toList()[index];
        final WidgetBuilder builder = cases.values.toList()[index];

        return GestureDetector(
          child: Container(
            height: 86.0,
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            alignment: AlignmentDirectional.center,
            color: Colors.grey,
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          onTap: () {
            Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => TestStub(builder(context))));
          },
        );
      },
      itemCount: cases.length)));
}
