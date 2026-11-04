import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main()=>runApp(const MyApp());
class MyApp extends StatelessWidget{const MyApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(title:'Counter',theme:ThemeData(colorSchemeSeed:Colors.teal,useMaterial3:true),home:const Home());}
class Home extends StatefulWidget{const Home({super.key});@override State<Home> createState()=>_H();}
class _H extends State<Home>{int n=0;@override void initState(){super.initState();SharedPreferences.getInstance().then((p)=>setState(()=>n=p.getInt('n')??0));}
void inc() async{final p=await SharedPreferences.getInstance();setState(()=>n++);p.setInt('n',n);}
@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('عداد')),body:Center(child:Text('$n',style:const TextStyle(fontSize:64))),floatingActionButton:FloatingActionButton(onPressed:inc,child:const Icon(Icons.add)));}
