import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/material.dart' hide Action, Page;

import 'action.dart';
import 'state.dart';

Widget buildView(
  ToDoState state,
  Dispatch dispatch,
  ViewService viewService,
) {
  return Container(
    padding: const EdgeInsets.all(8.0),
    child: GestureDetector(
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: Container(
              height: 36.0,
              color: state.isDone ? Colors.green : Colors.red,
              child: Row(
                children: <Widget>[
                  Container(
                    child: const Icon(Icons.label_outline),
                    margin: const EdgeInsets.all(8.0),
                  ),
                  Expanded(
                      child: Text(
                    state.title ?? '',
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  )),
                  GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(right: 16.0),
                      child: (() => state.isDone
                          ? const Icon(Icons.check_box)
                          : const Icon(Icons.check_box_outline_blank))(),
                    ),
                    onTap: () {
                      dispatch(ToDoActionCreator.doneAction(state.uniqueId));
                    },
                  )
                ],
              ),
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 24.0),
            color: const Color(0xFFE0E0E0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Container(
                  child: Text(
                    state.desc ?? '',
                    style: const TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                )),
                GestureDetector(
                  child: Container(
                    child: const Icon(Icons.edit),
                  ),
                  onTap: () {
                    dispatch(ToDoActionCreator.onEditAction(state.uniqueId));
                  },
                )
              ],
            ),
          )
        ],
      ),
      onLongPress: () {
        dispatch(ToDoActionCreator.onRemoveAction(state.uniqueId));
      },
    ),
  );
}
