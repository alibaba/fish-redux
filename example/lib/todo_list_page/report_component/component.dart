import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart';

import 'state.dart';
export 'state.dart';

class ReportComponent extends Component<ReportState> {
  ReportComponent() : super(
    view: (ReportState state, Dispatch dispatch, ComponentContext<ReportState> viewService) {
      return Container(
        height: 100,
        child: Text(
          '${state.hashCode ?? ''}'
        )
      );
    },
  );
}
