import 'dart:collection';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:async';
//import 'dart:js';
//import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tts_improved/flutter_tts_improved.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:http/http.dart';
import 'package:owlbot_dart/owlbot_dart.dart';
//import 'package:highlight_text/highlight_text.dart';
//import 'package:flutter_tts_improved/flutter_tts_improved.dart';
//import 'package:flutter_tts/flutter_tts.dart';

import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
//import 'package:substring_highlight/substring_highlight.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class selectfile extends StatefulWidget {
  @override
  _selectfileState createState() => _selectfileState();
}

class _selectfileState extends State<selectfile> {
  PlatformFile file1 = null;
  int pagenumber;
  String ans = null;
  bool flag = true;
  FlutterTtsImproved _flutterTts = FlutterTtsImproved();
  bool isPlaying = false;
  String _platformVersion = "Get the Text";
  bool status = false;
  String url = "https://owlbot.info/api/v4/dictionary/owl";

  Future<List<Details>> details1 = null;
  List<Details> details = [];
  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // initializeTts() {
  //   _flutterTts = FlutterTtsImproved();
  //
  //   _flutterTts.setStartHandler(() {
  //     setState(() {
  //       isPlaying = true;
  //     });
  //   });
  //
  //   _flutterTts.setCompletionHandler(() {
  //     setState(() {
  //       isPlaying = false;
  //     });
  //   });
  //
  //   _flutterTts.setErrorHandler((err) {
  //     setState(() {
  //       print("error occurred: " + err);
  //       isPlaying = false;
  //     });
  //   });
  // }

  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1);
    //await _flutterTts.setVolume(50);
    print(await _flutterTts.getVoices);
    print('VOICES: ${await _flutterTts.getVoices}');
    print('LANGUAGES: ${await _flutterTts.getLanguages}');

    _flutterTts
        .setProgressHandler((String words, int start, int end, String word) {
      setState(() {
        _platformVersion = word;
        status = true;
        print(status);
      });
      print('PROGRESS : $word => $start - $end $status');
    });
    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isPlaying = false;
      });
    });
  }
  // @override
  // void dispose() {
  //   super.dispose();
  //   _flutterTts.stop();
  // }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      backgroundColor: Colors.yellow,
      color: Colors.black,
    );
    Map<String, HighlightedWord> words = {
      _platformVersion: HighlightedWord(
          onTap: () async {
            if (status) {
              await search(_platformVersion);
              // if(details.length==0){
              //   return Center(child: CircularProgressIndicator(),);
              // }
              return show(context);
              // return showDialog(context: context, builder: ()=> AlertDialog(
              //     title: Text(_platformVersion),
              //     content: SingleChildScrollView(
              //       child: ListView.builder(
              //           itemCount: details.length,
              //           itemBuilder: (context, index) {
              //             return Container(
              //               child: Column(
              //                 children: [
              //                   Padding(
              //                     padding: const EdgeInsets.all(8.0),
              //                     child: Row(
              //                       children: [
              //                         details[index].image_url != null
              //                             ? CircleAvatar(
              //                             backgroundImage: NetworkImage(
              //                                 details[index].image_url))
              //                             : null,
              //                         Text(details[index].defination),
              //                       ],
              //                     ),
              //                   ),
              //                   Text(details[index].example),
              //                 ],
              //               ),
              //             );
              //           }),
              //     ),
              //   ),
              // );
            }
          },
          textStyle: status
              ? textStyle
              : TextStyle(
                  backgroundColor: Colors.transparent,
                  color: Colors.black,
                )),
    };
    //HighlightMap highlightMap = HighlightMap(words);
    //print(highlightMap.getMap);
    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        child: Container(
            padding: EdgeInsets.all(50.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      file1 = null;
                    });

                    FilePickerResult picked =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );

                    if (picked != null) {
                      setState(() {
                        file1 = picked.files.first;
                        print(file1.path);
                      });
                    }
                  },
                  child: Text(
                    'Choose',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                Center(
                  child: file1 == null
                      ? Text('Choose file')
                      : PDF.file(
                          File(file1.path),
                          height: 250,
                          width: 250,
                        ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      pagenumber = int.parse(value);
                    });
                  },
                ),
                Container(
                  child: Column(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            var data = File(file1.path).readAsBytesSync();
                            PdfDocument document = await PdfDocument(
                                inputBytes: File(file1.path).readAsBytesSync());
                            PdfTextExtractor extractor =
                                await PdfTextExtractor(document);
                            String doctext = await extractor
                                .extractText(startPageIndex: pagenumber - 1)
                                .toString();
                            var doclist = doctext.split("\n");
                            print("lsit");
                            String s = "";
                            for (String i in doclist) {
                              s += i.trim();
                              s += "; ";
                            }
                            doclist = s.split(" ");
                            s = "";
                            for (String i in doclist) {
                              s += i.trim();
                              s += " ";
                            }
                            //List<String> list = ['?','.','!'];
                            String newString = "";
                            for (int i = 0; i < s.length; i++) {
                              if (s[i] != '?' && s[i] != '.' && s[i] != '!') {
                                newString += s[i];
                                //rint(s[i]);
                              } else {
                                newString += ';';
                              }
                            }
                            print(newString);
                            //print(doctext);
                            //doctext="name";
                            //print(doctext);
                            if (doctext != null) {
                              setState(() {
                                status = false;
                                doctext = doctext.trim();
                                _platformVersion = newString.trim();
                                //print("value");
                                print(_platformVersion);
                                ans = newString.trim();
                                //print(ans);
                              });
                            }
                            // PDFDoc doc = await PDFDoc.fromURL('https://ncert.nic.in/textbook/pdf/keph206.pdf');
                            // // String doctext = await doc.text;
                            // print(doc.length);
                            // PDFPage page = doc.pageAt(2);
                            // String doctext = await page.text;
                            // print(doctext);

                            // String text = "";
                            // try {
                            //   text = await ReadPdfText.getPDFtext(file1.path);
                            // } on PlatformException {
                            //   text = 'Failed to get PDF text.';
                            // }
                            // if(text!=null){
                            //   setState(() {
                            //     ans=text;
                            //     print(text);
                            //   });
                            // }
                          },
                          child: Text('Get Text')),
                    ],
                  ),
                  margin: EdgeInsets.all(20),
                ),
                Container(
                  height: 250,
                  width: 250,
                  child: SingleChildScrollView(
                    reverse: false,
                    // controller: ,
                    scrollDirection: Axis.vertical,
                    child: TextHighlight(
                      text: ans ?? "Get the Text",
                      words: words,
                      textStyle: TextStyle(
                          color: Colors.black,
                          backgroundColor: Colors.transparent),
                    ),
                    // child: SubstringHighlight(
                    // text: ans ?? 'Show text',
                    //   term: _platformVersion,
                    //   //overflow: TextOverflow.clip,
                    //   textStyleHighlight: TextStyle(
                    //     backgroundColor: Colors.yellow
                    //   ),
                    //   textStyle: TextStyle(
                    //     color: Colors.black
                    //   ),
                    // )),
                  ),
                ),
                IconButton(
                    icon: !flag ? Icon(Icons.stop) : Icon(Icons.play_arrow),
                    onPressed: !flag
                        ? () async {
                            print("stop");
                            setState(() {
                              flag = !flag;
                            });
                            await _flutterTts.stop();
                          }
                        : () async {
                            print("play");
                            setState(() {
                              if (ans != null) {
                                flag = !flag;
                              }
                            });
                            //ans="Tee";
                            print(ans.length);
                            await _flutterTts.speak(ans ?? 'enter the text');
                          })
              ],
            )),
      ),
    ));
  }

  Future<void> setparams() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1);
    print(await _flutterTts.getVoices);
    //await flutterTts.setVolume(50.0);
  }

  void search(String str) async {
    // Response response = await get(url + str.trim(), headers: {"Authorization": "Token 3d05b1a4db4d2db87afbf5a2105e22d6cb54601f"});
    // if(response.statusCode==200){
    //        jsonDecode(response.body);
    // }

    OwlBot owlBot = OwlBot(token: token);
    final OwlBotResponse response = await owlBot.define(word: str);
    print(response.pronunciation);
    details = [];
    response.definitions.forEach((element) {
      print('${element.definition} , ${element.imageUrl} , ${element.example}');
      details
          .add(Details(element.definition, element.imageUrl, element.example));
    });
    // details1 = details as Future<List<Details>>;

    for (Details i in details) {
      //print(i.defination);
    }
  }

  Future<Widget> show(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          // Text(_platformVersion),
          child: Container(
            width: double.maxFinite,
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _platformVersion,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: details[index].image_url == null
                              ? SizedBox(
                                  width: 0.0,
                                  height: 0.0,
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(details[index].image_url),
                                ),
                          title: Text(details[index].defination),
                          subtitle: details[index].example!=null?Text("Ex: " + details[index].example):SizedBox(width: 0.0,height: 0.0,),
                        );
                        // return Container(
                        //
                        //     child: Column(
                        //       children: [
                        //         Expanded(child:Row(
                        //         children: [
                        //           details[index].image_url != null
                        //               ? CircleAvatar(
                        //               backgroundImage: NetworkImage(
                        //                   details[index].image_url))
                        //               : Text(" "),
                        //           Flexible(child: Text(details[index].defination,)),
                        //         ],
                        //           )),
                        //         Flexible(child: Text("Example : "+details[index].example,)),
                        //       ],
                        //     ),
                        //   );
                      }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Details>> getdata() async {
    return await details;
  }
}

class Details {
  String defination;
  String image_url;
  String example;
  Details(String def, String imageurl, String ex) {
    defination = def;
    image_url = imageurl;
    example = ex;
  }
}
