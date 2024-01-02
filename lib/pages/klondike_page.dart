import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:solitaire_dreamy/games/klondike_game.dart';

class KlondikePage extends StatelessWidget {
  const KlondikePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDFFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Back to the home page
          },
        ),
        title: const Text('Klondike'),
        actions: [
          Text(
            localizations.easy,
            style: const TextStyle(color: Color(0xFF008000)),
          ),
          const SizedBox(width: 16)
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/wallpaper.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          const GameWidget.controlled(gameFactory: KlondikeGame.new),
        ],
      ),
      bottomNavigationBar: SimpleShadow(
        offset: const Offset(0, -4),
        sigma: 4,
        color: Colors.black,
        opacity: 0.25,
        child: BottomAppBar(
          height: 48,
          color: const Color(0xFF997399),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/move_item.svg',
                semanticsLabel: localizations.moves,
                width: 32,
                height: 32,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '9999',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
              Icon(
                Icons.schedule,
                semanticLabel: localizations.timeTaken,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                '59:59',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
