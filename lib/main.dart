import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// to do
// add design
// add animations - showing "you win" text
// allow modification of range
// add a heading to guesses history
// add separating lines between each guess history row
// show current range on screen
// very big number causes error, fix that

void main() {
  runApp(const GuessingGameApp());
}

class GuessingGameApp extends StatelessWidget {
  const GuessingGameApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: GuessNumberGame(),
      backgroundColor: theme.colorScheme.onPrimary,
    );
  }
}

class GuessNumberGame extends StatefulWidget {
  const GuessNumberGame({super.key});
  @override
  State<StatefulWidget> createState() {
    return initialized();
  }
}

class initialized extends State<GuessNumberGame> {
  final text_input_controller = TextEditingController();
  final text_input_focus_node = FocusNode();
  final guesses_history_scroll_controller = ScrollController();
  final range_start =
      0; // the minimum number that can be randomly picked, inclusive
  final range_end =
      100; // the maximum number that can be randomly picked, inclusive
  final random_number_generator = Random();
  late int hidden_number; // is initialized in initstate()
  bool has_won = false;
  List<int> guesses = [];

  @override
  void initState() {
    super.initState();
    start_new_game();
  }

  @override
  void dispose() {
    text_input_controller.dispose();
    text_input_focus_node.dispose();
    super.dispose();
  }

  void start_new_game() {
    generate_hidden_number();
    setState(() {
      guesses.clear();
      has_won = false;
    });
  }

  void generate_hidden_number() {
    // generates the hidden number between the given range, start and end are inclusive
    hidden_number =
        random_number_generator.nextInt(range_end - range_start + 1) +
            range_start;
  }

  void on_user_guess() {
    String input = text_input_controller.text;
    if (input.isNotEmpty) {
      int num = int.parse(input);
      setState(() {
        guesses.add(num);
        if (num == hidden_number) {
          has_won = true;
        }
      });
      guesses_history_scroll_controller.animateTo(0,
          duration: Duration(seconds: 1), curve: Curves.linear);
      text_input_controller.clear();
    }
    text_input_focus_node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all_text_color = theme.colorScheme.primaryFixed;
    final body_text_style =
        theme.textTheme.titleLarge!.copyWith(color: all_text_color);
    final heading_text_style =
        theme.textTheme.displayLarge!.copyWith(color: all_text_color);
    final container_color = theme.colorScheme.primaryContainer;
    final button_style = ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(container_color));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            has_won ? "You Win!" : "",
            style: heading_text_style,
          ),
        ),
        Container(
          width: 300,
          padding: EdgeInsets.all(20),
          child: TextField(
            enabled: !has_won, // when the user wins disable any further input
            controller: text_input_controller,
            focusNode: text_input_focus_node,
            textAlign: TextAlign.center,
            style: body_text_style,
            decoration: InputDecoration(
              disabledBorder: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: all_text_color, width: 1)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: all_text_color, width: 3)),
              labelText: "Guess a Number",
              filled: true,
              fillColor: container_color,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (value) => on_user_guess(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    start_new_game();
                  },
                  style: button_style,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Reset",
                      style: body_text_style,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: () {
                    on_user_guess();
                  },
                  style: button_style,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "Guess",
                      style: body_text_style,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 200,
          child: RawScrollbar(
            controller: guesses_history_scroll_controller,
            thumbVisibility: true,
            trackVisibility: true,
            trackColor: container_color,
            thumbColor: all_text_color,
            radius: Radius.circular(10),
            thickness: 10,
            trackRadius: Radius.circular(10),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars:
                      false), // used to remove the scrollbar auto-generated by listView below so that the RawScrollbar above can be used for ListView
              child: ListView(
                controller: guesses_history_scroll_controller,
                children: create_guesses_history_widgets(
                    body_text_style: body_text_style),
              ),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> create_guesses_history_widgets({required body_text_style}) {
    List<Widget> guesses_column = [];
    List<Widget> hint_text_column = [];
    String hint_text;
    int num;
    for (int i = guesses.length - 1; i >= 0; i -= 1) {
      num = guesses[i];
      if (num > hidden_number) {
        hint_text = "Too High";
      } else if (num < hidden_number) {
        hint_text = "Too Low";
      } else {
        hint_text = "Correct";
      }
      guesses_column.add(
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            num.toString(),
            textAlign: TextAlign.center,
            style: body_text_style,
          ),
        ),
      );
      hint_text_column.add(
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(
            hint_text,
            textAlign: TextAlign.center,
            style: body_text_style,
          ),
        ),
      );
    }
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: guesses_column,
          ),
          Column(
            children: hint_text_column,
          )
        ],
      )
    ];
  }
}
