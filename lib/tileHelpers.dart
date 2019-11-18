import 'package:flutter/material.dart';
import 'package:spike_plan/db/task.dart';

String dictatePath(Task task){
  //TODO return task-type specific icons
  String path;
  switch(task.type){
    default:
      path = "error";
  }
  return path;
}

Color dictateColor(Task task){
  if(task.done == 1){
    return Colors.lightGreen;
  } else if (task.done == 0) {
    return Colors.black38;
  }
  return Colors.redAccent;
}

IconData dictateIcon(Task task){
  if(task.done == 1){
    return Icons.check;
  } else if (task.done == 0) {
    return Icons.timelapse;
  }
  return Icons.close;
}

Icon dictateLeading(Task task) {
  return Icon(
    dictateIcon(task),
    color: dictateColor(task),
    size: 36.0,
  );
}

Row ratingBar(Task task, double offSet, double size){
  List<Widget> stars = new List<Widget>();
  for(int i = 0; i < task.rating; i++){
    stars.add(new Icon(
      Icons.star,
      size: size,
      color: Colors.amber,
    ));
  }
  for(int i = 0; i < 5 - task.rating; i++){
    stars.add(new Icon(
      Icons.star,
      size: size,
      color: Colors.grey,
    ));
  }
  if (offSet != 0) {
    stars.add(SizedBox(width: offSet,));
  }
  return new Row(
    mainAxisSize: MainAxisSize.min,
    children: stars,
  );
}

