import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_shadow/simple_shadow.dart';
import '../games/klondike_game.dart';

enum Difficulty { easy, medium, hard }

class KlondikePage extends StatefulWidget {
  const KlondikePage({super.key});

  @override
  State<KlondikePage> createState() => _KlondikePageState();
}

class _KlondikePageState extends State<KlondikePage> {
  var difficulty = Difficulty.easy;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    const difficultyButtonBorderRadius = 4.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Back to home page
          },
        ),
        title: Text(
          'Klondike',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        actions: [
          if (difficulty case Difficulty.easy)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    difficultyButtonBorderRadius,
                  ),
                ),
              ),
              icon: const Icon(Icons.mood),
              label: Text(localizations.easy),
              onPressed: () => setState(() => difficulty = Difficulty.medium),
            )
          else if (difficulty case Difficulty.medium)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE57300),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    difficultyButtonBorderRadius,
                  ),
                ),
              ),
              icon: const Icon(Icons.sentiment_neutral),
              label: Text(localizations.medium),
              onPressed: () => setState(() => difficulty = Difficulty.hard),
            )
          else if (difficulty case Difficulty.hard)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    difficultyButtonBorderRadius,
                  ),
                ),
              ),
              icon: const Icon(Icons.mood_bad),
              label: Text(localizations.hard),
              onPressed: () => setState(() => difficulty = Difficulty.easy),
            ),
          const SizedBox(width: 16),
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
        color: Colors.black,
        opacity: 0.25,
        sigma: 4,
        child: Container(
          color: const Color(0xFF806080),
          height: 48,
          child: Row(
            children: [
              const SizedBox(width: 12),
              SvgPicture.asset(
                'assets/icons/move_item.svg',
                width: 32,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                semanticsLabel: localizations.moves,
              ),
              const SizedBox(width: 8),
              Text(
                '9999',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const Expanded(child: Center()),
              const Icon(Icons.schedule, color: Colors.white, size: 32),
              const SizedBox(width: 8),
              Text(
                '59:59',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
