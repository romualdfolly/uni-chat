import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as category;
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

const _platform = MethodChannel('emoji_picker_flutter');

Future<CategoryEmoji> getCategoryEmojis({
  required CategoryEmoji category,
}) async {
  // check for supported emojis
  var availaible =
      (await _platform.invokeListMethod<bool>('getSupportedEmojis', {
        'source': category.emoji.map((e) => e.emoji).toList(growable: false),
      }))!;

  // Create new category with only supported emojis
  return category.copyWith(
    emoji: [
      for (int i = 0; i < availaible.length; i++)
        if (availaible[i]) category.emoji[i],
    ],
  );
}

Future<List<CategoryEmoji>> filterUnsupported({
  required List<CategoryEmoji> data,
}) async {
  // skip filtering on the web and non-android
  if (kIsWeb || !Platform.isAndroid) {
    return data;
  }

  // fetching supported emojis for each category
  final futures = [for (final cat in data) getCategoryEmojis(category: cat)];
  return await Future.wait(futures);
}

// Emoji Picker widget
class EmojiPickerWidget extends StatefulWidget {
  //
  final Function addEmojiToTextController;

  const EmojiPickerWidget({super.key, required this.addEmojiToTextController});

  @override
  State<EmojiPickerWidget> createState() => _EmojiPickerWidgetState();
}

class _EmojiPickerWidgetState extends State<EmojiPickerWidget>
    with SingleTickerProviderStateMixin {
  // Tab controller for handling Emoji categories
  TabController? tabController;

  // Global keys to keep track of EmojiPicker
  GlobalKey<EmojiPickerState> key = GlobalKey();

  // List to store emojis for different categories
  final List<Emoji> _recentEmojis = [];
  final List<Emoji> _smileysEmojis = [];
  final List<Emoji> _animalsEmojis = [];
  final List<Emoji> _foodsEmojis = [];
  final List<Emoji> _activitiesEmojis = [];
  final List<Emoji> _travelEmojis = [];
  final List<Emoji> _symbolsEmojis = [];
  final List<Emoji> _objectsEmojis = [];
  final List<Emoji> _flagsEmojis = [];

  // Function to fetch recent emojis
  Future<void> getRecentEmojis() async {
    await EmojiPickerUtils().getRecentEmojis().then((results) {
      for (var r in results) {
        setState(() {
          _recentEmojis.add(r.emoji);
        });
      }
    });
  }

  // Function to fetch emojis for each categories
  Future<void> getEmojis() async {
    for (var emojiSet in defaultEmojiSet) {
      await getCategoryEmojis(category: emojiSet).then(
        (e) async => await filterUnsupported(data: [e]).then((filtered) {
          for (var element in filtered) {
            // Populating list based on emoji categories
            switch (emojiSet.category) {
              case category.Category.SMILEYS:
                setState(() {
                  _smileysEmojis.addAll(element.emoji);
                });
                break;
              case category.Category.ANIMALS:
                setState(() {
                  _animalsEmojis.addAll(element.emoji);
                });
                break;
              case category.Category.FOODS:
                setState(() {
                  _foodsEmojis.addAll(element.emoji);
                });
                break;
              case category.Category.ACTIVITIES:
                setState(() {
                  _activitiesEmojis.addAll(element.emoji);
                });
                break;
              case category.Category.TRAVEL:
                setState(() {
                  _travelEmojis.addAll(element.emoji);
                });
                break;
              case category.Category.SYMBOLS:
                setState(() {
                  _symbolsEmojis.addAll(element.emoji);
                });
                break;
              case category.Category.OBJECTS:
                setState(() {
                  _objectsEmojis.addAll(element.emoji);
                });
                break;
              case category.Category.FLAGS:
                setState(() {
                  _flagsEmojis.addAll(element.emoji);
                });
                break;
              default:
            }
          }
        }),
      );
    }
  }

  @override
  void initState() {
    // TabCOntroller init
    tabController = TabController(length: 9, vsync: this);

    // fetching recent emojis and emojis for each categories
    getRecentEmojis();
    getEmojis();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Emoji picker UI
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: Card(
            margin: const EdgeInsets.all(0),
            child: Column(
              children: [
                // Tab for navigation through emojis
                TabBar(
                  isScrollable: false,
                  labelPadding: const EdgeInsets.symmetric(vertical: 7.5),
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  indicator: MaterialIndicator(
                    height: 5,
                    topRightRadius: 5,
                    bottomRightRadius: 5,
                    topLeftRadius: 5,
                    bottomLeftRadius: 5,
                    color: Theme.of(context).primaryColor, // <-------------
                  ),
                  // icons representing emoji categories
                  tabs: const [
                    Icon(Icons.watch_later),
                    Icon(Icons.emoji_emotions),
                    Icon(Icons.pets),
                    Icon(Icons.fastfood),
                    Icon(Icons.sports_soccer),
                    Icon(Icons.directions_car),
                    Icon(Icons.lightbulb),
                    Icon(Icons.emoji_symbols_rounded),
                    Icon(Icons.flag),
                  ],
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 2.5,
                      right: 2.5,
                      bottom: 2.5,
                    ),
                    // TabViw for displaying emoji grids
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        // recent emojis
                        Scaffold(
                          body:
                              _recentEmojis.isEmpty
                                  ? const Center(
                                    child: Text("No Recent Emojis"),
                                  )
                                  : GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _recentEmojis.length,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                        ),
                                    itemBuilder: (context, index) {
                                      Emoji emoji = _recentEmojis[index];
                                      return Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            // add to the text controller
                                            widget.addEmojiToTextController(
                                              emoji: emoji,
                                            );
                                            // update of the recently used list
                                            EmojiPickerUtils()
                                                .addEmojiToRecentlyUsed(
                                                  key: key,
                                                  emoji: emoji,
                                                );
                                          },
                                          child: Text(
                                            emoji.emoji,
                                            style: const TextStyle(fontSize: 30),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),

                        




                        GridView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _smileysEmojis.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                          ),
                          itemBuilder: (context, index) {
                            Emoji emoji = _smileysEmojis[index];
                            return Center(
                              child: GestureDetector(
                                onTap: () {
                                  // add to the text controller
                                  widget.addEmojiToTextController(
                                    emoji: emoji,
                                  );
                                  // update of the recently used list
                                  EmojiPickerUtils()
                                      .addEmojiToRecentlyUsed(
                                        key: key,
                                        emoji: emoji,
                                      );
                                },
                                child: Text(
                                  emoji.emoji,
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
