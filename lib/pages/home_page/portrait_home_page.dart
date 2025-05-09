import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:tripeaks_rush/actions/actions.dart';
import 'package:tripeaks_rush/actions/intents.dart';
import 'package:tripeaks_rush/assets/custom_icons.dart';
import 'package:tripeaks_rush/l10n/app_localizations.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/board.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/card_counter.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/card_placeholder.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/cards.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/cleared_card.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/game_button.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/stalled_card.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/stock.dart';
import 'package:tripeaks_rush/pages/home_page/widgets/swipe_area.dart';
import 'package:tripeaks_rush/stores/data/back_options.dart';
import 'package:tripeaks_rush/stores/data/decor.dart';
import 'package:tripeaks_rush/stores/game.dart';
import 'package:tripeaks_rush/stores/session.dart';
import 'package:tripeaks_rush/stores/settings.dart';
import 'package:tripeaks_rush/widgets/constants.dart' as c;

class PortraitHomePage extends StatefulWidget {
  const PortraitHomePage({super.key});

  @override
  State<PortraitHomePage> createState() => _PortraitHomePageState();
}

class _PortraitHomePageState extends State<PortraitHomePage> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = _scale(MediaQuery.sizeOf(context));
    final session = Provider.of<Session>(context);
    final settings = Provider.of<Settings>(context);
    return Observer(
      builder: (context) {
        final game = session.game;
        final back = BackOptions(
          showValue: session.showAll,
          decor: settings.decor.icon,
          decorColour: settings.decorColour,
        );
        return Actions(
          actions: <Type, Action<Intent>>{
            TakeIntent: TakeAction(game, settings.sounds),
            DrawIntent: DrawAction(game, settings.sounds),
            RollbackIntent: RollbackAction(game, settings.sounds),
          },
          child: Builder(
            builder: (context) {
              return Focus(
                focusNode: _focusNode,
                autofocus: true,
                skipTraversal: true,
                descendantsAreFocusable: true,
                descendantsAreTraversable: true,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: EdgeInsets.all((24.0 * scale).floorToDouble()),
                    child: Stack(
                      children: [
                        SwipeArea(intent: const DrawIntent()),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: (16.0 * scale).floorToDouble(),
                          children: [
                            PortraitHomePageBoard(game: game, scale: scale, back: back),
                            PortraitHomePageCounter(game: game, scale: scale),
                            PortraitHomePageRightArea(game: game, scale: scale, back: back),
                          ],
                        ),
                        Center(
                          child: Observer(
                            builder: (context) {
                              return ClearedCardAnimated(
                                id: game.started.millisecondsSinceEpoch,
                                score: game.score,
                                show: game.isCleared,
                              );
                            },
                          ),
                        ),
                        Center(
                          child: Observer(
                            builder: (context) {
                              return StalledCardAnimated(
                                score: game.score,
                                id: game.started.millisecondsSinceEpoch + 1,
                                show: game.isStalled,
                                isRushGame: game.rushInfo != null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _scale(Size mediaSize) {
    final sx = (mediaSize.width - 2 * c.pagePadding) / c.requiredHeight;
    final sy = (mediaSize.height - 2 * c.pagePadding) / c.requiredWidth;
    return min(1.0, min(sx, sy));
  }
}

final class PortraitHomePageBoard extends StatelessWidget {
  const PortraitHomePageBoard({super.key, required this.game, required this.scale, required this.back});

  final Game game;
  final double scale;
  final BackOptions back;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [PortraitBoard(game: game, scale: scale, back: back)],
      ),
    );
  }
}

class PortraitHomePageCounter extends StatelessWidget {
  const PortraitHomePageCounter({super.key, required this.game, required this.scale});

  final Game game;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Observer(
            builder:
                (context) => IgnorePointer(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: CardCounter(
                      maxCount: game.layout.cardCount,
                      count: game.remaining,
                      chainLength: game.chain,
                    ),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

class PortraitHomePageRightArea extends StatelessWidget {
  const PortraitHomePageRightArea({super.key, required this.game, required this.scale, required this.back});

  final Game game;
  final double scale;
  final BackOptions back;

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 16.0 * scale,
      children: [
        CircleGameButton(
          scale: scale,
          icon: CustomIcons.menu,
          smallIcon: CustomIcons.menu16,
          tooltip: s.menuTooltip,
          onPressed: () => Scaffold.of(context).openDrawer(),
          // onPressed: () => Navigator.of(context).push(createRoute(() => const MenuPage())),
        ),
        Observer(
          builder:
              (context) => CircleGameButton(
                scale: scale,
                icon: CustomIcons.undo,
                smallIcon: CustomIcons.undo16,
                tooltip: s.undoTooltip,
                onPressed: Actions.handler(context, const RollbackIntent()),
              ),
        ),
        IgnorePointer(
          child: SizedBox(
            width: c.cardSize * scale,
            height: c.cardSize * scale,
            child: Observer(
              builder:
                  (context) =>
                      game.discard.isEmpty
                          ? CardPlaceHolder(scale: scale)
                          : FittedBox(
                            child: TileCard(
                              game.discard.last
                                ..open()
                                ..put(),
                              back: back,
                              orientation: Orientation.portrait,
                            ),
                          ),
            ),
          ),
        ),
        Spacer(),
        IgnorePointer(child: PortraitStock(game, scale: scale, back: back)),
        Observer(
          builder:
              (context) => GameButton.wide(
                scale: scale,
                icon: CustomIcons.draw,
                smallIcon: CustomIcons.draw16,
                tooltip: s.drawTooltip,
                onPressed: Actions.handler(context, const DrawIntent()),
              ),
        ),
      ],
    );
  }
}
